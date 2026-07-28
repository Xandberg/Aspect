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
