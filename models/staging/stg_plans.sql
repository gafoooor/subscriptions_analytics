select
    cast(plan_id as integer) as plan_id,
    trim(plan_name) as plan_name,
    lower(trim(billing_cycle)) as billing_cycle,
    cast(plan_price as decimal(10, 2)) as plan_price
from {{ source('subscriptions_raw', 'raw_plans') }}
