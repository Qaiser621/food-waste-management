CREATE TABLE users (
 id INTEGER PRIMARY KEY, email TEXT NOT NULL UNIQUE COLLATE NOCASE, password_hash TEXT NOT NULL,
 role TEXT NOT NULL CHECK(role IN ('DONOR','NGO','VOLUNTEER','ADMIN')), name TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','SUSPENDED')),
 verified INTEGER NOT NULL DEFAULT 0, address TEXT, lat REAL, lng REAL, capacity REAL NOT NULL DEFAULT 100,
 available INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE sessions (sid TEXT PRIMARY KEY, sess TEXT NOT NULL, expired INTEGER NOT NULL);
CREATE INDEX sessions_expired_idx ON sessions(expired);
CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, icon TEXT NOT NULL DEFAULT '🍲');
CREATE TABLE donations (
 id INTEGER PRIMARY KEY, donor_id INTEGER NOT NULL REFERENCES users(id), title TEXT NOT NULL, description TEXT NOT NULL,
 category_id INTEGER NOT NULL REFERENCES categories(id), quantity REAL NOT NULL CHECK(quantity>0), unit TEXT NOT NULL,
 available_quantity REAL NOT NULL, claimed_quantity REAL NOT NULL DEFAULT 0, reserved_quantity REAL NOT NULL DEFAULT 0,
 delivered_quantity REAL NOT NULL DEFAULT 0, prepared_at TEXT NOT NULL, expires_at TEXT NOT NULL, address TEXT NOT NULL,
 lat REAL NOT NULL, lng REAL NOT NULL, safety_ack INTEGER NOT NULL CHECK(safety_ack=1), status TEXT NOT NULL DEFAULT 'AVAILABLE',
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX donations_status_expiry ON donations(status,expires_at);
CREATE TABLE food_items(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id) ON DELETE CASCADE, name TEXT NOT NULL, category_id INTEGER NOT NULL REFERENCES categories(id), quantity REAL NOT NULL CHECK(quantity>0), unit TEXT NOT NULL);
CREATE TABLE requirements(id INTEGER PRIMARY KEY, ngo_id INTEGER NOT NULL REFERENCES users(id), category_id INTEGER NOT NULL REFERENCES categories(id), quantity REAL NOT NULL, priority INTEGER NOT NULL CHECK(priority BETWEEN 1 AND 5), details TEXT, active INTEGER NOT NULL DEFAULT 1);
CREATE TABLE claims(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), ngo_id INTEGER NOT NULL REFERENCES users(id), quantity REAL NOT NULL CHECK(quantity>0), status TEXT NOT NULL DEFAULT 'PENDING', reason TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE(donation_id,ngo_id,status));
CREATE TABLE assignments(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), claim_id INTEGER NOT NULL REFERENCES claims(id), volunteer_id INTEGER NOT NULL REFERENCES users(id), status TEXT NOT NULL DEFAULT 'OFFERED', created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE UNIQUE INDEX one_active_assignment ON assignments(donation_id) WHERE status IN ('OFFERED','ACCEPTED','PICKUP_STARTED','PICKED_UP','IN_TRANSIT');
CREATE TABLE verifications(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), assignment_id INTEGER NOT NULL REFERENCES assignments(id), stage TEXT NOT NULL CHECK(stage IN ('PICKUP','DELIVERY')), token_hash TEXT NOT NULL, code_hash TEXT NOT NULL, expires_at TEXT NOT NULL, used_at TEXT);
CREATE TABLE deliveries(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), assignment_id INTEGER NOT NULL REFERENCES assignments(id), expected_quantity REAL NOT NULL, delivered_quantity REAL NOT NULL, recipient_name TEXT NOT NULL, received_quantity REAL, accepted INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE ratings(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), rater_id INTEGER NOT NULL REFERENCES users(id), rated_id INTEGER NOT NULL REFERENCES users(id), stars INTEGER NOT NULL CHECK(stars BETWEEN 1 AND 5), UNIQUE(donation_id,rater_id,rated_id));
CREATE TABLE timeline_events(id INTEGER PRIMARY KEY, donation_id INTEGER NOT NULL REFERENCES donations(id), event_type TEXT NOT NULL, actor_id INTEGER REFERENCES users(id), details TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE notifications(id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL REFERENCES users(id), title TEXT NOT NULL, body TEXT NOT NULL, link TEXT, read_at TEXT, dedupe_key TEXT UNIQUE, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE audit_logs(id INTEGER PRIMARY KEY, actor_id INTEGER REFERENCES users(id), action TEXT NOT NULL, entity_type TEXT, entity_id INTEGER, details TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE demand_history(id INTEGER PRIMARY KEY, ngo_id INTEGER NOT NULL REFERENCES users(id), category_id INTEGER NOT NULL REFERENCES categories(id), demand REAL NOT NULL, demand_date TEXT NOT NULL, UNIQUE(ngo_id,category_id,demand_date));
CREATE TABLE settings(key TEXT PRIMARY KEY, value REAL NOT NULL);
CREATE TABLE ngo_applications(id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL UNIQUE REFERENCES users(id), status TEXT NOT NULL DEFAULT 'PENDING', reason TEXT, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
