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

--[[
"So much pain... Why not share it?"

Kill: Instantly (key word) inflict darkness damage at a lowish range (6). Reset cooldown when a "kill" happens? callbackOnDealDamage? Or callbackOnKill? Scales off spellpower AND mindpower
Dark Anger: Mind Crit +, activate for sustain that "charges." Once it reaches max charges or is deactivated, it "explodes". Dam based off mindpower and spellpower, uses mind crit, turns charged increases damage and radius.
Searing Pain: Mass confusion but fire dam
Anguish: reduction of powers and mind darkness and blight dam based off spellpower and mindpower
]]


--[[

newTalent { --Template
    name = "", short_name = "",
    type = {"", },
    require = wil_req1,
    points = 5,
    random_ego = "",
    cooldown = 1,
    hate = 1,
    range = 1,
    tactical = {},
    getPower = function(self, t) return 1 end,
    action = function(self, t)

    return true
    end,
    info = function(self, t)

        return():format()
    end,
}

]]
--changing kill to deal bonus damage to enemies below 50% health and lower CD
newTalent {
    name = "Kill", short_name = "MIC_KILL",
    type = {"psionic/pain", 1},
    require = wil_req1,
    points = 5,
    random_ego = "attack",
    cooldown = 4, --cooldown low, main attack talent.
    direct_hit = true,
    requires_target = true,
    vim = 3,
    psi = 5,
    range = 7, --makes it a mid range caster tool, which is what i want anguished to be, mid ranged
    tactical = {ATTACK = {DARKNESS = 2}},
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    getDamage = function(self, t) return (self:combatTalentMindDamage(t, 5, 170) + self:combatTalentSpellDamage(t, 5, 190)) end, --combo of mindpower scaling and spellpower scaling.
    action = function(self, t)
        local talDam = t.getDamage(self, t)
        local tg = self:getTalentTarget(t)
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        if target.life <= target.max_life*0.50 then --check for life less than or equal to 50%
            talDam *= 1.30 --increase talent damage
            self.energy.value = self.energy.value + game.energy_to_act * self:getSpeed("mind") --refund turn cost
        end
        self:project(tg, x, y, DamageType.DARKNESS, self:mindCrit(talDam))
        game.level.map:particleEmitter(x, y, 1, "reproach", {dx = self.x - x, dy = self.y - y})
        game:playSoundNear(self, "talents/fire")
        return true
    end,
    info = function(self, t)
        local damage = t.getDamage(self, t)
    return([[Unleash a blast of dark energy, dealing %0.1f darkness damage. If this talent is cast on a target with less than 50% max life, it will not take a turn and will deal 30%% increased damage (%0.1f).
This talent utilizes mind crit.
The damage will scale with your #GOLD#mindpower#WHITE# AND your #VIOLET#spellpower.#WHITE#]]):format(damDesc(self, DamageType.DARKNESS, damage), damDesc(self, DamageType.DARKNESS, damage*1.30)) end,
}

newTalent { --Dark Anger
    name = "Dark Anger", short_name = "MIC_DARK_ANGER",
    type = {"psionic/pain", 2},
    require = wil_req2,
    mode = "passive",
    points = 5,
    getCrit = function(self, t) return self:combatTalentLimit(t, 24, 1, 12) end,
    on_learn = function(self, t)
        local lev = self:getTalentLevelRaw(t)
        if lev == 1 then
            self:learnTalent(self.T_MIC_DARK_CHARGE, true, nil, {no_unlearn=true}) -- have to give a different talent to the player because you cant attach a passive to a sustain
        end
    end,
    getDamage = function(self, t) return (self:combatTalentMindDamage(t, 20, 100) + self:combatTalentSpellDamage(t, 25, 125)) end, --Use Dark Anger talent level for scaling of Dusk Bringer
    getMaxTurnCharge = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 1, 6)) end,
    on_unlearn = function(self, t)
        local lev = self:getTalentLevelRaw(t)
        if lev == 0 then
            self:unlearnTalent(self.T_MIC_DARK_CHARGE)
        end
    end,
    passives = function(self, t)
        self:addTemporaryValue(p, "combat_mindcrit", t.getCrit(self, t))
    end,
    info = function(self, t)
        local mindCrit = t.getCrit(self, t)
        return([[Your anger is restless within you, increasing your mind critical chance by %d%%. This bonus will scale with talent level.
In addition, you will learn a talent: Dusk Bringer. Dusk Bringer is a sustain that can be "charged" up to deal darkness damage in a radius.]]):format(mindCrit)
    end
}


newTalent { --Searing Pain
    name = "Searing Pain", short_name = "MIC_SEARING_PAIN",
    type = {"psionic/pain", 3},
    require = wil_req3,
    points = 5,
    random_ego = "attack",
    cooldown = 10,
    vim = 7,
    psi = 15,
    range = 7,
    direct_hit = true,
    requires_target = true,
    getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 60) end,
    radius = function(self, t) return self:combatTalentScale(t, 1, 2, 4) end,
    target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire = false} end,
    tactical = {CONFUSION = 2, ATTACKAREA = {FIRE = 2}},
    getDamage = function(self, t) return (self:combatTalentMindDamage(t, 10, 140) + self:combatTalentSpellDamage(t, 10, 140)) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
        local talPower = t.getPower(self, t)
        local talDamage = self:mindCrit(t.getDamage(self, t))
        local grids, px, py = self:project(tg, x, y, DamageType.FIRE, talDamage)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
            if target:canBe("confusion") then
			    target:setEffect(target.EFF_CONFUSED, 6, {power = talPower, apply_power = math.max(self:combatMindpower(), self:combatSpellpower())}) --flat duration of 5 also apply is higher of mind or spell power
            else
                game.logSeen(target, "%s resists the overwhelming pain!", target.name:capitalize())
            end
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "shout", {additive=true, life=10, size=3, distorion_factor=0.75, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.3, am=0.4, aM=0.6})
		game:playSoundNear(self, "talents/fire")
		return true
    end,
    info = function(self, t)
        talDamage = t.getDamage(self, t)
        talRadius = self:getTalentRadius(t)
        talPower = t.getPower(self, t)
    return([[Unleash a ball of red, hot pain in radius %d, dealing %0.1f fire damage and attempting to apply confusion (power %d), using the higher of spellpower or mindpower for application.
Damage scales with your #VIOLET#spellpower#WHITE# and #GOLD#mindpower#WHITE#, whilist the confusion power will scale ONLY with your #GOLD#mindpower.#WHITE#
#RED#This talent uses mind critical strike chance.#WHITE#]]):format(talRadius, damDesc(self, DamageType.FIRE, talDamage), talPower) end,
}
newTalent {
    name = "Anguish", short_name = "MIC_ANGUISH",
    type = {"psionic/pain", 4},
    require = wil_req4,
    points = 5,
    random_ego = "attack",
    cooldown = 15,
    vim = 15,
    psi = 25,
    range = 7,
    requires_target = true,
    direct_hit = true,
    tactical = {ATTACK = {DARKNESS = 2}},
    getDamage = function (self, t) return self:combatTalentMindDamage(t, 10, 50) + self:combatTalentSpellDamage(t, 10, 50) end, --hybrid scaling
    getPower = function(self, t) return self:combatTalentMindDamage(t, 5, 30) + self:combatTalentSpellDamage(t, 5, 30) end, --hybrid scaling
    getDuration = function(self, t) return self:combatTalentScale(t, 4, 7, 11) end, --added duration scaling
    action = function(self, t)
        local dur = t.getDuration(self, t)
        local talDam = t.getDamage(self, t)
        local range = self:getTalentRange(t)
        local talPower = self:mindCrit(t.getPower(self, t)) --Power can crit
        local tg = {type="hit", range = range}
        local x,y,target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        target:setEffect(target.EFF_MIC_ANGUISH_EFF, dur, {power = talPower, dam = talDam, apply_power = math.max(self:combatMindpower(), self:combatSpellpower())}) --pass in inital damage so we can use it later
        if target:hasEffect(target.EFF_MIC_ANGUISH_EFF) then
            self:setEffect(self.EFF_MIC_ANGUISH_POS_EFF, dur, {power = talPower}) --effect increases saves and powers, only works if original effect worked
        end
        game:playSoundNear(self, "talents/cloud")
        return true
    end,
    info = function(self, t)
        local talDur = t.getDuration(self, t)
        local talDam = t.getDamage(self, t)
        local talPower = t.getPower(self, t)
        return([[]]):format()
    end,
}
