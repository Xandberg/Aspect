# Gemeinsame Datenbank einrichten

Ohne diesen Schritt läuft Aspect Conditions trotzdem — dann eben rein lokal, ohne Austausch.
Für den gemeinsamen Betrieb brauchst du ein Supabase-Projekt. Kostenlos, ohne Kreditkarte,
Dauer etwa zehn Minuten.

## 1. Projekt anlegen

1. https://supabase.com → *Start your project* → mit GitHub anmelden.
2. *New project*. Name `aspect`, ein Datenbank-Passwort setzen (brauchst du später kaum,
   trotzdem notieren), Region **Frankfurt (eu-central-1)**.
3. Zwei bis drei Minuten warten, bis das Projekt bereitsteht.

## 2. Tabelle und Rechte anlegen

1. Links im Menü *SQL Editor* → *New query*.
2. Den kompletten Inhalt von `SERVER-EINRICHTEN.sql` hineinkopieren.
3. *Run*. Unten muss „Success" stehen.

Das legt die Tabelle `sichtungen`, den Foto-Speicher und die Zugriffsregeln an. Die Regeln
erlauben jedem Lesen und Anlegen, aber niemandem das Ändern oder Löschen fremder Beiträge.

## 3. Zugangsdaten in die App eintragen

1. Links unten *Project Settings* → *API Keys* (bei manchen Konten *Data API*).
2. Du brauchst zwei Werte:
   - **Project URL**, etwa `https://abcdefghijkl.supabase.co`
   - **anon public** key, ein sehr langer Text, der mit `eyJ` beginnt
3. In der `index.html` ganz oben im Skriptteil stehen diese Zeilen:

```js
const CLOUD_DEFAULT = {
  url: "",   // z. B. https://abcdefghijkl.supabase.co
  key: ""    // der öffentliche anon-Key
};
```

Beide Werte zwischen die Anführungszeichen setzen, Datei speichern, ins Repo hochladen.
Am Handy geht das direkt auf GitHub: `index.html` öffnen → Stift-Symbol → die zwei Zeilen
ändern → *Commit changes*.

Der anon-Key ist zum Veröffentlichen gedacht — er steht zwangsläufig in jeder Kopie der App.
Was er darf, bestimmen allein die Regeln aus Schritt 2.

## 4. Ausprobieren

App neu laden, *Setup* → *Beiträge teilen* einschalten und ein Kürzel eintragen. Ein Foto
machen, im Nachbereitungs-Fenster eine Bedingung wählen und *Sichern & teilen* drücken.
Unter *Setup → Abgleich* muss danach „1 geteilt" stehen. Auf einem zweiten Gerät dieselbe
Adresse öffnen, Karte → *Laden* — der Beitrag muss auftauchen.

## Was du wissen solltest

**Alles ist öffentlich.** Jeder, der die Adresse der App kennt, sieht alle Beiträge und kann
selbst welche anlegen. Es gibt keine Anmeldung und keine Prüfung. Für Bedingungsmeldungen
ist das gewollt; lade nichts hoch, das Personen erkennbar zeigt oder das du nicht auf einer
Anschlagtafel sehen möchtest.

**Löschen** geht nur von dem Gerät, das den Beitrag angelegt hat — dafür merkt sich die App
lokal ein Geheimnis. Löschst du die App-Daten, bleiben deine geteilten Beiträge stehen und
lassen sich nur noch im Supabase-Dashboard entfernen.

**Kontingent** (Stand Juli 2026). Kostenlos sind 1 GB Dateispeicher, 500 MB Datenbank und
5 GB Egress pro Monat, maximal 50 MB je Datei. Aspect verkleinert Fotos vor dem Hochladen auf
1600 px, das sind rund 300 KB pro Bild — also **etwa 3000 geteilte Fotos**. Die Datenbankzeilen
selbst sind winzig; 500 MB reichen für Millionen Einträge.

Der Egress ist meist die erste Grenze: 5 GB im Monat entsprechen ungefähr 15.000 geöffneten
Vollbildern. Miniaturen auf der Karte kosten nur etwa 15 KB und fallen kaum ins Gewicht.
Supabase meldet sich per E-Mail, sobald 80 % eines Limits erreicht sind.

**Pause.** Projekte ohne API-Zugriffe werden nach einer Woche automatisch pausiert. Bei
saisonaler Nutzung also nach jeder Sommerpause einmal im Dashboard aufwecken.

**Aufräumen.** Am Ende von `SERVER-EINRICHTEN.sql` steht ein fertiger pg_cron-Auftrag, der
wöchentlich alles löscht, was älter als ein Jahr ist. Für Bedingungsmeldungen ist alles
jenseits einer Saison ohnehin nur noch Archiv. Die Bilddateien selbst bleiben dabei liegen
und müssen gelegentlich von Hand im Storage-Bereich entfernt werden.

**Missbrauch.** Sollte jemand die Datenbank zumüllen, kannst du im Supabase-Dashboard unter
*Authentication → Rate Limits* bremsen oder die Schreibregel abschalten:
`drop policy "schreiben" on public.sichtungen;` — Lesen läuft dann weiter.
