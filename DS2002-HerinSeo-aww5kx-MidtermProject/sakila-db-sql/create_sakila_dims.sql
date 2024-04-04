-- using the sakila database provided by running sakila-schema first, then sakila-data
USE sakila;

-- creating and inserting data into actor dimension table (includes a key and a column addressing the actors full name)
CREATE TABLE IF NOT EXISTS dim_actor (
  actor_key INT NOT NULL AUTO_INCREMENT,
  actor_id SMALLINT UNSIGNED NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL,
  actor_full_name VARCHAR(100) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) STORED,
  PRIMARY KEY (actor_key),
  UNIQUE KEY (actor_id)
);
INSERT INTO dim_actor (actor_id, first_name, last_name, last_update)
SELECT a.actor_id, a.first_name, a.last_name, a.last_update
FROM actor a
LEFT JOIN dim_actor da ON a.actor_id = da.actor_id
WHERE da.actor_id IS NULL;

-- creating and inserting data into category dimension table (includes a key)
CREATE TABLE IF NOT EXISTS dim_category (
  category_key INT NOT NULL AUTO_INCREMENT,
  category_id TINYINT UNSIGNED NOT NULL,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY (category_key),
  UNIQUE KEY (category_id)
);
INSERT INTO dim_category (category_id, name, last_update)
SELECT c.category_id, c.name, c.last_update
FROM category c
LEFT JOIN dim_category dc ON c.category_id = dc.category_id
WHERE dc.category_id IS NULL;

-- creating and inserting data into customer dimension table (includes a key)
CREATE TABLE IF NOT EXISTS dim_customer (
  customer_key INT NOT NULL AUTO_INCREMENT,
  customer_id SMALLINT UNSIGNED NOT NULL,
  store_id TINYINT UNSIGNED NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_key),
  UNIQUE KEY (customer_id)
);
INSERT INTO dim_customer (customer_id, store_id, first_name, last_name, email, address_id, active, create_date, last_update)
SELECT c.customer_id, c.store_id, c.first_name, c.last_name, c.email, c.address_id, c.active, c.create_date, c.last_update
FROM customer c
LEFT JOIN dim_customer dc ON c.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

-- creating and inserting data into film dimension table (includes a key)
CREATE TABLE IF NOT EXISTS dim_film (
  film_key INT NOT NULL AUTO_INCREMENT,
  film_id SMALLINT UNSIGNED NOT NULL,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEAR DEFAULT NULL,
  language_id TINYINT UNSIGNED NOT NULL,
  original_language_id TINYINT UNSIGNED DEFAULT NULL,
  rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT UNSIGNED DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  special_features SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY (film_key),
  UNIQUE KEY (film_id)
);
INSERT INTO dim_film (film_id, title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update)
SELECT f.film_id, f.title, f.description, f.release_year, f.language_id, f.original_language_id, f.rental_duration, f.rental_rate, f.length, f.replacement_cost, f.rating, f.special_features, f.last_update
FROM film f
LEFT JOIN dim_film df ON f.film_id = df.film_id
WHERE df.film_id IS NULL;

-- creating and inserting data into store dimension table (includes a key)
CREATE TABLE IF NOT EXISTS dim_store (
  store_key INT NOT NULL AUTO_INCREMENT,
  store_id TINYINT UNSIGNED NOT NULL,
  manager_staff_id TINYINT UNSIGNED NOT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY (store_key),
  UNIQUE KEY (store_id)
);
INSERT INTO dim_store (store_id, manager_staff_id, address_id, last_update)
SELECT s.store_id, s.manager_staff_id, s.address_id, s.last_update
FROM store s
LEFT JOIN dim_store ds ON s.store_id = ds.store_id
WHERE ds.store_id IS NULL;


-- create and inserting data into fact table on rental payment which analyzes customer actions in paying, receiving, returning, etc. for rental movies
CREATE TABLE IF NOT EXISTS fact_rental_payment (
  rental_id INT NOT NULL,
  payment_id SMALLINT UNSIGNED NOT NULL,
  customer_id SMALLINT UNSIGNED NOT NULL,
  staff_id TINYINT UNSIGNED NOT NULL,
  inventory_id MEDIUMINT UNSIGNED NOT NULL,
  amount DECIMAL(5,2) NOT NULL,
  rental_date DATETIME NOT NULL,
  return_date DATETIME DEFAULT NULL,
  PRIMARY KEY (rental_id),
  FOREIGN KEY (payment_id) REFERENCES payment(payment_id),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
  FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
  FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
);
INSERT INTO fact_rental_payment (rental_id, payment_id, customer_id, staff_id, inventory_id, amount, rental_date, return_date)
SELECT r.rental_id, p.payment_id, r.customer_id, r.staff_id, r.inventory_id, p.amount, r.rental_date, r.return_date
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
LEFT JOIN fact_rental_payment frp ON r.rental_id = frp.rental_id
WHERE frp.rental_id IS NULL;



