--  Aufräumen: alte Beiträge automatisch entfernen
--  Einmal ausführen, dann läuft es von selbst.
-- =====================================================================
create extension if not exists pg_cron;

-- Jeden Montag um 03:00 UTC alles löschen, was älter als ein Jahr ist.
-- Zeitraum nach Bedarf ändern: '6 months', '2 years', …
select cron.schedule(
  'aspect-aufraeumen',
  '0 3 * * 1',
  $$ delete from public.sichtungen where ts < now() - interval '1 year' $$
);

-- Auftrag wieder entfernen:  select cron.unschedule('aspect-aufraeumen');
-- Laufende Aufträge ansehen:  select * from cron.job;

-- Diesen Block bitte separat ausführen, nicht zusammen mit der Haupt-Datei.
-- Falls pg_cron nicht verfügbar ist, einfach weglassen.

-- Achtung: die Bilddateien im Storage bleiben dabei liegen. Sie sind über die
-- App nicht mehr auffindbar, belegen aber weiter Platz. Zum echten Freiräumen
-- unter Supabase → Storage → fotos → nach Datum sortieren und löschen.
-- =====================================================================