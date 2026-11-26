WITH ranked AS (
    SELECT
        TRIM(customer_id) AS customer_id,
        TRIM(full_name) AS full_name,
        LOWER(TRIM(email)) AS email,
        LOWER(TRIM(tier)) AS loyalty_tier,
        CAST(updated_at AS TIMESTAMP) AS updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(customer_id)
            ORDER BY CAST(updated_at AS TIMESTAMP) DESC
        ) AS rn
    FROM {{ ref('brz_customers') }}
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    full_name,
    email,
    loyalty_tier,
    updated_at
FROM ranked
WHERE rn = 1
