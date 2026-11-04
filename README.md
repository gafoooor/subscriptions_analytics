# subscriptions_analytics

dbt project on Snowflake: raw subscription billing data is declared as sources, cleaned in staging views, modeled into dimension tables and an incremental fact table, tested, documented, and built by a dbt Cloud job.

## Layout

```
snowflake_sql/01_create_source.sql      Creates the raw source tables and loads sample rows
models/staging/sources.yml              Declares the raw tables (source())
models/staging/stg_*.sql                Staging views (view materialization)
models/staging/staging.yml              Descriptions and generic tests for staging
models/marts/dimensions/dim_*.sql       Dimension tables (table materialization)
models/marts/facts/fct_invoices.sql     Incremental fact table (incremental materialization, merge)
models/marts/marts.yml                  Descriptions and generic tests for marts
tests/assert_paid_invoices_match_plan_price.sql   Custom singular test
```

## Model initialization types

| Type | Where | How it is set |
|---|---|---|
| View | `stg_customers`, `stg_plans`, `stg_subscriptions`, `stg_invoices` | `staging: +materialized: view` in `dbt_project.yml` |
| Table | `dim_customers`, `dim_plans` | `{{ config(materialized='table') }}` in each model |
| Incremental | `fct_invoices` | `{{ config(materialized='incremental', incremental_strategy='merge', unique_key='invoice_id') }}` |

## Setup

1. **Create the source tables.** Run `snowflake_sql/01_create_source.sql` in a Snowflake worksheet. The last query should return 5 customers, 3 plans, 5 subscriptions and 8 invoices.
2. **Create the dbt Cloud project.** In dbt Cloud, create a project on Snowflake and connect it to a Git repository containing these files. Set the development schema (for example `SUBSCRIPTIONS_DEV`) and the warehouse and role you used in step 1.
3. **Check the connection and build in the IDE:**

   ```bash
   dbt debug
   dbt parse
   dbt build
   dbt docs generate
   ```

4. **Test incremental behaviour.** Run this in Snowflake, then `dbt build` again. Only `fct_invoices` should merge the changed row:

   ```sql
   UPDATE DEMO_DB.SUBSCRIPTIONS_RAW.RAW_INVOICES
   SET PAYMENT_STATUS = 'paid', UPDATED_AT = CURRENT_TIMESTAMP()
   WHERE INVOICE_ID = 1007;
   ```

## Testing

- Generic tests (`not_null`, `unique`, `accepted_values`, `relationships`) are declared in the YAML files.
- Custom singular test: `tests/assert_paid_invoices_match_plan_price.sql` fails if any paid invoice amount differs from its plan price. Run it with `dbt test --select assert_paid_invoices_match_plan_price`.

## dbt Cloud job (orchestration)

1. In dbt Cloud, go to **Deploy → Environments → Create environment**. Choose type **Deployment**, the same Snowflake connection, and target schema `SUBSCRIPTIONS_PROD`.
2. Go to **Deploy → Jobs → Create job → Deploy job**.
3. Set the name to `Subscriptions Daily Build`, the environment to the deployment environment, and add the command `dbt build`.
4. Under **Triggers**, turn on **Run on schedule** and set a daily time, for example 06:00 UTC.
5. Save and click **Run now**. A successful run lists every model and test as passed, and the run history shows the result.

`dbt build` runs models, tests, and snapshots (if any) in dependency order. A failing test stops downstream models that depend on it.

## Notes

- The source data is synthetic. No real customer data is included.
- Built against dbt 1.10 syntax (`arguments:` under generic tests, `data_tests:`). Older dbt versions need `tests:` and flat test arguments.
