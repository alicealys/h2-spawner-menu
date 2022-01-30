local json = require("json")

local spawnlocation = "crosshair"
local action = "give"

function mainmenu(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Spawn Weapon",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    game:setdvar("weapon_spawner_location", spawnlocation)
    game:setdvar("weapon_spawner_action", action)

    createdivider(menu, "Settings")

    LUI.Options.CreateOptionButton(menu, 
        "weapon_spawner_action", 
        "Action", 
        "What to do with the weapon", 
        {
            {
                value = "give",
                text = "Give"
            },
            {
                value = "spawn",
                text = "Spawn"
            }
        }, 
        nil, nil, function(value)
            action = value
        end
    )

    LUI.Options.CreateOptionButton(menu, 
        "weapon_spawner_location", 
        "Spawn location", 
        "Where to spawn the weapon", 
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

    menu:AddButton("Delete all weapons", function()
        lastaction = function()
            notify("delete_weapons")
        end
        lastaction()
    end, nil, true, nil, {
        desc_text = "Delete all the weapons in the map"
    })

    createdivider(menu, "Weapons")

    local weapons = game:assetlist("weapon")

    local addedweapons = {}
    for i = 1, math.min(64, #weapons) do
        local displayname = game:getweapondisplayname(weapons[i])
        if (displayname ~= "" and not addedweapons[displayname]) then
            addedweapons[displayname] = true
            menu:AddButton(displayname, function()
                lastaction = function()
                    notify("select_weapon_spawner", weapons[i], action, spawnlocation)
                end
                lastaction()
            end, nil, true, nil, {
                desc_text = "Spawn this weapon"
            })
        end
    end

    menu:AddBackButton(function(menu)
        Engine.PlaySound(CoD.SFX.MenuBack)
        LUI.FlowManager.RequestLeaveMenu(menu)
    end)

    LUI.Options.InitScrollingList(menu.list, nil)
    menu:CreateBottomDivider()
    menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)

    return menu
end

LUI.MenuBuilder.m_types_build["weapon_spawner_menu"] = mainmenu