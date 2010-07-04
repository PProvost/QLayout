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

local VSIZE, GAP = 85, 6

local groups = {
  [ChatFrame1] = {"SYSTEM", "SYSTEM_NOMENU", "SAY", "EMOTE", "CHANNEL", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "ACHIEVEMENT", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_MISC_INFO"},
  [ChatFrame3] = {"GUILD", "OFFICER", "GUILD_OFFICER", "GUILD_ACHIEVEMENT"},
  [ChatFrame4] = {"WHISPER", "AFK", "DND", "IGNORED", "PARTY", "PARTY_LEADER", "RAID_WARNING", "RAID", "RAID_LEADER", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "BATTLEGROUND", "BATTLEGROUND_LEADER"},
}

local function hide(self)
	if not self.override then
		self:Hide()
	end
	self.override = nil
end

local function noop()
	-- Do nothing!!
end

local function SetupFrame(frame, h, w, r, g, b, a, ...)
  local id = frame:GetID()
 
	-- Undock this frame
  if frame ~= ChatFrame1 then
		FCF_UnDockFrame(frame);
    -- for i,v in pairs(DOCKED_CHAT_FRAMES) do if v == frame then table.remove(DOCKED_CHAT_FRAMES, i) end end
  end

	frame:SetClampRectInsets(0, 0, 0, 0)

	ff = _G[frame:GetName() .. "Tab"]
	ff:Hide()
	ff:SetScript("OnShow", hide)

	-- Set the position and size
  frame:ClearAllPoints()
	frame:SetMinResize(w,h)
	frame:SetMaxResize(w,h)
  frame:SetPoint(...)
  frame:SetHeight(h)
  frame:SetWidth(w)
  frame:Show()
	frame:SetUserPlaced()
 
	-- Set the BG color
  FCF_SetWindowColor(frame, r/255, g/255, b/255)
  FCF_SetWindowAlpha(frame, a/255)
 
	-- Set the font
  local font, _, flags = frame:GetFont()
  frame:SetFont(font, 11, flags)
  -- SetChatWindowSize(id, 11)

	FCF_SetLocked(frame, true)
 
	-- Setup the channels for this frame
  ChatFrame_RemoveAllChannels(frame)
  ChatFrame_RemoveAllMessageGroups(frame)
  for i,v in pairs(groups[frame]) do ChatFrame_AddMessageGroup(frame, v) end

	-- Lock it in place
	FCF_SetLocked(frame, 1)

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
  SetCVar("UISCALE", 0.85)
 
	-- Editbox
	ChatFrame1EditBox:ClearAllPoints()
	ChatFrame1EditBox.ClearAllPoints = function() end
	ChatFrame1EditBox:SetPoint("CENTER", WorldFrame)
	ChatFrame1EditBox.SetPoint = function() end
	ChatFrame1EditBox:SetWidth(300)


	-- Setup our frames
	--[[
  SetupFrame(ChatFrame1, 240, 200, 51, 51, 51, 64, "TOPRIGHT", UIParent, "TOPRIGHT", 28, -20)
  SetupFrame(ChatFrame3, 312, 200, 5, 70, 6, 64, "TOPRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, -10)
  SetupFrame(ChatFrame4, 311, 200, 81, 14, 68, 64, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 28)
	]]

  SetupFrame(ChatFrame3, 312, 200, 5, 70, 6, 64, "TOPRIGHT", UIParent, "TOPRIGHT", 28, -20)
  SetupFrame(ChatFrame4, 311, 200, 81, 14, 68, 64, "TOPRIGHT", ChatFrame3, "BOTTOMRIGHT", 0, -10)
  SetupFrame(ChatFrame1, 240, 200, 65, 27, 0, 64, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 28)
	-- 65, 27, 0
	-- 51, 51, 51

	-- Combat log
	FCF_UnDockFrame(ChatFrame2);
	FCF_SetLocked(ChatFrame2, nil)
	ChatFrame2:ClearAllPoints()
	ChatFrame2:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", -15, 15 )
	ChatFrame2:Hide()
	ChatFrame2Tab:Hide()

	-- Watch frame
	local wf = WatchFrame
	local wfw, wfh = wf:GetWidth(), wf:GetHeight()
	wf:ClearAllPoints()
	wf.ClearAllPoints = function() end
	wf:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 25, -20)
	wf.SetPoint = function() end
	wf:SetHeight(wfh)
	wf:SetWidth(wfw)
	WatchFrame_Update()

 	-- Setup the world frame viewport
  WorldFrame:ClearAllPoints()
  WorldFrame:SetUserPlaced()
  WorldFrame:SetPoint("TOPLEFT", UIParent)
  WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, -173, 100)

	-- Make the options frames movable
	makeMovable(InterfaceOptionsFrame)
	makeMovable(ChatConfigFrame)
	makeMovable(AudioOptionsFrame)
	makeMovable(GameMenuFrame)
	makeMovable(VideoOptionsFrame)

end)
 
