require("vehicle")
require("ai")
require("weapon")

local json = require("json")

lastmenu = nil
function openmenu(menu)
    lastmenu = menu
    LUI.FlowManager.RequestAddMenu(nil, menu)
end

lastnotify = nil
function notify(...)
    local args = {...}
    lastnotify = args
    player:notify(table.unpack(args))
end

lastaction = nil

function createdivider(menu, text)
	local element = LUI.UIElement.new( {
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = true,
		bottomAnchor = false,
		top = 0,
		bottom = 33.33
	})

	element.scrollingToNext = true
	element:addElement(LUI.MenuBuilder.BuildRegisteredType("h1_option_menu_titlebar", {
		title_bar_text = Engine.ToUpperCase(Engine.Localize(text))
	}))

	menu.list:addElement(element)
end

function mainmenu(a1)
    local InitInGameBkg = LUI.MenuTemplate.InitInGameBkg
    LUI.MenuTemplate.InitInGameBkg = function() end

    local menu = LUI.MenuTemplate.new(a1, {
        menu_title = "Spawners",
        exclusiveController = 0,
        menu_width = 400,
        menu_top_indent = LUI.MenuTemplate.spMenuOffset,
        showTopRightSmallBar = true
    })

    LUI.MenuTemplate.InitInGameBkg = InitInGameBkg

    menu:AddButton("Vehicle", function()
        openmenu("vehicle_spawner_menu")
    end, nil, true, nil, {
        desc_text = "Open the vehicle spawner"
    })

    menu:AddButton("AI", function()
        openmenu("ai_spawner_menu")
    end, nil, true, nil, {
        desc_text = "Open the AI spawner"
    })

    menu:AddButton("Weapon", function()
        openmenu("weapon_spawner_menu")
    end, nil, true, nil, {
        desc_text = "Open the weapon spawner"
    })

    menu:AddBackButton(function(menu)
        Engine.PlaySound(CoD.SFX.MenuBack)
        LUI.FlowManager.RequestLeaveMenu(menu)
    end)

    LUI.Options.InitScrollingList(menu.list, nil)
    menu:CreateBottomDivider()
    menu.optionTextInfo = LUI.Options.AddOptionTextInfo(menu)

    return menu
end

LUI.MenuBuilder.m_types_build["spawner_main_menu"] = mainmenu

local keybinds = {}

-- F5
keybinds[171] = function()
    if (LUI.FlowManager.IsMenuOpenAndVisible(Engine.GetLuiRoot(), "spawner_main_menu")) then
        LUI.FlowManager.RequestLeaveMenu(nil, "spawner_main_menu")
    else
        Engine.PlaySound("h1_ui_menu_accept")
        LUI.FlowManager.RequestAddMenu(nil, "spawner_main_menu")
    end
end

-- F6
keybinds[172] = function()
    if (not lastmenu) then
        return
    end

    if (LUI.FlowManager.IsMenuOpenAndVisible(Engine.GetLuiRoot(), lastmenu)) then
        LUI.FlowManager.RequestLeaveMenu(nil, lastmenu)
    else
        Engine.PlaySound("h1_ui_menu_accept")
        LUI.FlowManager.RequestAddMenu(nil, lastmenu)
    end
end

-- X
keybinds[120] = function()
    if (not lastaction) then
        return
    end

    lastaction()
end

game:onnotify("keydown", function(key)
    if (keybinds[key]) then
        keybinds[key]()
    end
end)