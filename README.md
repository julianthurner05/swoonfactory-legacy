# Swoon Factory – Legacy-Website

Nachbau von swoonfactory.jimdoweb.com, selbst gehostet auf Cloudflare Workers unter **swoonfactory.com**.
Reines HTML und CSS: kein Framework, kein JavaScript, kein Build-Schritt.

## Aufbau

```
public/                       alles, was online geht
  index.html                  Home
  services/ studio/ clients/ about/
  contact/impressum-offenlegung/   Impressum + Datenschutz
  contact/terms-conditions/        AGB-Download
  404.html
  css/style.css               Gestaltung (Farben oben in :root)
  fonts/fonts.css             Schrift – nur hier ändern
  images/  downloads/agb.pdf
  _redirects                  alte Jimdo-Adressen -> neue Seiten
  _headers                    Sicherheits- und Cache-Header
originals/                    unveränderte Downloads von Jimdo (nicht online)
wrangler.jsonc                Cloudflare-Konfiguration
```

Die Seitenadressen sind dieselben wie bei Jimdo (`/services/`, `/studio/` …), `/about-1/` und die
übrigen Jimdo-Pfade leitet `_redirects` weiter.

## Bearbeiten

- Texte direkt in den HTML-Dateien ändern. Kopf- und Fußzeile stehen in allen 8 HTML-Dateien gleich –
  eine Änderung dort in allen Dateien machen.
- Schrift: `public/fonts/fonts.css` (Anleitung steht in der Datei).
- Bilder: neue Bilder am besten unter neuem Dateinamen ablegen (sie werden eine Woche gecacht).
- Lokal ansehen: `npx wrangler dev`, dann http://localhost:8787

## Mit Cloudflare verbinden

Workers & Pages → Create → Import a repository → `swoonfactory-legacy`.
Build command leer lassen, Deploy command `npx wrangler deploy`, Production branch `main`.
Jeder Push auf `main` geht danach automatisch online.

## Domain swoonfactory.com umstellen

Achtung E-Mail: `studio@swoonfactory.com` läuft über netcup. Die Einträge `MX`, `mail`, `autodiscover`,
`autoconfig` und die `TXT`/SPF-Einträge unbedingt stehen lassen.

1. DNS: nur den `A`-Eintrag für `swoonfactory.com` (Name `@`, zeigt auf die netcup-Platzhalterseite) löschen.
2. Worker → Settings → Domains & Routes → Add → Custom domain → `swoonfactory.com`.
3. www → ohne www: DNS-Eintrag `www` auf „Proxied“ (orange Wolke) stellen, dann
   Rules → Redirect Rules → Vorlage „Redirect from WWW to root“ (301).
4. SSL/TLS → Edge Certificates → „Always Use HTTPS“ einschalten.

## Alte Jimdo-Seite

Jimdo bietet keine echte Weiterleitung. Im Jimdo-Editor in die Fußzeile (Bereich mit Adresse –
erscheint auf allen Seiten) ein Element „Widget/HTML“ mit diesem Inhalt einfügen:

```html
<p>Die Swoon Factory ist umgezogen: <a href="https://swoonfactory.com/">swoonfactory.com</a></p>
<script>
  // Nur Besucher weiterleiten, nicht im Jimdo-Editor. Notausgang: ?bleiben an die Adresse hängen.
  if (document.body.classList.contains('cc-pagemode-default') && !(window.jimdoData && jimdoData.cstok) && location.search.indexOf('bleiben') < 0) {
    location.replace('https://swoonfactory.com' + location.pathname);
  }
</script>
```

Sobald swoonfactory.com in der Google Search Console steht (Sitemap: `/sitemap.xml`), kann die
Jimdo-Seite gelöscht werden.

## Hinweise

- Die Datenschutzerklärung ist unverändert von Jimdo übernommen. Sie nennt Google Analytics,
  Cookies und Facebook-Plugins – die neue Seite verwendet nichts davon (nur einfache Teilen-Links).
  Bitte inhaltlich prüfen und anpassen.
- Die Content-Security-Policy in `_headers` erlaubt kein JavaScript. Cloudflare-Funktionen, die
  Skripte einfügen (Web Analytics, Email Obfuscation, Rocket Loader), würden blockiert – dann
  `_headers` anpassen.
