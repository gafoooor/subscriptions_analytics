{{ config(materialized='table') }}

select
    p.plan_id,
    p.plan_name,
    p.billing_cycle,
    p.plan_price,
    count(s.subscription_id) as subscription_count,
    sum(case when s.subscription_status = 'active' then 1 else 0 end) as active_subscription_count
from {{ ref('stg_plans') }} p
left join {{ ref('stg_subscriptions') }} s on p.plan_id = s.plan_id
group by 1, 2, 3, 4
