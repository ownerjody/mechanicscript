**# mechanic_tablet

A fully functional mechanic tablet resource for FiveM with support for:

- `open` (standalone/open framework)
- `esx` (`es_extended`)
- `qbcore` (`qb-core`)

## Features

- Opens with `/mechanictablet` and default keybind `F6`.
- Framework auto-detection with optional forced mode via config.
- Job gate for mechanics (configurable per framework).
- NUI-safe startup handshake (`nuiReady`) to avoid startup race issues.
- Vehicle actions:
  - inspect nearby vehicle
  - repair nearby vehicle
  - clean nearby vehicle

## Installation

1. Copy `mechanic_tablet` into your server resources folder.
2. Add `ensure mechanic_tablet` to your `server.cfg`.
3. (Optional) Edit `shared/config.lua`.

## Notes

- Works with open/standalone framework and without ESX/QBCore.
- Uses no `esx:getSharedObject` events and does not require `es_extended` when in `open` mode.
**
