-- =====================================================================
--  Hangblick – Einrichtung der gemeinsamen Datenbank
--  Supabase → SQL Editor → alles einfügen → Run
-- =====================================================================

-- ---------- Tabelle ----------
create table if not exists public.sichtungen (
  id        uuid primary key,
  erstellt  timestamptz not null default now(),
  ts        timestamptz not null,
  lat       double precision not null,
  lon       double precision not null,
  acc       double precision,
  alt_msl   double precision,
  alt_ell   double precision,
  heading   double precision,
  tilt      double precision,
  kategorie text not null default 'sonst',
  notiz     text default '',
  autor     text,
  geheim    text not null,
  foto      text not null
);

create index if not exists sichtungen_ts_idx on public.sichtungen (ts desc);

-- Grobe Plausibilität, damit die Karte nicht durch Unsinn zerschossen wird
alter table public.sichtungen drop constraint if exists sichtungen_bereich;
alter table public.sichtungen add constraint sichtungen_bereich check (
  lat between -90 and 90 and lon between -180 and 180
  and (heading is null or heading between 0 and 360)
  and (alt_msl is null or alt_msl between -500 and 9000)
  and length(coalesce(notiz,'')) <= 400
  and length(coalesce(autor,'')) <= 24
);

-- ---------- Zugriffsrechte ----------
-- Wichtig: die Spalte "geheim" darf niemand lesen. Sie ist der Nachweis,
-- dass ein Beitrag vom eigenen Gerät stammt, und schützt vor fremdem Löschen.
alter table public.sichtungen enable row level security;

revoke all on public.sichtungen from anon;

grant select
  (id, ts, lat, lon, acc, alt_msl, alt_ell, heading, tilt, kategorie, notiz, autor, foto)
  on public.sichtungen to anon;

grant insert
  (id, ts, lat, lon, acc, alt_msl, alt_ell, heading, tilt, kategorie, notiz, autor, geheim, foto)
  on public.sichtungen to anon;

drop policy if exists "lesen"     on public.sichtungen;
drop policy if exists "schreiben" on public.sichtungen;

create policy "lesen"     on public.sichtungen for select to anon using (true);
create policy "schreiben" on public.sichtungen for insert to anon with check (true);

-- Kein update, kein delete: ohne Policy geht beides nicht.

-- ---------- Löschen nur mit passendem Geheimnis ----------
create or replace function public.sichtung_loeschen(p_id uuid, p_geheim text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  delete from public.sichtungen where id = p_id and geheim = p_geheim;
  get diagnostics n = row_count;
  return n > 0;
end $$;

revoke all on function public.sichtung_loeschen(uuid, text) from public;
grant execute on function public.sichtung_loeschen(uuid, text) to anon;

-- ---------- Speicher für die Fotos ----------
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do update set public = true;

drop policy if exists "fotos lesen"      on storage.objects;
drop policy if exists "fotos hochladen"  on storage.objects;

create policy "fotos lesen"     on storage.objects
  for select to anon using (bucket_id = 'fotos');
create policy "fotos hochladen" on storage.objects
  for insert to anon with check (bucket_id = 'fotos');

-- Kein delete auf storage.objects: Bilddateien bleiben nach dem Löschen eines
-- Beitrags als Waise liegen. Sie sind dann über die App nicht mehr auffindbar.
-- Zum endgültigen Aufräumen: Supabase → Storage → fotos.

-- =====================================================================
--  Nützliche Abfragen für später
-- =====================================================================
-- Was ist in den letzten 24 Stunden reingekommen?
--   select ts, kategorie, autor, round(alt_msl) as hoehe, notiz
--   from sichtungen where ts > now() - interval '24 hours' order by ts desc;
--
-- Beitrag von Hand entfernen:
--   delete from sichtungen where id = '....';
--
-- Alles älter als ein Jahr wegräumen:
--   delete from sichtungen where ts < now() - interval '1 year';

-- =====================================================================
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

-- Achtung: die Bilddateien im Storage bleiben dabei liegen. Sie sind über die
-- App nicht mehr auffindbar, belegen aber weiter Platz. Zum echten Freiräumen
-- unter Supabase → Storage → fotos → nach Datum sortieren und löschen.
-- =====================================================================
--  Nachtrag zu SERVER-EINRICHTEN.sql
--  Nötig, damit Bedingung und Notiz auch nach dem Teilen noch
--  geändert werden können. Einmal im SQL Editor ausführen.
--  Ohne diesen Schritt läuft alles andere weiter; Änderungen an
--  bereits geteilten Beiträgen bleiben dann nur lokal.
-- =====================================================================

create or replace function public.sichtung_aendern(
  p_id uuid, p_geheim text, p_kategorie text, p_notiz text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  update public.sichtungen
     set kategorie = coalesce(nullif(p_kategorie,''), kategorie),
         notiz     = left(coalesce(p_notiz,''), 400)
   where id = p_id and geheim = p_geheim;
  get diagnostics n = row_count;
  return n > 0;
end $$;

revoke all on function public.sichtung_aendern(uuid, text, text, text) from public;
grant execute on function public.sichtung_aendern(uuid, text, text, text) to anon;
