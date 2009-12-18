--[[
QLayout - My custom chat and worldframe layout stuff
Credits: Tekkub Stoutwrithe (tekLayout)

QLayout/QLayout.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

-- CHANGE THIS VALUE TO MATCH YOUR GAME SCREEN RESOLUTION! 
local SCREEN_WIDTH = 1680

local SCALE, VSIZE, GAP = .85, 85, 6

-- Layout looks like this [ ChatFrame1 ][    ChatFrame3    ][    ChatFrame4    ][ ChatFrame6 ]
local HSIZE_BIG = SCREEN_WIDTH * SCALE * 0.3 -- 30%
local HSIZE_SMALL = SCREEN_WIDTH * SCALE * 0.2 -- 20%
 
local groups = {
  [ChatFrame1] = {"SYSTEM", "SYSTEM_NOMENU", "SAY", "EMOTE", "CHANNEL", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "ACHIEVEMENT"},
	[ChatFrame2] = {},
  [ChatFrame3] = {"GUILD", "GUILD_OFFICER", "GUILD_ACHIEVEMENT"},
  [ChatFrame4] = {"WHISPER", "AFK", "DND", "IGNORED", "PARTY", "PARTY_LEADER", "RAID_WARNING", "RAID", "RAID_LEADER", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "BATTLEGROUND", "BATTLEGROUND_LEADER"},
  [ChatFrame6] = {"COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_MISC_INFO"},
}
 
local function SetupFrame(frame, h, w, r, g, b, a, ...)
  local id = frame:GetID()
 
	-- Undock this frame
  if frame ~= ChatFrame1 then
    -- SetChatWindowDocked(id, nil)
    for i,v in pairs(DOCKED_CHAT_FRAMES) do if v == frame then table.remove(DOCKED_CHAT_FRAMES, i) end end
    frame.isDocked = nil
 
    frame.isLocked = nil
    -- SetChatWindowLocked(id, nil)
  end
 
	-- Set the position and size
  frame:ClearAllPoints()
  frame:SetPoint(...)
  frame:SetHeight(h)
  frame:SetWidth(w)
  frame:Show()
 
	-- Set the BG color
  FCF_SetWindowColor(frame, r/255, g/255, b/255)
  FCF_SetWindowAlpha(frame, a/255)
 
	-- Set the font
  local font, _, flags = frame:GetFont()
  frame:SetFont(font, 11, flags)
  -- SetChatWindowSize(id, 11)
 
	-- Setup the channels for this frame
  ChatFrame_RemoveAllChannels(frame)
  ChatFrame_RemoveAllMessageGroups(frame)
  for i,v in pairs(groups[frame]) do ChatFrame_AddMessageGroup(frame, v) end
end

local function makeMovable(frame)
	local mover = _G[frame:GetName() .. "Mover"] or CreateFrame("Frame", frame:GetName() .. "Mover", frame)
	mover:EnableMouse(true)
	mover:SetPoint("TOP", frame, "TOP", 0, 10)
	mover:SetWidth(160)
	mover:SetHeight(40)
	mover:SetScript("OnMouseDown", function(self)
		self:GetParent():StartMoving()
	end)
	mover:SetScript("OnMouseUp", function(self)
		self:GetParent():StopMovingOrSizing()
	end)
	-- mover:SetClampedToScreen(true)		-- doesn't work?
	frame:SetMovable(true)
end

-- Event handler frame 
local f = CreateFrame("frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
	-- Only do this once
  f:UnregisterAllEvents()
  f:SetScript("OnEvent", nil)
 
  -- Seems Wrath likes to undo scale from time to time
  SetCVar("useUiScale", 1)
  SetCVar("UISCALE", SCALE)
 
  -- Hide those stupid dock thingies that show up on load for a moment
  for i=1,7 do _G["ChatFrame"..i.."TabDockRegionHighlight"]:Hide() end

	-- Setup our frames
  SetupFrame(ChatFrame1, VSIZE, HSIZE_SMALL, 51, 51, 51, 64, "BOTTOMLEFT", UIParent, GAP/2, GAP)
	SetupFrame(ChatFrame2, 100, 350, 32, 32, 32, 128, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 105)
  SetupFrame(ChatFrame3, VSIZE, HSIZE_BIG, 5, 70, 6, 64, "TOPLEFT", ChatFrame1, "TOPRIGHT", GAP, 0)
  SetupFrame(ChatFrame4, VSIZE, HSIZE_BIG, 81, 14, 68, 64, "TOPLEFT", ChatFrame3, "TOPRIGHT", GAP, 0)
  SetupFrame(ChatFrame6, VSIZE, HSIZE_SMALL, 39, 65, 68, 64, "TOPLEFT", ChatFrame4, "TOPRIGHT", GAP, 0)
  SetCVar("chatLocked", 1)

	-- For some reason, Blizz keeps moving this damn thing
  ChatFrame1.SetPoint = function() end
  ChatFrame2.SetPoint = function() end

	-- Hide the combat log frame
	ChatFrame2:Hide()
 
 	-- Setup the world frame viewport
  WorldFrame:ClearAllPoints()
  WorldFrame:SetUserPlaced()
  WorldFrame:SetPoint("TOPRIGHT", UIParent)
  WorldFrame:SetPoint("LEFT", UIParent)
  WorldFrame:SetPoint("BOTTOM", ChatFrame1, "TOP", 0, GAP/2)

	-- Make the options frames movable
	makeMovable(InterfaceOptionsFrame)
	makeMovable(ChatConfigFrame)
	makeMovable(AudioOptionsFrame)
	makeMovable(GameMenuFrame)
	makeMovable(VideoOptionsFrame)

end)
 
