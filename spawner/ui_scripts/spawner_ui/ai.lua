local json = require("json")
local menus = {}

local spawnlocation = "crosshair"
local targetteam = "auto"

function spawnlocationoptions(menu)
    game:setdvar("ai_spawner_location", spawnlocation)
    game:setdvar("ai_spawner_team", targetteam)

    LUI.Options.CreateOptionButton(menu, 
        "ai_spawner_location", 
        "Spawn location", 
        "Where to spawn the AI", 
        {
            {
                value = "crosshair",
                text = "Crosshair"
            },
            {
                value = "player",
                text = "Player location"
            }
        }, 
        nil, nil, function(value)
            spawnlocation = value
        end
    )

    LUI.Options.CreateOptionButton(menu, 
        "ai_spawner_team", 
        "Target AI team", 
        "Team to assign to the AI", 
        {
            {
                value = "auto",
                text = "Auto"
            },
            {
                value = "axis",
                text = "Axis"
            },
            {
                value = "allies",
                text = "Allies"
            },
            {
                value = "team3",
                text = "Team3"
            },
            {
                value = "neutral",
                text = "Neutral"
            }
        }, 
        nil, nil, function(value)
            targetteam = value
        end
    )
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
        lastaction = function()
            notify("delete_ai")
        end
        lastaction()
    end, nil, true, nil, {
        desc_text = "Delete all AI"
    })

    menu:AddButton("Delete Custom AI", function()
        lastaction = function()
            notify("delete_custom_ai")
        end
        lastaction()
    end, nil, true, nil, {
        desc_text = "Delete custom AI"
    })
end

function controllerbutton(menu)
    menu:AddButton("Controller", function()
        openmenu("ai_spawner_controller_menu")
    end, nil, true, nil, {
        desc_text = "Edit AI controller settings"
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
    controllerbutton(menu)

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
        controllerbutton(menu)
    
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
                    lastaction = function()
                        notify("select_ai_spawner", v.num, spawnlocation, targetteam)
                    end
                    lastaction()
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

function controllermenu(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "AI Controller",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    LUI.Options.CreateOptionButton(menu, 
        "ai_controller_follow", 
        "Follow", 
        "What to follow.", 
        {
            {
                value = "auto",
                text = "Automatic"
            },
            {
                value = "none",
                text = "Nothing"
            },
            {
                value = "player",
                text = "Player"
            },
            {
                value = "lookat",
                text = "Crosshair"
            }
        }, 
        nil, nil, function(value)
        end
    )

    LUI.Options.CreateOptionButton(menu, 
        "ai_controller_shoot", 
        "Target entity", 
        "What the AI should attack.", 
        {
            {
                value = "auto",
                text = "Automatic"
            },
            {
                value = "enemies",
                text = "Enemies"
            },
            {
                value = "lookat",
                text = "Crosshair"
            }
        }, 
        nil, nil, function(value)
        end
    )

    backbutton(menu)
    scrolllist(menu)

    return menu
end

LUI.MenuBuilder.m_types_build["ai_spawner_controller_menu"] = controllermenu
LUI.MenuBuilder.m_types_build["ai_spawner_menu"] = mainmenu