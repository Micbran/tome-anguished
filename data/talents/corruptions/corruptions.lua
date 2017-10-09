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

--For loading talents
damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

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

mag_req1 = {
    stat = { mag=function(level) return 12 + (level-1) * 2 end },
    level = function(level) return 0 + (level-1)  end,
}

mag_req2 = {
    stat = { mag=function(level) return 20 + (level-1) * 2 end },
    level = function(level) return 4 + (level-1)  end,
}

mag_req3 = {
    stat = { mag=function(level) return 28 + (level-1) * 2 end },
    level = function(level) return 8 + (level-1)  end,
}

mag_req4 = {
    stat = { mag=function(level) return 36 + (level-1) * 2 end },
    level = function(level) return 12 + (level-1)  end,
}

highmag_req1 = {
    stat = { mag=function(level) return 22 + (level-1) * 2 end },
    level = function(level) return 10 + (level-1)  end,
}

highmag_req2 = {
    stat = { mag=function(level) return 30 + (level-1) * 2 end },
    level = function(level) return 14 + (level-1)  end,
}

highmag_req3 = {
    stat = { mag=function(level) return 38 + (level-1) * 2 end },
    level = function(level) return 18 + (level-1)  end,
}

highmag_req4 = {
    stat = { mag=function(level) return 46 + (level-1) * 2 end },
    level = function(level) return 22 + (level-1)  end,
}

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


if not Talents.talents_types_def["corruption/dark-thoughts"] then
	newTalentType{type="corruption/dark-thoughts", name = "dark thoughts", allow_random=true, no_silence=true, is_spell=true, description = "Dredge up the most demented thoughts from your mind, using them to signal the dusk of your enemies' lives."}
	load("/data-anguish/talents/corruptions/dark-thoughts.lua")
end


--[[
if not Talents.talents_types_def["corruption/pain"] then
	newTalentType{type="corruption/pain", allow_random=true, no_silence=true, is_spell=true, name = "pain", description = "Inflict pain upon those who wish you the same." }
	load("/data-anguish/talents/corruptions/pain.lua")
end
]]

if not Talents.talents_types_def["corruption/defiled-mind"] then
	newTalentType{type="corruption/defiled-mind", name = "defiled mind", generic = true, allow_random=true, no_silence=true, is_spell=true, description = "Use your long since corrupted mind as a tool to destroy your enemies." }
	load("/data-anguish/talents/corruptions/defiled-mind.lua")
end

if not Talents.talents_types_def["corruption/balance"] then
	newTalentType{type="corruption/balance", name = "balance", allow_random=true, no_silence=true, is_spell=true, description = "Techniques used to keep the balance between Vim and Psi." }
	load("/data-anguish/talents/corruptions/balance.lua")
end

if not Talents.talents_types_def["corruption/doom"] then
	newTalentType{type="corruption/doom", name = "doom", allow_random=true, no_silence=true, is_spell=true, description = "Bring your enemies closer to their demise with long-lasting curses." }
	load("/data-anguish/talents/corruptions/doom.lua")
end

if not Talents.talents_types_def["corruption/mic-other"] then
	newTalentType{ allow_random=true, type="corruption/mic-other", is_mind = true, name = "balance", description = "Other talents." }
	load("/data-anguish/talents/corruptions/mic-other.lua")
end
