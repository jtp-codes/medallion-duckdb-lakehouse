{{
    config(
        post_hook="COPY {{ this }} TO '../lakehouse/gold_customer_revenue.parquet' (FORMAT PARQUET);"
    )
}}

SELECT
    c.customer_id,
    c.full_name,
    c.loyalty_tier,
    COUNT(t.txn_id) AS valid_txn_count,
    COALESCE(SUM(CASE WHEN t.txn_status = 'COMPLETED' THEN t.amount_usd ELSE 0 END), 0) AS completed_revenue_usd,
    MAX(t.event_ts) AS last_activity_ts
FROM {{ ref('slv_customers') }} c
LEFT JOIN {{ ref('slv_transactions') }} t
    ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id,
    c.full_name,
    c.loyalty_tier
