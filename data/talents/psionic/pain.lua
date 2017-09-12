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
newTalent {
    name = "Kill", short_name = "MIC_KILL",
    type = {"psionic/pain", 1},
    require = wil_req1,
    points = 5,
    random_ego = "attack",
    no_energy = true,
    cooldown = 7,
    direct_hit = true,
    requires_target = true,
    vim = 3,
    psi = 5,
    range = 6,
    tactical = {ATTACK = {DARKNESS = 2}},
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    getDamage = function(self, t) return (self:combatTalentMindDamage(t, 5, 85) + self:combatTalentSpellDamage(t, 5, 110)) end, --Should work.
    action = function(self, t)
        local talDam = t.getDamage(self, t)
        local tg = self:getTalentTarget(t)
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        self:project(tg, x, y, DamageType.DARKNESS, self:mindCrit(talDam))
        game.level.map:particleEmitter(x, y, 1, "reproach", {dx = self.x - x, dy = self.y - y}) --Probably won't work.
        game:playSoundNear(self, "talents/fire")
        game:onTickEnd(function()
            if target.life <= 0 then --Might cause issues with neg life
                self:alterTalentCoolingdown(self.T_MIC_KILL, -1000)
            end
        end)
        return true
    end,
    info = function(self, t)
        local damage = t.getDamage(self, t)
    return([[Unleash a lethal force, dealing %0.1f darkness damage. If this kills the target, the cooldown is reset.
This talent is instant and utilizes mind crit.
The damage will scale with your #GOLD#mindpower#WHITE# AND your #VIOLET#spellpower.#WHITE#]]):format(damDesc(self, DamageType.DARKNESS, damage)) end,
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
            self:learnTalent(self.T_MIC_DARK_CHARGE, true, nil, {no_unlearn=true})
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
    cooldown = 20,
    vim = 5,
    psi = 15,
    range = 8,
    direct_hit = true,
    requires_target = true,
    getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 60) end,
    radius = function(self, t) return self:combatTalentScale(t, 1, 2, 3) end,
    target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire = false} end,
    tactical = {CONFUSION = 2, ATTACKAREA = {FIRE = 2}},
    getDamage = function(self, t) return (self:combatTalentMindDamage(t, 10, 120) + self:combatTalentSpellDamage(t, 10, 140)) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
        local talPower = t.getPower(self, t)
        local talDamage = self:mindCrit(t.getDamage(self, t))
        local grids, px, py = self:project(tg, x, y, DamageType.FIRE, talDamage) --Not sure if 100% correct. NOTE
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_CONFUSED, 5, {power = talPower, apply_power = math.max(self:combatMindpower(), self:combatSpellpower())})
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
    return([[Unleash a ball of red, hot pain in radius %d, dealing %0.1f fire damage and attempting to apply confusion (power %d), using the higher of spellpower or mindpower for application, in the area.
Damage scales with your #VIOLET#spellpower#WHITE# and #GOLD#mindpower#WHITE#, whilist the confusion power will scale ONLY with your #GOLD#mindpower.#WHITE#
#RED#This talent uses mind critical strike chance.#WHITE#]]):format(talRadius, damDesc(self, DamageType.FIRE, talDamage), talPower) end,
}

newTalent {
    name = "Anguish", short_name = "MIC_ANGUISH",
    type = {"psionic/pain", 4},
    require = wil_req4,
    points = 5,
    random_ego = "attack",
    cooldown = 25,
    vim = 15,
    psi = 25,
    range = 10,
    requires_target = true,
    direct_hit = true,
    tactical = {ATTACK = {BLIGHT = 1, DARKNESS = 1, MIND = 1}},
    getDarkDam = function(self, t) return (self:combatTalentMindDamage(t, 20, 140) + self:combatTalentSpellDamage(t, 25, 160)) end, --Based off Mindpower AND spellpower
    getBlightDam = function(self, t) return self:combatTalentSpellDamage(t, 20, 140) end, --Based off ONLY spellpower
    getMindDam = function(self, t) return self:combatTalentMindDamage(t, 20, 140) end,  --Based off ONLY mindpower
    getPower = function(self, t) return self:combatTalentMindDamage(t, 1, 30) end, --Based off MINDPOWER
    action = function(self, t)
        local range = self:getTalentRange(t)
        local darkDam = t.getDarkDam(self ,t)
        local blightDam = t.getBlightDam(self, t)
        local mindDam = t.getMindDam(self, t)
        local talPower = t.getPower(self, t)
        local tg = {type="hit", range = range}
        local x,y,target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        self:project(tg, x, y, DamageType.DARKNESS, self:mindCrit(darkDam)) --Darkness Portion
        self:project(tg, x, y, DamageType.BLIGHT, self:spellCrit(blightDam)) --Blight
        self:project(tg, x, y, DamageType.MIND, self:mindCrit(mindDam)) --Mind
        target:setEffect(target.EFF_MIC_ANGUISH_EFF, 6, {power = talPower, apply_power = self:combatMindpower()}) --Duration is a static 6
        --Three separate projections. Very messy.
        --TODO Particles
        game:playSoundNear(self, "talents/fire")
        return true
    end,
    info = function(self, t)
        local darkDam = t.getDarkDam(self ,t)
        local blightDam = t.getBlightDam(self, t)
        local mindDam = t.getMindDam(self, t)
        local talPower = t.getPower(self, t)
        return([[Inflict a curse of anguish and suffering upon an enemy causing them to be harassed with a multitude of elements, dealing %0.1f darkness damage, %0.1f blight damage, and %0.1f mind damage. Also, due to the great pain your target is experiencing, all of their powers will be reduced by %d, should the effect be applied.
The darkness damage will scale with your #GOLD#mindpower#WHITE# and your #VIOLET#spellpower#WHITE# and use mind critical strike chance.
The blight damage will scale with your #VIOLET#spellpower#WHITE# and use spell critical strike chance.
The mind damage will scale with your #GOLD#mindpower#WHITE# and use mind critical strike chance.
The effect of powers reduction and the apply power will scale with your mindpower.
Each instance of damage can critically strike separately]]):format(damDesc(self, DamageType.DARKNESS, darkDam), damDesc(self, DamageType.BLIGHT, blightDam), damDesc(self, DamageType.MIND, mindDam), talPower)
    end,
}
