--[[--------------------------------------------------------------------
	PhanxMinimap
	Just another basic minimap modification.
	Copyright (c) 2008-2015 Phanx <addons@phanx.net>. All rights reserved.
----------------------------------------------------------------------]]

local SCALE = 1.25

------------------------------------------------------------------------
--	General

Minimap:SetScale(SCALE)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, -10, -10)

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
	GarrisonLandingPageMinimapButton,
	MinimapBorder,
	MinimapBorderTop,
	MinimapCompassTexture,
	MiniMapInstanceDifficulty,
	MinimapNorthTag,
	MinimapToggleButton,
	MiniMapTracking,
	MiniMapVoiceChatFrame,
	MiniMapWorldMapButton,
	MinimapZoneText,
	MinimapZoneTextButton,
	MinimapZoomIn,
	MinimapZoomOut,
	TimeManagerClockButton,
}) do
	Hide(obj)
end

GameTimeFrame:SetAlpha(0)
GameTimeFrame:EnableMouse(false)

GameTimeCalendarInvitesTexture:SetParent(Minimap)

GarrisonLandingPageMinimapButton.IsShown = function() return true end -- otherwise the Garrison Report UI won't show

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
