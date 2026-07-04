-- ═══════════════════════════════════════════════════════════
-- ASPL Team Manager – Supabase Datenbankschema
-- Im Supabase SQL Editor ausführen (Dashboard → SQL Editor → New query)
-- ═══════════════════════════════════════════════════════════

-- ── Fahrer ──────────────────────────────────────────────────
CREATE TABLE drivers (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Rennen ──────────────────────────────────────────────────
CREATE TABLE races (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title      TEXT NOT NULL,             -- z.B. "Runde 5 – Monza"
  track      TEXT,                      -- Streckenname
  date       DATE NOT NULL,             -- Renndatum
  status     TEXT DEFAULT 'upcoming',   -- 'upcoming' | 'registration_open' | 'completed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Anmeldungen (Fahrer ↔ Rennen) ──────────────────────────
CREATE TABLE registrations (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  race_id       UUID REFERENCES races(id)   ON DELETE CASCADE,
  driver_id     UUID REFERENCES drivers(id) ON DELETE CASCADE,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(race_id, driver_id)
);

-- ── Resultate ───────────────────────────────────────────────
CREATE TABLE results (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  race_id     UUID REFERENCES races(id)   ON DELETE CASCADE,
  driver_id   UUID REFERENCES drivers(id) ON DELETE CASCADE,
  position    INTEGER NOT NULL,          -- Endposition (1 = Sieger)
  dnf         BOOLEAN DEFAULT FALSE,      -- Did Not Finish
  fastest_lap BOOLEAN DEFAULT FALSE,
  points      INTEGER DEFAULT 0,         -- Erzielte Punkte (von der App automatisch berechnet)
  notes       TEXT,                      -- Optionale Notizen (z.B. "Penalty", "Safety Car")
  UNIQUE(race_id, driver_id)
);

-- Indizes für schnellere Abfragen
CREATE INDEX idx_registrations_race ON registrations(race_id);
CREATE INDEX idx_results_race        ON results(race_id);
CREATE INDEX idx_results_driver      ON results(driver_id);

-- ═══════════════════════════════════════════════════════════
-- Row Level Security – alle Operationen ohne Login erlauben
-- (die App identifiziert Fahrer nur über den Namen, kein Passwort)
-- ═══════════════════════════════════════════════════════════
ALTER TABLE drivers       ENABLE ROW LEVEL SECURITY;
ALTER TABLE races         ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE results       ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_drivers"       ON drivers       FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_races"         ON races         FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_registrations" ON registrations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_results"       ON results       FOR ALL USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════
-- Optional: ein paar Beispieldaten zum Testen (kann man weglassen)
-- ═══════════════════════════════════════════════════════════
-- INSERT INTO races (title, track, date, status) VALUES
--   ('Runde 1 – Monza',  'Autodromo Nazionale Monza', '2026-06-21', 'registration_open'),
--   ('Runde 2 – Spa',    'Circuit de Spa-Francorchamps', '2026-07-05', 'upcoming');
