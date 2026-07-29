-- =====================================================================
--  Nachtrag: Bildwinkel je Aufnahme speichern
--  Ab Version 4.2.0 gehoert der Oeffnungswinkel zur Aufnahme, nicht mehr
--  zur Anzeige. Einmal im SQL Editor ausfuehren.
--  Ohne diesen Schritt laeuft alles weiter; geteilte Beitraege werden dann
--  bei anderen mit deren eigener Einstellung gezeichnet.
-- =====================================================================

alter table public.sichtungen add column if not exists fov double precision;

alter table public.sichtungen drop constraint if exists sichtungen_fov;
alter table public.sichtungen add constraint sichtungen_fov
  check (fov is null or fov between 0 and 360);

-- Spaltenrechte muessen die neue Spalte ausdruecklich einschliessen
grant select
  (id, ts, lat, lon, acc, alt_msl, alt_ell, heading, tilt, fov, kategorie, notiz, autor, foto)
  on public.sichtungen to anon;

grant insert
  (id, ts, lat, lon, acc, alt_msl, alt_ell, heading, tilt, fov, kategorie, notiz, autor, geheim, foto)
  on public.sichtungen to anon;

-- Bestehende Beitraege auf einen sinnvollen Wert setzen
update public.sichtungen set fov = 65 where fov is null;
