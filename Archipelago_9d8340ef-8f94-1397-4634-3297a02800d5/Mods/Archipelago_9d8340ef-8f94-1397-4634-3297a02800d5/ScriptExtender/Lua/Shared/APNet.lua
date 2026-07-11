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

APNet = APNet or {}

local function make_netchannel(name)
    -- Modern NetChannel API (preferred).
    if (Ext.Net == nil or Ext.Net.CreateChannel == nil) then return nil end
    local ok, raw = pcall(Ext.Net.CreateChannel, ModuleUUID, name)
    if (not ok or raw == nil) then return nil end
    local ch = { _raw = raw }
    function ch:SetHandler(fn)
        pcall(function() self._raw:SetHandler(function(data, user) fn(data, user) end) end)
    end
    function ch:Broadcast(tbl)
        pcall(function() self._raw:Broadcast(tbl) end)
    end
    function ch:SendToServer(tbl)
        pcall(function() self._raw:SendToServer(tbl) end)
    end
    return ch
end

local function make_legacy(name)
    -- Deprecated NetMessage API (string payloads over named channels).
    if (Ext.Events == nil or Ext.Events.NetMessage == nil) then return nil end
    local ch = { _name = name }
    function ch:SetHandler(fn)
        pcall(function()
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
        pcall(function()
            Ext.ServerNet.BroadcastMessage(ch._name, Ext.Json.Stringify(tbl))
        end)
    end
    function ch:SendToServer(tbl)
        pcall(function()
            Ext.ClientNet.PostMessageToServer(ch._name, Ext.Json.Stringify(tbl))
        end)
    end
    return ch
end

function APNet.Channel(name)
    local ch = make_netchannel(name)
    if (ch == nil) then ch = make_legacy(name) end
    if (ch == nil) then
        print("APNet: no usable net API in this Script Extender version; channel '" .. name .. "' disabled")
    end
    return ch
end
