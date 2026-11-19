# Flipo

**Flipchart-Figuren zeichnen lernen.** Strich für Strich, Lektion für Lektion, direkt auf dem Handy.

Flipo ist eine Zeichen-App für alle, die auf Flipcharts und Whiteboards visualisieren wollen und dabei sicherer werden möchten. Jede Figur liegt blass als Vorlage unter dem Blatt. Man malt sie nach, Schritt für Schritt, mit Anleitung und Merkhilfe. Alles bleibt auf dem Handy. Kein Konto, kein Server, keine Werbung.

## Funktionen

- **Acht Lektionen, 48 Figuren:** Grundformen, Container und Rahmen, Pfeile, Figuren, Gesichter und Emotionen, Symbole (Klassiker, Arbeit und Alltag, Ziele und Aufbruch). Alle Figuren sind minimalistisch im Stil gängiger Visualisierungsbücher: Grundformen, offene Pfeilspitzen, Figuren ohne Hals und Gesicht, grauer Schatten rechts unten.
- **Schritt für Schritt:** Jede Figur hat drei bis sechs Schritte mit kurzer Anleitung. Die Vorlage zeigt den aktuellen Schritt kräftiger, erledigte Schritte blasser. Die Vorführung zeichnet den Schritt animiert vor.
- **Merkhilfen:** Zu jeder Figur gibt es eine Eselsbrücke (zum Beispiel „Licht von oben links, Schatten rechts unten“ oder „Kopf, Strich, Stern“).
- **Marker-Effekt:** Striche sind leicht durchscheinend, Überlappungen werden dunkler, eine Keilspitze trägt quer breiter auf als längs. Fünf Farben wie bei echten Flipchart-Markern: Schwarz, Rot, Grün, Blau und Grau für Schatten. Drei Strichstärken.
- **Kariertes Papier:** Feine, zurückhaltende Linien als Zeichengrund.
- **Rückmeldung:** Nach „Fertig“ vergleicht die App die Zeichnung mit der Vorlage (Deckung und Genauigkeit) und merkt sich den Bestwert. Ab 50 Prozent gilt die Figur als geübt.
- **Freies Blatt:** Zeichnen ohne Vorlage, zum Ausprobieren eigener Kombinationen.

## Aufbau

```
lib/
  model/        Figuren, Schritte, Striche, Zeichnung, Bewertung
  data/         Lektionen (eine Datei pro Lektion) und Fortschritt
  paint/        Marker-Rendering, Vorlagen-Painter, kariertes Papier
  widgets/      Zeichenfläche, Stifteablage, Vorschau, skizzenhafte Karten
  screens/      Start, Lektion, Übungsblatt
  theme/        Farben und Schrift
```

Figuren werden in einem 100 × 100 Raster als Polylinien beschrieben (`lib/data/lesson_*.dart`). Die Werkzeuge in `Shapes` und `Fig` liefern Linien, Kreise, Bögen, Bezierkurven, Wolken, Sterne, Zahnräder, Pfeilspitzen und Schatten. Eine neue Figur ist ein `Figure` mit `FigureStep`-Liste; eine neue Lektion eine `Lesson`, die in `lib/data/lessons.dart` eingetragen wird.

## APK installieren (Android)

Jeder Push baut eine APK über GitHub Actions.

1. Auf GitHub **Actions** öffnen, den neuesten Lauf „Build APK“ anklicken.
2. Unten bei **Artifacts** die Datei `flipo-apk-<nummer>` herunterladen und entpacken (eine `.apk`).
3. Die APK aufs Handy übertragen (z. B. per Download im Handy-Browser, USB oder Drive) und öffnen.
4. Android fragt einmalig nach „Installation aus unbekannten Quellen“ für die App, mit der du die APK öffnest. Erlauben, installieren.

Updates installieren sich über die alte Version, solange die APK mit demselben Schlüssel signiert ist. Dafür liegt ein Release-Keystore als GitHub Secret (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, Key-Alias `dagobert`, weil der Keystore aus dem Dagobert-Projekt weiterverwendet wird). Ohne Secret signiert GitHub mit einem Wegwerf-Key.

## Entwicklung

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Alle Figuren als Kontaktbögen rendern, um sie zu prüfen:

```bash
flutter test test/render_figures_test.dart --dart-define=RENDER_FIGURES=true --dart-define=RENDER_OUT=build/figures
```

Icons neu erzeugen nach Änderung der PNGs in `assets/icon/`: `dart run flutter_launcher_icons`.

Schrift: Patrick Hand (SIL Open Font License, siehe `assets/fonts/OFL.txt`).
