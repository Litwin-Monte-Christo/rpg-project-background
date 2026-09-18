from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
import pymysql
from typing import Literal, Optional

app = FastAPI(
    title="API Gra RPG - Cudaki",
    description="API do obsługi postaci, cudaków oraz ekwipunku",
    version="1.0.0"
)

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",         
    "database": "rpg_game",  
    "cursorclass": pymysql.cursors.DictCursor
}

def get_db():
    try:
        return pymysql.connect(**DB_CONFIG)
    except pymysql.Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Błąd połączenia z bazą danych: {str(e)}"
        )

class CharacterCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=50, example="Makumba")
    level: int = Field(default=1, ge=1)
    position_x: int = Field(default=0)
    position_y: int = Field(default=0)
    location_id: int = Field(default=1)

class CatchMonsterRequest(BaseModel):
    character_id: int
    species_id: int

class AddItemRequest(BaseModel):
    item_id: int
    owner_type: Literal['CHARACTER', 'MONSTER']
    owner_id: int
    slot_number: int = Field(..., ge=1)
    quantity: int = Field(default=1, ge=1)

class UseItemRequest(BaseModel):
    inventory_id: int
    monster_id: int



@app.get("/", tags=["Status"])
def root():
    return {"status": "OK", "message": "działa"}


#1.POSTACIE GRACZY

@app.get("/characters", tags=["Postacie"])
def get_all_characters():
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM characters")
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/characters", tags=["Postacie"], status_code=status.HTTP_201_CREATED)
def create_character(data: CharacterCreate):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            sql = """
                INSERT INTO characters (name, level, position_x, position_y, location_id)
                VALUES (%s, %s, %s, %s, %s)
            """
            cur.execute(sql, (data.name, data.level, data.position_x, data.position_y, data.location_id))
            conn.commit()
            return {"message": "Stworzono postać", "id": cur.lastrowid}
    except pymysql.Error as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Błąd podczas tworzenia postaci: {str(e)}")
    finally:
        conn.close()


#2.CUDAKI GRACZA

@app.get("/characters/{character_id}/monsters", tags=["Cudaki"])
def get_player_monsters(character_id: int):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            sql = """
                SELECT m.id, mc.name AS gatunek, m.level, m.current_hp, m.hp AS max_hp,
                       m.physical_power, m.magical_power
                FROM monsters m
                JOIN monster_catalog mc ON m.species_id = mc.id
                WHERE m.character_id = %s
            """
            cur.execute(sql, (character_id,))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/monsters/catch", tags=["Cudaki"], status_code=status.HTTP_201_CREATED)
def catch_monster(data: CatchMonsterRequest):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT hp, physical_power, magical_power FROM monster_catalog WHERE id = %s", (data.species_id,))
            base = cur.fetchone()
            if not base:
                raise HTTPException(status_code=404, detail="Gatunek o podanym ID nie istnieje w katalogu")

            sql = """
                INSERT INTO monsters (character_id, species_id, level, current_hp, hp, physical_power, magical_power)
                VALUES (%s, %s, 1, %s, %s, %s, %s)
            """
            cur.execute(sql, (data.character_id, data.species_id, base["hp"], base["hp"], base["physical_power"], base["magical_power"]))
            conn.commit()
            return {"message": "Złapano cudaka!", "id": cur.lastrowid}
    except pymysql.Error as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Błąd bazy danych: {str(e)}")
    finally:
        conn.close()

@app.put("/monsters/{monster_id}/heal", tags=["Cudaki"])
def heal_monster(monster_id: int, heal_val: int = 50):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE monsters SET current_hp = LEAST(current_hp + %s, hp) WHERE id = %s", (heal_val, monster_id))
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Nie znaleziono stworka o tym ID")
            conn.commit()
            return {"message": f"Uleczono cudaka o {heal_val} HP"}
    finally:
        conn.close()


#3. EKWIPUNEK

@app.get("/inventory/{owner_type}/{owner_id}", tags=["Ekwipunek"])
def get_inventory(owner_type: Literal['CHARACTER', 'MONSTER'], owner_id: int):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            sql = """
                SELECT inv.id AS inventory_id, inv.slot_number, i.name AS przedmiot, 
                       i.type, inv.quantity, i.heal_value, i.description
                FROM inventory inv
                JOIN items i ON inv.item_id = i.id
                WHERE inv.owner_type = %s AND inv.owner_id = %s
                ORDER BY inv.slot_number ASC
            """
            cur.execute(sql, (owner_type, owner_id))
            return cur.fetchall()
    finally:
        conn.close()

@app.post("/inventory", tags=["Ekwipunek"], status_code=status.HTTP_201_CREATED)
def add_item_to_inventory(data: AddItemRequest):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            sql = """
                INSERT INTO inventory (item_id, owner_type, owner_id, slot_number, quantity)
                VALUES (%s, %s, %s, %s, %s)
            """
            cur.execute(sql, (data.item_id, data.owner_type, data.owner_id, data.slot_number, data.quantity))
            conn.commit()
            return {"message": "Dodano przedmiot do ekwipunku", "id": cur.lastrowid}
    except pymysql.IntegrityError:
        conn.rollback()
        raise HTTPException(
            status_code=400, 
            detail=f"Slot numer {data.slot_number} u właściciela {data.owner_type} ({data.owner_id}) jest już zajęty!"
        )
    except pymysql.Error as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Błąd bazy danych: {str(e)}")
    finally:
        conn.close()

@app.post("/inventory/use", tags=["Ekwipunek"])
def use_item(data: UseItemRequest):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            # 1.Pobieramy informacje o przedmiocie z ekwipunku
            sql = """
                SELECT inv.id, inv.quantity, i.heal_value, i.type 
                FROM inventory inv
                JOIN items i ON inv.item_id = i.id
                WHERE inv.id = %s
            """
            cur.execute(sql, (data.inventory_id,))
            item_data = cur.fetchone()

            if not item_data:
                raise HTTPException(status_code=404, detail="Nie znaleziono takiego przedmiotu w ekwipunku")

            # 2. Jeśli przedmiot leczy, przywracamy HP stworkowi
            if item_data["heal_value"] > 0:
                cur.execute(
                    "UPDATE monsters SET current_hp = LEAST(current_hp + %s, hp) WHERE id = %s", 
                    (item_data["heal_value"], data.monster_id)
                )

            # 3.Zmniejszamy ilość przedmiotu lub go usuwamy gdy ilość == 1
            if item_data["quantity"] > 1:
                cur.execute("UPDATE inventory SET quantity = quantity - 1 WHERE id = %s", (data.inventory_id,))
            else:
                cur.execute("DELETE FROM inventory WHERE id = %s", (data.inventory_id,))

            conn.commit()
            return {"message": "Użyto przedmiotu pomyślnie"}
    except pymysql.Error as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Błąd podczas używania przedmiotu: {str(e)}")
    finally:
        conn.close()

@app.delete("/inventory/{inventory_id}", tags=["Ekwipunek"])
def delete_item_from_inventory(inventory_id: int):
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM inventory WHERE id = %s", (inventory_id,))
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Przedmiot o tym ID nie istnieje w ekwipunku")
            conn.commit()
            return {"message": "Usunięto przedmiot z ekwipunku"}
    finally:
        conn.close()