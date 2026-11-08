# Dagobert

**Erst merken, dann entscheiden.** Dagobert ist eine Flutter-App gegen Impulskäufe.

Die Idee stammt aus *Happy Money* (Elizabeth Dunn, Michael Norton): Nicht wie viel du ausgibst entscheidet über dein Glück, sondern wie. Dagobert hilft, Geld in Zeit, Erlebnisse, Nähe, Treats und Vorfreude zu verwandeln.

Alles bleibt auf dem Handy. Kein Konto, kein Server, keine Werbung.

## Funktionen

- **Merkliste:** Wünsche eintragen statt sofort kaufen. Jede Karte zeigt Preis, Netto-Arbeitsstunden, Wartezeit und einen Reifering bis zur nächsten Erinnerung. Mit Link zum Produkt.
- **Erinnerungen:** 24 h, 3 Tage, 7 Tage, 2 Wochen oder 1 Monat. Die Vorauswahl richtet sich nach den Arbeitsstunden. Push-Benachrichtigungen kommen nur im Zeitfenster (Standard 9 bis 20 Uhr) und haben die Aktionen *Verzichten* und *Später erinnern*.
- **Brauche ich / Will ich:** Bei echtem Bedarf geht es nicht um *ob*, sondern um *wie*. Der Check bekommt dann drei Zusatzfragen (Reparieren? Folgekosten? Lieferung?), der Timer bleibt kurz.
- **5-Fragen-Check:** Zeit, Geschichte, Nähe, Treat, Vorfreude. Ja / Teils / Nein. Drei oder mehr Punkte: kluge Ausgabe. Null: stille Leckage. Dazu ein Kosten-pro-Nutzung-Rechner.
- **Wunsch-Thermometer:** Beim Merken und im Entscheidungsmoment. „Vor 7 Tagen: 4 von 5. Heute: 2 von 5. Der Wunsch kühlt ab.“
- **Tresor:** Alles, worauf du bewusst verzichtet hast, mit Münzflug in den Geldsack, Sparziel, Monatsbalken, Meilensteinen und dem häufigsten Auslöser.
- **Teilen-Menü:** Link aus Browser oder Shop-App an Dagobert teilen, der Wunsch ist vorbefüllt.
- **Sicherung:** Export und Import als JSON.

## APK installieren (Android)

Jeder Push baut eine APK über GitHub Actions.

1. Auf GitHub **Actions** öffnen, den neuesten Lauf „Build APK“ anklicken.
2. Unten bei **Artifacts** die Datei `dagobert-apk-<nummer>` herunterladen und entpacken (eine `.apk`).
3. Die APK aufs Handy übertragen (z. B. per Download im Handy-Browser, USB oder Drive) und öffnen.
4. Android fragt einmalig nach „Installation aus unbekannten Quellen“ für die App, mit der du die APK öffnest (Browser oder Dateimanager). Erlauben, installieren.

Updates installieren sich über die alte Version, solange die APK mit demselben Schlüssel signiert ist (siehe unten).

## Signaturschlüssel einrichten (einmalig)

Ohne eigenen Schlüssel signiert GitHub jede APK mit einem Wegwerf-Key, und Updates lassen sich nicht über die alte Version installieren. Darum liegt ein Release-Keystore als **GitHub Secret**:

1. Repository → **Settings → Secrets and variables → Actions → New repository secret**.
2. Zwei Secrets anlegen:
   - `KEYSTORE_BASE64`: der Keystore als Base64-Text (`base64 -w0 dagobert-release.jks`).
   - `KEYSTORE_PASSWORD`: das Passwort des Keystores (Key-Alias ist `dagobert`, Key-Passwort = Store-Passwort).
3. Den Keystore zusätzlich **außerhalb von GitHub sichern** (Passwort-Manager, verschlüsselte Festplatte). Geht er verloren, muss die App deinstalliert werden, und die Daten sind weg.

Lokal lässt sich mit `android/key.properties` signieren (nicht committen):

```
storeFile=dagobert-release.jks
storePassword=…
keyAlias=dagobert
keyPassword=…
```

## Entwicklung

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Icons neu erzeugen nach Änderung der SVGs in `assets/icon/`: PNGs rendern, dann `dart run flutter_launcher_icons`.

## Technik

- Flutter (stable), Riverpod 3 ohne Codegen, Hive CE mit JSON-Einträgen und `schemaVersion`, `flutter_local_notifications` mit inexakten Alarmen und Boot-Receiver, `receive_sharing_intent`, `intl` (de_DE).
- Schrift: Plus Jakarta Sans (OFL), als Asset gebündelt.
- Farben: Dukaten-Orange `#E2711D`, Kupfer `#B85A12` (Text-Buttons, WCAG AA), Taler-Gold `#D9A425`, Warmweiß `#FFF8F1`, Espresso `#2A2118`.
