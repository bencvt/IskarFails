local addonName = ...
local A = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0")
A.NAME = addonName
A.VERSION = GetAddOnMetadata(A.NAME, "Version")
A.AUTHOR = GetAddOnMetadata(A.NAME, "Author")
A.DEBUG = 0 -- 0=off 1=on 2=verbose
_G[A.NAME] = A
local L = LibStub("AceLocale-3.0"):GetLocale(A.NAME)

-- GLOBALS: LibStub, SLASH_ISKARFAILS1
local date, pairs, print, format, gsub, random, select, strlower, strsplit, time, tonumber, wipe = date, pairs, print, format, gsub, random, select, strlower, strsplit, time, tonumber, wipe
local GetSpellLink, InCombatLockdown, IsInRaid, RegisterAddonMessagePrefix, SendAddonMessage, SendChatMessage, UnitExists, UnitIsUnit = GetSpellLink, InCombatLockdown, IsInRaid, RegisterAddonMessagePrefix, SendAddonMessage, SendChatMessage, UnitExists, UnitIsUnit
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local PREFIX = "ISKARFAILS"
local ENCOUNTERID_ISKAR = 1788
local DIFFICULTYID_RAIDFINDER = 17
local SPELLID_EYE = 179202
local SPELLID_WINDS = 181957
local SPELLID_DETONATION = 181748
local SPELLIDS_CORRUPTION = {[181824]=true, [187990]=true}
local SPELLIDS_CONDUIT = {[181827]=true, [187998]=true}

L["fail.detonation"] = "{rt7} "..L["fail.detonation"]
L["fail.conduit"] = "{rt1} "..L["fail.conduit"]
L["fail.corruption"] = "{rt2} "..L["fail.corruption"]
L["fail.winds"] = "{rt6} "..L["fail.winds"]

A.private = {
  db = false,
  newerVersion = false,
  priority = random() + 0, -- increment by 1 for each major version
  someoneElseAnnouncing = false,
  someoneElseAnnouncingTimer = false,
  standby = true,
  eyeHolder = L["nobody"],
  detonationDone = 0,
  windsVictims = {},
  windsTimer = false,
  windsSeconds = 0,
  isRaidFinder = false,
}
local R = A.private

SLASH_ISKARFAILS1 = "/iskarfails"
SlashCmdList["ISKARFAILS"] = function(args)
  args = strlower(args)
  if args == "off" or args == "raid" or args == "self" or args == "always" then
    R.db.profile.options.announce = args
    if R.standby then
      A:Printf(L["announceChange"], "|cff1784d1"..R.db.profile.options.announce.."|r", "|cff1784d1/iskarfails|r")
    else
      A:PrintAnnounceMode()
    end
  else
    A:Printf(L["help.1"], A.VERSION, "|cff33ff99"..A.AUTHOR.."|r")
    print(format(L["help.2"], "|cff1784d1"..R.db.profile.options.announce.."|r"))
    print("  |cff1784d1/iskarfails raid|r - "..L["help.raid"])
    print("  |cff1784d1/iskarfails self|r - "..L["help.self"])
    print("  |cff1784d1/iskarfails always|r - "..L["help.always"])
    print("  |cff1784d1/iskarfails off|r - "..L["help.off"])
  end
end

function A:OnInitialize()
  R.db = LibStub("AceDB-3.0"):New("IskarFailsDB", {profile={options={announce="raid"}}}, true)
end

function A:OnEnable()
  A:RegisterEvent("CHAT_MSG_ADDON")
  A:RegisterEvent("ENCOUNTER_START")
  A:RegisterEvent("ENCOUNTER_END")
  A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  RegisterAddonMessagePrefix(PREFIX)
end

function A:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
  if prefix ~= PREFIX or not sender or not message then
    return
  end
  if not UnitExists(sender) then
    sender = strsplit("-", sender, 2)
  end
  message = gsub(message, "|", "||")
  if A.DEBUG >= 1 then A:Debugf("event=%s prefix=%s message=%s channel=%s sender=%s isPlayer=%s", event, prefix, message, channel, sender, UnitIsUnit("player", sender) and "true" or "false") end
  if UnitIsUnit("player", sender) then
    return
  end
  local cmd
  cmd, message = strsplit(":", message, 2)
  if cmd == "v" then
    if not R.newerVersion and (message > A.VERSION) then
      A:Printf(L["newerVersion"], "|cff1784d1"..message.."|r", A.VERSION)
      R.newerVersion = message
    end
  elseif cmd == "p" then
    message = tonumber(message)
    if (message and message > R.priority) or not A:IsAnnouncingToRaid() then
      R.someoneElseAnnouncing = sender
      -- Use a short timer to ensure we only get the ultimate king of the hill.
      if not R.someoneElseAnnouncingTimer then
        R.someoneElseAnnouncingTimer = A:ScheduleTimer(A.PrintAnnounceMode, 2.5)
      end
    end
  end
end

function A:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, raidSize)
  if A.DEBUG >= 1 then A:Debugf("event=%s encounterID=%s encounterName=%s difficultyID=%s raidSize=%s", event, encounterID, encounterName, difficultyID, raidSize) end
  R.isRaidFinder = (difficultyID == 17)
  if encounterID == ENCOUNTERID_ISKAR then
    R.standby = false
    A:Reset()
    if A:IsAnnouncingToRaid() then
      -- In case there are multiple people running this addon, determine who
      -- gets to spam chat. Add in a short delay so as to not add to the
      -- initial flood of fight data going back and forth. Nothing dangerous
      -- happens during the first few seconds of the fight anyway.
      A:SendDelayedAddonMessage(2.5, "p:"..R.priority)
    end
    A:PrintAnnounceMode()
  else
    R.standby = true
  end
end

function A:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, raidSize, endStatus)
  if A.DEBUG >= 1 then A:Debugf("event=%s encounterID=%s encounterName=%s difficultyID=%s raidSize=%s endStatus=%s", event, encounterID, encounterName, difficultyID, raidSize, endStatus) end
  R.standby = true
  A:Reset()
  R.eyeHolder = L["nobody"]
  A:SendDelayedAddonMessage(2.5, "v:"..A.VERSION)
end

function A:COMBAT_LOG_EVENT_UNFILTERED(event, ts, e, ...)
  if R.standby then
    -- Eye can (and should) be grabbed before the encounter starts.
    if e == "SPELL_AURA_APPLIED" and select(10, ...) == SPELLID_EYE then
      R.eyeHolder = select(7, ...)
    end
    -- Ignore other events when on standby.
  elseif e == "SPELL_AURA_APPLIED" then
    local spellID = select(10, ...)
    if SPELLIDS_CORRUPTION[spellID] then
      A:SendChatMessagef(L["fail.corruption"], R.eyeHolder, GetSpellLink(spellID), select(7, ...))
    elseif spellID == SPELLID_EYE then
      R.eyeHolder = select(7, ...)
      A:StartWindsTimer()
    elseif spellID == SPELLID_WINDS then
      local victims = A:NumWindsVictims()
      R.windsVictims[select(7, ...)] = true
      if victims == 0 then
        A:StartWindsTimer()
      end
    end
  elseif e == "SPELL_AURA_REMOVED" then
    if select(10, ...) == SPELLID_WINDS then
      R.windsVictims[select(7, ...)] = nil
    end
  elseif e == "SPELL_DAMAGE" then
    local spellID = select(10, ...)
    if spellID == SPELLID_DETONATION then
      local now = time()
      if now > R.detonationDone then
        R.detonationDone = now + 10
        A:SendChatMessagef(L["fail.detonation"], R.eyeHolder, GetSpellLink(spellID))
      end
    end
  elseif e == "SPELL_CAST_SUCCESS" then
    local spellID = select(10, ...)
    if SPELLIDS_CONDUIT[spellID] then
      A:SendChatMessagef(L["fail.conduit"], R.eyeHolder, GetSpellLink(spellID))
    end
  end
end

function A:Reset()
  R.someoneElseAnnouncing = false
  if R.someoneElseAnnouncingTimer then
    A:CancelTimer(R.someoneElseAnnouncingTimer)
  end
  R.someoneElseAnnouncingTimer = false
  R.detonationDone = 0
  wipe(R.windsVictims)
  A:StopWindsTimer()
end

function A:StopWindsTimer()
  if R.windsTimer then
    A:CancelTimer(R.windsTimer)
    R.windsTimer = false
  end
  R.windsSeconds = 0
end

local function windsTick()
  if R.standby or A:NumWindsVictims() == 0 or not InCombatLockdown() then
    A:StopWindsTimer()
    return
  end
  R.windsSeconds = R.windsSeconds + 2
  A:SendChatMessagef(L["fail.winds"], R.eyeHolder, R.windsSeconds, GetSpellLink(SPELLID_WINDS))
end

function A:StartWindsTimer()
  A:StopWindsTimer()
  if A:NumWindsVictims() == 0 then
    if A.DEBUG >= 2 then A:Debugf("skip StartWindsTimer eyeHolder=%s #windsVictims=0", R.eyeHolder) end
    return
  end
  if A.DEBUG >= 2 then A:Debugf("set StartWindsTimer eyeHolder=%s #windsVictims=%s", R.eyeHolder, A:NumWindsVictims()) end
  R.windsSeconds = 0
  R.windsTimer = A:ScheduleRepeatingTimer(windsTick, 2.0)
end

function A:NumWindsVictims()
  local count = 0
  for name, _ in pairs(R.windsVictims) do
    if UnitExists(name) then
      count = count + 1
    else
      R.windsVictims[name] = nil
    end
  end
  return count
end

function A:IsAnnouncingToRaid()
  if not IsInRaid() or R.standby or R.someoneElseAnnouncing or R.isRaidFinder then
    return false
  else
    return R.db.profile.options.announce == "raid" or R.db.profile.options.announce == "always"
  end
end

function A:IsAnnouncingToSelf()
  if R.standby or R.someoneElseAnnouncing then
    return false
  elseif R.isRaidFinder then
    return R.db.profile.options.announce == "always"
  else
    return R.db.profile.options.announce == "self" or R.db.profile.options.announce == "always"
  end
end

function A:PrintAnnounceMode()
  local message
  if R.someoneElseAnnouncing then
    message = format(L["announceDefer"], R.someoneElseAnnouncing)
  elseif A:IsAnnouncingToRaid() then
    message = L["announceRaid"]
  elseif A:IsAnnouncingToSelf() then
    message = L["announceSelf"]
  else
    message = L["announceOff"]
  end
  A:Printf("%s %s", message, format(L["announceChange"], "|cff1784d1"..R.db.profile.options.announce.."|r", "|cff1784d1/iskarfails|r"))
end

function A:SendDelayedAddonMessage(delay, message)
  A:ScheduleTimer(function()
    if IsInRaid() then
      SendAddonMessage(PREFIX, message, IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID")
    end
  end, delay)
end

function A:SendChatMessagef(message, ...)
  if A:IsAnnouncingToRaid() then
    message = format("%s %s", A.NAME, format(message, ...))
    SendChatMessage(message, IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID")
  elseif A:IsAnnouncingToSelf() then
    A:Printf(message, ...)
  end
end

function A:Printf(message, ...)
  message = format(message, ...)
  message = gsub(message, "{rt([1-8])}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:14:14:0:0|t")
  print(format("|cff33ff99%s|r %s", A.NAME, message))
end

function A:Debugf(message, ...)
  print(format("|cff999999[%s %s]|r %s", A.NAME, date("%H:%M:%S"), format(message, ...)))
end

function A:DebugTestAnnounce(eyeHolder, tankName)
  eyeHolder = eyeHolder or "Halfasleep"
  tankName = tankName or "Mctank"
  SendChatMessage(A.NAME.." "..format(L["fail.winds"], eyeHolder, 2, GetSpellLink(SPELLID_WINDS)), "RAID")
  SendChatMessage(A.NAME.." "..format(L["fail.winds"], eyeHolder, 4, GetSpellLink(SPELLID_WINDS)), "RAID")
  SendChatMessage(A.NAME.." "..format(L["fail.winds"], eyeHolder, 6, GetSpellLink(SPELLID_WINDS)), "RAID")
  SendChatMessage(A.NAME.." "..format(L["fail.detonation"], eyeHolder, GetSpellLink(SPELLID_DETONATION), tankName), "RAID")
  SendChatMessage(A.NAME.." "..format(L["fail.conduit"], eyeHolder, GetSpellLink(181827)), "RAID")
  SendChatMessage(A.NAME.." "..format(L["fail.corruption"], eyeHolder, GetSpellLink(181824), tankName), "RAID")
end
