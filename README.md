# BG3ArchipelagoMod
This is a mod for Baldur's Gate 3 to support the Archipelago Multi-world randomizer. This requires an Archipelago installation for functionality.

## Script layout

- `ScriptExtender/Lua/BootstrapServer.lua` → `Server/Archipelago_….lua` — all game logic
  and all file IPC with the Archipelago BG3 client (item grants, location checks,
  deathlink, heartbeat/presence, the 250 ms sync timer).
- `ScriptExtender/Lua/BootstrapClient.lua` → `Client/APGui.lua` — the in-game
  Archipelago status window (IMGUI). Toggle with `U`; it also opens itself if no
  BG3 client is detected. Talks to the server script over SE net channels only.
- `ScriptExtender/Lua/Shared/APNet.lua` — small wrapper around SE's client/server
  messaging API so version churn there is a one-file fix.

## Credits

The in-game status window is patterned on the one in the
[Archipelago-BG3-ToT](https://github.com/Zoltun456/Archipelago-BG3-ToT) spinoff
(Trials of Tav integration), which proved out the IMGUI approach for an in-game
Archipelago client display. No code was copied (their project is CC BY-NC 4.0);
thanks to Zoltun456 for the working example.
