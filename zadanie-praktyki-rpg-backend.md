# Zadanie praktyk zawodowych  
## Projekt i implementacja backendu oraz modelu danych dla gry typu RPG

**Praktykant:** Oskar  
**Termin realizacji:** do 21 września 2026 r.  
**Tryb pracy:** indywidualny  
**Wymagany zakres techniczny:** relacyjna baza danych, interfejs API, konteneryzacja (Docker Compose)  
**Poza zakresem:** warstwa prezentacji (frontend), silnik gry, grafika, integracja z istniejącymi tytułami komercyjnymi

---

### 1. Cel zadania

Celem praktyk jest samodzielne **zaprojektowanie oraz uruchomienie warstwy serwerowej** odwzorowującej stan świata gry typu RPG.

Aplikacja kliencka gry nie stanowi przedmiotu prac. Przedmiotem prac jest komponent odpowiedzialny za trwałe przechowywanie stanu oraz udostępnianie operacji umożliwiających jego odczyt i zmianę. Praktykant projektuje model dziedziny, schemat bazy oraz kontrakt API, a następnie implementuje i uruchamia to rozwiązanie w środowisku kontenerowym.

---

### 2. Zakres merytoryczny — do samodzielnego zaprojektowania

Strukturę rozwiązania określa praktykant. Nie obowiązuje narzucony wykaz tabel ani zamknięty zestaw zasobów API.

W ramach projektu należy samodzielnie rozstrzygnąć w szczególności:

- jakie byty dziedziny RPG podlegają modelowaniu (postać, przedmiot, lokacja oraz ewentualnie inne, o ile są uzasadnione);
- w jaki sposób byty odwzorować w schemacie relacyjnym i jakie występują między nimi powiązania;
- rozróżnienie katalogu (definicja bytu) od instancji (wystąpienie przypisane do konkretnego stanu gry);
- które operacje muszą być dostępne po stronie API (utworzenie, odczyt, zmiana stanu);
- które wartości są przechowywane trwale, a które mogą być wyliczane;
- konwencję nazewnictwa zasobów API oraz kształt danych wejściowych i wyjściowych.

Oczekiwany jest model **zwarty i spójny**. Preferowane jest ograniczone, poprawnie zrelacjonowane zestawienie tabel względem rozbudowanego schematu bez uzasadnienia.

---

### 3. Wymagania ramowe (obowiązkowe)

1. Baza danych: relacyjna, MySQL.  
2. Warstwa API: Python (FastAPI lub Flask — wybór praktykanta).  
3. Uruchomienie: Docker Compose; minimum dwa serwisy — baza oraz API.  
4. API nie zwraca warstwy widoku (HTML/CSS). Komunikacja odbywa się przez żądania HTTP i reprezentację danych (JSON).  
5. Poza zakresem pozostają m.in.: system walki tura po turze, czat, uwierzytelnianie użytkowników końcowych, płatności, mapa trójwymiarowa, integracja z klientami gier zewnętrznych.  
6. Charakter dziedziny pozostaje RPG (stan postaci, ekwipunek, przestrzeń gry). Nie dopuszcza się sprowadzenia tematu do statystyk meczów.

---

### 4. Produkty podlegające ocenie

| Lp. | Produkt | Opis |
| ---: | --- | --- |
| 1 | Dokumentacja modelu | Krótki opis decyzji projektowych: byty, tabele, relacje, operacje API. |
| 2 | `schema.sql` | Definicja schematu oraz dane początkowe umożliwiające weryfikację modelu. |
| 3 | Implementacja API | Endpointy zgodne z modelem opracowanym przez praktykanta. |
| 4 | Konfiguracja Docker Compose | Uruchomienie bazy i API poleceniem `docker compose up`. |
| 5 | `README` | Instrukcja uruchomienia, opis modelu, przykładowe wywołania API. |
| 6 | Repozytorium Git | Publiczny lub udostępniony nauczycielowi projekt z historią commitów. |

---

### 5. Wymagana kolejność prac

1. Opracowanie modelu dziedziny i schematu relacyjnego.  
2. Przygotowanie skryptu SQL oraz danych startowych.  
3. Implementacja API.  
4. Konteneryzacja i weryfikacja uruchomienia.  

Implementacja warstwy aplikacyjnej przed zamknięciem modelu danych jest nieuzasadniona.  
**Checkpoint pośredni:** przedstawienie schematu oraz danych startowych — przed rozpoczęciem kodu API.

---

### 6. Kryteria oceny

Ocena obejmuje:

- poprawność i spójność modelu danych względem dziedziny RPG;
- jakość relacji w schemacie (klucze, normalizacja w zakresie adekwatnym do zadania; unikanie przechowywania kolekcji w pojedynczej komórce bez uzasadnienia);
- zgodność API z przyjętym projektem oraz faktyczne utrwalanie stanu w bazie;
- poprawność uruchomienia środowiska Docker Compose na stanowisku praktykanta;
- kompletność `README` umożliwiającą odtworzenie rozwiązania przez osobę trzecią.

Liczba endpointów nie stanowi kryterium samodzielnego. Istotna jest spójność projektu i możliwość jego uruchomienia.

---

### 7. Rozszerzenia

Dopuszcza się ograniczone rozszerzenie modelu (np. zużycie przedmiotu, atrybut waluty, lokacja startowa), pod warunkiem że nie zagraża terminowi oraz nie przesuwa środka ciężkości poza bazę danych i API.

W razie wątpliwości obowiązuje zasada: **najpierw domknięcie rdzenia, potem ewentualne rozszerzenie**.

---

### 8. Forma kontaktu i przekazania pracy

Repozytorium GitHub oraz krótki opis decyzji projektowych przekazywane są nauczycielowi w terminie praktyk.  
Pytania dotyczące interpretacji polecenia należy zgłaszać przed rozpoczęciem implementacji API.

---

*Dokument stanowi polecenie zadaniowe. Ostateczny kształt schematu bazy oraz kontraktu API opracowuje praktykant.*
