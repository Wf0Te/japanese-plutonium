require("T6.CoDBase")
require("T6.Lobby")
require("T6.EdgeShadow")
require("T6.Menus.Playercard")
require("T6.JoinableList")
require("T6.Error")
require("T6.Menus.CODTv")
require("T6.Menus.SignOutPopup")
require("T6.Menus.RejoinSessionPopup")
CoD.MainLobby = {}
CoD.MainLobby.ShouldPreventCreateLobby = function ()
	if Engine.IsGameLobbyRunning() then
		return true
	else
		return false
	end
end

CoD.MainLobby.OnlinePlayAvailable = function (MainLobbyWidget, ClientInstance, Boolean)
	if Boolean == nil then
		Boolean = false
	end
	if UIExpression.IsSignedInToLive(ClientInstance.controller) == 0 then
		if 0 == UIExpression.GetUsedControllerCount() then
			Engine.Exec(ClientInstance.controller, "xsigninlivenoguests")
		else
			Engine.Exec(ClientInstance.controller, "xsigninlive")
		end
		if 0 == UIExpression.GetUsedControllerCount() then
			Engine.Exec(ClientInstance.controller, "xsigninlivenoguests")
		elseif UIExpression.IsSignedIn(ClientInstance.controller) == 1 then
			MainLobbyWidget:openPopup("popup_signintolive", ClientInstance.controller)
		else
			Engine.Exec(ClientInstance.controller, "xsigninlive")
		end
	elseif UIExpression.IsDemonwareFetchingDone(ClientInstance.controller) == 1 then
		local PlayerStatTable1 = Engine.GetPlayerStats(ClientInstance.controller)
		local PlayerStatTable2 = Engine.GetPlayerStats(ClientInstance.controller)
		if PlayerStatTable1.cacLoadouts.resetWarningDisplayed:get() == 0 then
			PlayerStatTable1.cacLoadouts.resetWarningDisplayed:set(1)
			if PlayerStatTable2.cacLoadouts.classWarningDisplayed ~= nil then
				PlayerStatTable2.cacLoadouts.classWarningDisplayed:set(1)
			end
			local ErrorPopup = MainLobbyWidget:openPopup("Error", ClientInstance.controller)
			ErrorPopup:setMessage(Engine.Localize("MENU_STATS_RESET"))
			ErrorPopup.anyControllerAllowed = true
		elseif CoD.isZombie == false and PlayerStatTable2.cacLoadouts.classWarningDisplayed:get() == 0 then
			PlayerStatTable2.cacLoadouts.classWarningDisplayed:set(1)
			local ErrorPopup = MainLobbyWidget:openPopup("Error", ClientInstance.controller)
			ErrorPopup:setMessage(Engine.Localize("MENU_RESETCUSTOMCLASSES"))
			ErrorPopup.anyControllerAllowed = true
		else
			return 1
		end
	else
		Engine.ExecNow(nil, "initiatedemonwareconnect")
		local ConnectingDemonwarePopup = MainLobbyWidget:openPopup("popup_connectingdw", ClientInstance.controller)
		ConnectingDemonwarePopup.openingStore = Boolean
		ConnectingDemonwarePopup.callingMenu = MainLobbyWidget
	end
	return 0
end

CoD.MainLobby.IsControllerCountValid = function (MainLobbyWidget, LocalClientIndex, MaxLocalPlayers)
	return 1
end

CoD.MainLobby.OpenPlayerMatchPartyLobby = function (MainLobbyWidget, ClientInstance)
	if CoD.MainLobby.ShouldPreventCreateLobby() then
		return 
	elseif CoD.MainLobby.OnlinePlayAvailable(MainLobbyWidget, ClientInstance) == 1 then
		Engine.ProbationCheckForDashboardWarning(CoD.GAMEMODE_PUBLIC_MATCH)
		local InProbation, LocalClientIndexInProbation = Engine.ProbationCheckInProbation(CoD.GAMEMODE_PUBLIC_MATCH)
		if InProbation == true then
			MainLobbyWidget:openPopup("popup_public_inprobation", LocalClientIndexInProbation)
			return 
		end
		local GivenProbation, LocalClientIndexGivenProbation = Engine.ProbationCheckForProbation(CoD.GAMEMODE_PUBLIC_MATCH)
		if GivenProbation == true then
			MainLobbyWidget:openPopup("popup_public_givenprobation", LocalClientIndexGivenProbation)
			return 
		elseif Engine.ProbationCheckParty(CoD.GAMEMODE_PUBLIC_MATCH, ClientInstance.controller) == true then
			MainLobbyWidget:openPopup("popup_public_partyprobation", ClientInstance.controller)
			return 
		end
		local MaxLocalPlayers = UIExpression.DvarInt(LocalClientIndexGivenProbation, "party_maxlocalplayers_playermatch")
		if CoD.MainLobby.IsControllerCountValid(MainLobbyWidget, ClientInstance.controller, MaxLocalPlayers) == 1 then
			MainLobbyWidget.lobbyPane.body.lobbyList.maxLocalPlayers = MaxLocalPlayers
			CoD.SwitchToPlayerMatchLobby(ClientInstance.controller)
			if CoD.isZombie == true then
				Engine.PartyHostSetUIState(CoD.PARTYHOST_STATE_SELECTING_PLAYLIST)
				CoD.PlaylistCategoryFilter = "playermatch"
				MainLobbyWidget:openMenu("SelectMapZM", ClientInstance.controller)
				CoD.GameGlobeZombie.MoveToCenter(ClientInstance.controller)
			else
				MainLobbyWidget:openMenu("PlayerMatchPartyLobby", ClientInstance.controller)
			end
			MainLobbyWidget:close()
		end
	end
end

CoD.MainLobby.OpenCustomGamesLobby = function (MainLobbyWidget, ClientInstance)
	if CoD.MainLobby.ShouldPreventCreateLobby() then
		return 
	else
		CoD.SwitchToPrivateLobby(ClientInstance.controller)
		if CoD.isZombie == true then
			Engine.SetDvar("ui_zm_mapstartlocation", "")
			MainLobbyWidget:openMenu("SelectMapZM", ClientInstance.controller)
			CoD.GameGlobeZombie.MoveToCenter(ClientInstance.controller)
		else
			local PrivateOnlineLobbyMenu = MainLobbyWidget:openMenu("PrivateOnlineGameLobby", ClientInstance.controller)
		end
		MainLobbyWidget:close()
	end
end

CoD.MainLobby.OpenTheaterLobby = function (MainLobbyWidget, ClientInstance)
	if CoD.MainLobby.ShouldPreventCreateLobby() then
		return 
	else
		CoD.SwitchToTheaterLobby(ClientInstance.controller)
		local TheaterLobbyMenu = MainLobbyWidget:openMenu("TheaterLobby", ClientInstance.controller, {
			parent = "MainLobby"
		})
		MainLobbyWidget:close()
	end
end

CoD.MainLobby.OpenBarracks = function (MainLobbyWidget, ClientInstance)
	Engine.Exec(ClientInstance.controller, "party_setHostUIString MENU_VIEWING_PLAYERCARD")
	MainLobbyWidget:openPopup("Barracks", ClientInstance.controller)
end

CoD.MainLobby.OpenControlsMenu = function (MainLobbyWidget, ClientInstance)
	MainLobbyWidget:openPopup("WiiUControllerSettings", ClientInstance.controller, true)
end

CoD.MainLobby.OpenOptionsMenu = function (MainLobbyWidget, ClientInstance)
	MainLobbyWidget:openPopup("OptionsMenu", ClientInstance.controller)
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Multiplayer = function (MainLobbyButtonPane)
	if CoD.isPartyHost() then
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.matchmakingButton)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.customGamesButton)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.theaterButton)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.postTheaterSpacer)
	end
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Zombie = function (MainLobbyButtonPane)
	if CoD.isPartyHost() then
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.customSpacer)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.customGamesButton)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.theaterSpacer)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.theaterButton)
		MainLobbyButtonPane.body.buttonList:addElement(MainLobbyButtonPane.body.optionSpacer)
	end
end

CoD.MainLobby.UpdateButtonPaneButtonVisibilty = function (MainLobbyButtonPane)
	if MainLobbyButtonPane == nil or MainLobbyButtonPane.body == nil then
		return 
	elseif CoD.isZombie == true then
		CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Zombie(MainLobbyButtonPane)
	else
		CoD.MainLobby.UpdateButtonPaneButtonVisibilty_Multiplayer(MainLobbyButtonPane)
	end
	MainLobbyButtonPane:setLayoutCached(false)
end

CoD.MainLobby.UpdateButtonPromptVisibility = function (MainLobbyWidget)
	if MainLobbyWidget == nil then
		return 
	end
	MainLobbyWidget:removeBackButton()
	local ShouldAddJoinButton = false
	if MainLobbyWidget.joinButton ~= nil then
		MainLobbyWidget.joinButton:close()
		ShouldAddJoinButton = true
	end
	MainLobbyWidget.friendsButton:close()
	if MainLobbyWidget.partyPrivacyButton ~= nil then
		MainLobbyWidget.partyPrivacyButton:close()
	end
	MainLobbyWidget:addBackButton()
	MainLobbyWidget:addFriendsButton()
	if ShouldAddJoinButton then
		MainLobbyWidget:addJoinButton()
	end
	if MainLobbyWidget.panelManager.slidingEnabled ~= true then
		MainLobbyWidget.friendsButton:disable()
	end
	if MainLobbyWidget.panelManager:isPanelOnscreen("buttonPane") then
		MainLobbyWidget:addPartyPrivacyButton()
	end
	MainLobbyWidget:addNATType()
end

CoD.MainLobby.PopulateButtons_Multiplayer = function (MainLobbyButtonPane)
	MainLobbyButtonPane.body.matchmakingButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("RANKED"), nil, 1)
	MainLobbyButtonPane.body.matchmakingButton.hintText = Engine.Localize(CoD.MPZM("Change your loadout for public servers.", "ZMUI_PLAYER_MATCH_DESC"))
	MainLobbyButtonPane.body.matchmakingButton:setActionEventName("open_player_match_party_lobby")
	CoD.SetupMatchmakingLock(MainLobbyButtonPane.body.matchmakingButton)
	MainLobbyButtonPane.body.serverBrowserButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("SERVER BROWSER"), nil, 2)
	MainLobbyButtonPane.body.serverBrowserButton.hintText = Engine.Localize(CoD.MPZM("MPUI_PLAYER_MATCH_DESC", "ZMUI_PLAYER_MATCH_DESC"))
	MainLobbyButtonPane.body.serverBrowserButton:setActionEventName("open_server_browser_mainlobby")
	CoD.SetupMatchmakingLock(MainLobbyButtonPane.body.serverBrowserButton)
	MainLobbyButtonPane.body.customGamesButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("PRIVATE MATCH"), nil, 3)
	MainLobbyButtonPane.body.customGamesButton.hintText = Engine.Localize(CoD.MPZM("MPUI_CUSTOM_MATCH_DESC", "ZMUI_CUSTOM_MATCH_DESC"))
	MainLobbyButtonPane.body.customGamesButton:setActionEventName("open_custom_games_lobby")
	CoD.SetupCustomGamesLock(MainLobbyButtonPane.body.customGamesButton)
	MainLobbyButtonPane.body.theaterButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("THEATER"), nil, 4)
	MainLobbyButtonPane.body.theaterButton:setActionEventName("open_theater_lobby")
	MainLobbyButtonPane.body.theaterButton.hintText = Engine.Localize(CoD.MPZM("MPUI_THEATER_DESC", "ZMUI_THEATER_DESC"))
	MainLobbyButtonPane.body.postTheaterSpacer = MainLobbyButtonPane.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 5)
	MainLobbyButtonPane.body.barracksButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("BARRACKS"), nil, 5)
	MainLobbyButtonPane.body.barracksButton.id = "CoD9Button" .. "." .. "MainLobby" .. "." .. Engine.Localize("MENU_BARRACKS_CAPS")
	CoD.SetupBarracksLock(MainLobbyButtonPane.body.barracksButton)
	CoD.SetupBarracksNew(MainLobbyButtonPane.body.barracksButton)
	MainLobbyButtonPane.body.barracksButton:setActionEventName("open_barracks")
	MainLobbyButtonPane.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 8)
	MainLobbyButtonPane.body.optionsButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("OPTIONS"), nil, 6)
	MainLobbyButtonPane.body.optionsButton.hintText = Engine.Localize("MPUI_OPTIONS_DESC")
	MainLobbyButtonPane.body.optionsButton:setActionEventName("open_options_menu")
end

CoD.MainLobby.PopulateButtons_Zombie = function (MainLobbyButtonPane)
	MainLobbyButtonPane.body.customSpacer = MainLobbyButtonPane.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 3)
	MainLobbyButtonPane.body.customGamesButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("PLAY"), nil, 1)
	MainLobbyButtonPane.body.customGamesButton.hintText = Engine.Localize(CoD.MPZM("MPUI_CUSTOM_MATCH_DESC", "ZMUI_CUSTOM_MATCH_DESC"))
	MainLobbyButtonPane.body.customGamesButton:setActionEventName("open_custom_games_lobby")
	CoD.SetupCustomGamesLock(MainLobbyButtonPane.body.customGamesButton)
	MainLobbyButtonPane.body.serverBrowserButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("SERVER BROWSER"), nil, 2)
	MainLobbyButtonPane.body.serverBrowserButton.hintText = Engine.Localize(CoD.MPZM("MPUI_PLAYER_MATCH_DESC", "ZMUI_PLAYER_MATCH_DESC"))
	MainLobbyButtonPane.body.serverBrowserButton:setActionEventName("open_server_browser_mainlobby")
	CoD.SetupMatchmakingLock(MainLobbyButtonPane.body.serverBrowserButton)
	MainLobbyButtonPane.body.theaterButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("MENU_THEATER_CAPS"), nil, 3)
	MainLobbyButtonPane.body.theaterButton:setActionEventName("open_theater_lobby")
	MainLobbyButtonPane.body.theaterButton.hintText = Engine.Localize(CoD.MPZM("MPUI_THEATER_DESC", "ZMUI_THEATER_DESC"))
	MainLobbyButtonPane.body.theaterSpacer = MainLobbyButtonPane.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 6)
	MainLobbyButtonPane.body.optionSpacer = MainLobbyButtonPane.body.buttonList:addSpacer(CoD.CoD9Button.Height / 2, 9)
	MainLobbyButtonPane.body.optionsButton = MainLobbyButtonPane.body.buttonList:addButton(Engine.Localize("MENU_OPTIONS_CAPS"), nil, 4)
	MainLobbyButtonPane.body.optionsButton.hintText = Engine.Localize("MPUI_OPTIONS_DESC")
	MainLobbyButtonPane.body.optionsButton:setActionEventName("open_options_menu")
end

CoD.MainLobby.PopulateButtons = function (MainLobbyButtonPane)
	if CoD.isZombie == true then
		CoD.MainLobby.PopulateButtons_Zombie(MainLobbyButtonPane)
	else
		CoD.MainLobby.PopulateButtons_Multiplayer(MainLobbyButtonPane)
	end
	if CoD.isOnlineGame() then
		if MainLobbyButtonPane.playerCountLabel == nil then
			MainLobbyButtonPane.playerCountLabel = LUI.UIText.new()
			MainLobbyButtonPane:addElement(MainLobbyButtonPane.playerCountLabel)
		end
		MainLobbyButtonPane.playerCountLabel:setLeftRight(true, false, 0, 0)
		MainLobbyButtonPane.playerCountLabel:setTopBottom(false, true, -30 - CoD.textSize.Big, -30)
		MainLobbyButtonPane.playerCountLabel:setFont(CoD.fonts.Big)
		MainLobbyButtonPane.playerCountLabel:setRGB(CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b)
		local PlayerCountText = CoD.Menu.GetOnlinePlayerCountText()
		local PlayerCountUpdateTimer = nil
		if PlayerCountText ~= "" then
			MainLobbyButtonPane.playerCountLabel:setText(PlayerCountText)
			PlayerCountUpdateTimer = LUI.UITimer.new(60000, "update_online_player_count", false, MainLobbyButtonPane.playerCountLabel)
		else
			PlayerCountUpdateTimer = LUI.UITimer.new(1000, "update_online_player_count", false, MainLobbyButtonPane.playerCountLabel)
		end
		MainLobbyButtonPane.playerCountLabel:registerEventHandler("update_online_player_count", CoD.MainLobby.UpdateOnlinePlayerCount)
		MainLobbyButtonPane.playerCountLabel.timer = PlayerCountUpdateTimer
		MainLobbyButtonPane:addElement(PlayerCountUpdateTimer)
	end
end

CoD.MainLobby.UpdateOnlinePlayerCount = function (PlayerCountLabel)
	if CoD.isOnlineGame() then
		local PlayerCountText = CoD.Menu.GetOnlinePlayerCountText()
		if PlayerCountText ~= "" then
			PlayerCountLabel:setText(PlayerCountText)
			PlayerCountLabel.timer.interval = 60000
			PlayerCountLabel.timer:reset()
		end
	end
end

CoD.MainLobby.FirstSignedInToLive = function (MainLobbyWidget)
	if MainLobbyWidget ~= nil then
		if MainLobbyWidget.friendsButton == nil then
			MainLobbyWidget:addFriendsButton()
		end
	end
end

CoD.MainLobby.LastSignedOutOfLive = function (MainLobbyWidget)
end

CoD.MainLobby.PlayerSelected = function (MainLobbyWidget, PlayerSelectedEvent)
	if PlayerSelectedEvent.joinable ~= nil and CoD.canJoinSession(UIExpression.GetPrimaryController(), PlayerSelectedEvent.playerXuid) then
		if MainLobbyWidget.joinButton == nil and not MainLobbyWidget.m_blockJoinButton then
			MainLobbyWidget:addJoinButton()
			MainLobbyWidget:addNATType()
		end
	elseif MainLobbyWidget.joinButton ~= nil then
		MainLobbyWidget.joinButton:close()
		MainLobbyWidget.joinButton = nil
	end
	MainLobbyWidget:dispatchEventToChildren(PlayerSelectedEvent)
end

CoD.MainLobby.PlayerDeselected = function (MainLobbyWidget, PlayerDeselectedEvent)
	if MainLobbyWidget.joinButton ~= nil then
		MainLobbyWidget.joinButton:close()
		MainLobbyWidget.joinButton = nil
	end
	MainLobbyWidget:dispatchEventToChildren(PlayerDeselectedEvent)
end

CoD.MainLobby.CurrentPanelChanged = function (MainLobbyWidget, f27_arg1)
	MainLobbyWidget.m_blockJoinButton = f27_arg1.id ~= "PanelManager.lobbyPane"
end

CoD.MainLobby.BusyList_Update = function (f28_arg0, f28_arg1, f28_arg2, f28_arg3, f28_arg4)
	CoD.PlayerList.Update(f28_arg0, Engine.GetBusyFriendsOfAllLocalPlayers(f28_arg0.maxRows - f28_arg2), f28_arg2, f28_arg3, f28_arg4)
end

CoD.MainLobby.Update = function (MainLobbyWidget, ClientInstance)
	if MainLobbyWidget == nil then
		return 
	elseif UIExpression.IsDemonwareFetchingDone(ClientInstance.controller) == 1 == true then
		MainLobbyWidget.panelManager:processEvent({
			name = "fetching_done"
		})
	end
	CoD.MainLobby.UpdateButtonPaneButtonVisibilty(MainLobbyWidget.buttonPane)
	CoD.MainLobby.UpdateButtonPromptVisibility(MainLobbyWidget)
	MainLobbyWidget:dispatchEventToChildren(ClientInstance)
end

CoD.MainLobby.ClientLeave = function (MainLobbyWidget, ClientInstance)
	Engine.ExecNow(ClientInstance.controller, "leaveAllParties")
	Engine.PartyHostClearUIState()
	CoD.StartMainLobby(ClientInstance.controller)
	CoD.MainLobby.UpdateButtonPaneButtonVisibilty(MainLobbyWidget.buttonPane)
	CoD.MainLobby.UpdateButtonPromptVisibility()
end

CoD.MainLobby.GoBack = function (MainLobbyWidget, ClientInstance)
	Engine.SessionModeResetModes()
	Engine.Exec(ClientInstance.controller, "xstopprivateparty")
	if CoD.isPS3 then
		Engine.Exec(ClientInstance.controller, "signoutSubUsers")
	end
	MainLobbyWidget:setPreviousMenu("MainMenu")
	CoD.Menu.goBack(MainLobbyWidget, ClientInstance.controller)
end

CoD.MainLobby.Back = function (MainLobbyWidget, ClientInstance)
	if CoD.Lobby.OpenSignOutPopup(MainLobbyWidget, ClientInstance) == true then
		return 
	elseif UIExpression.IsPrimaryLocalClient(ClientInstance.controller) == 0 then
		Engine.Exec(ClientInstance.controller, "signclientout")
		MainLobbyWidget:processEvent({
			name = "controller_backed_out"
		})
		return 
	elseif UIExpression.AloneInPartyIgnoreSplitscreen(ClientInstance.controller, 1) == 0 then
		local CustomLeaveMessage = {
			params = {}
		}
		if not CoD.isPartyHost() then
			CustomLeaveMessage.titleText = Engine.Localize("MENU_LEAVE_LOBBY_TITLE")
			CustomLeaveMessage.messageText = Engine.Localize("MENU_LEAVE_LOBBY_CLIENT_WARNING")
			table.insert(CustomLeaveMessage.params, {
				leaveHandler = CoD.MainLobby.ClientLeave,
				leaveEvent = "client_leave",
				leaveText = Engine.Localize("MENU_LEAVE_LOBBY_AND_PARTY"),
				debugHelper = "You're a client of a private party, remove you from the party"
			})
		else
			CustomLeaveMessage.titleText = Engine.Localize("MENU_DISBAND_PARTY_TITLE")
			CustomLeaveMessage.messageText = Engine.Localize("MENU_DISBAND_PARTY_HOST_WARNING")
			table.insert(CustomLeaveMessage.params, {
				leaveHandler = CoD.MainLobby.GoBack,
				leaveEvent = "host_leave",
				leaveText = Engine.Localize("MENU_LEAVE_AND_DISBAND_PARTY"),
				debugHelper = "You're the leader of a private party, choosing this will disband your party"
			})
		end
		CoD.Lobby.ConfirmLeave(MainLobbyWidget, ClientInstance.controller, nil, nil, CustomLeaveMessage)
	else
		CoD.MainLobby.GoBack(MainLobbyWidget, ClientInstance)
	end
end

CoD.MainLobby.AddLobbyPaneElements = function (LobbyPane, MenuParty)
	CoD.LobbyPanes.addLobbyPaneElements(LobbyPane, MenuParty, UIExpression.DvarInt(nil, "party_maxlocalplayers_mainlobby"))
	LobbyPane.body.lobbyList.joinableList = CoD.JoinableList.New({
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = true,
		bottomAnchor = false,
		top = 0,
		bottom = 0
	}, false, "", "joinableList", LobbyPane.id)
	LobbyPane.body.lobbyList.joinableList.pane = LobbyPane
	LobbyPane.body.lobbyList.joinableList.maxRows = CoD.MaxPlayerListRows - 2
	LobbyPane.body.lobbyList.joinableList.statusText = Engine.Localize("MENU_PLAYERLIST_FRIENDS_PLAYING")
	LobbyPane.body.lobbyList:addElement(LobbyPane.body.lobbyList.joinableList)
end

CoD.MainLobby.ButtonListButtonGainFocus = function (f34_arg0, ClientInstance)
	f34_arg0:dispatchEventToParent({
		name = "add_party_privacy_button"
	})
	CoD.Lobby.ButtonListButtonGainFocus(f34_arg0, ClientInstance)
end

CoD.MainLobby.ButtonListAddButton = function (f35_arg0, f35_arg1, f35_arg2, f35_arg3)
	local f35_local0 = CoD.Lobby.ButtonListAddButton(f35_arg0, f35_arg1, f35_arg2, f35_arg3)
	f35_local0:registerEventHandler("gain_focus", CoD.MainLobby.ButtonListButtonGainFocus)
	return f35_local0
end

CoD.MainLobby.AddButtonPaneElements = function (f36_arg0)
	CoD.LobbyPanes.addButtonPaneElements(f36_arg0)
	f36_arg0.body.buttonList.addButton = CoD.MainLobby.ButtonListAddButton
end

CoD.MainLobby.PopulateButtonPaneElements = function (MainLobbyButtonPane)
	CoD.MainLobby.PopulateButtons(MainLobbyButtonPane)
	CoD.MainLobby.UpdateButtonPaneButtonVisibilty(MainLobbyButtonPane)
end

CoD.MainLobby.GoToFindingGames_Zombie = function (MainLobbyWidget, ClientInstance)
	Engine.Exec(ClientInstance.controller, "xstartparty")
	Engine.Exec(ClientInstance.controller, "updategamerprofile")
	local PublicGameLobbyMenu = MainLobbyWidget:openMenu("PublicGameLobby", ClientInstance.controller)
	PublicGameLobbyMenu:setPreviousMenu("MainLobby")
	PublicGameLobbyMenu:registerAnimationState("hide", {
		alpha = 0
	})
	PublicGameLobbyMenu:animateToState("hide")
	PublicGameLobbyMenu:registerAnimationState("show", {
		alpha = 1
	})
	PublicGameLobbyMenu:animateToState("show", 500)
	MainLobbyWidget:close()
end

CoD.MainLobby.ButtonPromptJoin = function (MainLobbyWidget, ClientInstance)
	if UIExpression.IsGuest(ClientInstance.controller) == 1 then
		local f39_local0 = MainLobbyWidget:openPopup("Error", ClientInstance.controller)
		f39_local0:setMessage(Engine.Localize("XBOXLIVE_NOGUESTACCOUNTS"))
		f39_local0.anyControllerAllowed = true
		return 
	end 
	if MainLobbyWidget.lobbyPane.body.lobbyList.selectedPlayerXuid ~= nil then
		Engine.SetDvar("selectedPlayerXuid", MainLobbyWidget.lobbyPane.body.lobbyList.selectedPlayerXuid)
		CoD.joinPlayer(ClientInstance.controller, MainLobbyWidget.lobbyPane.body.lobbyList.selectedPlayerXuid)
	end
end

CoD.MainLobby.OpenIMGUIServerBrowser = function(MainLobbyWidget, ClientInstance)
	Engine.Exec(ClientInstance.controller, "plutoniumServers")
end

LUI.createMenu.MainLobby = function (LocalClientIndex)
	local MainLobbyName = Engine.Localize(CoD.MPZM("MENU_MULTIPLAYER_CAPS", "MENU_ZOMBIES_CAPS"))
	local MainLobbyWidget = CoD.Lobby.New("MainLobby", LocalClientIndex, nil, MainLobbyName)
	MainLobbyWidget.controller = LocalClientIndex
	MainLobbyWidget.anyControllerAllowed = true
	MainLobbyWidget:setPreviousMenu("MainMenu")
	MainLobbyWidget.m_blockJoinButton = true
	if CoD.isZombie == true then
		Engine.Exec(LocalClientIndex, "xsessionupdate")
		Engine.SetDvar("party_readyPercentRequired", 0)
	end
	MainLobbyWidget:addTitle(MainLobbyName)
	MainLobbyWidget.addButtonPaneElements = CoD.MainLobby.AddButtonPaneElements
	MainLobbyWidget.populateButtonPaneElements = CoD.MainLobby.PopulateButtonPaneElements
	MainLobbyWidget.addLobbyPaneElements = CoD.MainLobby.AddLobbyPaneElements
	MainLobbyWidget:updatePanelFunctions()
	MainLobbyWidget:registerEventHandler("partylobby_update", CoD.MainLobby.Update)
	MainLobbyWidget:registerEventHandler("button_prompt_back", CoD.MainLobby.Back)
	MainLobbyWidget:registerEventHandler("first_signed_in", CoD.MainLobby.FirstSignedInToLive)
	MainLobbyWidget:registerEventHandler("last_signed_out", CoD.MainLobby.LastSignedOutOfLive)
	MainLobbyWidget:registerEventHandler("player_selected", CoD.MainLobby.PlayerSelected)
	MainLobbyWidget:registerEventHandler("player_deselected", CoD.MainLobby.PlayerDeselected)
	MainLobbyWidget:registerEventHandler("current_panel_changed", CoD.MainLobby.CurrentPanelChanged)
	MainLobbyWidget:registerEventHandler("open_custom_games_lobby", CoD.MainLobby.OpenCustomGamesLobby)
	MainLobbyWidget:registerEventHandler("open_theater_lobby", CoD.MainLobby.OpenTheaterLobby)
	MainLobbyWidget:registerEventHandler("open_barracks", CoD.MainLobby.OpenBarracks)
	MainLobbyWidget:registerEventHandler("open_options_menu", CoD.MainLobby.OpenOptionsMenu)
	MainLobbyWidget:registerEventHandler("open_session_rejoin_popup", CoD.MainLobby.OpenSessionRejoinPopup)
	MainLobbyWidget:registerEventHandler("button_prompt_join", CoD.MainLobby.ButtonPromptJoin)
	MainLobbyWidget:registerEventHandler("open_player_match_party_lobby", CoD.MainLobby.OpenPlayerMatchPartyLobby)
	MainLobbyWidget:registerEventHandler("open_server_browser_mainlobby", CoD.MainLobby.OpenIMGUIServerBrowser)
	MainLobbyWidget.lobbyPane.body.lobbyList:setSplitscreenSignInAllowed(true)
	CoD.MainLobby.PopulateButtons(MainLobbyWidget.buttonPane)
	CoD.MainLobby.UpdateButtonPaneButtonVisibilty(MainLobbyWidget.buttonPane)
	CoD.MainLobby.UpdateButtonPromptVisibility(MainLobbyWidget)
	if CoD.useController then
		if CoD.isZombie then
			MainLobbyWidget.buttonPane.body.buttonList:selectElementIndex(1)
		elseif not MainLobbyWidget.buttonPane.body.buttonList:restoreState() then
			if CoD.isPartyHost() then
				MainLobbyWidget.buttonPane.body.matchmakingButton:processEvent({
					name = "gain_focus"
				})
			else
				MainLobbyWidget.buttonPane.body.theaterButton:processEvent({
					name = "gain_focus"
				})
			end
		end
	end
	MainLobbyWidget.categoryInfo = CoD.Lobby.CreateInfoPane()
	MainLobbyWidget.playlistInfo = CoD.Lobby.CreateInfoPane()
	MainLobbyWidget.lobbyPane.body:close()
	MainLobbyWidget.lobbyPane.body = nil
	CoD.MainLobby.AddLobbyPaneElements(MainLobbyWidget.lobbyPane, Engine.Localize("MENU_PARTY_CAPS"))
	if UIExpression.AnySignedInToLive() == 1 then
		CoD.MainLobby.FirstSignedInToLive(MainLobbyWidget)
	else
		CoD.MainLobby.LastSignedOutOfLive(MainLobbyWidget)
	end
	Engine.SystemNeedsUpdate(nil, "party")
	if not CoD.isZombie then
		CoD.CheckClasses.CheckClasses()
	end
	Engine.SessionModeSetOnlineGame(true)
	return MainLobbyWidget
end

CoD.MainLobby.OpenSessionRejoinPopup = function (MainLobbyWidget, ClientInstance)
	MainLobbyWidget:openPopup("RejoinSessionPopup", ClientInstance.controller)
end