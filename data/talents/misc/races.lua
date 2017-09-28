-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

newTalentType{ type="race/soulless", name = "soulless", generic = true, is_spell=true, description = "The various racial bonuses a character can have." }


--[[ Talents

Power of the Eternals: Powers boost and all damage inc. Scales off wil or mag, whichever is higher.
Mind of the Eternals: Increase mental save by x and give mind/spell power.
Etheral Body: Reduces the duration of all negative status by x and allows you to survive with -x life.
Soul Steal: Use transfer buff and debuff from anguihsed 2.0?

]]

newTalent {
    name = "Power of the Eternals", short_name = "MIC_POWER_OF_THE_ETERNALS",
    type = {"race/soulless", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 45, 25) end,
	action = function(self, t)
		self:setEffect(self.EFF_MIC_POWER_OF_THE_ETERNALS, 6, {power = math.max(self:getWil(), self:getMag()) * 0.25 + 5, power2 = math.max(self:getWil(), self:getMag()) * 0.5 + 10})
		return true
	end,
	info = function(self, t)
		pow = math.max(self:getWil(), self:getMag()) * 0.5 + 10
		dam = math.max(self:getWil(), self:getMag()) * 0.25 + 5
		return ([[Allow the ancient power of the eternals to surge through you, increasing all of your powers by %d and all of your damage by %d%%.
The powers boost and all damage increase will scale with the higher of your willpower and magic stats.]]):format(pow, dam)
	end,
}

newTalent {
	name = "Mind of the Eternals", short_name = "MIC_MIND_OF_THE_ETERNALS",
	type = {"race/soulless", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getMentalBoost = function(self, t) return self:getTalentLevelRaw(t) * 4 end,
	getPowersBoost = function(self, t) return self:getTalentLevelRaw(t) * 3 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_mindpower", t.getPowersBoost(self, t))
		self:talentTemporaryValue(p, "combat_spellpower", t.getPowersBoost(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getMentalBoost(self, t))
	end,
	info = function(self, t)
		pow = t.getPowersBoost(self, t)
		save = t.getMentalBoost(self, t)
		return ([[Your mind is like that of your ancestors, both resistant and acclimated to magic and mind powers.
Increases your mindpower and spellpower by %d and your mental save by %d.]]):format(pow, save)
	end,
}

newTalent {
	name = "Ethereal Body", short_name = "MIC_ETHEREAL_BODY",
	type = {"race/soulless", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getDieAt = function(self, t) return self:getTalentLevelRaw(t) * 20 end,
	getReduction = function(self, t) return self:combatTalentLimit(t, 0.5, 0.1, 0.4) end, --Called in M:on_set_temporary_effect in Actor.lua
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "die_at", t.getDieAt(self, t))
		self:talentTemporaryValue(p, "reduce_detrimental_status_effects_time", t.getReduction(self, t))
	end,

	info = function(self, t)
		return ([[Your body is ever so slightly out of phase all the time. This condition allows you to go to up to -%d life and reduces the duration of all status effects by %d%%]]):format(t.getDieAt(self, t), t.getReduction(self, t) * 100)
	end,
}

newTalent { --Copied code from dusk.lua/transfer from anguished 2.0
	name = "Soul Steal", short_name = "MIC_SOUL_STEAL",
	type = {"race/soulless", 4},
	require = racial_req4,
	points = 5,
	random_ego = "buff",
    cooldown = function(self, t) return self:combatTalentLimit(t, 20, 50, 30) end,
    range = function(self, t) return self:combatTalentLimit(t, 11, 7, 10) end,
    tactical = {BUFF = 2},
	getPower = function(self, t) return math.max(self:getWil(), self:getMag()) * 0.33 + 5 end,
    requires_target = true,
    direct_hit = true,
	getDuration = function(self, t) return self:combatTalentLimit(t, 8, 4, 6) end,
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

        local talDuration = t.getDuration(self, t)
        local talPower = t.getPower(self, t)
        target:setEffect(target.EFF_MIC_TRANSFER_MALUS, talDuration, {src = self, apply_power = 100, power = talPower, power2 = talPower*0.75})
        self:setEffect(self.EFF_MIC_TRANSFER_BUFF, talDuration, {src = self, power = talPower, power2 = talPower*0.75})
    return true
    end,
    info = function(self, t)
        local talDuration = t.getDuration(self, t)
        local talPower = t.getPower(self, t)
        return([[Steal a part of your target's soul and thus, some of their power for %d turns. This decreases their all damage by %d%% and their all resistance by %0.2f%% while increasing your own all damage and all resistance by the same amount.
The amount of all damage and all resistance stolen will scale with the higher of your magic or willpower stat.]]):format(talDuration, talPower, talPower*.75)
    end,
}
