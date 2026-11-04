{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='invoice_id'
) }}

-- Grain: one row per invoice. Only rows changed since the last run are merged,
-- so a status change in raw_invoices updates the existing fact row.
select
    i.invoice_id,
    i.subscription_id,
    s.customer_id,
    s.plan_id,
    i.invoice_date,
    i.payment_status,
    i.amount,
    i.tax,
    i.amount + i.tax as total_amount,
    case when i.payment_status = 'paid' then i.amount + i.tax else 0 end as collected_amount,
    i.updated_at
from {{ ref('stg_invoices') }} i
inner join {{ ref('stg_subscriptions') }} s
    on i.subscription_id = s.subscription_id
{% if is_incremental() %}
where i.updated_at >= (select coalesce(max(updated_at), '1900-01-01'::timestamp_ntz) from {{ this }})
{% endif %}
