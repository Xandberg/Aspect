-- Zeigt, was bereits eingerichtet ist. Ändert nichts.
select 'Tabelle sichtungen' as objekt,
       count(*)::text || ' Spalten' as status
  from information_schema.columns
 where table_schema = 'public' and table_name = 'sichtungen'
union all
select 'Funktion ' || p.proname,
       'vorhanden'
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public' and p.proname in ('sichtung_loeschen','sichtung_aendern')
union all
select 'Bucket ' || id, case when public then 'öffentlich' else 'privat' end
  from storage.buckets where id = 'fotos'
union all
select 'Regel ' || policyname, cmd::text
  from pg_policies where schemaname = 'public' and tablename = 'sichtungen'
order by 1;
