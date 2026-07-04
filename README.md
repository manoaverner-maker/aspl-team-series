# ASPL · Team Series · Saison 2

Offline-fähige Single-File Web-App für die **ASPL Team Series (Saison 2)** — GT3-Sim-Racing.
Dunkles „Race-Control"-Design mit drei Team-Lackierungen, animierten GT3-Autos, komplettem
Rennkalender und — sobald Supabase verbunden ist — Live-Anmeldung und Statistik.

**🔗 Live:** https://manoaverner-maker.github.io/aspl-team-series/

## Inhalt
- **Teams** — Chronos Motorsport (rot), Omega Racing (navy), Academy (pink) mit Fahrer-Lineups & GT3 in Teamfarbe
- **Rennkalender** — alle 8 Runden + Mid-Season-Pause, Streckenfakten, „Saison abspielen" mit Pace-Car
- **Pit Wall** — Anmeldung & Statistik (aktiv, sobald Supabase verbunden ist)

## Nutzung
Einfach `index.html` öffnen — läuft sofort im **Showcase-Modus** (offline).
Für **Live-Anmeldung & Statistik** die Schritte in [`SETUP.md`](SETUP.md) befolgen (kostenloses Supabase-Projekt, Zugangsdaten in `index.html` eintragen).

## Technik
Vanilla HTML/CSS/JS, keine Build-Tools. Hintergrundbilder liegen lokal in `assets/` (Unsplash, frei nutzbar).
Optionales Backend: [Supabase](https://supabase.com). Datenbankschema in [`supabase_schema.sql`](supabase_schema.sql).

---

*Manoa Verner · ASPL · Saison 2 · #ASPLS2*
