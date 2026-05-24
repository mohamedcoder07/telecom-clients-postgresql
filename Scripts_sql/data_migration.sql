-- 1. Remplissage de la table principale : CUSTOMERS
INSERT INTO customers (customer_id, gender, age, married, number_of_dependents)
SELECT DISTINCT customer_id, gender, age, married, number_of_dependents
FROM raw_import;

-- 2. Remplissage de la table : LOCATIONS
INSERT INTO locations (customer_id, city, zip_code, latitude, longitude)
SELECT customer_id, city, zip_code, latitude, longitude
FROM raw_import;

-- 3. Remplissage de la table : SUBSCRIPTIONS
INSERT INTO subscriptions (
    customer_id, tenure_months, contract, offer, 
    internet_service, internet_type, phone_service, 
    multiple_lines, unlimited_data
)
SELECT 
    customer_id, tenure_months, contract, offer, 
    internet_service, internet_type, phone_service, 
    multiple_lines, unlimited_data
FROM raw_import;

-- 4. Remplissage de la table : SERVICE_FEATURES
INSERT INTO service_features (
    customer_id, online_security, online_backup, 
    device_protection_plan, premium_tech_support, 
    streaming_tv, streaming_movies, streaming_music, 
    paperless_billing
)
SELECT 
    customer_id, online_security, online_backup, 
    device_protection_plan, premium_tech_support, 
    streaming_tv, streaming_movies, streaming_music, 
    paperless_billing
FROM raw_import;

-- 5. Remplissage de la table : BILLING
INSERT INTO billing (
    customer_id, monthly_charge, total_charges, total_refunds, 
    total_extra_data_charges, total_long_distance_charges, 
    total_revenue, avg_monthly_long_distance_charges, 
    avg_monthly_gb_download, payment_method
)
SELECT 
    customer_id, monthly_charge, total_charges, total_refunds, 
    total_extra_data_charges, total_long_distance_charges, 
    total_revenue, avg_monthly_long_distance_charges, 
    avg_monthly_gb_download, payment_method
FROM raw_import;

-- 6. Remplissage de la table : CHURN
INSERT INTO churn (
    customer_id, customer_status, churn_category, 
    churn_reason, number_of_referrals
)
SELECT 
    customer_id, customer_status, churn_category, 
    churn_reason, number_of_referrals
FROM raw_import;