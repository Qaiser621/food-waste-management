# SmartFood

Local food rescue platform connecting donors, verified NGOs, and volunteers in Chennai. SmartFood does not inspect or certify food safety; donors and receiving organisations are responsible for safe preparation, storage, and receipt.

## Live deployment

Visit the deployed app: <https://smart-food-waste-management-hini.onrender.com/>

## Prerequisites

- Node.js 20 or newer (tested with Node 24.15.0)
- npm

## Install and run

```powershell
npm install
Copy-Item .env.example .env
npm run db:migrate
npm run db:seed
npm run dev
```

Open <http://127.0.0.1:5173>. Vite serves the React client and proxies `/api` requests to Express on port 3001. The root development command starts both processes.

The default local database is `data/smartfood.db`; optional verified images are stored in `data/uploads`. Both paths are configurable with `DATABASE_PATH` and `UPLOAD_DIR`. Keep `.env`, database files, and uploads private; they are ignored by Git. Change `SESSION_SECRET` before exposing the app beyond a local demonstration.

## Demo accounts

All seeded accounts use `Demo@12345`.

| Role | Email |
|---|---|
| Admin | `admin@smartfood.demo` |
| Donor | `donor@smartfood.demo` |
| NGO | `ngo@smartfood.demo` |
| Volunteer | `volunteer@smartfood.demo` |

Public registration supports donors, NGOs, and volunteers. New NGOs remain pending until an admin approves them; admins are seeded and cannot be registered publicly.

## Database and tests

```powershell
npm run db:migrate
npm run db:seed
npm run typecheck
npm test
npm run build
```

`npm run db:seed` is repeatable and creates fictional demo records. Tests use isolated temporary SQLite databases.

## Production build

```powershell
npm run build
$env:NODE_ENV = 'production'
npm start
```

Express serves the generated `dist` client and API from the same origin when `NODE_ENV=production`. Set `PORT`, `SESSION_SECRET`, `DATABASE_PATH`, and `UPLOAD_DIR` for the deployment environment. The local demo uses HTTP; enable HTTPS and secure cookies behind a correctly configured TLS proxy before public deployment.

## Architecture

- `src/`: React, TypeScript, React Router, reusable CSS, role dashboards, and charts.
- `server/`: Express API, Zod validation, session/auth middleware, SQL access, pure scoring logic, and maintenance job.
- `server/migrations/`: ordered SQL migrations for the normalized SQLite schema.
- `server/scripts/`: migration and repeatable seed commands.
- `tests/`: Vitest and Supertest API/security/workflow tests plus pure scoring tests.

Sessions are stored in SQLite, passwords are hashed with bcryptjs, and write requests use a session CSRF token. SQLite transactions protect claim quantity reservations. Verification tokens are single-use and expire; QR/manual-code support is provided for pickup and delivery.

## Scoring and estimates

Freshness, urgency, priority, distance, NGO match, volunteer selection, and impact calculations are deterministic and live in `server/logic/scoring.ts`. Match and volunteer scores use persisted location, requirement, capacity, rating, and completion records. Impact counts confirmed receipts only. Seeded defaults estimate 0.4 kg per meal and 2.5 kg CO₂ avoided per kg; admins can edit these factors. People served uses recorded recipient counts rather than an inferred population.

Route lines are straight-line visual estimates, not road directions. Travel time assumes 20 km/h. Leaflet uses OpenStreetMap tiles and needs internet access; the rest of the app runs locally, and tile errors are handled in the map view. QR camera scanning depends on the browser's `BarcodeDetector` and camera permissions; manual eight-digit codes are the fallback.

## Known limitations

- The current donation form creates one primary food item; the API accepts an array of item records, but the form does not yet expose multiple independently categorized food items.
- Food classification is a transparent text-keyword suggestion only. Images are not analyzed by computer vision.
- Browser verification covered each seeded role and completed the full rescue from donation creation through confirmed receipt. The landing and claims views were visually checked at phone width; other routes were smoke-checked at desktop width, not exhaustively at every breakpoint.
- Ratings are accepted by a secured API, but a rating form is not yet exposed in the UI. Admin manual volunteer assignment is also not exposed in the UI. The local production dependency audit reports two moderate React Router advisories; npm proposes a major-version upgrade, so dependencies were not force-upgraded without migration validation.


