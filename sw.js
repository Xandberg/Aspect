/* Aspect Conditions – Service Worker */
const SHELL = "aspect-shell-v8";
const TILES = "aspect-tiles";
const MEDIA = "aspect-media";

const FILES = ["./", "./index.html", "./manifest.webmanifest",
  "./icon-192.png", "./icon-512.png", "./icon-512-maskable.png"];

self.addEventListener("install", e =>
  e.waitUntil(caches.open(SHELL).then(c => c.addAll(FILES)).then(() => self.skipWaiting())));

self.addEventListener("activate", e =>
  e.waitUntil(caches.keys()
    .then(k => Promise.all(k.filter(n => ![SHELL, TILES, MEDIA].includes(n)).map(n => caches.delete(n))))
    .then(() => self.clients.claim())));

async function cacheFirst(req, cacheName) {
  const cache = await caches.open(cacheName);
  const hit = await cache.match(req);
  if (hit) return hit;
  try {
    const res = await fetch(req);
    if (res.ok || res.type === "opaque") cache.put(req, res.clone());
    return res;
  } catch (err) {
    return new Response("", { status: 504 });
  }
}

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET") return;

  // Kartenkacheln
  if (url.hostname.endsWith("tile.openstreetmap.org"))
    return e.respondWith(cacheFirst(e.request, TILES));

  // Geteilte Fotos: einmal geladen, danach auch offline sichtbar
  if (url.pathname.includes("/storage/v1/object/public/"))
    return e.respondWith(cacheFirst(e.request, MEDIA));

  // Datenbank und Höhenmodell immer frisch holen
  if (url.pathname.startsWith("/rest/v1/") || url.hostname.includes("open-meteo.com")) return;

  // App-Hülle
  e.respondWith(caches.open(SHELL).then(async cache => {
    const hit = await cache.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(res => {
      if (res.ok && url.origin === location.origin) cache.put(e.request, res.clone());
      return res;
    }).catch(() => hit);
    return hit || net;
  }));
});
