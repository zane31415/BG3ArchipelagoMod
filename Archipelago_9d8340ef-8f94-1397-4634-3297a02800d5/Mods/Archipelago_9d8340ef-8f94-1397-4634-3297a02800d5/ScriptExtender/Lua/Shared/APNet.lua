-- APNet: the one place that knows Script Extender's client/server messaging
-- API names. SE has changed these across versions (NetChannel supersedes the
-- NetMessage API), so everything else in the mod talks to this wrapper and the
-- next SE rename is a one-file fix.
--
-- Usage (same object on either side; calls that don't apply are no-ops):
--   local ch = APNet.Channel("AP_State")
--   ch:SetHandler(function(data, user) ... end)   -- data is a Lua table
--   ch:Broadcast(tbl)                             -- server -> all clients
--   ch:SendToServer(tbl)                          -- client -> server
--
-- Two failure modes this wrapper exists to make visible, both of which cost a
-- player a week of "items just never arrive":
--
--   * the two contexts silently choosing DIFFERENT net APIs. Each side picks
--     independently from whatever its own context exposes, so a build where
--     Ext.Net exists on the server but not the client leaves one end speaking
--     NetChannel and the other NetMessage. Every message is dropped and
--     nothing says why. APNet now prints the chosen mode, with the context
--     name, on both sides: two different modes in the console is the bug.
--   * pcall swallowing a send or handler error forever. Errors are now printed
--     once per channel+operation (once, because Broadcast runs every tick).

APNet = APNet or {}

APNet.Mode = "none"     -- "netchannel" | "legacy" | "none"

local function detect_context()
    local ok, isServer = pcall(function() return Ext.IsServer() end)
    if (ok and isServer ~= nil) then
        return (isServer and "server") or "client"
    end
    return "?"
end

APNet.Context = detect_context()

local function log(msg)
    print("APNet[" .. APNet.Context .. "] " .. msg)
end

-- One line per channel+operation, so a per-tick Broadcast that always throws
-- doesn't drown the console.
local warned = {}

local function warn_once(chName, op, err)
    local key = chName .. "." .. op
    if (warned[key]) then return end
    warned[key] = true
    log("channel '" .. chName .. "' " .. op .. " failed, suppressing further reports: " .. tostring(err))
end

local function guard(chName, op, fn)
    local ok, err = pcall(fn)
    if (not ok) then warn_once(chName, op, err) end
    return ok
end

local function detect_mode()
    if (Ext.Net ~= nil and Ext.Net.CreateChannel ~= nil) then return "netchannel" end
    if (Ext.Events ~= nil and Ext.Events.NetMessage ~= nil) then return "legacy" end
    return "none"
end

local function make_netchannel(name)
    -- Modern NetChannel API (preferred).
    local ok, raw = pcall(Ext.Net.CreateChannel, ModuleUUID, name)
    if (not ok or raw == nil) then
        log("Ext.Net.CreateChannel('" .. name .. "') failed: " .. tostring(raw))
        return nil
    end
    local ch = { _name = name, _raw = raw }
    function ch:SetHandler(fn)
        guard(self._name, "SetHandler", function()
            self._raw:SetHandler(function(data, user) fn(data, user) end)
        end)
    end
    function ch:Broadcast(tbl)
        guard(self._name, "Broadcast", function() self._raw:Broadcast(tbl) end)
    end
    function ch:SendToServer(tbl)
        guard(self._name, "SendToServer", function() self._raw:SendToServer(tbl) end)
    end
    return ch
end

local function make_legacy(name)
    -- Deprecated NetMessage API (string payloads over named channels).
    local ch = { _name = name }
    function ch:SetHandler(fn)
        guard(self._name, "SetHandler", function()
            Ext.Events.NetMessage:Subscribe(function(e)
                if (e.Channel == ch._name) then
                    local data = nil
                    pcall(function() data = Ext.Json.Parse(e.Payload) end)
                    fn(data, e.UserID)
                end
            end)
        end)
    end
    function ch:Broadcast(tbl)
        -- Server-only call: reaching it from the client means the two contexts
        -- disagree about who owns this channel, which is worth saying out loud
        -- rather than pcall-ing into silence.
        if (Ext.ServerNet == nil or Ext.ServerNet.BroadcastMessage == nil) then
            warn_once(self._name, "Broadcast", "Ext.ServerNet unavailable in the " .. APNet.Context .. " context")
            return
        end
        guard(self._name, "Broadcast", function()
            Ext.ServerNet.BroadcastMessage(self._name, Ext.Json.Stringify(tbl))
        end)
    end
    function ch:SendToServer(tbl)
        if (Ext.ClientNet == nil or Ext.ClientNet.PostMessageToServer == nil) then
            warn_once(self._name, "SendToServer", "Ext.ClientNet unavailable in the " .. APNet.Context .. " context")
            return
        end
        guard(self._name, "SendToServer", function()
            Ext.ClientNet.PostMessageToServer(self._name, Ext.Json.Stringify(tbl))
        end)
    end
    return ch
end

APNet.Mode = detect_mode()

if (APNet.Mode == "none") then
    log("no usable net API in this Script Extender build; the in-game window will stay empty")
else
    log("using the " .. APNet.Mode .. " API (both contexts must print the same mode)")
end

function APNet.Channel(name)
    local ch = nil
    if (APNet.Mode == "netchannel") then
        ch = make_netchannel(name)
        if (ch == nil) then
            -- Creation failed despite the API being present: fall back rather
            -- than lose the channel, but say so, because the other context
            -- probably succeeded and is now on a different API.
            log("falling back to the legacy API for '" .. name .. "'")
            if (Ext.Events ~= nil and Ext.Events.NetMessage ~= nil) then
                ch = make_legacy(name)
            end
        end
    elseif (APNet.Mode == "legacy") then
        ch = make_legacy(name)
    end
    if (ch == nil) then
        log("channel '" .. name .. "' is disabled")
    end
    return ch
end

-- Short string for the status window and the startup banner.
function APNet.Describe()
    return APNet.Context .. "/" .. APNet.Mode
end
