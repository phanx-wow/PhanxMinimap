--[[
	PhanxMinimap
	Based on LynSettings, oMinimap, nMinimap, rMinimap, Wanderlust, etc.
--]]

local SCALE = 1.2

local FONT      = [[Interface\AddOns\PhanxMedia\font\PTSans-Bold.ttf]]
local FONT_BOLD = [[Interface\AddOns\PhanxMedia\font\PTSans-Bold.ttf]]

if not IsAddOnLoaded( "Blizzard_TimeManager" ) then
	LoadAddOn( "Blizzard_TimeManager" )
end

local ADDON_NAME, namespace = ...

local PhanxMinimap = CreateFrame( "Frame" )
PhanxMinimap:SetScript( "OnEvent", function( self, event, ... ) return self[ event ] and self[ event ]( self, ... ) end )
PhanxMinimap:RegisterEvent( "ADDON_LOADED" )

function PhanxMinimap:ADDON_LOADED( addon )
	if addon ~= ADDON_NAME then return end

	local color = ( CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS )[ select( 2, UnitClass( "player" ) ) ]
	local classR, classG, classB = color.r, color.g, color.b

	MinimapCluster:EnableMouse( false )

	Minimap:SetMaskTexture( [[Interface\AddOns\PhanxMinimap\media\Minimap-Mask]] )

	Minimap:SetScale( SCALE )

	-- Hide ugly checkboard ring crap on quest/archaology blobs
	-- http://www.wowinterface.com/forums/showthread.php?t=42303
	Minimap:SetArchBlobRingScalar( 0 )
	Minimap:SetQuestBlobRingScalar( 0 )

	Minimap:ClearAllPoints()
	Minimap:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", math.floor( -15 / SCALE ), math.floor( -15 / SCALE ) )

	Minimap:EnableMouseWheel( true )
	Minimap:SetScript( "OnMouseWheel", function( self, z )
		local c = Minimap:GetZoom()
		if z > 0 and c < 5 then
			Minimap:SetZoom( c + 1 )
		elseif z < 0 and c > 0 then
			Minimap:SetZoom( c - 1 )
		end
	end )

	local noop = function() end
	for _, obj in pairs( {
		BattlegroundShine,
		GameTimeFrame,
		MiniMapBattlefieldBorder,
		MinimapBorder,
		MinimapBorderTop,
		MiniMapInstanceDifficulty,
		MiniMapMeetingStoneBorder,
		MinimapNorthTag,
		MinimapToggleButton,
		MiniMapTracking,
		MiniMapVoiceChatFrame,
		MiniMapWorldMapButton,
		MinimapZoneText,
		MinimapZoneTextButton,
		MinimapZoomIn,
		MinimapZoomOut,
	} ) do
		obj:Hide()
		obj.Show = noop
	end

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent( Minimap )
	MiniMapBattlefieldFrame:SetPoint( "TOPLEFT", 2, -2 )

	GameTimeFrame:SetAlpha( 0 )
	GameTimeFrame:EnableMouse( false )
	GameTimeCalendarInvitesTexture:SetParent( "Minimap" )

--- Tracking menu on right-click ---

	local Minimap_OnClick = Minimap:GetScript( "OnMouseUp" )
	Minimap:SetScript( "OnMouseUp", function( self, button )
		if button == "RightButton" then
			ToggleDropDownMenu( 1, nil, MiniMapTrackingDropDown, "cursor" )
		else
			Minimap_OnClick( self, button )
		end
	end )

--- Tracking text on mouseover ---
--[==[
	local trackingText = Minimap:CreateFontString( nil, "OVERLAY" )
	trackingText:SetPoint( "BOTTOMLEFT", 3, 1 )
	trackingText:SetFont( FONT, 16 / SCALE, "OUTLINE" )
	trackingText:SetShadowOffset( 0, 0 )
	trackingText:SetTextColor( classR, classG, classB )

	Minimap.trackingText = trackingText

	local trackingNames = setmetatable( {
		["BattleMaster"] = "Battle",
		["Flight Master"] = "Flight",
		["Food & Drink"] = "Food",
		["Profession Trainers"] = "Profession",
		["Low Level Quests"] = "Quests",
		["Points of Interest"] = "POIs",
	}, { __index = function( t, k )
		if not k then return "" end
		local v = k:match( "^[^ ]+ (.+)$" )
		rawset( t, k, v )
		return v
	end } )

	local TEXTURE_STRING_LONG = string.format( "|T%s:%d:%d:0:2:64:64:4:60:4:60|t %s", "%s", 20 / SCALE, 20 / SCALE, "%s" )
	local TEXTURE_STRING_SHORT = string.format( "|T%s:%d:%d:0:2|t%s", "%s", 20 / SCALE, 20 / SCALE, "%s" )
	local textureStrings = setmetatable( { }, { __index = function( t, texture )
		if not texture then return "%s" end
		local textureString
		if texture:match( [[^Interface\Icons\]] ) then
			textureString = string.format( TEXTURE_STRING_LONG, texture, "%s" )
		else
			textureString = string.format( TEXTURE_STRING_SHORT, texture, "%s" )
		end
		rawset( t, texture, textureString )
		return textureString
	end } )

	Minimap:HookScript( "OnEnter", function( self )
		for i = 1, GetNumTrackingTypes() do
			local name, texture, active = GetTrackingInfo( i )
			if active then
				self.trackingText:SetFormattedText( textureStrings[ texture ], trackingNames[ name ] )
				break
			end
		end
		self.trackingText:Show()
	end )

	Minimap:HookScript( "OnLeave", function( self )
		self.trackingText:Hide()
	end )
]==]
--- Instance difficulty text ---

	local instanceText = Minimap:CreateFontString( nil, "OVERLAY" )
	instanceText:SetPoint( "TOPRIGHT", -3, -3 )
	instanceText:SetFont( FONT, 16 / SCALE, "OUTLINE" )
	instanceText:SetShadowOffset( 0, 0 )

	Minimap.instanceText = instanceText

	self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	self:RegisterEvent( "PLAYER_DIFFICULTY_CHANGED" )

	self:PLAYER_DIFFICULTY_CHANGED()

--- Mail text ---

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint( "TOPLEFT", 3, -3 )
	MiniMapMailFrame:SetHeight( 10 )

	MiniMapMailIcon:SetTexture( "" )
	MiniMapMailBorder:SetTexture( "" )

	local mailText = MiniMapMailFrame:CreateFontString( nil, "OVERLAY" )
	mailText:SetPoint( "TOPLEFT" )
	mailText:SetFont( FONT_BOLD, 16 / SCALE, "OUTLINE" )
	mailText:SetShadowOffset( 0, 0 )
	mailText:SetTextColor( 0.4, 1, 0.2 )
	mailText:SetText( "Mail!" )

	Minimap.mailText = mailText

--- Clock ---

	TimeManagerFrame:ClearAllPoints()
	TimeManagerFrame:SetPoint( "TOPRIGHT", Minimap, "BOTTOMRIGHT", 52, -10 )

	local clockButton = TimeManagerClockButton

	clockButton:ClearAllPoints()
	clockButton:SetPoint( "BOTTOMRIGHT", Minimap, -3, 3 )
	clockButton:SetWidth( 55 )
	clockButton:SetHeight( 18 )

	clockButton:RegisterForClicks( "AnyUp" )

	clockButton:SetScript( "OnClick", function( self, button )
		if self.alarmFiring then
			PlaySound( "igMainMenuQuit" )
			TimeManager_TurnOffAlarm()
		elseif button == "RightButton" then
			if not Calendar_Toggle then
				LoadAddOn( "Blizzard_Calendar" )
			end
			Calendar_Toggle()
		else
			TimeManager_Toggle()
		end
	end )

	local GAMETIME_TOOLTIP_TOGGLE_CALENDAR = GAMETIME_TOOLTIP_TOGGLE_CALENDAR:gsub( "Click", "Right-click" )

	function TimeManagerClockButton_UpdateTooltip()
		GameTooltip:ClearLines()

		if TimeManagerClockButton.alarmFiring then
			local alarmMessage = GetCVar( CVAR_ALARM_MESSAGE )
			if alarmMessage:trim() ~= "" then
				GameTooltip:AddLine( alarmMessage, 1, 1, 1 )
				GameTooltip:AddLine( " " )
			end
			GameTooltip:AddLine( TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF )
		else
			GameTime_UpdateTooltip()
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( GAMETIME_TOOLTIP_TOGGLE_CLOCK )
			GameTooltip:AddLine( GAMETIME_TOOLTIP_TOGGLE_CALENDAR )
		end

		GameTooltip:Show()
	end

	function GameTime_UpdateTooltip()
		GameTooltip:AddLine( date( "%A, %d %B %Y" ), 1, 1, 1 )
		GameTooltip:AddLine( " " )
		GameTooltip:AddDoubleLine( TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), nil, nil, nil, 1, 1, 1 )
		GameTooltip:AddDoubleLine( TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), nil, nil, nil, 1, 1, 1 )
	end

	local clockFrame, clockText, clockAlarmTexture = clockButton:GetRegions()

	clockFrame:Hide()
	clockAlarmTexture:SetTexture( "" )

	clockText:ClearAllPoints()
	clockText:SetPoint( "BOTTOMRIGHT", clockButton )
	clockText:SetFont( FONT, 18 / SCALE, "OUTLINE" )
	clockText:SetShadowOffset( 1, -1 )
	clockText:SetJustifyH( "RIGHT" )
	clockText:SetTextColor( classR, classG, classB )

	Minimap.clockText = clockText

	do
		local OnUpdate = TimeManagerClockButton:GetScript( "OnUpdate" )

		local counter = 0
		TimeManagerClockButton:SetScript( "OnUpdate", function( self, elapsed )
			OnUpdate( self, elapsed )
			if not self.alarmFiring then return end
			counter = counter + elapsed
			local val = counter % 0.4
			if counter > 0.2 then
				val = 0.4 - val
			end
			val = val * 5
			clockText:SetTextColor( 1, 1 / val, 1 / val )
		end )
	end

	hooksecurefunc( "TimeManager_FireAlarm", function()
		clockText:SetFont( FONT_BOLD, 18 / SCALE, "OUTLINE" )
		clockText:SetTextColor( 1, 0, 0 )
	end )

	hooksecurefunc( "TimeManager_TurnOffAlarm", function()
		if CalendarGetNumPendingInvites() > 0 then
			clockText:SetFont( FONT_BOLD, 18 / SCALE, "OUTLINE" )
			clockText:SetTextColor( 1, 0.8, 0 )
		else
			clockText:SetFont( FONT, 18 / SCALE, "OUTLINE" )
			clockText:SetTextColor( classR, classG, classB )
		end
	end )

	GameTimeFrame:SetScript( "OnEvent", function()
		if TimeManagerClockButton.alarmFiring then
			return
		end
		if CalendarGetNumPendingInvites() > 0 then
			clockText:SetFont( FONT_BOLD, 18 / SCALE, "OUTLINE" )
			clockText:SetTextColor( 1, 0.8, 0 )
		else
			clockText:SetFont( FONT, 18 / SCALE, "OUTLINE" )
			clockText:SetTextColor( classR, classG, classB )
		end
	end )

--- Gloss overlay effect ---
--[=[
	local gloss = Minimap:CreateTexture( nil, "OVERLAY" )
	gloss:SetTexture( [[Interface\AddOns\PhanxMinimap\media\Minimap-Gloss]] )
	gloss:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", -3, 3 )
	gloss:SetPoint( "BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 3, -3 )
	gloss:SetVertexColor( 0.7, 0.7, 0.7 )
	gloss:SetAlpha( 0.4 )

	Minimap.gloss = gloss
-- ]=]
--- Done! ---

	self:UnregisterEvent( "ADDON_LOADED" )
	self.ADDON_LOADED = nil
end

function PhanxMinimap:PLAYER_DIFFICULTY_CHANGED()
	local name, type, difficulty, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo()

	if ( type == "raid" or type == "party" ) and not ( difficulty == 1 and maxPlayers == 5 ) then
		local heroic

		if isDynamic then
			heroic = dynamicDifficulty == 1
		else
			heroic = difficulty >= 3
		end

		if heroic then
			Minimap.instanceText:SetText( size .. "+" )
			Minimap.instanceText:SetTextColor( 0.4, 1, 0.2 )
		else
			Minimap.instanceText:SetText( size )
			Minimap.instanceText:SetTextColor( 0.4, 1, 0.2 )
		end
	else
		Minimap.instanceText:SetText( "" )
	end
end

PhanxMinimap.PLAYER_ENTERING_WORLD = PhanxMinimap.PLAYER_DIFFICULTY_CHANGED

function GetMinimapShape() return "SQUARE" end