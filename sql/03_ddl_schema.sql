-- Pet categories
CREATE TABLE dim_pet_category (
    pet_category_id   SERIAL PRIMARY KEY,
    pet_category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Shared country dimension
CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- Product categories -> pet_category
CREATE TABLE dim_product_category (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE,
    pet_category_id INTEGER REFERENCES dim_pet_category(pet_category_id)
);

-- Brands
CREATE TABLE dim_brand (
    brand_id   SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

-- Suppliers
CREATE TABLE dim_supplier (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    contact       VARCHAR(200),
    email         VARCHAR(200),
    phone         VARCHAR(50),
    address       VARCHAR(300),
    city          VARCHAR(100),
    country_id    INTEGER REFERENCES dim_country(country_id)
);

--Customers
CREATE TABLE dim_customer (
    customer_id INTEGER PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    age         INTEGER,
    email       VARCHAR(200),
    country_id  INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(20)
);

-- Pets linked to customer
CREATE TABLE dim_pet (
    pet_id      SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    pet_type    VARCHAR(50),
    pet_name    VARCHAR(100),
    pet_breed   VARCHAR(100)
);

-- Sellers
CREATE TABLE dim_seller (
    seller_id   INTEGER PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(200),
    country_id  INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(20)
);

-- Products
CREATE TABLE dim_product (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR(200),
    category_id  INTEGER REFERENCES dim_product_category(category_id),
    price        NUMERIC(10,2),
    quantity     INTEGER,
    weight       NUMERIC(10,2),
    color        VARCHAR(50),
    size         VARCHAR(50),
    brand_id     INTEGER REFERENCES dim_brand(brand_id),
    material     VARCHAR(100),
    description  TEXT,
    rating       NUMERIC(3,1),
    reviews      INTEGER,
    release_date DATE,
    expiry_date  DATE,
    supplier_id  INTEGER REFERENCES dim_supplier(supplier_id)
);

-- Stores
CREATE TABLE dim_store (
    store_id   SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    location   VARCHAR(200),
    city       VARCHAR(100),
    state      VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id),
    phone      VARCHAR(50),
    email      VARCHAR(200)
);

-- Dates
CREATE TABLE dim_date (
    date_id      SERIAL PRIMARY KEY,
    full_date    DATE NOT NULL UNIQUE,
    day          INTEGER,
    month        INTEGER,
    year         INTEGER,
    quarter      INTEGER,
    day_of_week  INTEGER
);

-- Sales
CREATE TABLE fact_sales (
    sale_id          SERIAL PRIMARY KEY,
    customer_id      INTEGER REFERENCES dim_customer(customer_id),
    seller_id        INTEGER REFERENCES dim_seller(seller_id),
    product_id       INTEGER REFERENCES dim_product(product_id),
    store_id         INTEGER REFERENCES dim_store(store_id),
    date_id          INTEGER REFERENCES dim_date(date_id),
    sale_quantity    INTEGER,
    sale_total_price NUMERIC(10,2)
);
