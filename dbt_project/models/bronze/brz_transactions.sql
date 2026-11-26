SELECT
    txn_id,
    customer_id,
    amount_usd,
    status,
    event_ts,
    CURRENT_TIMESTAMP AS _ingested_at
FROM read_parquet('../data/raw/transactions_raw.parquet')
