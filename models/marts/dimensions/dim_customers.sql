{{ config(materialized='table') }}

with subscription_counts as (
    select
        customer_id,
        count(*) as total_subscriptions,
        sum(case when subscription_status = 'active' then 1 else 0 end) as active_subscriptions
    from {{ ref('stg_subscriptions') }}
    group by customer_id
),

customer_revenue as (
    select
        customer_id,
        sum(collected_amount) as lifetime_collected_amount
    from {{ ref('fct_invoices') }}
    group by customer_id
)

select
    c.customer_id,
    c.customer_name,
    c.email,
    c.country_code,
    c.signed_up_at,
    coalesce(s.total_subscriptions, 0) as total_subscriptions,
    coalesce(s.active_subscriptions, 0) as active_subscriptions,
    coalesce(r.lifetime_collected_amount, 0) as lifetime_collected_amount
from {{ ref('stg_customers') }} c
left join subscription_counts s on c.customer_id = s.customer_id
left join customer_revenue r on c.customer_id = r.customer_id
