select
    cast(subscription_id as integer) as subscription_id,
    cast(customer_id as integer) as customer_id,
    cast(plan_id as integer) as plan_id,
    cast(start_date as date) as start_date,
    lower(trim(status)) as subscription_status,
    cast(updated_at as timestamp_ntz) as updated_at
from {{ source('subscriptions_raw', 'raw_subscriptions') }}
