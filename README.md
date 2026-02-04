<div align="center">

# Toolbox  🛠️

Lightweight collection of small Flutter UI helpers and utilities.

</div>

## Overview

`toolbox` groups together a few reusable pieces you often end up re‑writing in many apps:

* A titled border container with a cut border segment to display a title (optionally with an icon) drawn via `CustomPainter`.
* Minimal UI spacing helpers (`hSpacer`, `vSpacer`) and an explicit zero‑sized widget (`voidWidget`).
* A flexible dialog builder with predefined styles (info, warning, error, question, remove) + custom actions, optional tagging to avoid re‑showing a dialog, and background blur / color logic.

The goal: keep API surfaces tiny, explicit, and easy to test.

## Contents

### 1. DialogBuilder (file: `dialogs.dart`)
Fluent style API to show modal dialogs with a consistent look & behavior.

Key capabilities:

* `ok()`, `warning()`, `error()`, `yesNo()`, `removeCancel()` convenience methods.
* `custom()` for arbitrary button sets (each a `DialogButton(label, value, isDefault)`).
* Automatic icon / color selection per `DialogType` (info, error, warning, question, remove, none).
* Optional `tag` string: when provided and the user checks "Ne plus afficher", subsequent calls with same tag will silently return `null` (preventing duplicate dialogs).
* Optional `altMessage` (String or Widget) shown under the main message (allows richer inline formatting, icons, etc.).
* Background blur toggle (`blurBackground`) and colored barrier when `withBackgroundColor` is true.
* Dismissibility decided by explicit `dimissible` or by `DialogType.dimissible` fallback.
* Button order shuffle via `shuffleButtons` (e.g. to prevent muscle memory on destructive confirmations).

Return value: each show method returns `Future<T?>` resolving to the tapped button value (or `null` if dismissed / suppressed by tag).

Usage (basic):
```dart
final bool? result = await DialogBuilder<bool>(
	context: context,
	message: 'Delete this item?',
).removeCancel();
if (result == true) { /* proceed */ }
```

Custom dialog:
```dart
final int? temp = await DialogBuilder<int>(
	context: context,
	message: 'Office temperature?',
	altMessage: 'Select how you feel.',
	icon: const Icon(Icons.ac_unit, color: Colors.blue, size: 40),
).custom(
	type: DialogType.question,
	dialogButtons: [
		DialogButton(label: 'Cold', value: 1),
		DialogButton(label: 'Perfect', value: 2, isDefault: true),
		DialogButton(label: 'Hot', value: 3),
	],
);
```

Tag suppression:
```dart
await DialogBuilder<bool>(
	context: context,
	message: 'Show this only once',
	tag: 'unique_dialog',
).ok();
// If user checks the "Ne plus afficher" checkbox, further calls return null without UI.
```

### 2. TitleBorderBox (file: `titleborderbox.dart`)
`TitleBorderBox` draws a rounded rectangle whose top border segment is cut out to host a title (String) or an icon + title combination. It uses a `CustomPainter` (`TitledBorderPainter`) to create the gap and paint the text.

Highlights:
* Accepts `title` as `String` or a custom `Widget` (widget titles are laid out inside but not painted in the border gap; the gap is skipped if title is null / empty).
* Optional `icon` (`Icon`) placed directly before the title text with configurable `iconSpacing`.
* Style options: `borderColor`, `backgroundColor`, `borderRadius`, `borderWidth`, `contentPadding`, `titleStyle`.
* Fallback factory `TitleBorderBox.none()` for an empty box (renders a minimal structure; consider plain `Container` if truly no decoration needed).

Example:
```dart
TitleBorderBox(
	title: 'Profile',
	icon: const Icon(Icons.person, size: 18, color: Colors.blue),
	child: Column(
		crossAxisAlignment: CrossAxisAlignment.start,
		children: const [Text('Name: John'), Text('Role: Admin')],
	),
)
```

### 3. Spacing & Utility Widgets (file: `widgets.dart`)
* `voidWidget()` -> explicit `SizedBox.shrink()` alias (semantic clarity when returning an "empty" branch).
* `hSpacer(double w)` -> horizontal `SizedBox(width: w)`.
* `vSpacer(double h)` -> vertical `SizedBox(height: h)`.

These helpers trade a tiny abstraction for more readable build trees.

### 4. Platform Utilities (file: `utils.dart`)
Static predicates that wrap `kIsWeb` + `defaultTargetPlatform` so call sites remain concise and testable via the optional `forceValue` parameter.

Available checks:
* `OS.isMobile()`
* `OS.isWeb()`
* `OS.isDesktop()`
* `OS.isAndroid()`
* `OS.isIOS()`
* `OS.isLinux()`
* `OS.isWindows()`

All accept an optional override: `OS.isWeb(true)` for forced logic in tests.

### 5. Barrel Export (file: `toolbox.dart`)
Single entry point re‑exporting: `utils.dart`, `titleborderbox.dart`, `widgets.dart`, `dialogs.dart`.

```dart
import 'package:toolbox/toolbox.dart';
```

### 6. String extensions (file: `extensions.dart`)

The `extensions.dart` file adds convenient extension methods on `String` to simplify common transformations and parsing. They can be called directly on `String` instances.

Key helpers provided:

* `toSql()` — Escapes single quotes and backslashes and wraps the string in single quotes for safe inclusion in SQL statements. Returns a `String?`.
* `toDouble()` — Parses the string to `double`, accepting either `,` or `.` as decimal separators. Returns `double?`.
* `toInt()` — Parses the string to `int`. Returns `int?`.
* `right(int len)` / `left(int len)` — Return the rightmost / leftmost `len` characters (clamped to the string length).
* `concat(String append)` — Appends `append` only when the receiver is not empty.
* `capitalizeFirstLetter()` — Capitalizes the first character and lowercases the rest of the string.
* `capitalizeWords()` — Capitalizes the first letter of each word and lowercases other letters; treats spaces and hyphens as word separators.

Usage examples:

```dart
final raw = "O'Hara\\path";
final sql = raw.toSql(); // -> `'O''Hara\\path'`

final value = '1,23'.toDouble(); // -> 1.23
final n = '42'.toInt(); // -> 42

final name = 'john doe'.capitalizeWords(); // -> 'John Doe'
final first = 'hello'.left(2); // -> 'he'
final last = 'hello'.right(2); // -> 'lo'

final s = ''.concat(', world'); // -> '' (unchanged)
final t = 'Hi'.concat(', there'); // -> 'Hi, there'
```

Notes and edge cases:

* `toSql()` performs simple escaping by doubling single quotes and escaping backslashes. It returns `null` only if the receiver is `null` (the extension operates on non-nullable `String` in this package; adapt if using nullable inputs).
* `toDouble()` and `toInt()` use `double.parse` / `int.parse` and will throw a `FormatException` for invalid inputs. Consider wrapping calls in `try/catch` or validating input first if user-provided strings are untrusted.
* `capitalizeWords()` uses rune iteration and treats both spaces and hyphens as word boundaries; it will lowercase other letters.

This extension file is small and focused — a handy place to keep these common manipulations consistent across apps.


## Installation

dependencies:	
    toolbox:
        git:
            url: https://github.com/cdesbois/toolbox
            ref: main

This package ships with widget & unit tests (see `test/`). Run:
```bash
flutter test
```

## Design Notes

* Favors explicit parameters over hidden theme coupling.
* Keeps state minimal; dialog suppression uses a simple in‑memory `Map<String,bool>` (`checked`) – adapt if you need persistence.
* `TitleBorderBox` relies on calculated text metrics to leave a precise border gap.

## Roadmap Ideas

* Persist dialog suppression (e.g. via `SharedPreferences`).
* Add light/dark adaptive styles for dialogs & TitleBorderBox.
* Provide layout examples / screenshots in README.

## Contributing

Issues & PRs welcome. Please include tests for behavioral changes.

## License

Add your license text in `LICENSE` (currently placeholder).

---

Made with simplicity in mind.
