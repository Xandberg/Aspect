/* Feldblick – Service Worker
   Hülle: fest zwischengespeichert. Kartenkacheln: bei Bedarf, dauerhaft. */
const SHELL = "feldblick-shell-v1";
const TILES = "feldblick-tiles";

const FILES = [
  "./", "./index.html", "./manifest.webmanifest",
  "./icon-192.png", "./icon-512.png", "./icon-512-maskable.png"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(SHELL).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== SHELL && k !== TILES).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET") return;

  // Kartenkacheln: erst Cache, sonst Netz und ablegen
  if (url.hostname.endsWith("tile.openstreetmap.org")) {
    e.respondWith(caches.open(TILES).then(async cache => {
      const hit = await cache.match(e.request);
      if (hit) return hit;
      try {
        const res = await fetch(e.request);
        cache.put(e.request, res.clone());
        return res;
      } catch (err) {
        return new Response("", { status: 504 });
      }
    }));
    return;
  }

  // Höhenmodell nie aus dem Cache beantworten
  if (url.hostname.includes("open-meteo.com")) return;

  // App-Hülle: erst Cache, im Hintergrund auffrischen
  e.respondWith(caches.open(SHELL).then(async cache => {
    const hit = await cache.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(res => {
      if (res.ok && url.origin === location.origin) cache.put(e.request, res.clone());
      return res;
    }).catch(() => hit);
    return hit || net;
  }));
});
