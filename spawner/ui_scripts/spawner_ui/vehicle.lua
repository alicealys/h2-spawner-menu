local json = require("json")

local spawnlocation = "crosshair"

function mainmenu(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Spawn Vehicle",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg
    local spawners_json = game:sharedget("menu_vehicle_spawners")

    if (spawners_json == "") then
        return menu
    end

    local spawners = json.decode(spawners_json)

    createdivider(menu, "Settings")

    Engine.SetDvarFromString("vehicle_spawner_location", spawnlocation)
    LUI.Options.CreateOptionButton(
        menu, 
        "vehicle_spawner_location", 
        "Spawn location", 
        "Where to spawn the vehicle", 
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
        nil, 
        nil, 
        function(value)
            spawnlocation = value
        end
    )

    menu:AddButton("Delete all vehicles", function()
        lastaction = function()
            notify("delete_vehicles")
        end
        lastaction()
    end, nil, true, nil, {
        desc_text = "Delete all the vehicles in the map"
    })

    createdivider(menu, "Vehicles")

    for k, v in pairs(spawners) do
        menu:AddButton(v.name, function()
            lastaction = function()
                notify("select_vehicle_spawner", v.num, spawnlocation)
            end
            lastaction()
        end, nil, true, nil, {
            desc_text = "Spawn this vehicle type"
        })
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

LUI.MenuBuilder.m_types_build["vehicle_spawner_menu"] = mainmenu