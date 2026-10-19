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

-- Build version of THIS file, kept deliberately separate from the server's
-- copy in Server/Archipelago_<uuid>.lua rather than shared. The failure being
-- caught is one script being stale while the other is current, so a shared
-- constant would agree with itself and catch nothing. Bump both together.
local SCRIPT_VERSION = "0.8.0"

-- How long to wait for the server's first AP_State push before concluding the
-- server script is not the one we shipped with. The request sent at session
-- load is often lost (the server script is not listening yet), so it is
-- repeated every STATE_RETRY_MS until state arrives, and the server pushes
-- unasked on its first few heartbeats. Only when all of that has failed does
-- the window say the server is not responding.
local STATE_RETRY_MS = 3000
local STATE_RETRIES = 10
local STATE_TIMEOUT_MS = STATE_RETRY_MS * STATE_RETRIES + 5000

local state = nil               -- last AP_State payload received
local stateEverReceived = false
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

-- The three ways the two halves of the mod can disagree, in the words a
-- player can act on. All three were real: a stale Server/*.lua loose under
-- Data\Mods shadowed the pak's copy for one player and cost a week of
-- "my items never arrive", with nothing in the log naming the cause.
local INSTALL_HELP = table.concat({
    "Look for a loose Archipelago_9d8340ef-8f94-1397-4634-3297a02800d5 folder",
    "under the BG3 install's Data/Mods and delete the whole folder, then",
    "check the Mods folder for a second Archipelago .pak -- a renamed .pak",
    "still loads, because the game matches on the mod UUID, not the name.",
}, "\n")

local NO_STATE_TEXT = table.concat({
    "The server half of this mod is not responding.",
    "This window loaded, but no game state has arrived, which means the",
    "server script is missing, too old, or a stale copy is overriding it.",
    INSTALL_HELP,
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

-- nil/"" hides the banner; anything else shows it in the alarming colour.
local function set_diagnostic(text)
    if (win == nil or widgets.diag == nil) then return end
    local shown = (text ~= nil and text ~= "")
    widgets.diag.Label = shown and text or ""
    widgets.diag.Visible = shown
    if (shown) then
        set_text_color(widgets.diag, PRESENCE_COLORS.NO_CLIENT)
    end
end

local function build_window()
    win = Ext.IMGUI.NewWindow("Archipelago")
    win.Closeable = true

    widgets.status = win:AddText("Waiting for game state...")
    widgets.slotSeed = win:AddText("")
    widgets.counters = win:AddText("")
    widgets.build = win:AddText("")

    widgets.diag = win:AddText("")
    widgets.diag.Visible = false

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
        .. "    Deathlink: " .. (state.deathlink and (state.surviveOnDeathlink and "on (knockout)" or "on (kill)") or "off")

    local serverBuild = state.script_version
    widgets.build.Label = "Window build: " .. SCRIPT_VERSION
        .. "    Server build: " .. tostring(serverBuild or "unknown")
        .. "    Net: " .. tostring(state.net_mode or "?")
    if (serverBuild == nil) then
        set_diagnostic(table.concat({
            "The server script is too old to report its build (pre-0.7.1), but",
            "this window is build " .. SCRIPT_VERSION .. ". Two copies of the mod are",
            "installed and the stale one is being loaded.",
            INSTALL_HELP,
        }, "\n"))
    elseif (serverBuild ~= SCRIPT_VERSION) then
        set_diagnostic(table.concat({
            "Version mismatch: this window is build " .. SCRIPT_VERSION .. " but the",
            "server script is build " .. tostring(serverBuild) .. ". Two copies of the",
            "mod are installed and the stale one is being loaded.",
            INSTALL_HELP,
        }, "\n"))
    else
        set_diagnostic(nil)
    end

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
    stateEverReceived = true
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

-- The server never pushed state. Either it isn't the script we shipped
-- alongside this window, or the net channels never linked up. Say so in the
-- window instead of sitting on "Waiting for game state..." forever.
local function on_state_timeout()
    if (stateEverReceived) then return end
    if (not ensure_window()) then return end
    widgets.status.Label = "Status: server script not responding"
    set_text_color(widgets.status, PRESENCE_COLORS.NO_CLIENT)
    widgets.build.Label = "Window build: " .. SCRIPT_VERSION
        .. "    Server build: no reply"
        .. "    Net: " .. ((APNet ~= nil and APNet.Describe ~= nil) and APNet.Describe() or "none")
    set_diagnostic(NO_STATE_TEXT)
    set_shown(true)
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

-- Greppable build banner, matching the server script's. Two different builds
-- in the console means two copies of the mod are installed.
print("Archipelago CLIENT window script loaded: build " .. SCRIPT_VERSION
    .. ", net " .. ((APNet ~= nil and APNet.Describe ~= nil) and APNet.Describe() or "none"))

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
    -- Ext.Timer is not guaranteed in the client context on every SE build, so
    -- the retries and the timeout are best-effort: without it the window
    -- simply behaves as it did before.
    pcall(function()
        local tries = 0
        local function retry()
            if (stateEverReceived or tries >= STATE_RETRIES) then return end
            tries = tries + 1
            pcall(function() send_command("refresh_state") end)
            Ext.Timer.WaitForRealtime(STATE_RETRY_MS, retry)
        end
        Ext.Timer.WaitForRealtime(STATE_RETRY_MS, retry)
    end)
    pcall(function()
        Ext.Timer.WaitForRealtime(STATE_TIMEOUT_MS, function()
            pcall(on_state_timeout)
        end)
    end)
end)
