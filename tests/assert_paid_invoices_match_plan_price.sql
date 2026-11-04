-- Custom singular test: every paid invoice should be billed at the current price
-- of the plan it belongs to. A passing test returns zero rows.
select
    i.invoice_id,
    i.subscription_id,
    i.plan_id,
    i.amount,
    p.plan_price
from {{ ref('fct_invoices') }} i
inner join {{ ref('dim_plans') }} p
    on i.plan_id = p.plan_id
where i.payment_status = 'paid'
  and i.amount <> p.plan_price
