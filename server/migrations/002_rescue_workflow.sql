ALTER TABLE verifications ADD COLUMN token_encrypted TEXT;
ALTER TABLE verifications ADD COLUMN code_encrypted TEXT;
ALTER TABLE verifications ADD COLUMN attempts INTEGER NOT NULL DEFAULT 0;
CREATE TABLE receipts(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL UNIQUE REFERENCES donations(id), ngo_id INTEGER NOT NULL REFERENCES users(id), received_quantity REAL NOT NULL, safety_ack INTEGER NOT NULL CHECK(safety_ack=1), received_by TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
