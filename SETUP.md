# ASPL · Team Series · Saison 2 — Web-App

Eine einzelne, offline-fähige HTML-Datei: Saison-Showcase **und** Live-Anmeldung in einem.
Dunkles „Race-Control"-Design, drei Team-Lackierungen mit animierten GT3-Autos, kompletter
Rennkalender und – sobald Supabase verbunden ist – Anmeldung + Statistik.

## Dateien in diesem Ordner

| Datei | Zweck |
|-------|-------|
| `index.html` | Die komplette App (HTML + CSS + JS in einer Datei) |
| `assets/` | 7 Hintergrundbilder (lokal, damit es auch **offline** episch aussieht) |
| `supabase_schema.sql` | Datenbankschema für die Live-Features |
| `SETUP.md` | Diese Anleitung |
| `ASPL_Team_WebApp_Prompt.md` | Der ursprüngliche Bauauftrag |

> **Wichtig:** `index.html` und der Ordner `assets/` müssen **zusammen** bleiben. Verschiebst
> du die App, nimm `assets/` mit, sonst fehlen die Hintergrundbilder.

---

## Sofort loslegen (ohne alles weitere)

`index.html` doppelklicken → die App läuft im **Showcase-Modus**:

- 🏁 **Hero** mit Countdown zum nächsten Rennen
- 🏎️ **Teams** — Chronos Motorsport (rot), Omega Racing (navy), Academy (pink) mit Fahrer-Lineups,
  Auto-Modellen und je einem GT3 in Teamfarbe, das auf Klick „auf die Strecke" fährt
- 📅 **Rennkalender** — alle 8 Runden + Mid-Season-Pause, Streckenfakten beim Aufklappen,
  „Saison abspielen" mit Pace-Car
- 📊 **Pit Wall** — Anmeldung & Statistik (Platzhalter, bis Supabase verbunden ist)

Das genügt schon als komplette Saison-Übersicht. Für **An-/Abmeldung und Live-Statistik**
folgt der Supabase-Teil.

---

## Live-Features aktivieren (Supabase, kostenlos)

### 1. Projekt anlegen
1. Auf <https://supabase.com> registrieren → **New Project** (Name z.B. „ASPL", Region Frankfurt).

### 2. Datenbank einrichten
1. **SQL Editor → New query** → kompletten Inhalt von `supabase_schema.sql` einfügen → **Run**.
   (Legt die Tabellen `drivers`, `races`, `registrations`, `results` mit Policies an.)

### 3. Zugangsdaten holen
1. **Project Settings → API**: **Project URL** und **anon / public** Key kopieren.
   (Der anon-Key ist für den Browser gedacht und darf öffentlich sein — den `service_role`-Key niemals eintragen.)

### 4. In der App eintragen
`index.html` im Editor öffnen, oben im `<script>` den Konfig-Block ausfüllen:

```javascript
// ═══════════════════════════════════════
// KONFIGURATION – HIER ANPASSEN
// ═══════════════════════════════════════
const SUPABASE_URL      = 'https://abcdxyz.supabase.co';     // ← deine Project URL
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6...'; // ← dein anon public Key
const SEASON_HASHTAG    = '#ASPLS2';
```

Speichern, App neu laden. Die App **synchronisiert die 8 Rennen automatisch** in die
Datenbank (kein manuelles Anlegen nötig). Fahrer melden sich oben rechts mit ihrem Namen an
(kein Passwort) und können sich dann für das nächste Rennen ein-/austragen.

### Resultate & Punkte (Race Control)
Unten im Footer **„⚙ Race Control"** öffnet den Admin-Bereich: Status setzen, **Resultate eintragen**
(Punkte automatisch nach F1-System 25-18-15-12-10-8-6-4-2-1, +1 für die schnellste Runde in den Top 10),
Fahrer verwalten. Aus den Resultaten entsteht das Leaderboard mit Fahrerprofilen + Verlaufsgrafik.

---

## Online stellen (optional)
Da alles in einer Datei + `assets/` steckt, reicht ein statisches Hosting:
- **GitHub Pages** — Repo erstellen, `index.html` **und** `assets/` hochladen, Pages aktivieren.
- **Netlify** — den **ganzen Ordner** (mit `assets/`) auf <https://app.netlify.com/drop> ziehen.

---

## Hinweise
- **Bilder:** stammen von Unsplash (kostenlos, kommerziell nutzbar, keine Attribution nötig) und liegen lokal in `assets/`.
- **Sicherheit:** Identifikation läuft offen über den Namen (kein Login). Für ein kleines, vertrautes
  Team gedacht — jeder mit der URL kann Daten ändern. Für größere/öffentliche Nutzung echte
  Supabase-Auth + restriktivere RLS-Policies ergänzen.
- **Animationen** respektieren `prefers-reduced-motion` (System-Einstellung „Bewegung reduzieren").
