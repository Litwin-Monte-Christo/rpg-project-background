DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS monsters;
DROP TABLE IF EXISTS characters;
DROP TABLE IF EXISTS monster_catalog;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS locations;

CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    boosted_element_1 VARCHAR(50),
    boosted_element_2 VARCHAR(50)
);

CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(100) NOT NULL,
    physical_power INT DEFAULT 0,
    magical_power INT DEFAULT 0,
    physical_penetration INT DEFAULT 0,
    magical_penetration INT DEFAULT 0,
    physical_penetration_perc DECIMAL(3,2) DEFAULT 0,
    magical_penetration_perc DECIMAL(3,2) DEFAULT 0,
    max_hp_add INT DEFAULT 0,
    heal_value INT DEFAULT 0,
    life_steal INT DEFAULT 0,
    description TEXT
);

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

CREATE TABLE monster_catalog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    base_hp INT DEFAULT 0,
    base_pp INT DEFAULT 0,
    base_mp INT DEFAULT 0,
    pp_perc_add DECIMAL(3,2) DEFAULT 0,
    mp_perc_add DECIMAL(3,2) DEFAULT 0,
    element VARCHAR(50) NOT NULL
);

CREATE TABLE monsters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    character_id INT NOT NULL,
    species_id INT NOT NULL,
    level INT DEFAULT 1,
    current_hp INT DEFAULT 50,
    
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES monster_catalog(id)
);

CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    character_id INT NULL,
    monster_id INT NULL,
    quantity INT DEFAULT 1,
    slot_number INT NOT NULL,

    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (monster_id) REFERENCES monsters(id) ON DELETE CASCADE,

    CONSTRAINT chk_owner CHECK (
        (character_id IS NOT NULL AND monster_id IS NULL) OR 
        (character_id IS NULL AND monster_id IS NOT NULL)
    ),

    CONSTRAINT chk_slot_limits CHECK (
        (character_id IS NOT NULL AND slot_number BETWEEN 1 AND 50) OR
        (monster_id IS NOT NULL AND slot_number BETWEEN 1 AND 5)
    ),

    CONSTRAINT uq_character_slot UNIQUE (character_id, slot_number),
    CONSTRAINT uq_monster_slot UNIQUE (monster_id, slot_number)
);