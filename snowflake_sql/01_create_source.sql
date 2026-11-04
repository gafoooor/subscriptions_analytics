-- Source setup for the subscriptions_analytics dbt project.
-- Run in Snowflake with a role that can create schemas in DEMO_DB.
-- If your account uses a different database or schema name, change it here and in models/staging/sources.yml.

CREATE SCHEMA IF NOT EXISTS DEMO_DB.SUBSCRIPTIONS_RAW;
USE SCHEMA DEMO_DB.SUBSCRIPTIONS_RAW;

CREATE OR REPLACE TABLE RAW_CUSTOMERS (
    CUSTOMER_ID NUMBER NOT NULL,
    FULL_NAME   VARCHAR,
    EMAIL       VARCHAR,
    COUNTRY     VARCHAR,
    SIGNUP_TS   TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE RAW_PLANS (
    PLAN_ID       NUMBER NOT NULL,
    PLAN_NAME     VARCHAR,
    BILLING_CYCLE VARCHAR,
    PLAN_PRICE    NUMBER(10, 2)
);

CREATE OR REPLACE TABLE RAW_SUBSCRIPTIONS (
    SUBSCRIPTION_ID NUMBER NOT NULL,
    CUSTOMER_ID     NUMBER,
    PLAN_ID         NUMBER,
    START_DATE      DATE,
    STATUS          VARCHAR,
    UPDATED_AT      TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE RAW_INVOICES (
    INVOICE_ID      NUMBER NOT NULL,
    SUBSCRIPTION_ID NUMBER,
    INVOICE_DATE    DATE,
    AMOUNT          NUMBER(10, 2),
    TAX             NUMBER(10, 2),
    PAYMENT_STATUS  VARCHAR,
    UPDATED_AT      TIMESTAMP_NTZ
);

INSERT INTO RAW_CUSTOMERS VALUES
    (1, '  Asha Rao ',  ' Asha.Rao@Example.com ', 'in', '2026-01-05 09:12:00'),
    (2, 'Ben Clarke',   'ben.clarke@example.com',  'US', '2026-01-18 14:40:00'),
    (3, 'Chen Wei',     'chen.wei@example.com',    'IN', '2026-02-02 11:05:00'),
    (4, 'Dana Lopez',   'dana.lopez@example.com',  'GB', '2026-02-20 16:30:00'),
    (5, 'Eli Novak',    'eli.novak@example.com',   'DE', '2026-03-03 08:55:00');

INSERT INTO RAW_PLANS VALUES
    (1, 'Starter', 'monthly', 9.00),
    (2, 'Pro',     'monthly', 29.00),
    (3, 'Team',    'annual',  99.00);

INSERT INTO RAW_SUBSCRIPTIONS VALUES
    (101, 1, 2, '2026-01-10', 'active',    '2026-03-10 00:00:00'),
    (102, 2, 1, '2026-02-01', 'cancelled', '2026-03-02 10:00:00'),
    (103, 3, 3, '2026-02-15', 'active',    '2026-02-15 00:00:00'),
    (104, 1, 1, '2026-03-01', 'Paused',    '2026-03-05 00:00:00'),
    (105, 4, 2, '2026-03-20', 'active',    '2026-04-20 00:00:00');

INSERT INTO RAW_INVOICES VALUES
    (1001, 101, '2026-02-10', 29.00, 5.22,  'paid',     '2026-02-10 06:00:00'),
    (1002, 101, '2026-03-10', 29.00, 5.22,  'Paid',     '2026-03-10 06:00:00'),
    (1003, 102, '2026-02-01',  9.00, 1.62,  'paid',     '2026-02-01 06:00:00'),
    (1004, 102, '2026-03-01',  9.00, 1.62,  'failed',   '2026-03-01 06:00:00'),
    (1005, 103, '2026-02-15', 99.00, 17.82, 'paid',     '2026-02-15 06:00:00'),
    (1006, 104, '2026-03-01',  9.00, 1.62,  'refunded', '2026-03-08 12:00:00'),
    (1007, 105, '2026-03-20', 29.00, 5.22,  'pending',  '2026-03-20 06:00:00'),
    (1008, 105, '2026-04-20', 29.00, 5.22,  'paid',     '2026-04-20 06:00:00');

-- Verification: expect 5 customers, 3 plans, 5 subscriptions, 8 invoices.
SELECT 'RAW_CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM RAW_CUSTOMERS
UNION ALL SELECT 'RAW_PLANS', COUNT(*) FROM RAW_PLANS
UNION ALL SELECT 'RAW_SUBSCRIPTIONS', COUNT(*) FROM RAW_SUBSCRIPTIONS
UNION ALL SELECT 'RAW_INVOICES', COUNT(*) FROM RAW_INVOICES;
