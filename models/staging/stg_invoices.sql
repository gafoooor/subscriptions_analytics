select
    cast(invoice_id as integer) as invoice_id,
    cast(subscription_id as integer) as subscription_id,
    cast(invoice_date as date) as invoice_date,
    cast(amount as decimal(10, 2)) as amount,
    cast(tax as decimal(10, 2)) as tax,
    lower(trim(payment_status)) as payment_status,
    cast(updated_at as timestamp_ntz) as updated_at
from {{ source('subscriptions_raw', 'raw_invoices') }}
