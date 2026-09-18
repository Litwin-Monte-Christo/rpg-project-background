DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS monsters;
DROP TABLE IF EXISTS characters;
DROP TABLE IF EXISTS monster_catalog;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS locations;


-- 1. KWESTIA KATALOGOWA (SUCHE INFORMACJE STAŁE)

-- Tabela dostępnych lokacji w świecie gry
CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    boosted_element_1 VARCHAR(50),
    boosted_element_2 VARCHAR(50)
);

-- Tabela przedmiotów i ich statystyk
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(100) NOT NULL,
    physical_power INT DEFAULT 0,
    magical_power INT DEFAULT 0,
    physical_penetration INT DEFAULT 0,
    magical_penetration INT DEFAULT 0,
    physical_penetration_perc DECIMAL(3,2) DEFAULT 0,   -- procentowe przebicie pancerza fizycznego
    magical_penetration_perc DECIMAL(3,2) DEFAULT 0,    -- procentowe przebicie pancerza magicznego
    physical_armor INT DEFAULT 0,
    magical_armor INT DEFAULT 0,
    hp INT DEFAULT 0,
    life_steal_perc DECIMAL(3,2) DEFAULT 0, -- procentowa kradzież życia zależna od zadanych obrażeń
    dodge_chance DECIMAL(3,2) DEFAULT 0,
    heal_value INT DEFAULT 0,   -- leczenie dla mikstury
    all_dmg_up DECIMAL(3,2) DEFAULT 0,  -- procentowe dodane obrażenia jeśli to mikstura
    all_max_hp_up DECIMAL(3,2) DEFAULT 0,   -- procentowe dodane życie jeśli to mikstura
    description TEXT
);

-- Tabela z gatunkami cudaków i ich bazowymi statystykami
CREATE TABLE monster_catalog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    element_1 VARCHAR(50) NOT NULL,
    element_2 VARCHAR(50) NOT NULL,
    physical_power INT DEFAULT 0,
    magical_power INT DEFAULT 0,
    physical_penetration INT DEFAULT 0,
    magical_penetration INT DEFAULT 0,
    physical_penetration_perc DECIMAL(3,2) DEFAULT 0,   -- procentowe przebicie pancerza fizycznego
    magical_penetration_perc DECIMAL(3,2) DEFAULT 0,    -- procentowe przebicie pancerza magicznego
    physical_armor INT DEFAULT 0,
    magical_armor INT DEFAULT 0,
    hp INT DEFAULT 0,
    life_steal_perc DECIMAL(3,2) DEFAULT 0, -- procentowa kradzież życia zależna od zadanych obrażeń
    dodge_chance DECIMAL(3,2) DEFAULT 0
);


-- 2. KWESTIA INSTANCJI (SPRAWY RUCHOME)

-- Tabela graczy (7 kolumn)
CREATE TABLE characters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    level INT DEFAULT 1,
    position_x INT DEFAULT 0,
    position_y INT DEFAULT 0,
    location_id INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Tabela dla konkretnych cudaków należących do gracza
CREATE TABLE monsters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    character_id INT,
    species_id INT NOT NULL,
    level INT DEFAULT 1,
    current_hp INT DEFAULT 0,   -- aktualne zdrowie cudaka
    hp INT DEFAULT 0,   -- maksymalne zdrowie cudaka
    physical_power INT DEFAULT 0,
    magical_power INT DEFAULT 0,
    physical_penetration INT DEFAULT 0,
    magical_penetration INT DEFAULT 0,
    physical_penetration_perc DECIMAL(3,2) DEFAULT 0,   -- procentowe przebicie pancerza fizycznego
    magical_penetration_perc DECIMAL(3,2) DEFAULT 0,    -- procentowe przebicie pancerza magicznego
    physical_armor INT DEFAULT 0,
    magical_armor INT DEFAULT 0,
    life_steal_perc DECIMAL(3,2) DEFAULT 0, -- procentowa kradzież życia zależna od zadanych obrażeń
    dodge_chance DECIMAL(3,2) DEFAULT 0,
    all_dmg_up DECIMAL(3,2) DEFAULT 0,  -- procentowe dodane obrażenia (np. z efektu mikstury)
    all_max_hp_up DECIMAL(3,2) DEFAULT 0,   -- procentowe dodane życie (np. z efektu mikstury)
    
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES monster_catalog(id)
);

-- Tabela z ekwipunkiem gracza lub cudaka
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    owner_type ENUM('CHARACTER', 'MONSTER') NOT NULL, -- Określa rodzaj właściciela
    owner_id INT NOT NULL,                            -- ID postaci lub cudaka
    quantity INT DEFAULT 1,
    slot_number INT NOT NULL,

    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,

    -- Zapobiega zdublowaniu tego samego slotu u tego samego właściciela
    CONSTRAINT uq_owner_slot UNIQUE (owner_type, owner_id, slot_number)
);


-- 3. WYPEŁNIANIE DANYCH TESTOWYCH

-- Lokacje
INSERT INTO locations (
    id, name, description, boosted_element_1, boosted_element_2
) VALUES 
(1, 'Wioska Ducha Lasu', 'Spokojna wioska początkowa dla świerzaków.', NULL, NULL),
(2, 'Ognisty Las', 'Wiecznie płonące drzewa dają siłe do walki typowi Ogniowemu i Roślinnemu', 'Fire', 'Grass'),
(3, 'Lodowa Otchłań', 'Zimno lodu w połączone z zimnem mrocznej otchłani', 'Ice', 'Dark');

-- Przedmioty
INSERT INTO items (
    id, name, type, physical_power, magical_power, 
    physical_penetration, magical_penetration, physical_penetration_perc, magical_penetration_perc, 
    physical_armor, magical_armor, hp, life_steal_perc, 
    dodge_chance, heal_value, all_dmg_up, all_max_hp_up, description
) VALUES 
(1, 'Pół Kija', 'Weapon-Mele-Phy', 15, 0, 2, 0, 0.00, 0.00, 0, 0, 0, 0.00, 0.00, 0, 0.00, 0.00, 'Pół Kija nadal ma dwa końce.'),
(2, 'Amelinowa Różdżka', 'Weapon-Range-Mag', 0, 25, 0, 5, 0.00, 0.10, 0, 0, 0, 0.00, 0.00, 0, 0.00, 0.00, 'Tego nie pomalujesz ale może coś ubijesz'),
(3, 'Mała Mikstura Leczenia', 'Consumable', 0, 0, 0, 0, 0.00, 0.00, 0, 0, 0, 0.00, 0.00, 30, 0.00, 0.00, 'Odnawia 30 punktów życia cudaka.'),
(4, 'Pierścień Witalności', 'Accessory', 0, 0, 0, 0, 0.00, 0.00, 0, 0, 50, 0.05, 0.00, 0, 0.00, 0.00, 'Daje dodatkowe zdrowie i kradzież życia.');

-- Katalog cudaków
INSERT INTO monster_catalog (
    id, name, element_1, element_2, physical_power, magical_power, 
    physical_penetration, magical_penetration, physical_penetration_perc, magical_penetration_perc, 
    physical_armor, magical_armor, hp, life_steal_perc, dodge_chance
) VALUES 
(1, 'Kot Schrödingera', 'Psychic', 'Fighting', 0, 25, 0, 0, 0.00, 0.15, 0, 0, 50, 0.00, 0.50),
(2, 'Smog Krakowski', 'Dark', 'Dragon', 15, 15, 0, 0, 0.20, 0.20, 0, 0, 80, 0.00, 0.15),
(3, 'Śnieżka', 'Rock', 'Ice', 30, 10, 0, 0, 0.10, 0.00, 0, 0, 100, 0.00, 0.00);

-- Gracze
INSERT INTO characters (
    id, name, level, position_x, position_y, location_id, created_at
) VALUES 
(1, 'Makumba', 1, 0, 0, 1, NOW()),
(2, 'Hymel Jadwiga', 1, 0, 0, 1, NOW());

-- Cudaki graczy
INSERT INTO monsters (
    id, character_id, species_id, level, current_hp, 
    physical_power, magical_power, physical_penetration, magical_penetration, 
    physical_penetration_perc, magical_penetration_perc, physical_armor, magical_armor, 
    hp, life_steal_perc, dodge_chance, all_dmg_up, all_max_hp_up
) VALUES 
(1, 1, 1, 5, 50, 0, 25, 0, 0, 0.00, 0.15, 0, 0, 0, 0.00, 0.50, 0.00, 0.00), -- Kot Schrödingera
(2, 1, 2, 3, 80, 15, 15, 0, 0, 0.20, 0.20, 0, 0, 0, 0.00, 0.15, 0.00, 0.00), -- Smog Krakowski
(3, 2, 3, 1, 100, 30, 10, 0, 0, 0.10, 0.00, 0, 0, 0, 0.00, 0.00, 0.00, 0.00); -- Śnieżka

-- Ekwipunek / Inventory
INSERT INTO inventory (id, item_id, owner_type, owner_id, quantity, slot_number) VALUES 
(1, 3, 'CHARACTER', 1, 5, 1), -- 5x Mikstura u gracza ID 1 (slot 1)
(2, 1, 'CHARACTER', 1, 1, 2), -- Pół Kija u gracza ID 1 (slot 2)
(3, 2, 'MONSTER', 1, 1, 1),   -- Amelinowa Różdżka u cudaka ID 1 (slot 1)
(4, 4, 'MONSTER', 3, 1, 1);   -- Pierścień Witalności u cudaka ID 3 (slot 1)