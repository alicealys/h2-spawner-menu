local json = require("json")

-- game:detour("_ID43797", "_ID44261", function() end)

local mission_failed_wrapper_hook = nil
mission_failed_wrapper_hook = game:detour("_ID42407", "_ID23778", function()
    game:setsaveddvar("hud_missionFailed", 0)
    game:setsaveddvar("hud_showstance", 1)
    game:setsaveddvar("actionSlotsHide", 0)
    game:setsaveddvar("ui_hideCompassTicker", 0)
    game:setsaveddvar("ammoCounterHide", 0)
end)

-- game:detour("_ID42291", "_ID1538", function() end)

--[[game:oninterval(function()
    local ents = game:getentarray("script_model", "classname")
    for i = 1, #ents do
        if (string.match(ents[i].model, "training_target_enemy")) then
            game:radiusdamage(ents[i].origin, 10, 100, 100, player)
        end
    end
end, 0)--]]

-- local vehicle_init_hook = nil
-- vehicle_init_hook = game:detour("_ID42413", "_ID40173", function(self_, vehicle)
--     vehicle_init_hook.invoke(self_, vehicle)
--     vehicle:makeusable()
-- end)

-- Don't delete spawners
game:detour("_ID43797", "_ID44261", function() end)

-- Change max ai count
game:setdvar("ai_count", 64)

function string:split()
    local t = {}

    for str in string.gmatch(self, "([^%s]+)") do
        table.insert(t, str)
    end

    return t
end

function cleanvehiclename(name)
    local translations = {
        ["laatpv"] = "humvee"
    }

    name = name:gsub("vehicle", ""):gsub("h2", ""):gsub("_", " ")
    local split = name:split()
    local cleanname = ""

    for i, v in ipairs(split) do
        local str = translations[v] or v
        cleanname = cleanname .. str

        if (i < #split) then
            cleanname = cleanname .. " "
        end
    end

    return cleanname
end

game:ontimeout(function()
    local spawners = game:vehicle_getspawnerarray()
    local validspawners = {}
    local done = {}

    for i = 1, #spawners do
        local model = spawners[i].model
        if (model ~= "tag_origin" and done[model] == nil) then
            done[model] = true

            table.insert(validspawners, {
                name = cleanvehiclename(spawners[i].model),
                num = spawners[i]:getentitynumber()
            })
        end
    end

    table.sort(validspawners, function(a, b)
        return a.name < b.name
    end)

    game:sharedset("menu_vehicle_spawners", json.encode(validspawners))
end, 0)

game:ontimeout(function()
    local data = {}
    
    local addteamspawners = function(team)
        local spawners = game:getspawnerteamarray(team)
        local validspawners = {}
        local done = {}
    
        for i = 1, #spawners do
            local targetname = spawners[i].targetname
            if (targetname and done[targetname] == nil) then
                done[targetname] = true
                table.insert(validspawners, {
                    name = targetname,
                    num = spawners[i]:getentitynumber()
                })
            end
        end
    
        table.sort(validspawners, function(a, b)
            return a.name < b.name
        end)
    
        data[team] = validspawners
    end

    addteamspawners("axis")
    addteamspawners("allies")
    addteamspawners("team3")
    addteamspawners("neutral")

    game:sharedset("menu_ai_spawners", json.encode(data))
end, 0)

function getlookat()
    local forward = player:getplayerangles():toforward() * 10000000
    local trace = game:playerphysicstrace(player:geteye(), forward, false, player)
    return trace
end

function getplayervehicle()
    local linked = player:getlinkedparent()
    if (linked and linked.classname and linked.classname:match("vehicle")) then
        return linked
    end

    return nil
end

player:onnotify("select_vehicle_spawner", function(spawner, location)
    local vehicleorigin = player.origin

    if (location == "crosshair") then
        vehicleorigin = getlookat()
    end

    local spawner = game:getentbynum(spawner)
    if (game:isspawner(spawner) == 1) then
        local origin = spawner.origin
        spawner.origin = vehicleorigin
        local vehicle = spawner:vehicle_dospawn()
        vehicle:makeusable()
        vehicle.maxhealth = 100000
        vehicle.health = 100000
        vehicle:vehicle_turnengineon()
        spawner.origin = origin
    end
end)

player:onnotify("select_ai_spawner", function(spawner, location, team)
    local aiorigin = player.origin
    local aicount = game:getdvarint("ai_count")
    local total = game:getaiarray()

    if (#total >= aicount) then
        game:iprintln("AI limit reached")
        return
    end

    if (location == "crosshair") then
        aiorigin = getlookat()
    end

    local spawner = game:getentbynum(spawner)
    if (game:isspawner(spawner) == 1) then
        local origin = spawner.origin
        spawner.origin = aiorigin
        spawner.count = spawner.count + 1

        local ai = spawner:stalingradspawn()
        if (team ~= "auto") then
            ai.team = team
        end

        spawner.origin = origin
    end
end)

player:onnotify("select_weapon_spawner", function(weapon, action, location)
    if (action == "give") then
        player:giveweapon(weapon)
        player:switchtoweapon(weapon)
        player:givemaxammo(weapon)
    elseif (action == "spawn") then
        local origin = player.origin
        if (location == "crosshair") then
            origin = game:getgroundposition(getlookat())
        end

        origin.z = origin.z + 20
        game:spawn("weapon_" .. weapon, origin)
    end
end)

player:onnotify("delete_weapons", function()
    local ents = game:getentarray()
    local count = 0

    for i = 1, #ents do
        if (ents[i].classname and ents[i].classname:match("weapon_")) then
            ents[i]:delete()
            count = count + 1
        end
    end

    game:iprintln("^2" .. count .. "^7 weapons deleted")
end)

player:onnotify("delete_ai", function()
    local ai = game:getaiarray()

    game:iprintln("^2" .. #ai .. "^7 ai deleted")
    for i = 1, #ai do
        ai[i]:delete()
    end
end)

player:onnotify("delete_vehicles", function()
    local vehicles = game:vehicle_getarray()
    local vehicle = getplayervehicle()
    local count = #vehicles
    if (vehicle) then
        count = count - 1
    end

    game:iprintln("^2" .. count .. "^7 vehicles deleted")
    for i = 1, #vehicles do
        if (vehicles[i] ~= vehicle) then
            vehicles[i]:delete()
        end
    end
end)

player:notifyonplayercommand("+vehicle_fire_", "+attack")
player:notifyonplayercommand("-vehicle_fire_", "-attack")
player:notifyonplayercommand("vehicle_boost_", "+melee")
player:notifyonplayercommand("vehicle_boost_", "+melee_zoom")
local vehicleattack = false

function firevehicleweapon()
    local vehicle = getplayervehicle()
    if (vehicle) then
        vehicle:fireweapon()
    end
end

if (game:getdvar("vehicle_firemode") == "") then
    game:setdvar("vehicle_firemode", 0)
end

if (game:getdvar("vehicle_fireinterval") == "") then
    game:setdvar("vehicle_fireinterval", 200)
end

player:onnotify("vehicle_boost_", function()
    local vehicle = getplayervehicle()
    if (vehicle and vehicle:vehicle_isphysveh() == 1) then
        vehicle:vehphys_setspeed(100)
    end
end)

local burstinterval = nil
player:onnotify("+vehicle_fire_", function()
    local mode = game:getdvarint("vehicle_firemode")

    if (mode == 0) then
        firevehicleweapon()
    elseif (mode == 1 and not burstinterval) then
        local rate = math.max(0, math.min(game:getdvarint("vehicle_fireinterval"), 1000))

        local i = 0
        firevehicleweapon()
        burstinterval = game:oninterval(function()
            firevehicleweapon()
        end, rate)

        game:ontimeout(function()
            burstinterval:clear()
            burstinterval = nil
        end, rate * 2)
    elseif (mode >= 2) then
        vehicleattack = true
    end
end)

player:onnotify("-vehicle_fire_", function()
    vehicleattack = false
end)

local time = 0
game:oninterval(function()
    time = time + 50
end, 0)

local start = 0
game:oninterval(function()
    local now = time
    local rate = math.max(0, math.min(game:getdvarint("vehicle_fireinterval"), 1000))

    if (now - start >= rate) then
        start = now
        if (vehicleattack) then
            firevehicleweapon()
        end
    end
end, 0)