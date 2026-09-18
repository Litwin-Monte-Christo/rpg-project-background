# API Gra RPG - Cudaki (Backend)

Prosty i wydajny backend gry RPG napisany w języku Python przy użyciu frameworka **FastAPI** oraz bazy danych **MySQL**. Aplikacja obsługuje logikę tworzenia postaci, łapania stworków (Cudaków) oraz zarządzania ekwipunkiem. 

Komunikacja z serwerem odbywa się wyłącznie za pomocą zapytań HTTP oraz danych w formacie **JSON**

---

## Opis Modelu Bazy Danych

Baza relacyjna `rpg_game` składa się z następujących tabel:

* **`locations`** – Słownik lokacji w świecie gry.
* **`items`** – Katalog dostępnych przedmiotów (mikstury, przedmioty fabularne).
* **`monster_catalog`** – Katalog bazowych gatunków stworków (statystyki HP, atak fizyczny, atak magiczny).
* **`characters`** – Postacie graczy (poziom, pozycja na mapie X/Y, aktualna lokacja).
* **`monsters`** – Złapane stworki przypisane do konkretnego gracza (z własnymi statystykami i aktualnym HP).
* **`inventory`** – Ekwipunek obsługujący mechanikę slotów. Używa relacji z kolumnami `owner_type` (`CHARACTER` / `MONSTER`) oraz `owner_id`, co zapobiega powstawaniu wartości `NULL`.

---

## Instrukcja Uruchomienia

### 1. Przygotowanie Bazy Danych (XAMPP)
1. Uruchom **XAMPP Control Panel** i włącz moduł **MySQL** (przycisk *Start*).
2. Otwórz panel **phpMyAdmin** (`http://localhost/phpmyadmin`).
3. Stwórz nową bazę danych o nazwie **`rpg_game`**.
4. Importuj strukturę bazy z pliku `schema.sql`.

### 2. Instalacja Wymaganych Bibliotek
Otwórz terminal w folderze projektu i zainstaluj zależności:

```bash
pip install fastapi uvicorn pymysql pydantic
```

### 3. Uruchomienie Serwera Aplikacji
Uruchom serwer Uvicorn za pomocą polecenia:

```bash
python -m uvicorn main:app --reload
```
(Po poprawnym uruchomieniu serwer zacznie nasłuchiwać pod adresem: http://127.0.0.1:8000)
(Panel do zarządzania api znajduje się pod adresem `http://127.0.0.1:8000/docs`)

---

## Przykładowe Wywołania API
### 1. Pobranie listy postaci (`GET`)
Pobiera wszystkie zarejestrowane postacie graczy.

```bash
curl -X GET "[http://127.0.0.1:8000/characters](http://127.0.0.1:8000/characters)"
```

### 2. Tworzenie nowej postaci (`POST`)
Tworzy nową postać w bazie danych.

```bash
curl -X POST "[http://127.0.0.1:8000/characters](http://127.0.0.1:8000/characters)" \
     -H "Content-Type: application/json" \
     -d '{
           "name": "Geralt",
           "level": 1,
           "position_x": 0,
           "position_y": 0,
           "location_id": 1
         }'
```
### 3. Złapanie Cudaka (`POST`)
Przypisuje stworka z katalogu do konkretnego gracza.

```bash
curl -X POST "[http://127.0.0.1:8000/monsters/catch](http://127.0.0.1:8000/monsters/catch)" \
     -H "Content-Type: application/json" \
     -d '{
           "character_id": 1,
           "species_id": 1
         }'
```
### 4. Dodanie przedmiotu do ekwipunku (`POST`)
Umieszcza przedmiot w wskazanym slocie ekwipunku postaci lub stworka.

```bash
curl -X POST "[http://127.0.0.1:8000/inventory](http://127.0.0.1:8000/inventory)" \
     -H "Content-Type: application/json" \
     -d '{
           "item_id": 1,
           "owner_type": "CHARACTER",
           "owner_id": 1,
           "slot_number": 1,
           "quantity": 3
         }'
```

### 5. Użycie przedmiotu (`POST`)
Zużywa przedmiot z ekwipunku (np. miksturę leczącą) i aplikuje jego efekt na wybranym stworku.

```bash
curl -X POST "[http://127.0.0.1:8000/inventory/use](http://127.0.0.1:8000/inventory/use)" \
     -H "Content-Type: application/json" \
     -d '{
           "inventory_id": 1,
           "monster_id": 1
         }'
```