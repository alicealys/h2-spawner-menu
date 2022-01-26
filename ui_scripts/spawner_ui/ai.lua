local json = require("json")
local menus = {}

local spawnlocation = "crosshair"

function spawnlocationoptions(menu)
    game:setdvar("ai_spawner_dummy_var", spawnlocation)

    local options = {
        {
            value = "crosshair",
            text = "Crosshair"
        },
        {
            value = "player",
            text = "Player location"
        }
    }

    LUI.Options.CreateOptionButton(menu, "ai_spawner_dummy_var", "Spawn location", "Where to spawn the AI", options, nil, nil, function(value)
        spawnlocation = value
    end)
end

function backbutton(menu)
    menu:AddBackButton(function(menu)
        Engine.PlaySound(CoD.SFX.MenuBack)
        LUI.FlowManager.RequestLeaveMenu(menu)
    end)
end

function scrolllist(menu)
    LUI.Options.InitScrollingList(menu.list, nil)
    menu:CreateBottomDivider()
    menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)
end

function deleteaibutton(menu)
    menu:AddButton("Delete AI", function()
        notify("delete_ai")
    end, nil, true, nil, {
        desc_text = "Delete all AI"
    })
end

function mainmenu(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Spawn AI",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    createdivider(menu, "Settings")

    spawnlocationoptions(menu)
    deleteaibutton(menu)

    createdivider(menu, "Teams")

    for k, v in pairs(menus) do
        menu:AddButton(v.name, function()
            openmenu(v.menu)
        end, nil, true, nil, {
            desc_text = "Open menu for this AI team"
        })
    end

    backbutton(menu)
    scrolllist(menu)

    return menu
end

function createmenu(team)
    local teammenu = function(a1)
        local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
        LUI.MenuTemplate.InitInGameBkg = function() end
    
        local menu = LUI.MenuTemplate.new(a1, {
            menu_title = "Spawn " .. team .. " AI",
            exclusiveController = 0,
            menu_width = 400,
            menu_top_indent = LUI.MenuTemplate.spMenuOffset,
            showTopRightSmallBar = true
        })
    
        LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

        createdivider(menu, "Settings")

        spawnlocationoptions(menu)
        deleteaibutton(menu)
    
        createdivider(menu, "Spawner types")

        local spawners_json = game:sharedget("menu_ai_spawners")

        if (spawners_json == "") then
            backbutton(menu)
            scrolllist(menu)
            return menu
        end
    
        local spawners = json.decode(spawners_json)

        if (spawners[team]) then
            for k, v in pairs(spawners[team]) do
                menu:AddButton(v.name, function()
                    notify("select_ai_spawner", v.num, spawnlocation)
                end, nil, true, nil, {
                    desc_text = "Spawn this AI type"
                })
            end
        end

        backbutton(menu)
        scrolllist(menu)

        return menu
    end

    local menuname = "ai_spawner_" .. team .. "_menu"

    table.insert(menus, {
        name = team,
        menu = menuname
    })

    LUI.MenuBuilder.m_types_build[menuname] = teammenu    
end

createmenu("axis")
createmenu("allies")
createmenu("team3")
createmenu("neutral")

LUI.MenuBuilder.m_types_build["ai_spawner_menu"] = mainmenu