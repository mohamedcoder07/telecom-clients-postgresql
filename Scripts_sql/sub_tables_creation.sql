CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    married VARCHAR(10),
    number_of_dependents INT
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6)
);

CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    tenure_months INT,
    contract VARCHAR(50),
    offer VARCHAR(50),
    internet_service VARCHAR(20),
    internet_type VARCHAR(50),
    phone_service VARCHAR(20),
    multiple_lines VARCHAR(20),
    unlimited_data VARCHAR(20)
);

CREATE TABLE service_features (
    feature_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection_plan VARCHAR(20),
    premium_tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20),
    streaming_music VARCHAR(20),
    paperless_billing VARCHAR(20)
);

CREATE TABLE billing (
    billing_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    monthly_charge DECIMAL(10,2),
    total_charges DECIMAL(10,2),
    total_refunds DECIMAL(10,2),
    total_extra_data_charges DECIMAL(10,2),
    total_long_distance_charges DECIMAL(10,2),
    total_revenue DECIMAL(10,2),
    avg_monthly_long_distance_charges DECIMAL(10,2),
    avg_monthly_gb_download DECIMAL(10,2),
    payment_method VARCHAR(50)
);

CREATE TABLE churn (
    churn_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    customer_status VARCHAR(50),
    churn_category VARCHAR(100),
    churn_reason TEXT,
    number_of_referrals INT
);
