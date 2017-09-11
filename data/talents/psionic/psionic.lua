-- ToME - Tales of Maj'Eyal:
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org


damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
    level = function(level) return 0 + (level-1)  end,
}

cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}

cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
    level = function(level) return 8 + (level-1)  end,
}

cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

highCun_req1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
    level = function(level) return 10 + (level-1)  end,
}

highCun_req2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
    level = function(level) return 14 + (level-1)  end,
}

highCun_req3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
    level = function(level) return 18 + (level-1)  end,
}

highCun_req4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
    level = function(level) return 22 + (level-1)  end,
}

wil_req1 = {
    stat = { wil=function(level) return 12 + (level-1) * 2 end },
    level = function(level) return 0 + (level-1)  end,
}

wil_req2 = {
    stat = { wil=function(level) return 20 + (level-1) * 2 end },
    level = function(level) return 4 + (level-1)  end,
}

wil_req3 = {
    stat = { wil=function(level) return 28 + (level-1) * 2 end },
    level = function(level) return 8 + (level-1)  end,
}

wil_req4 = {
    stat = { wil=function(level) return 36 + (level-1) * 2 end },
    level = function(level) return 12 + (level-1)  end,
}

highWil_req1 = {
    stat = { wil=function(level) return 22 + (level-1) * 2 end },
    level = function(level) return 10 + (level-1)  end,
}

highWil_req2 = {
    stat = { wil=function(level) return 30 + (level-1) * 2 end },
    level = function(level) return 14 + (level-1)  end,
}

highWil_req3 = {
    stat = { wil=function(level) return 38 + (level-1) * 2 end },
    level = function(level) return 18 + (level-1)  end,
}

highWil_req4 = {
    stat = { wil=function(level) return 46 + (level-1) * 2 end },
    level = function(level) return 22 + (level-1)  end,
}

if not Talents.talents_types_def["psionic/cleansing"] then
	newTalentType{ allow_random=true, type="psionic/cleansing", is_mind = true, name = "cleansing", description = "Burn away the arcane power that every mage depends oh so greatly on. And fight magic with magic!" }
	load("/data-anguish/talents/psionic/cleansing.lua")
end

if not Talents.talents_types_def["psionic/consumption"] then
	newTalentType{ allow_random=true, type="psionic/consumption", is_mind = true, name = "consumption", description = "Consume the energies that surround every entity, using them restore yourself." }
	load("/data-anguish/talents/psionic/consumption.lua")
end

if not Talents.talents_types_def["psionic/control"] then
	newTalentType{ allow_random=true, type="psionic/control", is_mind = true, generic = true, name = "control", description = "Manipulate your enemies and the elements around yourself." }
	load("/data-anguish/talents/psionic/control.lua")
end

if not Talents.talents_types_def["psionic/pain"] then
	newTalentType{ allow_random=true, type="psionic/pain", is_mind = true, name = "pain", description = "Inflict pain upon those who would do the same to you." }
	load("/data-anguish/talents/psionic/pain.lua")
end

if not Talents.talents_types_def["psionic/mic-other"] then
	newTalentType{ allow_random=true, type="psionic/mic-other", is_mind = true, name = "pain", description = "Other talents." }
	load("/data-anguish/talents/psionic/mic-other.lua")
end
