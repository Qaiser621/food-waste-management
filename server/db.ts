import Database from 'better-sqlite3';
import fs from 'node:fs';
import path from 'node:path';

const dbPath = process.env.DATABASE_PATH ?? './data/smartfood.db';
fs.mkdirSync(path.dirname(path.resolve(dbPath)), { recursive: true });
export const db = new Database(dbPath);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');
db.pragma('busy_timeout = 5000');

export function migrate() {
  db.exec(`CREATE TABLE IF NOT EXISTS schema_migrations (name TEXT PRIMARY KEY, applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)`);
  const dir = path.join(process.cwd(), 'server', 'migrations');
  for (const name of fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort()) {
    if (db.prepare('SELECT 1 FROM schema_migrations WHERE name=?').get(name)) continue;
    const sql = fs.readFileSync(path.join(dir, name), 'utf8');
    db.transaction(() => { db.exec(sql); db.prepare('INSERT INTO schema_migrations(name) VALUES(?)').run(name); })();
  }
}

export function audit(actorId: number | null, action: string, entityType?: string, entityId?: number, details?: string) {
  db.prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)').run(actorId, action, entityType ?? null, entityId ?? null, details ?? null);
}
export function event(donationId: number, type: string, actorId: number | null, details?: string) {
  db.prepare('INSERT INTO timeline_events(donation_id,event_type,actor_id,details) VALUES(?,?,?,?)').run(donationId, type, actorId, details ?? null);
}
