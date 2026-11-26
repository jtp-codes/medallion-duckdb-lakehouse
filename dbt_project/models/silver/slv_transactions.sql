WITH deduplicated AS (
    SELECT
        TRIM(txn_id) AS txn_id,
        TRIM(customer_id) AS customer_id,
        CAST(amount_usd AS DOUBLE) AS amount_usd,
        UPPER(TRIM(status)) AS txn_status,
        CAST(event_ts AS TIMESTAMP) AS event_ts,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(txn_id)
            ORDER BY CAST(event_ts AS TIMESTAMP) DESC
        ) AS rn
    FROM {{ ref('brz_transactions') }}
    WHERE txn_id IS NOT NULL
      AND CAST(amount_usd AS DOUBLE) > 0
      AND UPPER(TRIM(status)) IN ('COMPLETED', 'PENDING')
)
SELECT
    txn_id,
    customer_id,
    amount_usd,
    txn_status,
    event_ts
FROM deduplicated
WHERE rn = 1
