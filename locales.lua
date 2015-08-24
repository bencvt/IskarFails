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
  L["announceChange"] = "Deine aktuelle Einstellung ist %s. Tippe %s ein, um dies zu ändern."
  L["announceDefer"] = "%s kündigt Fehler an."
  L["announceOff"] = "Fehlerankündigung ist deaktiviert."
  L["announceRaid"] = "Fehler werden in den Schlachtzugs-Chat angekündigt."
  L["announceSelf"] = "Fehlerankündigung nur zu dir selbst" -- Needs review
  L["fail.conduit"] = "%s hat das Auge, %s hat den Schlachtzug getroffen. Nur die Person mit dem Auge kann den Zauber vom Wächter unterbrechen."
  L["fail.corruption"] = "%s hat das Auge, %s hat den Schlachtzug getroffen. Der Tank des Rabens brauchte das Auge, um den Debuff zu verhindern."
  L["fail.detonation"] = "%s hat das Auge, %s hat den Schlachtzug getroffen. Ein Heiler brauchte das Auge, um die Bombe des Priesters zu bannen."
  L["fail.winds"] = "%s hat das Auge für %ss während %s." -- Needs review
  L["help.1"] = "Version %s von %s"
  L["help.2"] = "Deine aktuelle Einstellung ist %s. Um dies zu ändern, Tippe einen der:" -- Needs review
  L["help.always"] = "Fehler werden ab Normal in den Schlachtzugs-Chat angekündigt und im Schlachtzugsbrowser zu dir" -- Needs review
  L["help.off"] = "Fehler nicht ankündigen"
  L["help.raid"] = "Fehler werden auf Normal oder höher in den Schlachtzugs-Chat angekündigt"
  L["help.self"] = "Fehler werden auf Normal oder höher dir selbst angekündigt" -- Needs review
  L["newerVersion"] = "Version %s ist verfügbar. Du benutzt momentan die Version %s."
  L["nobody"] = "NIEMAND"
end
