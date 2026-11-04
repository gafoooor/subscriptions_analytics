select
    cast(customer_id as integer) as customer_id,
    trim(full_name) as customer_name,
    lower(trim(email)) as email,
    upper(trim(country)) as country_code,
    cast(signup_ts as timestamp_ntz) as signed_up_at
from {{ source('subscriptions_raw', 'raw_customers') }}
