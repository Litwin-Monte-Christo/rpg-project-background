# Dokumentacja modelu dziedziny i schematu relacyjnego

## 1. Opracowanie Modelu Dziedziny

### 1. Identyfikacja Głównych Encji

- Gracz/Postać(Character): Reprezentuje gracza na mapie (ma poziom, pozycje i lokalizacje w której się znajduje);
- Cudak(Monster): Reprezentuje konkretnego stworka Istniejącego w świecie gry;
- Gatunek Cudaka(MonsterSpecies): Reprezentuje szablon stworka, jego podstawowe statystyki, żywioł itp.;
- Przedmiot(Item): Przedmiot konsumbcyjny lub fizyczny z możliwością złożenia go na cudaka;
- Lokacja(Location): Miejsce w świecie gry gdzie porusza się gracz, może wzmacniać poszczególne żywioły;
- Ekwipunek/Slot(Inventory): Reprezentuje konkretne miejsce w torbie gracza/cudaka.

---

### 2. Opis Relacji

- Gracz przebywa w jednej Lokacji (1 do wielu);
- Gracz posiada od 0 do wielu Cudaków (1 do wielu);
- Cudak bazuje na jednym Gatunku Cudaka z katalogu;
- Ekwipunek należy albo do Gracza (max 50 slotów + 5 slotów na ekwipunek zbrojeniowy), albo do Cudaka (max 5 slotów + 5 slotów na ekwipunek zbrojeniowy);
- Każdy Slot Ekwipunku mieści jeden konkretny Przedmiot;

---

## 2.Opracowanie Schematu Relacyjnego

### 1. Zapis Notacji Relacyjnej

##### 1. Kwestia Katalogowa (Dane Stałe)

locations (id **[PK]**, name, description, boosted_element_1, boosted_element_2)

items (id **[PK]**, name, type, physical_power, magical_power, physical_penetration, magical_penetration, physical_penetration_perc, magical_penetration_perc, physical_armor, magical_armor, hp, life_steal_perc, dodge_chance, heal_value, all_dmg_up, all_max_hp_up, description)

monster_catalog (id **[PK]**, name, element_1, element_2, physical_power, magical_power, physical_penetration, magical_penetration, physical_penetration_perc, magical_penetration_perc, physical_armor, magical_armor, hp, life_steal_perc, dodge_chance)

##### 2. Kwestia Instancji (Dane Zmienne / Gracz)

characters (id **[PK]**, name, level, position_x, position_y, location_id **[FK -> locations.id]**, created_at)

monsters (id **[PK]**, character_id **[FK -> characters.id]**, species_id **[FK -> monster_catalog.id]**, level, current_hp, physical_power, magical_power, physical_penetration, magical_penetration, physical_penetration_perc, magical_penetration_perc, physical_armor, magical_armor, hp, life_steal_perc, dodge_chance, all_dmg_up, all_max_hp_up)

inventory (id **[PK]**, item_id **[FK -> items.id]**, character_id **[FK -> characters.id, NULL]**, monster_id **[FK -> monsters.id, NULL]**, quantity, slot_number)

---

### 2. Diagram Bazy Danych
Dołączony plik png.