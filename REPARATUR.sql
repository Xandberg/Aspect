-- =====================================================================
--  Reparatur: die beiden Funktionen nachtragen
--  Diesen Block ALLEIN in den SQL Editor einfügen und ausführen.
--  Mehrfaches Ausführen schadet nicht.
-- =====================================================================

-- Löschen nur mit passendem Geheimnis
create or replace function public.sichtung_loeschen(p_id uuid, p_geheim text)
returns boolean
language plpgsql
security definer
set search_path = public
as $fn_del$
declare n int;
begin
  delete from public.sichtungen where id = p_id and geheim = p_geheim;
  get diagnostics n = row_count;
  return n > 0;
end
$fn_del$;

-- Bedingung und Notiz nachträglich ändern, ebenfalls nur mit Geheimnis
create or replace function public.sichtung_aendern(
  p_id uuid, p_geheim text, p_kategorie text, p_notiz text)
returns boolean
language plpgsql
security definer
set search_path = public
as $fn_upd$
declare n int;
begin
  update public.sichtungen
     set kategorie = coalesce(nullif(p_kategorie, ''), kategorie),
         notiz     = left(coalesce(p_notiz, ''), 400)
   where id = p_id and geheim = p_geheim;
  get diagnostics n = row_count;
  return n > 0;
end
$fn_upd$;

grant execute on function public.sichtung_loeschen(uuid, text) to anon;
grant execute on function public.sichtung_aendern(uuid, text, text, text) to anon;
