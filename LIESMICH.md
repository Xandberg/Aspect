# Feldblick

Offline-fähige Progressive Web App für Android: Fotos aufnehmen und dabei Position,
Höhe über NN und Blickrichtung festhalten – danach alles als Punkt mit Sichtkegel auf der Karte.

## Dateien

```
index.html                 die komplette App
sw.js                      Service Worker (Offline-Betrieb, Kachel-Cache)
manifest.webmanifest       Installationsdaten
icon-192.png / icon-512.png / icon-512-maskable.png
vendor/leaflet.js, leaflet.css, images/   Kartenbibliothek, lokal eingebunden
```

Es gibt keinen Build-Schritt und keine Abhängigkeiten. Ordner hochladen, fertig.

## Installation

Kamera, GPS und Kompass funktionieren im Browser nur über **HTTPS**. Eine Datei per
`file://` zu öffnen reicht nicht.

**Weg 1 – GitHub Pages (kostenlos, dauerhaft)**

1. Neues Repository anlegen, den Inhalt dieses Ordners hochladen (die Ordnerstruktur beibehalten).
2. Settings → Pages → Source: `main`, Ordner `/root` → Save.
3. Nach ein bis zwei Minuten erreichst du die App unter
   `https://<dein-name>.github.io/<repo>/`.

**Weg 2 – eigener Webspace**

Ordner per FTP in ein Verzeichnis mit HTTPS legen und die `index.html` aufrufen.

**Auf dem Handy installieren**

Adresse in Chrome für Android öffnen → Menü ⋮ → *App installieren* bzw. *Zum Startbildschirm
hinzufügen*. Danach startet Feldblick im Vollbild ohne Browserleiste und läuft ohne Netz.
Beim ersten Start einmal online sein, damit sich der Service Worker einrichtet.

## Erste Schritte

1. **Setup → Freigeben** antippen und Kamera, Standort und Sensoren erlauben.
   Standortzugriff bitte auf *Immer erlauben* und *Genauer Standort* stellen.
2. Den Kompass einmal kalibrieren: Handy in einer liegenden Acht bewegen, weg von
   Metall und Magnethüllen.
3. **Setup → Höhe abgleichen** einmal im Freien drücken, solange Netz da ist (siehe unten).
4. Auslöser drücken. Die Werte werden im Moment der Aufnahme eingefroren.

## Wie die Werte zustande kommen

**Position** aus dem GPS des Geräts, mit angezeigter Lagegenauigkeit. Unter freiem Himmel
typisch 3–8 m.

**Höhe über NN.** Android liefert die Höhe über dem WGS84-Ellipsoid, nicht über dem
Meeresspiegel. Der Unterschied heißt Geoid-Undulation N und beträgt in Deutschland etwa
45–48 m. Die App rechnet `Höhe ü. NN = GPS-Höhe − N`. Der Wert steht in den Einstellungen und
lässt sich mit *Höhe abgleichen* automatisch bestimmen: dabei wird die Geländehöhe deines
Standorts aus einem digitalen Höhenmodell abgefragt (braucht einmalig Netz) und daraus N
berechnet. Danach arbeitet die App wieder vollständig offline. Rechne mit einer
Höhengenauigkeit von grob ±10 m – GPS ist in der Vertikalen deutlich schwächer als in der Lage.

**Blickrichtung** aus Magnetometer und Lagesensoren. Berechnet wird die Achse der
Rückkamera, deshalb stimmt die Peilung in jeder Haltung – hochkant, quer oder schräg nach
oben. Zusätzlich wird die Neigung gespeichert. Angezeigt wird rechtweisend Nord.
Bleibt eine systematische Abweichung, lässt sie sich unter *Kompass-Korrektur* als festen
Zuschlag ausgleichen.

## Karte

Punkt und Sichtkegel je Aufnahme. Reichweite und Öffnungswinkel des Kegels sind im Setup
einstellbar und wirken sofort auf alle Aufnahmen. *Offline laden* speichert den aktuellen
Kartenausschnitt in drei Zoomstufen auf dem Gerät – vor einer Tour einmal über dem
Zielgebiet drücken, dann ist die Karte auch ohne Empfang da.

## Export

*Export* im Archiv erzeugt eine ZIP-Datei mit allen Fotos, `punkte.geojson` und `punkte.csv`.
Das GeoJSON enthält pro Aufnahme zwei Objekte: den Standpunkt und das Blickfeld als Polygon –
direkt in QGIS, Google Earth oder ArcGIS zu öffnen.

Jedes Foto trägt die Daten außerdem im EXIF-Kopf (GPSLatitude, GPSLongitude, GPSAltitude,
GPSImgDirection). Damit erkennen auch fremde Programme Ort und Blickrichtung ohne die
Begleitdateien.

## Datenhaltung

Alles bleibt auf dem Gerät (IndexedDB). Nichts wird hochgeladen. Unter *Setup → Speicher →
Dauerhaft* bittest du Android, den Speicher vor automatischem Aufräumen zu schützen –
empfehlenswert vor längeren Aufnahmereihen. Kartenkacheln stammen von OpenStreetMap;
bei starker Nutzung bitte die Tile Usage Policy beachten oder einen eigenen Kachelserver
in `index.html` eintragen.

## Grenzen

* Ohne freie Sicht zum Himmel gibt es keine brauchbare Höhe.
* Der Magnetkompass reagiert auf Autos, Zäune, Stativköpfe und Magnethüllen.
* iOS ist nicht das Ziel dieser App; Kompass und Kamera laufen dort teils anders.
