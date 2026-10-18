# Proxy Container Circuit Fix

A [Factorio](https://www.factorio.com/) 2.1 data-stage fix mod. Factorio **2.1.21** changed `ProxyContainerPrototype`: `circuit_connector` must now be a *list* of `CircuitConnectorDefinition`s (one entry per direction) with an explicit `direction_count`, instead of the single definition table older mods assigned. Affected mods fail prototype loading with:

> Value must be a list in property tree at ROOT.proxy-container.\<name\>.circuit_connector

This mod runs in `data-final-fixes.lua` — after every other mod's data stages, but before the engine validates prototypes — and repairs all proxy-container prototypes in one pass:

- A **single** definition (`{sprites = ..., points = ...}`) is wrapped into a one-element list (direction-agnostic, same behavior as before 2.1.21).
- A **list without `direction_count`** (e.g. copied from a 4-direction entity) gets `direction_count` set to the list length.

The patch is generic: no specific mods are required or edited, and the number of repaired prototypes is logged at load time.

## Compatibility

- Requires Factorio 2.1.21 or later (the change it fixes does not exist before that).
- No dependencies, no settings, no runtime code. Safe to add or remove at any time; removing it simply restores the original load errors if a broken mod is still present.

## License

MIT — see [LICENSE](LICENSE).
