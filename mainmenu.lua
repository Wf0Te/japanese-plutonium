require("T6.MainLobby")
require("T6.Menus.MOTD")
if CoD.isZombie == false then
	require("T6.Menus.EliteRegistrationPopup")
	require("T6.Menus.EliteWelcomePopup")
	require("T6.Menus.EliteMarketingOptInPopup")
	require("T6.Menus.DLCPopup")
	require("T6.Menus.VotingPopup")
	require("T6.Menus.SPReminderPopup")
	require("T6.Menus.DSPPromotionPopup")
end
CoD.MainMenu = {}
CoD.MainMenu.SystemLinkLastUsedButton = 0

LUI.createMenu.MainMenu = function (LocalClientIndex)
	local MainMenuWidget = CoD.Menu.New("MainMenu")
	MainMenuWidget.anyControllerAllowed = true
	MainMenuWidget:registerEventHandler("open_main_lobby_requested", CoD.MainMenu.OpenMainLobbyRequested)
	MainMenuWidget:registerEventHandler("open_options_menu", CoD.MainMenu.OpenOptionsMenu)
	MainMenuWidget:registerEventHandler("button_prompt_back", CoD.MainMenu.Back)
	MainMenuWidget:registerEventHandler("first_signed_in", CoD.MainMenu.SignedIntoLive)
	MainMenuWidget:registerEventHandler("last_signed_out", CoD.MainMenu.SignedOut)
	MainMenuWidget:registerEventHandler("open_menu", CoD.Lobby.OpenMenu)
	MainMenuWidget:registerEventHandler("invite_accepted", CoD.inviteAccepted)
	MainMenuWidget:registerEventHandler("button_prompt_friends", CoD.MainMenu.ButtonPromptFriendsMenu)
	MainMenuWidget:registerEventHandler("open_quit_popup", CoD.MainMenu.OpenQuitPopup)
	if CoD.isZombie == false then
		MainMenuWidget:registerEventHandler("motd_popup_closed", CoD.MainMenu.Popup_Closed)
		MainMenuWidget:registerEventHandler("dlcpopup_closed", CoD.MainMenu.Popup_Closed)
		MainMenuWidget:registerEventHandler("voting_popup_closed", CoD.MainMenu.Popup_Closed)
		MainMenuWidget:registerEventHandler("spreminder_popup_closed", CoD.MainMenu.Popup_Closed)
		MainMenuWidget:registerEventHandler("dsppromotion_popup_closed", CoD.MainMenu.Popup_Closed)
	end
	MainMenuWidget:addSelectButton()
	if UIExpression.AnySignedInToLive(LocalClientIndex) == 1 then
		MainMenuWidget:addFriendsButton()
	end
	if CoD.isZombie == false then
		local MainMenuBackgroundMP = LUI.UIImage.new()
		MainMenuBackgroundMP:setLeftRight(false, false, -640, 640)
		MainMenuBackgroundMP:setTopBottom(false, false, -360, 360)
		MainMenuBackgroundMP:setImage(RegisterMaterial("menu_mp_soldiers"))
		MainMenuBackgroundMP:setPriority(-1)
		MainMenuWidget:addElement(MainMenuBackgroundMP)
		local MainMenuBackgroundMP = LUI.UIImage.new()
		MainMenuBackgroundMP:setLeftRight(false, false, -640, 640)
		MainMenuBackgroundMP:setTopBottom(false, false, 180, 360)
		MainMenuBackgroundMP:setImage(RegisterMaterial("ui_smoke"))
		MainMenuBackgroundMP:setAlpha(0.1)
		MainMenuWidget:addElement(MainMenuBackgroundMP)
	end
	if CoD.isZombie then
		local f4_local1 = 192
		local f4_local2 = f4_local1 * 2
		local f4_local3 = 230
		local MainMenuBackgroundZM = LUI.UIImage.new()
		MainMenuBackgroundZM:setLeftRight(true, false, 0, f4_local2)
		MainMenuBackgroundZM:setTopBottom(true, false, f4_local3 - f4_local1 / 2, f4_local3 + f4_local1 / 2)
		MainMenuBackgroundZM:setImage(RegisterMaterial("menu_zm_title_screen"))
		MainMenuWidget:addElement(MainMenuBackgroundZM)
		CoD.GameGlobeZombie.gameGlobe.currentMenu = MainMenuWidget
	else
		local f4_local1 = 48
		local f4_local2 = f4_local1 * 8
		local f4_local3 = 210
		local f4_local4 = LUI.UIImage.new()
		f4_local4:setLeftRight(true, false, 0, f4_local2)
		f4_local4:setTopBottom(true, false, f4_local3, f4_local3 + f4_local1)
		f4_local4:setImage(RegisterMaterial("menu_mp_title_screen"))
		MainMenuWidget:addElement(f4_local4)
		local Language = Dvar.loc_language:get()
		if Language == CoD.LANGUAGE_ENGLISH or Language == CoD.LANGUAGE_BRITISH then
			local f4_local6 = 24
			local f4_local7 = f4_local6 * 16
			local f4_local8 = f4_local3 + f4_local1 + 2
			local f4_local9 = LUI.UIImage.new()
			f4_local9:setLeftRight(true, false, 0, f4_local7)
			f4_local9:setTopBottom(true, false, f4_local8, f4_local8 + f4_local6)
			f4_local9:setImage(RegisterMaterial("menu_mp_title_screen_mp"))
			MainMenuWidget:addElement(f4_local9)
		end
	end
	local f4_local1 = 8
	local HorizontalOffset = 6
	local f4_local3 = CoD.CoD9Button.Height * f4_local1
	local f4_local5 = -f4_local3 - CoD.ButtonPrompt.Height
	MainMenuWidget.buttonList = CoD.ButtonList.new({
		leftAnchor = true,
		rightAnchor = false,
		left = HorizontalOffset,
		right = HorizontalOffset + CoD.ButtonList.DefaultWidth,
		topAnchor = false,
		bottomAnchor = true,
		top = f4_local5,
		bottom = -CoD.ButtonPrompt.Height,
		alpha = 1
	})
	MainMenuWidget.buttonList:setPriority(10)
	MainMenuWidget.buttonList:registerAnimationState("disabled", {
		alpha = 0.5
	})
	MainMenuWidget:addElement(MainMenuWidget.buttonList)
	MainMenuWidget.mainLobbyButton = MainMenuWidget.buttonList:addButton(Engine.Localize("PLATFORM_XBOXLIVE_INSTR"), nil, 1)
	MainMenuWidget.mainLobbyButton:setActionEventName("open_main_lobby_requested")
	MainMenuWidget.optionsButton = MainMenuWidget.buttonList:addButton(Engine.Localize("OPTIONS"), nil, 4)
	MainMenuWidget.optionsButton:setActionEventName("open_options_menu")
	MainMenuWidget.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 5)
	MainMenuWidget.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 8)
	MainMenuWidget.quitButton = MainMenuWidget.buttonList:addButton(Engine.Localize("MENU_QUIT_CAPS"), nil, 9)
	MainMenuWidget.quitButton:setActionEventName("open_quit_popup")
	MainMenuWidget:addLeftButtonPrompt(CoD.ButtonPrompt.new("secondary", "", MainMenuWidget, "open_quit_popup", true))
	MainMenuWidget.buttonList:setLeftRight(true, false, HorizontalOffset, HorizontalOffset + 120)
	if not MainMenuWidget.buttonList:restoreState() then
		MainMenuWidget.buttonList:processEvent({
			name = "gain_focus"
		})
	end
	HideGlobe()
	return MainMenuWidget
end

CoD.MainMenu.Popup_Closed = function (MainMenuWidget, ClientInstance)
	CoD.MainMenu.OpenMainLobbyRequested(MainMenuWidget, ClientInstance)
end

CoD.MainMenu.OpenMainLobbyRequested = function (MainMenuWidget, ClientInstance)
	if Engine.CheckNetConnection() == false then
		local PopupNetConnection = MainMenuWidget:openPopup("popup_net_connection", ClientInstance.controller)
		PopupNetConnection.callingMenu = MainMenuWidget
		return 
	elseif CoD.isZombie == false then
		if CoD.MainLobby.OnlinePlayAvailable(MainMenuWidget, ClientInstance) == 1 then
			Engine.Exec(ClientInstance.controller, "setclientbeingusedandprimary")
			if Engine.ShouldShowMOTD(ClientInstance.controller) ~= nil and Engine.ShouldShowMOTD(ClientInstance.controller) == true then
				local MOTDPopup = MainMenuWidget:openPopup("MOTD", ClientInstance.controller)
				MOTDPopup.callingMenu = MainMenuWidget
			elseif Engine.ShouldShowVoting(ClientInstance.controller) == true then
				local VotingPopup = MainMenuWidget:openPopup("VotingPopup", ClientInstance.controller)
				VotingPopup.callingMenu = MainMenuWidget
			else
				CoD.perController[ClientInstance.controller].IsDLCPopupViewed = nil
				CoD.MainMenu.OpenMainLobby(MainMenuWidget, ClientInstance)
			end
		end
	elseif CoD.MainLobby.OnlinePlayAvailable(MainMenuWidget, ClientInstance) == 1 then
		Engine.Exec(ClientInstance.controller, "setclientbeingusedandprimary")
		if Engine.ShouldShowMOTD(ClientInstance.controller) then
			local MOTDPopup = MainMenuWidget:openPopup("MOTD", ClientInstance.controller)
			MOTDPopup.callingMenu = MainMenuWidget
		else
			CoD.MainMenu.OpenMainLobby(MainMenuWidget, ClientInstance)
		end
	end
end

CoD.MainMenu.OpenMainLobby = function (MainMenuWidget, ClientInstance)
	if CoD.MainLobby.OnlinePlayAvailable(MainMenuWidget, ClientInstance) == 1 then
		MainMenuWidget.buttonList:saveState()
		Engine.SessionModeSetOnlineGame(true)
		Engine.Exec(ClientInstance.controller, "xstartprivateparty")
		Engine.Exec(ClientInstance.controller, "party_statechanged")
		CoD.MainMenu.InitializeLocalPlayers(ClientInstance.controller)
		local MainLobbyMenu = MainMenuWidget:openMenu("MainLobby", ClientInstance.controller)
		Engine.Exec(ClientInstance.controller, "session_rejoinsession " .. CoD.SESSION_REJOIN_CHECK_FOR_SESSION)
		if CoD.isZombie then
			CoD.GameGlobeZombie.gameGlobe.currentMenu = MainLobbyMenu
		end
		MainMenuWidget:close()
	end
end

CoD.MainMenu.OpenOptionsMenu = function (MainMenuWidget, ClientInstance)
	if CoD.MainMenu.OfflinePlayAvailable(MainMenuWidget, ClientInstance) == 0 then
		return 
	else
		CoD.MainMenu.InitializeLocalPlayers(ClientInstance.controller)
		MainMenuWidget:openPopup("OptionsMenu", ClientInstance.controller)
		Engine.PlaySound("cac_screen_fade")
	end
end

CoD.MainMenu.OfflinePlayAvailable = function (MainMenuWidget, ClientInstance, f20_arg2)
	if UIExpression.IsSignedIn(ClientInstance.controller) == 0 then
		if f20_arg2 ~= nil and f20_arg2 == true then
			return 0
		else
			Engine.Exec(ClientInstance.controller, "xsignin")
			return 1
		end
		return 0
	else
		return 1
	end
end

CoD.MainMenu.OpenQuitPopup = function (MainMenuWidget, ClientInstance)
	MainMenuWidget:openPopup("QuitPopup", ClientInstance.controller)
end

CoD.MainMenu.FlyoutBack = function (FlyoutButtonList, ClientInstance)
	if FlyoutButtonList.m_backReady then
		FlyoutButtonList:dispatchEventToParent({
			name = "button_prompt_back",
			controller = ClientInstance.controller
		})
		FlyoutButtonList.m_backReady = nil
	else
		FlyoutButtonList.m_backReady = true
	end
end

CoD.MainMenu.Leave = function (f34_arg0, ClientInstance)
	Dvar.ui_changed_exe:set(1)
	Engine.Exec(ClientInstance.controller, "wait;wait;wait")
	Engine.Exec(ClientInstance.controller, "startSingleplayer")
end

CoD.MainMenu.Back = function (MainMenuWidget, ClientInstance)
	local MainMenuQuit = {
		params = {},
		titleText = Engine.Localize("MENU_MAIN_MENU_CAPS")
	}
	local LeavePopup = MainMenuWidget:openPopup("ConfirmLeave", ClientInstance.controller, MainMenuQuit)
	LeavePopup.anyControllerAllowed = true
end

CoD.MainMenu.ButtonPromptFriendsMenu = function (MainMenuWidget, ClientInstance)
	if UIExpression.IsGuest(ClientInstance.controller) == 1 then
		local FriendsMenuPopup = MainMenuWidget:openPopup("popup_guest_contentrestricted", ClientInstance.controller)
		FriendsMenuPopup.anyControllerAllowed = true
		FriendsMenuPopup:setOwner(ClientInstance.controller)
		return 
	elseif UIExpression.IsSignedInToLive(ClientInstance.controller) == 0 then
		local FriendsMenuPopup = MainMenuWidget:openPopup("Error", ClientInstance.controller)
		FriendsMenuPopup:setMessage(Engine.Localize("XBOXLIVE_FRIENDS_UNAVAILABLE"))
		FriendsMenuPopup.anyControllerAllowed = true
		return 
	elseif UIExpression.IsContentRatingAllowed(ClientInstance.controller) == 0 or UIExpression.IsAnyControllerMPRestricted() == 1 or not Engine.HasMPPrivileges(ClientInstance.controller) then
		local FriendsMenuPopup = MainMenuWidget:openPopup("Error", ClientInstance.controller)
		FriendsMenuPopup:setMessage(Engine.Localize("XBOXLIVE_MPNOTALLOWED"))
		FriendsMenuPopup.anyControllerAllowed = true
		return 
	elseif UIExpression.AreStatsFetched(ClientInstance.controller) == 0 then
		return 
	elseif UIExpression.IsSubUser(ClientInstance.controller) ~= 1 then
		local FriendsMenuPopup = MainMenuWidget:openPopup("FriendsList", ClientInstance.controller)
		CoD.MainMenu.InitializeLocalPlayers(ClientInstance.controller)
		FriendsMenuPopup:setOwner(ClientInstance.controller)
	end
end

CoD.MainMenu.SignedIntoLive = function (MainMenuWidget, f37_arg1)
	if MainMenuWidget.friendsButton == nil then
		MainMenuWidget:addFriendsButton()
	end
end

CoD.MainMenu.SignedOut = function (MainMenuWidget, f38_arg1)
	if MainMenuWidget.friendsButton ~= nil then
		MainMenuWidget.friendsButton:close()
		MainMenuWidget.friendsButton = nil
	end
end

CoD.MainMenu.InitializeLocalPlayers = function (LocalClientIndex)
	Engine.ExecNow(LocalClientIndex, "disableallclients")
	Engine.ExecNow(LocalClientIndex, "setclientbeingusedandprimary")
end

LUI.createMenu.VCS = function (f40_arg0)
	local f40_local0 = CoD.Menu.New("VCS")
	f40_local0.anyControllerAllowed = true
	f40_local0:addElement(LUI.UIImage.new({
		left = 0,
		top = 0,
		right = 1080,
		bottom = 600,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = false,
		bottomAnchor = false,
		red = 1,
		green = 1,
		blue = 1,
		alpha = 1,
		material = RegisterMaterial("vcs_0")
	}))
	return f40_local0
end

