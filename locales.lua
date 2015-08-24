local L = LibStub("AceLocale-3.0"):NewLocale(..., "enUS", true)
L["announceChange"] = "Your current setting is %s. Type %s to change."
L["announceDefer"] = "%s is announcing fails."
L["announceOff"] = "Announcing fails is disabled."
L["announceSelf"] = "Announcing fails to self only."
L["announceRaid"] = "Announcing fails to raid chat."
L["help.1"] = "version %s by %s"
L["help.2"] = "Your current setting is %s. To change it, type one of:"
L["help.always"] = "announce fails to raid chat for Normal+, to self Raid Finder"
L["help.off"] = "do not announce fails"
L["help.raid"] = "announce fails to raid chat for Normal+"
L["help.self"] = "announce fails to self for Normal+"
L["fail.detonation"] = "%s has eye, %s hit the raid. A healer needed the eye to dispel the Priest's bomb."
L["fail.conduit"] = "%s has eye, %s hit the raid. Only the person with the eye can interrupt the Warden's cast."
L["fail.corruption"] = "%s has eye, %s hit %s. The Raven tank needed the eye to prevent the debuff."
L["fail.winds"] = "%s has eye for %ss during %s."
L["newerVersion"] = "Version %s is available. You're currently running version %s."
L["nobody"] = "NOBODY"

-- If you would like to translate, please do!
-- http://wow.curseforge.com/addons/iskarfails/localization/

local locale = GetLocale()
if locale == "deDE" then
  L = LibStub("AceLocale-3.0"):NewLocale(..., locale)
  -- no translation yet
end
