-- =====================================================================
--  Beiträge von Hand entfernen  (Supabase → SQL Editor)
--  Nur du als Betreiber kannst das. In der App geht es nicht.
-- =====================================================================

-- 1. Ansehen, was da ist. Die Spalte foto nennt den Dateinamen im Speicher.
select ts, kategorie, autor, round(alt_msl) as hoehe, left(notiz,60) as notiz, foto, id
  from sichtungen
 order by ts desc
 limit 50;

-- 2. Einen einzelnen Beitrag löschen
delete from sichtungen where id = 'HIER-DIE-ID-EINSETZEN';

-- 3. Alles von einem Verfasser
delete from sichtungen where autor = 'Kürzel';

-- 4. Alle Beiträge ohne Verfasserangabe aus den letzten 24 Stunden
delete from sichtungen where autor is null and ts > now() - interval '24 hours';

-- 5. Ein Gebiet leeren (grober Rahmen aus zwei Eckpunkten)
delete from sichtungen
 where lat between 47.0 and 47.5
   and lon between 11.0 and 11.8;

-- 6. Restlos alles
-- truncate table sichtungen;

-- =====================================================================
--  Dateinamen der zu löschenden Bilder VORHER notieren, sonst bleiben
--  sie als Waisen im Speicher liegen:
--    select foto from sichtungen where <deine Bedingung>;
--  Danach unter Storage → fotos → voll bzw. mini die Dateien entfernen.
-- =====================================================================
