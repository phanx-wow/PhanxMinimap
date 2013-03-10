--[[--------------------------------------------------------------------
----------------------------------------------------------------------]]

local ADDON = ...

local SCALE = 1.25

local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[ select(2, UnitClass("player")) ]
local classR, classG, classB = color.r, color.g, color.b

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

------------------------------------------------------------------------
--	General

Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, floor(-15 / SCALE), floor(-15 / SCALE))

Minimap:SetScale(SCALE)

Minimap:SetMaskTexture("Interface\\AddOns\\"..ADDON.."\\media\\Minimap-Mask")
function GetMinimapShape() return "SQUARE" end

MinimapCluster:EnableMouse(false)

------------------------------------------------------------------------
--	Zoom with mousewheel

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	local zoom = self:GetZoom()
	if delta > 0 and zoom < 5 then
		self:SetZoom(zoom + 1)
	elseif delta < 0 and zoom > 0 then
		self:SetZoom(zoom - 1)
	end
end)

------------------------------------------------------------------------
--	Hide ugly checkboard ring crap on quest/archaology blobs
--	http://www.wowinterface.com/forums/showthread.php?t=42303

Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

------------------------------------------------------------------------
--	Hide buttons and borders

local function Hide(obj)
	if obj.UnregisterAllEvents then
		obj:UnregisterAllEvents()
	end
	obj:Hide()
	obj.Show = obj.Hide
end
for _, obj in pairs({
	BattlegroundShine,
	GameTimeFrame,
	MinimapBorder,
	MinimapBorderTop,
	MinimapCompassTexture,
	MinimapNorthTag,
	MinimapToggleButton,
	MiniMapTracking,
	MiniMapVoiceChatFrame,
	MiniMapWorldMapButton,
	MinimapZoneText,
	MinimapZoneTextButton,
	MinimapZoomIn,
	MinimapZoomOut,
}) do
	Hide(obj)
end

GameTimeFrame:SetAlpha(0)
GameTimeFrame:EnableMouse(false)

GameTimeCalendarInvitesTexture:SetParent(Minimap)

------------------------------------------------------------------------
--	Tracking menu on click

local Minimap_OnClick = Minimap:GetScript("OnMouseUp")
Minimap:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
	else
		Minimap_OnClick(self, button)
	end
end)

------------------------------------------------------------------------
--	Mail text

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMLEFT")
MiniMapMailFrame:SetSize(50, 20)
MiniMapMailFrame:SetScale(1 / SCALE)

MiniMapMailIcon:SetTexture("")
MiniMapMailBorder:SetTexture("")

local mailText = MiniMapMailFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
mailText:SetPoint("BOTTOMLEFT", 5, 3)
mailText:SetTextColor(1, 0.9, 0.8)
mailText:SetText("Mail!")

Minimap.mailText = mailText

------------------------------------------------------------------------
--	Instance difficulty text

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOPLEFT")

GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("TOPLEFT")

------------------------------------------------------------------------
--	Clock text

TimeManagerFrame:ClearAllPoints()
TimeManagerFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 52, -10)
TimeManagerFrame:SetScale(1 / SCALE)

local clockButton = TimeManagerClockButton

clockButton:ClearAllPoints()
clockButton:SetPoint("BOTTOMRIGHT", Minimap, -3, 3)
clockButton:SetWidth(55)
clockButton:SetHeight(18)

clockButton:RegisterForClicks("AnyUp")
clockButton:SetScript("OnClick", function(self, button)
	if self.alarmFiring then
		PlaySound("igMainMenuQuit")
		TimeManager_TurnOffAlarm()
	elseif button == "RightButton" then
		if not Calendar_Toggle then
			LoadAddOn("Blizzard_Calendar")
		end
		Calendar_Toggle()
	else
		TimeManager_Toggle()
	end
end)
--[[
local GAMETIME_TOOLTIP_TOGGLE_CALENDAR = GAMETIME_TOOLTIP_TOGGLE_CALENDAR:gsub("Click", "Right-click")

function TimeManagerClockButton_UpdateTooltip()
	GameTooltip:ClearLines()

	if TimeManagerClockButton.alarmFiring then
		local alarmMessage = GetCVar(CVAR_ALARM_MESSAGE)
		if alarmMessage:trim() ~= "" then
			GameTooltip:AddLine(alarmMessage, 1, 1, 1)
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF)
	else
		GameTime_UpdateTooltip()
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CLOCK)
		GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	end

	GameTooltip:Show()
end

function GameTime_UpdateTooltip()
	GameTooltip:AddLine(date("%A, %d %B %Y"), 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), nil, nil, nil, 1, 1, 1)
end
]]
local clockFrame, clockText, clockAlarmTexture = clockButton:GetRegions()

clockFrame:Hide()
clockAlarmTexture:SetTexture("")

clockText:ClearAllPoints()
clockText:SetPoint("BOTTOMRIGHT", clockButton)
clockText:SetFontObject(NumberFontNormalSmall)
clockText:SetJustifyH("RIGHT")
clockText:SetTextColor(classR, classG, classB)

Minimap.clockText = clockText
--[[
do
	local OnUpdate = TimeManagerClockButton:GetScript("OnUpdate")

	local counter = 0
	TimeManagerClockButton:SetScript("OnUpdate", function(self, elapsed)
		OnUpdate(self, elapsed)
		if not self.alarmFiring then return end
		counter = counter + elapsed
		local val = counter % 0.4
		if counter > 0.2 then
			val = 0.4 - val
		end
		val = val * 5
		clockText:SetTextColor(1, 1 / val, 1 / val)
	end)
end

hooksecurefunc("TimeManager_FireAlarm", function()
	clockText:SetFontObject(NumberFontNormal)
	clockText:SetTextColor(1, 0, 0)
end)

hooksecurefunc("TimeManager_TurnOffAlarm", function()
	if CalendarGetNumPendingInvites() > 0 then
		clockText:SetFontObject(NumberFontNormal)
		clockText:SetTextColor(1, 0.8, 0)
	else
		clockText:SetFontObject(NumberFontNormalSmall)
		clockText:SetTextColor(classR, classG, classB)
	end
end)

GameTimeFrame:SetScript("OnEvent", function()
	if TimeManagerClockButton.alarmFiring then
		return
	end
	if CalendarGetNumPendingInvites() > 0 then
		clockText:SetFontObject(NumberFontNormal)
		clockText:SetTextColor(1, 0.8, 0)
	else
		clockText:SetFontObject(NumberFontNormalSmall)
		clockText:SetTextColor(classR, classG, classB)
	end
end)
]]