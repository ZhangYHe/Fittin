## 1. Implementation

- [x] 1.1 Add a repeatable tool that rewrites unsafe Isar-generated schema/index identifiers to JavaScript-safe integer literals.
- [x] 1.2 Apply the tool to the checked-in `lib/src/data/models/*.g.dart` files that currently break Flutter Web compilation.
- [x] 1.3 Verify the Flutter Web build no longer fails on schema integer literal precision errors.
- [x] 1.4 Make web datastore startup avoid native-only local directory APIs before `runApp()`.
