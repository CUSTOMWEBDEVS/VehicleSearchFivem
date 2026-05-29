# vehsrch_clean

Clean standalone FiveM NPC vehicle search/evidence script.

## Install

Put `vehsrch_clean` in your resources folder.

Add to `server.cfg`:

```cfg
ensure vehsrch_clean
```

## Controls

- `O` = search nearby NPC vehicle
- `K` = mark/unmark current or nearby vehicle as evidence/supply vehicle
- `E` = interact when prompted
- `/vs_search` = backup search command
- `/vs_markvehicle` = backup mark command
- `/vs_clear` = emergency clear animation

## Flow

1. Sit in your patrol/custom vehicle once, or press `K` near/in it.
2. Walk to an NPC vehicle.
3. Press `O`.
4. Vehicle doors pop open while searching.
5. Evidence items spawn by the searched vehicle.
6. Go to your patrol/supply vehicle trunk and press `E` to grab a bag.
7. Bag evidence, store it in your trunk, then turn it in at an evidence station.

NPC cars are not bag supply vehicles.

## v1.0.2
- Replaced `GetVehicleModelNumberOfSeats` with a safer fixed-seat scan for compatibility.

## v1.0.3
- Restored the full evidence station list.
- Moved stations to exterior/parking-lot style spots to reduce custom PD/MLO conflicts.

## v1.0.4
- Relocated all stations to parking lots / curbside exterior spots.


## v1.0.5 station tool

The station coordinates are now wider/open-area defaults, but custom police stations/MLOs can still move walls/floors.

Use this command in game:

```txt
/vs_stationcoords Mission Row Evidence
```

Stand exactly where you want the evidence drop-off marker, run the command, then open F8 console and copy the printed line into `Config.Stations` in `config.lua`.

This is the reliable way to place markers for your actual server map.
