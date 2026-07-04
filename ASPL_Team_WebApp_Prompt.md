# ASPL Team Manager – Web-App Bauauftrag für Claude

## Aufgabe

Bitte baue mir eine vollständige Web-App für mein ASPL (Amateur Sim Racing Pro League) Team. Die App soll es Fahrern ermöglichen, sich für kommende Rennen an- oder abzumelden, und am Ende jedes Rennens können Resultate eingetragen werden, woraus eine detaillierte Statistik für jeden Fahrer entsteht.

---

## Tech-Stack

- **Frontend:** Einzelne HTML-Datei mit eingebettetem CSS und JavaScript (kein Build-Step nötig)
- **Backend / Datenbank:** Supabase (kostenloser Tier reicht aus)
- **Supabase SDK:** Über CDN eingebunden (`https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2`)
- Die App soll vollständig in einer einzigen `index.html` Datei liegen, die man direkt im Browser öffnen oder auf einem einfachen Hosting (z.B. GitHub Pages, Netlify) deployen kann.

---

## Supabase Setup

Erstelle folgendes Datenbankschema in Supabase (SQL für den Supabase SQL Editor):

```sql
-- Fahrer-Tabelle
CREATE TABLE drivers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Rennen-Tabelle
CREATE TABLE races (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,           -- z.B. "Runde 5 – Monza"
  track TEXT,                    -- Streckenname
  date DATE NOT NULL,            -- Renndatum
  status TEXT DEFAULT 'upcoming' -- 'upcoming', 'registration_open', 'completed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Anmeldungen (Fahrer zu Rennen)
CREATE TABLE registrations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  race_id UUID REFERENCES races(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(race_id, driver_id)
);

-- Resultate
CREATE TABLE results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  race_id UUID REFERENCES races(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,     -- Endposition (1 = Sieger)
  dnf BOOLEAN DEFAULT FALSE,     -- Did Not Finish
  fastest_lap BOOLEAN DEFAULT FALSE,
  points INTEGER DEFAULT 0,      -- Erzielte Punkte (manuell oder automatisch)
  notes TEXT,                    -- Optionale Notizen (z.B. "Penalty", "Safety Car")
  UNIQUE(race_id, driver_id)
);
```

Aktiviere **Row Level Security (RLS)** und stelle folgende Policies ein, sodass alle Operationen ohne Login möglich sind (die App nutzt einen simplen Namens-basierten Identifikationsmechanismus):

```sql
-- Für alle Tabellen: Lesen erlaubt für alle
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE races ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_drivers" ON drivers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_races" ON races FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_registrations" ON registrations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_results" ON results FOR ALL USING (true) WITH CHECK (true);
```

---

## App-Struktur (Seiten / Ansichten)

Die App hat **keine URL-Änderungen** – alles passiert auf einer Seite, Ansichten werden per JavaScript ein-/ausgeblendet.

### 1. Willkommensseite / Name-Eingabe

Beim allerersten Besuch (oder wenn noch kein Name im `localStorage` gespeichert ist) sieht der Benutzer:

- Ein sauberes Willkommens-Modal / Formular mit dem Text: **„Willkommen beim ASPL Team Manager – Wie heisst du?"**
- Ein Textfeld für den Namen
- Button **„Weiter"**
- Beim Absenden: Prüfen ob der Name bereits in der `drivers`-Tabelle existiert. Falls ja → direkt einloggen. Falls nein → neuen Fahrer anlegen und einloggen.
- Name wird in `localStorage` gespeichert (`key: "aspl_driver_name"`, `value: driver_id`)
- Kein Passwort nötig. Name ist eindeutig (UNIQUE constraint).

Oben rechts in der App soll immer angezeigt werden: **„Hallo, [Name]"** + ein kleiner Button **„Wechseln"** (löscht den localStorage-Eintrag und zeigt wieder die Namenseingabe).

---

### 2. Navigation

Drei Tabs / Navigationspunkte:
- 🏁 **Nächstes Rennen** (Standard-Tab beim Öffnen)
- 📊 **Statistiken**
- ⚙️ **Admin** (nicht passwortgeschützt, aber etwas versteckt – z.B. kleines Zahnrad-Icon)

---

### 3. Tab: Nächstes Rennen

Zeigt das nächste Rennen mit `status = 'registration_open'` oder das nächste nach Datum.

**Anzeige:**
- Rennname, Strecke, Datum (schön formatiert auf Deutsch, z.B. „Samstag, 21. Juni 2026")
- Countdown in Tagen bis zum Rennen
- Liste aller angemeldeten Fahrer (mit Avatar-Initialen, schön gestaltet)
- Anzahl angemeldeter Fahrer

**Aktionen des eingeloggten Fahrers:**
- Grosser Button **„✅ Ich bin dabei!"** wenn noch nicht angemeldet
- Grosser Button **„❌ Abmelden"** wenn bereits angemeldet (mit kurzer Bestätigung)
- Der Button des aktuellen Fahrers ist visuell hervorgehoben

Falls kein kommendes Rennen eingetragen ist: Freundliche Meldung „Noch kein Rennen geplant – schau später nochmal vorbei!"

---

### 4. Tab: Statistiken

#### 4a. Übersicht aller Fahrer (Tabelle / Leaderboard)

Sortierbare Tabelle mit allen Fahrern die mindestens 1 Rennen gefahren sind:

| Fahrer | Rennen | Siege | Podien | Ø Position | Punkte Total | Schnellste Runden | DNFs |
|--------|--------|-------|--------|------------|--------------|-------------------|------|

- Klick auf einen Fahrer öffnet dessen Detailansicht
- Standard-Sortierung: Punkte absteigend
- Visuell schöne Tabelle mit Rang-Nummern (🥇🥈🥉 für Top 3)

#### 4b. Fahrer-Detailprofil

Wenn man auf einen Fahrer klickt, öffnet sich eine Detailansicht:

- **Profilkopf:** Name, Initialen-Avatar (gross), Beitrittsdatum
- **Kennzahlen-Karten:**
  - Gesamte Rennen gefahren
  - Gesamtpunkte
  - Bestes Ergebnis
  - Durchschnittliche Position
  - Siege / Podien / Top-5
  - Schnellste Runden (Anzahl)
  - DNFs
  - AnmeldeRate: „X von Y Rennen angemeldet" (auch wenn nicht angetreten)
- **Verlauf:** Tabelle aller Rennen mit Position, Punkten, Notizen
- **Verlaufsgrafik:** Einfaches Liniendiagramm (mit Chart.js über CDN) das die Positionen über die Rennen zeigt (Y-Achse invertiert: Position 1 oben)

---

### 5. Tab: Admin

Dieser Bereich erlaubt es, Rennen zu verwalten und Resultate einzutragen.

#### 5a. Rennen erstellen

Formular:
- Rennname (z.B. „Runde 5 – Monza")
- Strecke
- Datum (Datepicker)
- Status: `upcoming` / `registration_open` / `completed`
- Button **„Rennen erstellen"**

#### 5b. Rennen verwalten

Liste aller Rennen mit:
- Status-Badge (farblich: grün = offen, grau = upcoming, blau = abgeschlossen)
- Button **„Status ändern"**
- Button **„Resultate eintragen"** (nur bei `completed`)
- Button **„Löschen"** (mit Bestätigung)

#### 5c. Resultate eintragen

Wenn man bei einem abgeschlossenen Rennen auf **„Resultate eintragen"** klickt:

- Liste aller angemeldeten Fahrer (aus der registrations-Tabelle)
- Pro Fahrer:
  - Positions-Eingabe (Zahl, 1–99)
  - Checkbox „DNF"
  - Checkbox „Schnellste Runde"
  - Punkte (automatisch berechnet nach Standard F1-Punktesystem: 25-18-15-12-10-8-6-4-2-1, +1 Punkt für schnellste Runde wenn in Top 10)
  - Notiz-Feld (optional)
- Button **„Resultate speichern"**
- Falls Resultate bereits vorhanden: Anzeigen und editierbar machen

**Punktesystem (automatisch):**
```
Position 1  → 25 Punkte
Position 2  → 18 Punkte
Position 3  → 15 Punkte
Position 4  → 12 Punkte
Position 5  → 10 Punkte
Position 6  → 8 Punkte
Position 7  → 6 Punkte
Position 8  → 4 Punkte
Position 9  → 2 Punkte
Position 10 → 1 Punkt
Position 11+ → 0 Punkte
DNF         → 0 Punkte
Schnellste Runde (wenn in Top 10) → +1 zusätzlicher Punkt
```

#### 5d. Fahrer verwalten

- Liste aller registrierten Fahrer
- Button **„Fahrer löschen"** (mit Bestätigung, löscht auch alle zugehörigen Daten)

---

## Design-Anforderungen

- **Dunkles Theme** (Racing-Feeling): Hintergrund `#0f0f1a`, Karten `#1a1a2e`, Akzentfarbe `#e63946` (Rot) oder `#00b4d8` (Hellblau)
- **Responsive:** Funktioniert auf Desktop und Handy
- **Schriftart:** `Inter` oder `Roboto` über Google Fonts
- **Karten-Design:** Abgerundete Ecken, leichte Box-Shadows, saubere Typografie
- **Loading-States:** Beim Laden von Daten einen Spinner / „Laden..." anzeigen
- **Toast-Nachrichten:** Bei Aktionen (Anmeldung, Abmeldung, Resultate gespeichert) kurze Erfolgs- oder Fehlermeldung einblenden (unten rechts, 3 Sekunden)
- **Animationen:** Subtile Fade-In Animationen beim Wechseln der Tabs

---

## Konfiguration

Ganz oben in der `index.html` soll ein klar markierter Konfigurationsblock stehen:

```javascript
// ═══════════════════════════════════════
// KONFIGURATION – HIER ANPASSEN
// ═══════════════════════════════════════
const SUPABASE_URL = 'DEINE_SUPABASE_URL_HIER';
const SUPABASE_ANON_KEY = 'DEIN_SUPABASE_ANON_KEY_HIER';
const TEAM_NAME = 'ASPL Team'; // Wird im Header angezeigt
// ═══════════════════════════════════════
```

---

## Wichtige technische Details

- Alle Datenbankabfragen laufen über den Supabase JavaScript Client
- Fehlerbehandlung bei allen Supabase-Calls (try/catch mit verständlichen Fehlermeldungen)
- `localStorage` speichert nur `driver_id` und `driver_name` – keine sensitiven Daten
- Die App soll ohne Reload funktionieren (Single Page App Prinzip)
- Kommentare im Code auf Deutsch oder Englisch

---

## Lieferumfang

Bitte liefere:
1. Die vollständige `index.html` Datei (alles in einer Datei: HTML + CSS + JS)
2. Den SQL-Code für Supabase (zum Ausführen im Supabase SQL Editor)
3. Eine kurze Setup-Anleitung (wie man den Supabase-Schlüssel einträgt und die App startet)

---

## Zusammenfassung der wichtigsten Features

✅ Fahrer-Registrierung per Name (kein Passwort)  
✅ An- und Abmeldung für Rennen  
✅ Echtzeit-Anzeige wer angemeldet ist  
✅ Admin-Bereich für Rennen und Resultate  
✅ Automatisches Punktesystem (F1-Style)  
✅ Statistik-Leaderboard für alle Fahrer  
✅ Detailprofil pro Fahrer mit Verlaufsgrafik  
✅ Dunkles Racing-Design  
✅ Responsive (Desktop + Handy)  
