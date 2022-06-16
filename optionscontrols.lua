require("T6.KeyBindSelector")
require("T6.ButtonLayoutOptions")
require("T6.StickLayoutOptions")

CoD.OptionsControls = {}
CoD.OptionsControls.CurrentTabIndex = nil

CoD.OptionsControls.Button_AddChoices_LookSensitivity = function (sensitivities)
	sensitivities.strings = {
		Engine.Localize("VERY LOW"),
		Engine.Localize("LOW"),
		"3",
		Engine.Localize("MEDIUM"),
		"5",
		"6",
		"7",
		Engine.Localize("HIGH"),
		"9",
		"10",
		Engine.Localize("VERY HIGH"),
		"12",
		"13",
		Engine.Localize("INSANE")
	}
	sensitivities.values = {
		CoD.SENSITIVITY_1,
		CoD.SENSITIVITY_2,
		CoD.SENSITIVITY_3,
		CoD.SENSITIVITY_4,
		CoD.SENSITIVITY_5,
		CoD.SENSITIVITY_6,
		CoD.SENSITIVITY_7,
		CoD.SENSITIVITY_8,
		CoD.SENSITIVITY_9,
		CoD.SENSITIVITY_10,
		CoD.SENSITIVITY_11,
		CoD.SENSITIVITY_12,
		CoD.SENSITIVITY_13,
		CoD.SENSITIVITY_14
	}
	CoD.Options.Button_AddChoices(sensitivities)
end

CoD.OptionsControls.Button_AddChoices_InvertMouse = function (lookTabButtonList, LocalClientIndex)
	lookTabButtonList:addChoice(LocalClientIndex, Engine.Localize("NO"), 0.02)
	lookTabButtonList:addChoice(LocalClientIndex, Engine.Localize("YES"), -0.02)
end

CoD.OptionsControls.Callback_GamepadSelector = function (gamepadEnabled, client)
	if client then
		Engine.SetHardwareProfileValue(gamepadEnabled.parentSelectorButton.m_profileVarName, gamepadEnabled.value)
		if gamepadEnabled.value == 1 then
			Dvar.gpad_enabled:set(true)
			Engine.Exec(0, "execcontrollerbindings")
		else
			Dvar.gpad_enabled:set(false)
		end
	end
end

CoD.OptionsControls.Button_AddChoices_Gamepad = function (gamepadButtonList)
	gamepadButtonList:addChoice(Engine.Localize("DISABLED"), 0, nil, CoD.OptionsControls.Callback_GamepadSelector)
	gamepadButtonList:addChoice(Engine.Localize("ENABLED"), 1, nil, CoD.OptionsControls.Callback_GamepadSelector)
end

CoD.OptionsControls.AddKeyBindingElements = function (localClientIndex, buttonList, keyCommandsAndLabels)
	for Key, keyCommandAndLabel in ipairs(keyCommandsAndLabels) do
		if keyCommandAndLabel.command == "break" then
			buttonList:addSpacer(CoD.CoD9Button.Height / 2)
		else
			if keyCommandAndLabel.hint ~= nil then
				buttonList:addKeyBindSelector(localClientIndex, Engine.Localize(keyCommandAndLabel.label), keyCommandAndLabel.command, CoD.BIND_PLAYER, keyCommandAndLabel.hint)
			else 
				buttonList:addKeyBindSelector(localClientIndex, Engine.Localize(keyCommandAndLabel.label), keyCommandAndLabel.command, CoD.BIND_PLAYER)
			end
		end
	end
end

CoD.OptionsControls.Button_AddChoices_YesOrNo = function (lookTabButtonList, LocalClientIndex)
	lookTabButtonList.strings = {
		Engine.Localize("NO"),
		Engine.Localize("YES")
	}
	lookTabButtonList.values = {
		0,
		1
	}
	CoD.OptionsControls.Button_AddChoices(lookTabButtonList, LocalClientIndex)
end

CoD.OptionsControls.Button_AddChoices = function (lookTabButtonList, LocalClientIndex)
	if lookTabButtonList.strings == nil or #lookTabButtonList.strings == 0 then
		return 
	end
	for StringIndex = 1, #lookTabButtonList.strings, 1 do
		lookTabButtonList:addChoice(LocalClientIndex, lookTabButtonList.strings[StringIndex], lookTabButtonList.values[StringIndex])
	end
end

CoD.OptionsControls.CreateLookTab = function (lookTab, localClientIndex)
	local lookTabContainer = LUI.UIContainer.new()
	local lookTabButtonList = CoD.Options.CreateButtonList()
	lookTab.buttonList = lookTabButtonList
	lookTabContainer:addElement(lookTabButtonList)
	CoD.OptionsControls.AddKeyBindingElements(localClientIndex, lookTabButtonList, {
		{
			command = "+leanleft",
			label = "LEAN LEFT"
		},
		{
			command = "+leanright",
			label = "LEAN RIGHT"
		},
		{
			command = "+lookup",
			label = "LOOK UP"
		},
		{
			command = "+lookdown",
			label = "LOOK DOWN"
		},
		{
			command = "+left",
			label = "TURN LEFT"
		},
		{
			command = "+right",
			label = "TURN RIGHT"
		},
		{
			command = "+mlook",
			label = "MOUSE LOOOK"
		},
		{
			command = "centerview",
			label = "CENTER VIEW"
		}
	})
	lookTabButtonList:addSpacer(CoD.CoD9Button.Height / 2)
	CoD.OptionsControls.Button_AddChoices_InvertMouse(lookTabButtonList:addDvarLeftRightSelector(localClientIndex, Engine.Localize("INVERT MOUSE"), "m_pitch"), localClientIndex)
	CoD.OptionsControls.Button_AddChoices_YesOrNo(lookTabButtonList:addDvarLeftRightSelector(localClientIndex, Engine.Localize("FREE LOOK"), "cl_freelook"), localClientIndex)
	local MouseSensitivityOptions = lookTabButtonList:addProfileLeftRightSlider(localClientIndex, Engine.Localize("MOUSE SENSITIVITY"), "mouseSensitivity", 0.01, 30, "Use the left and right arrow keys for more precise adjustments.", nil, nil, CoD.Options.AdjustSFX)
	MouseSensitivityOptions:setNumericDisplayFormatString("%.2f")
	MouseSensitivityOptions:setRoundToFraction(0.5)
	MouseSensitivityOptions:setBarSpeed(0.01)
	return lookTabContainer
end

CoD.OptionsControls.CreateMoveTab = function (moveTab, localClientIndex)
	local moveTabContainer = LUI.UIContainer.new()
	local moveTabButtonList = CoD.Options.CreateButtonList()
	moveTab.buttonList = moveTabButtonList
	moveTabContainer:addElement(moveTabButtonList)
	CoD.OptionsControls.AddKeyBindingElements(localClientIndex, moveTabButtonList, {
		{
			command = "+forward",
			label = "FORWARD"
		},
		{
			command = "+back",
			label = "BACKPEDAL"
		},
		{
			command = "+moveleft",
			label = "MOVE LEFT"
		},
		{
			command = "+moveright",
			label = "MOVE RIGHT"
		},
		{
			command = "break"
		},
		{
			command = "+gostand",
			label = "JUMP"
		},
		{
			command = "gocrouch",
			label = "GO TO CROUCH"
		},
		{
			command = "goprone",
			label = "GO TO PRONE"
		},
		{
			command = "togglecrouch",
			label = "TOGGLE CROUCH"
		},
		{
			command = "toggleprone",
			label = "TOGGLE PRONE"
		},
		{
			command = "+movedown",
			label = "CROUCH"
		},
		{
			command = "+prone",
			label = "PRONE"
		},
		{
			command = "break"
		},
		{
			command = "+stance",
			label = "CHANGE STANCE"
		},
		{
			command = "+strafe",
			label = "STRAFE"
		}
	})
	return moveTabContainer
end

CoD.OptionsControls.CreateCombatTab = function (combatTab, localClientIndex)
	local combatTabContainer = LUI.UIContainer.new()
	local combatTabButtonList = CoD.Options.CreateButtonList()
	combatTab.buttonList = combatTabButtonList
	combatTabContainer:addElement(combatTabButtonList)
	CoD.OptionsControls.AddKeyBindingElements(localClientIndex, combatTabButtonList, {
		{
			command = "+attack",
			label = "ATTACK"
		},
		{
			command = "+speed_throw",
			label = "ADS"
		},
		{
			command = "+toggleads_throw",
			label = "TOGGLE ADS"
		},
		{
			command = "+melee",
			label = "MELEE ATTACK"
		},
		{
			command = "+weapnext_inventory",
			label = "PREVIOUS WEAPON"
		},
		{
			command = "weapprev",
			label = "NEXT WEAPON"
		},
		{
			command = "+reload",
			label = "RELOAD"
		},
		{
			command = "+sprint",
			label = "SPRINT"
		},
		{
			command = "+breath_sprint",
			label = "SPRINT/HOLD BREATH"
		},
		{
			command = "+holdbreath",
			label = "STEAD SNIPER RIFLE"
		},
		{
			command = "+frag",
			label = "THROW PRIMARY"
		},
		{
			command = "+smoke",
			label = "THROW SECONDARY"
		}
	})
	return combatTabContainer
end

CoD.OptionsControls.CreateInteractTab = function (interactTab, localClientIndex)
	local interactTabContainer = LUI.UIContainer.new()
	local interactTabButtonList = CoD.Options.CreateButtonList()
	interactTab.buttonList = interactTabButtonList
	interactTabContainer:addElement(interactTabButtonList)
	local interactTabContents = {}
	if CoD.isZombie then
		interactTabContents = {
			{
				command = "+activate",
				label = "USE"
			},
			{
				command = "break"
			},
			{
				command = "+actionslot 3",
				label = "ALT FIRE"
			},
			{
				command = "+actionslot 1",
				label = "NEXT SCORESTREAK",
				hint = "Key used to take equipment out."
			},
			{
				command = "+actionslot 2",
				label = "PREVIOUS SCORESTREAK",
				hint = "Key used to take out the quadrorotor(Origins only)."
			},
			{
				command = "+actionslot 4",
				label = "ACTIVATE SCORESTREAK",
				hint = "Key used to take claymores out."
			},
			{
				command = "break"
			},
			{
				command = "screenshotjpeg",
				label = "SCREENSHOT"
			}
		}
	elseif CoD.isMultiplayer then
		interactTabContents = {
			{
				command = "+activate",
				label = "USE"
			},
			{
				command = "break"
			},
			{
				command = "+actionslot 3",
				label = "ALT FIRE"
			},
			{
				command = "+actionslot 1",
				label = "NEXT SCORESTREAK"
			},
			{
				command = "+actionslot 2",
				label = "PREVIOUS SCORESTREAK"
			},
			{
				command = "+actionslot 4",
				label = "ACTIVATE SCORESTREAK"
			},
			{
				command = "break"
			},
			{
				command = "screenshotjpeg",
				label = "SCREENSHOT"
			}
		}
	end
	table.insert(interactTabContents, {
		command = "chooseclass_hotkey",
		label = "CHOOSECLASS"
	})
	table.insert(interactTabContents, {
		command = "+scores",
		label = "SCOREBOARD"
	})
	table.insert(interactTabContents, {
		command = "togglescores",
		label = "SCOREBOARD TOGGLE"
	})
	table.insert(interactTabContents, {
		command = "break"
	})
	table.insert(interactTabContents, {
		command = "chatmodepublic",
		label = "CHAT"
	})
	table.insert(interactTabContents, {
		command = "chatmodeteam",
		label = "TEAM CHAT"
	})
	CoD.OptionsControls.AddKeyBindingElements(localClientIndex, interactTabButtonList, interactTabContents)
	return interactTabContainer
end

CoD.OptionsControls.CreateGamepadTab = function (gamepadTab, localClientIndex)
	local gamepadButtonListContainer = LUI.UIContainer.new()
	local gamepadButtonList = CoD.Options.CreateButtonList()
	gamepadTab.buttonList = gamepadButtonList
	gamepadButtonListContainer:addElement(gamepadButtonList)
	CoD.OptionsControls.Button_AddChoices_Gamepad(gamepadButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("ENABLE GAMEPAD"), "gpad_enabled"))
	if UIExpression.IsInGame() == 1 and UIExpression.DvarBool(nil, "sv_allowAimAssist") == 0 then
		local targetAssistSelector = gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("AIM ASSIST"), "somethingalwaysfalse", "Target Assist is disabled on this server.")	
		targetAssistSelector:lock()
		CoD.Options.Button_AddChoices_EnabledOrDisabled(targetAssistSelector)
	else
		local targetAssistSelector = gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("AIM ASSIST"), "input_targetAssist", Engine.Localize("MENU_TARGET_ASSIST_DESC"))	
		CoD.Options.Button_AddChoices_EnabledOrDisabled(targetAssistSelector)
	end
	CoD.Options.Button_AddChoices_EnabledOrDisabled(gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("LOOK INVERSION"), "input_invertpitch", Engine.Localize("MENU_LOOK_INVERSION_DESC")))
	CoD.Options.Button_AddChoices_EnabledOrDisabled(gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("GAMEPAD VIBRATION"), "gpad_rumble", Engine.Localize("PLATFORM_CONTROLLER_VIBRATION_DESC")))
	if UIExpression.IsDemoPlaying(localClientIndex) ~= 0 then
		local theaterButtonLayout = gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("MENU_THEATER_BUTTON_LAYOUT_CAPS"), "demo_controllerconfig", Engine.Localize("MENU_THEATER_BUTTON_LAYOUT_DESC"))
		CoD.ButtonLayout.AddChoices(theaterButtonLayout, localClientIndex)
		theaterButtonLayout:disableCycling()
		theaterButtonLayout:registerEventHandler("button_action", CoD.OptionsControls.Button_ButtonLayout)
	else
		local gamepadThumbSticksOptions = gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("STICK LAYOUT"), "gpad_sticksConfig", Engine.Localize("MENU_THUMBSTICK_LAYOUT_DESC"))
		CoD.StickLayout.AddChoices(gamepadThumbSticksOptions)
		gamepadThumbSticksOptions:disableCycling()
		gamepadThumbSticksOptions:registerEventHandler("button_action", CoD.OptionsControls.Button_StickLayout)
		local gamepadButtonsOptions = gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("BUTTON LAYOUT"), "gpad_buttonsConfig", Engine.Localize("MENU_BUTTON_LAYOUT_DESC"))
		CoD.ButtonLayout.AddChoices(gamepadButtonsOptions, localClientIndex)
		gamepadButtonsOptions:disableCycling()
		gamepadButtonsOptions:registerEventHandler("button_action", CoD.OptionsControls.Button_ButtonLayout)
	end
	CoD.OptionsControls.Button_AddChoices_LookSensitivity(gamepadButtonList:addProfileLeftRightSelector(localClientIndex, Engine.Localize("LOOK SENSITIVITY"), "input_viewSensitivity", Engine.Localize("PLATFORM_LOOK_SENSITIVITY_DESC")))
	return gamepadButtonListContainer
end

CoD.OptionsControls.TabChanged = function (controlsWidget, controlsTab)
	controlsWidget.buttonList = controlsWidget.tabManager.buttonList
	local child = controlsWidget.buttonList:getFirstChild()
	while not child.m_focusable do
		child = child:getNextSibling()
	end
	if child ~= nil then
		child:processEvent({
			name = "gain_focus"
		})
	end
	CoD.OptionsControls.CurrentTabIndex = controlsTab.tabIndex
end

CoD.OptionsControls.DefaultPopup_RestoreDefaultControls = function (defaultsPopup, client)
	Engine.SetProfileVar(client.controller, "input_invertpitch", 0)
	Engine.SetProfileVar(client.controller, "gpad_rumble", 1)
	Engine.SetProfileVar(client.controller, "gpad_sticksConfig", CoD.THUMBSTICK_DEFAULT)
	Engine.SetProfileVar(client.controller, "gpad_buttonsConfig", CoD.BUTTONS_DEFAULT)
	Engine.SetProfileVar(client.controller, "input_viewSensitivity", CoD.SENSITIVITY_4)
	Engine.SetProfileVar(client.controller, "mouseSensitivity", 5)
	local defaultControlsConfig = "default_controls"
	if CoD.isMultiplayer then
		defaultControlsConfig = "default_mp_controls"
	end
	local language = Engine.GetLanguage()
	if language then
		defaultControlsConfig = defaultControlsConfig .. "_" .. language
	end
	Engine.ExecNow(client.controller, "exec " .. defaultControlsConfig)
	Engine.Exec(client.controller, "execcontrollerbindings")
	Engine.SyncHardwareProfileWithDvars()
	defaultsPopup:goBack(client.controller)
end

CoD.OptionsControls.OnFinishControls = function (menu, client)
	Engine.Exec(client.controller, "updateMustHaveBindings")
	if UIExpression.IsInGame() == 1 then
		Engine.Exec(client.controller, "updateVehicleBindings")
	end
	if CoD.useController and Engine.LastInput_Gamepad() then
		menu:dispatchEventToRoot({
			name = "input_source_changed",
			controller = client.controller,
			source = 0
		})
	else
		menu:dispatchEventToRoot({
			name = "input_source_changed",
			controller = client.controller,
			source = 1
		})
	end
end



CoD.OptionsControls.CloseMenu = function (menu, client)
	CoD.OptionsControls.OnFinishControls(menu, client)
	CoD.Options.CloseMenu(menu, client)
end

CoD.OptionsControls.OpenDefaultPopup = function (popup, client)
	local menu = popup:openMenu("SetDefaultControlsPopup", client.controller)
	menu:registerEventHandler("confirm_action", CoD.OptionsControls.DefaultPopup_RestoreDefaultControls)
	popup:close()
end

CoD.OptionsControls.OpenButtonLayout = function (buttonLayout, client)
	buttonLayout:saveState()
	buttonLayout:openMenu("ButtonLayout", client.controller)
	buttonLayout:close()
end

CoD.OptionsControls.OpenStickLayout = function (stickLayout, client)
	stickLayout:saveState()
	stickLayout:openMenu("StickLayout", client.controller)
	stickLayout:close()
end

CoD.OptionsControls.Button_StickLayout = function (gamepadThumbSticksOptions, client)
	gamepadThumbSticksOptions:dispatchEventToParent({
		name = "open_stick_layout",
		controller = client.controller
	})
end

CoD.OptionsControls.Button_ButtonLayout = function (gamepadButtonsOptions, client)
	gamepadButtonsOptions:dispatchEventToParent({
		name = "open_button_layout",
		controller = client.controller
	})
end

LUI.createMenu.OptionsControlsMenu = function (localClientIndex)
	local controlsWidget = nil
	if UIExpression.IsInGame() == 1 then
		controlsWidget = CoD.InGameMenu.New("OptionsControlsMenu", localClientIndex, Engine.Localize("CONTROLS"))
	else
		controlsWidget = CoD.Menu.New("OptionsControlsMenu")
		controlsWidget:addTitle(Engine.Localize("CONTROLS"), LUI.Alignment.Center)
		controlsWidget:addLargePopupBackground()
	end
	controlsWidget:setPreviousMenu("OptionsMenu")
	controlsWidget:setOwner(localClientIndex)
	controlsWidget:registerEventHandler("button_prompt_back", CoD.OptionsControls.Back)
	controlsWidget:registerEventHandler("restore_default_controls", CoD.OptionsControls.RestoreDefaultControls)
	controlsWidget:registerEventHandler("tab_changed", CoD.OptionsControls.TabChanged)
	controlsWidget:registerEventHandler("open_button_layout", CoD.OptionsControls.OpenButtonLayout)
	controlsWidget:registerEventHandler("open_stick_layout", CoD.OptionsControls.OpenStickLayout)
	controlsWidget:registerEventHandler("open_default_popup", CoD.OptionsControls.OpenDefaultPopup)
	controlsWidget:addSelectButton()
	controlsWidget:addBackButton()
	CoD.Options.AddResetPrompt(controlsWidget)
	local controlsTabs = CoD.Options.SetupTabManager(controlsWidget, 800)
	controlsTabs:addTab(localClientIndex, "LOOK", CoD.OptionsControls.CreateLookTab)
	controlsTabs:addTab(localClientIndex, "MOVE", CoD.OptionsControls.CreateMoveTab)
	controlsTabs:addTab(localClientIndex, "COMBAT", CoD.OptionsControls.CreateCombatTab)
	controlsTabs:addTab(localClientIndex, "INTERACT", CoD.OptionsControls.CreateInteractTab)
	controlsTabs:addTab(localClientIndex, "GAMEPAD", CoD.OptionsControls.CreateGamepadTab)
	if CoD.OptionsControls.CurrentTabIndex then
		controlsTabs:loadTab(localClientIndex, CoD.OptionsControls.CurrentTabIndex)
	else
		controlsTabs:refreshTab(localClientIndex)
	end
	return controlsWidget
end