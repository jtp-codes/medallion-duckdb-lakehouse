from pathlib import Path
import duckdb
import pyarrow as pa
import pyarrow.parquet as pq

RAW_DIR = Path("data/raw")
RAW_DIR.mkdir(parents=True, exist_ok=True)


def generate_raw_landing_files() -> None:
    # 1. Raw Customers CSV (includes duplicate customer_id C002 and dirty whitespace/casing)
    customers_csv = """customer_id,full_name,email,tier,updated_at
C001,  Aarav Sharma ,AARAV@EXAMPLE.COM,gold,2026-11-20T10:00:00
C002,Diya Patel,diya@example.com,silver,2026-11-20T11:00:00
C002,Diya Patel,diya.patel@example.com,gold,2026-11-22T09:30:00
C003,Rohan Verma,rohan@example.com,bronze,2026-11-21T14:15:00
"""
    (RAW_DIR / "customers_raw.csv").write_text(customers_csv.strip() + "\n", encoding="utf-8")

    # 2. Raw Transactions Parquet (includes duplicate txn_id TX102 and negative/invalid record TX999)
    txns_table = pa.table(
        {
            "txn_id": ["TX101", "TX102", "TX102", "TX103", "TX104", "TX999"],
            "customer_id": ["C001", "C002", "C002", "C001", "C003", "C001"],
            "amount_usd": [250.00, 120.50, 120.50, 499.99, 75.00, -50.00],
            "status": ["COMPLETED", "COMPLETED", "COMPLETED", "COMPLETED", "PENDING", "FAILED"],
            "event_ts": [
                "2026-11-23T08:00:00",
                "2026-11-23T09:15:00",
                "2026-11-23T09:15:00",
                "2026-11-24T12:30:00",
                "2026-11-24T16:45:00",
                "2026-11-25T01:00:00",
            ],
        }
    )
    pq.write_table(txns_table, RAW_DIR / "transactions_raw.parquet")

    # 3. Pre-warm DuckDB catalog directory
    Path("lakehouse").mkdir(exist_ok=True)
    con = duckdb.connect("lakehouse/medallion.duckdb")
    con.close()
    print("Generated raw landing CSV/Parquet files in data/raw/ and initialized DuckDB.")


if __name__ == "__main__":
    generate_raw_landing_files()
