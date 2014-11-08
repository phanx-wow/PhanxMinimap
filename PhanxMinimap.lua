--[[--------------------------------------------------------------------
	PhanxMinimap
	Just another basic minimap modification.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
----------------------------------------------------------------------]]

local SCALE = 1.5

------------------------------------------------------------------------
--	General

Minimap:SetScale(SCALE)
Minimap:ClearAllPoints()
Minimap:SetPoint("BOTTOMRIGHT", UIParent, -10, 40)

Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
function GetMinimapShape() return "SQUARE" end

MinimapCluster:EnableMouse(false)

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

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

	MiniMapInstanceDifficulty,
	TimeManagerClockButton,
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
