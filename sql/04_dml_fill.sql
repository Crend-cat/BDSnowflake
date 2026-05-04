-- 1. dim_pet_category
INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT TRIM(pet_category)
FROM mock_data
WHERE pet_category IS NOT NULL AND TRIM(pet_category) != ''
ORDER BY 1;


-- 2. dim_country
INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT NULLIF(TRIM(customer_country), '')  AS country_name FROM mock_data
    UNION
    SELECT NULLIF(TRIM(seller_country), '')    FROM mock_data
    UNION
    SELECT NULLIF(TRIM(store_country), '')     FROM mock_data
    UNION
    SELECT NULLIF(TRIM(supplier_country), '')  FROM mock_data
) t
WHERE country_name IS NOT NULL
ORDER BY 1;


-- 3. dim_product_category
INSERT INTO dim_product_category (category_name, pet_category_id)
SELECT DISTINCT ON (m.product_category)
    TRIM(m.product_category),
    pc.pet_category_id
FROM mock_data m
JOIN dim_pet_category pc ON pc.pet_category_name = TRIM(m.pet_category)
WHERE m.product_category IS NOT NULL AND TRIM(m.product_category) != ''
ORDER BY m.product_category;


-- 4. dim_brand
INSERT INTO dim_brand (brand_name)
SELECT DISTINCT TRIM(product_brand)
FROM mock_data
WHERE product_brand IS NOT NULL AND TRIM(product_brand) != ''
ORDER BY 1;


-- 5. dim_supplier
INSERT INTO dim_supplier (supplier_name, contact, email, phone, address, city, country_id)
SELECT DISTINCT ON (m.supplier_name, m.supplier_city)
    TRIM(m.supplier_name),
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    m.supplier_city,
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = NULLIF(TRIM(m.supplier_country), '')
WHERE m.supplier_name IS NOT NULL AND TRIM(m.supplier_name) != ''
ORDER BY m.supplier_name, m.supplier_city;


-- 6. dim_customer
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country_id, postal_code)
SELECT DISTINCT ON (m.sale_customer_id)
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = NULLIF(TRIM(m.customer_country), '')
WHERE m.sale_customer_id IS NOT NULL
ORDER BY m.sale_customer_id;


-- 7. dim_pet
INSERT INTO dim_pet (customer_id, pet_type, pet_name, pet_breed)
SELECT DISTINCT
    m.sale_customer_id,
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed
FROM mock_data m
WHERE m.sale_customer_id IS NOT NULL
  AND m.customer_pet_type IS NOT NULL
  AND TRIM(m.customer_pet_type) != '';


-- 8. dim_seller
INSERT INTO dim_seller (seller_id, first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT ON (m.sale_seller_id)
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = NULLIF(TRIM(m.seller_country), '')
WHERE m.sale_seller_id IS NOT NULL
ORDER BY m.sale_seller_id;


-- 9. dim_product
INSERT INTO dim_product (
    product_id, product_name, category_id, price, quantity,
    weight, color, size, brand_id, material, description,
    rating, reviews, release_date, expiry_date, supplier_id
)
SELECT DISTINCT ON (m.sale_product_id)
    m.sale_product_id,
    m.product_name,
    pc.category_id,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_color,
    m.product_size,
    b.brand_id,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    CASE WHEN m.product_release_date IS NOT NULL AND TRIM(m.product_release_date) != ''
         THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY') ELSE NULL END,
    CASE WHEN m.product_expiry_date IS NOT NULL AND TRIM(m.product_expiry_date) != ''
         THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY') ELSE NULL END,
    s.supplier_id
FROM mock_data m
LEFT JOIN dim_product_category pc ON pc.category_name = TRIM(m.product_category)
LEFT JOIN dim_brand b ON b.brand_name = TRIM(m.product_brand)
LEFT JOIN dim_supplier s ON s.supplier_name = TRIM(m.supplier_name)
    AND TRIM(LOWER(COALESCE(s.city, ''))) = TRIM(LOWER(COALESCE(m.supplier_city, '')))
WHERE m.sale_product_id IS NOT NULL
ORDER BY m.sale_product_id;


-- 10. dim_store
INSERT INTO dim_store (store_name, location, city, state, country_id, phone, email)
SELECT DISTINCT ON (TRIM(m.store_name), TRIM(m.store_city))
    TRIM(m.store_name),
    m.store_location,
    TRIM(m.store_city),
    m.store_state,
    c.country_id,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = NULLIF(TRIM(m.store_country), '')
WHERE m.store_name IS NOT NULL AND TRIM(m.store_name) != ''
ORDER BY m.store_name, m.store_city;


-- 11. dim_date
INSERT INTO dim_date (full_date, day, month, year, quarter, day_of_week)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    EXTRACT(DAY     FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(MONTH   FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(YEAR    FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(DOW     FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER
FROM mock_data
WHERE sale_date IS NOT NULL AND TRIM(sale_date) != ''
ORDER BY 1;


-- 12. fact_sales
INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, date_id, sale_quantity, sale_total_price)
SELECT
    m.sale_customer_id,
    m.sale_seller_id,
    m.sale_product_id,
    st.store_id,
    d.date_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
LEFT JOIN dim_store st ON TRIM(LOWER(st.store_name)) = TRIM(LOWER(m.store_name))
    AND TRIM(LOWER(COALESCE(st.city, ''))) = TRIM(LOWER(COALESCE(m.store_city, '')))
LEFT JOIN dim_date d ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
WHERE m.sale_customer_id IS NOT NULL
  AND m.sale_seller_id   IS NOT NULL
  AND m.sale_product_id  IS NOT NULL;
