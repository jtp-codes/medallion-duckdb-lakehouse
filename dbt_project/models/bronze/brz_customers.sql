SELECT
    customer_id,
    full_name,
    email,
    tier,
    updated_at,
    CURRENT_TIMESTAMP AS _ingested_at
FROM read_csv_auto('../data/raw/customers_raw.csv', header = true)
