-- In-game Archipelago status window (client context).
--
-- Renders the compact state table the server Lua broadcasts on the AP_State
-- channel and sends button presses back on AP_Command. The server remains the
-- single owner of all file IPC; this file never touches Ext.IO.
--
-- Everything is defensive: if this Script Extender build has no IMGUI (or the
-- player is on a platform where it ends up unusable), the mod degrades to the
-- server-side notifications and nothing errors.

local TOGGLE_KEY = "U"          -- keyboard toggle; change here if it clashes

local state = nil               -- last AP_State payload received
local lastPresence = nil
local win = nil
local widgets = {}
local guiBroken = false

local RECENT_LINES = 15
local LOG_LINES = 12

local PRESENCE_TEXT = {
    STARTING = "Waiting for the Archipelago BG3 Client...",
    OK = "Connected",
    NO_CLIENT = "BG3 Client not detected",
    NO_SERVER = "Client running, AP server lost",
    SEED_MISMATCH = "Connected room does not match this savegame",
}

local PRESENCE_COLORS = {
    STARTING = { 0.85, 0.85, 0.40, 1.0 },
    OK = { 0.35, 0.90, 0.35, 1.0 },
    NO_CLIENT = { 0.95, 0.30, 0.30, 1.0 },
    NO_SERVER = { 0.95, 0.65, 0.20, 1.0 },
    SEED_MISMATCH = { 0.95, 0.30, 0.30, 1.0 },
}

local HELP_TEXT = table.concat({
    "1. Open the Archipelago Launcher and start 'Baldur's Gate 3 Client'.",
    "   (The generic Text Client will NOT deliver items to the game.)",
    "2. Or double-click the .apbg3 file from your seed's output folder.",
    "3. Connect it to your room and slot. This window should turn green",
    "   within about 15 seconds.",
    "Checks you make while disconnected are saved and sent on reconnect.",
}, "\n")

local stateChannel = nil
local commandChannel = nil

local function send_command(cmd)
    if (commandChannel ~= nil) then
        commandChannel:SendToServer({ command = cmd })
    end
end

local function set_text_color(widget, color)
    pcall(function() widget:SetColor("Text", color) end)
end

local function build_window()
    win = Ext.IMGUI.NewWindow("Archipelago")
    win.Closeable = true

    widgets.status = win:AddText("Waiting for game state...")
    widgets.slotSeed = win:AddText("")
    widgets.counters = win:AddText("")

    local resync = win:AddButton("Resync")
    resync.OnClick = function()
        send_command("resync")
    end
    local help = win:AddButton("Connection help")
    help.SameLine = true
    help.OnClick = function()
        widgets.help.Visible = not widgets.help.Visible
    end
    widgets.help = win:AddText(HELP_TEXT)
    widgets.help.Visible = false

    win:AddSeparatorText("Recent items")
    widgets.recent = {}
    for i = 1, RECENT_LINES do
        widgets.recent[i] = win:AddText("")
    end

    win:AddSeparatorText("Gates")
    widgets.gates = win:AddText("")

    win:AddSeparatorText("Log")
    local clear = win:AddButton("Clear log")
    clear.OnClick = function()
        for i = 1, LOG_LINES do widgets.log[i].Label = "" end
    end
    widgets.log = {}
    for i = 1, LOG_LINES do
        widgets.log[i] = win:AddText("")
    end
end

local function ensure_window()
    if (win ~= nil) then return true end
    if (guiBroken) then return false end
    if (Ext.IMGUI == nil or Ext.IMGUI.NewWindow == nil) then
        guiBroken = true
        print("AP GUI: Ext.IMGUI unavailable; status window disabled")
        return false
    end
    local ok, err = pcall(build_window)
    if (not ok or win == nil) then
        guiBroken = true
        win = nil
        print("AP GUI: failed to create window, disabled: " .. tostring(err))
        return false
    end
    return true
end

local function set_shown(shown)
    if (win == nil) then return end
    pcall(function()
        win.Visible = shown
        win.Open = shown
    end)
end

local function refresh()
    if (win == nil or state == nil) then return end
    local presence = state.presence or "STARTING"
    widgets.status.Label = "Status: " .. (PRESENCE_TEXT[presence] or presence)
    set_text_color(widgets.status, PRESENCE_COLORS[presence] or { 1, 1, 1, 1 })
    widgets.slotSeed.Label = "Slot: " .. tostring(state.slot or "?")
        .. "    Seed: " .. tostring(state.seed or "?")
    widgets.counters.Label = "Items received: " .. tostring(state.items_granted or 0)
        .. "    Checks logged: " .. tostring(state.checks_logged or 0)
        .. "    Deathlink: " .. ((state.deathlink and "on") or "off")

    local recent = state.recent or {}
    for i = 1, RECENT_LINES do
        local entry = recent[i]
        if (entry ~= nil) then
            local stamp = (entry.t ~= nil and entry.t ~= "") and (entry.t .. "  ") or ""
            widgets.recent[i].Label = stamp .. tostring(entry.name)
        else
            widgets.recent[i].Label = ""
        end
    end

    local gates = state.gates or {}
    if (#gates == 0) then
        widgets.gates.Label = "(entrance blocking off)"
    else
        local locked = {}
        local unlockedCount = 0
        for _, g in ipairs(gates) do
            if (g.unlocked) then
                unlockedCount = unlockedCount + 1
            else
                -- strip the "Gate-" prefix for display
                table.insert(locked, string.sub(tostring(g.name), 6))
            end
        end
        if (#locked == 0) then
            widgets.gates.Label = "All " .. #gates .. " gates unlocked"
        else
            widgets.gates.Label = unlockedCount .. "/" .. #gates .. " unlocked. Still locked: "
                .. table.concat(locked, ", ")
        end
    end

    local log = state.log or {}
    for i = 1, LOG_LINES do
        widgets.log[i].Label = tostring(log[i] or "")
    end
end

local function on_state(data)
    if (type(data) ~= "table") then return end
    state = data
    if (not ensure_window()) then return end
    refresh()
    -- NO_CLIENT is the one state where the player must act, so surface the
    -- window unasked (once per transition into the state).
    if (state.presence == "NO_CLIENT" and lastPresence ~= "NO_CLIENT") then
        set_shown(true)
    end
    lastPresence = state.presence
end

local function toggle_window()
    if (not ensure_window()) then return end
    local shown = false
    pcall(function() shown = win.Open and win.Visible end)
    set_shown(not shown)
    refresh()
end

if (APNet ~= nil) then
    stateChannel = APNet.Channel("AP_State")
    commandChannel = APNet.Channel("AP_Command")
    if (stateChannel ~= nil) then
        stateChannel:SetHandler(function(data, user)
            on_state(data)
        end)
    end
end

-- Keyboard toggle. Ext.Events.KeyInput is not in the documented API surface,
-- so treat it as optional: if it's missing, the window still auto-shows on
-- NO_CLIENT and can be closed with its own close button.
pcall(function()
    Ext.Events.KeyInput:Subscribe(function(e)
        if (e.Event == "KeyDown" and e.Repeat == false and e.Key == TOGGLE_KEY) then
            toggle_window()
        end
    end)
end)

-- Ask the server for a state push once the session is up, so the window has
-- data even if nothing changed since we loaded in.
Ext.Events.SessionLoaded:Subscribe(function()
    pcall(function() send_command("refresh_state") end)
end)
