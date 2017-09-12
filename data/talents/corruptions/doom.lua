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
-- along with this program. If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

--[[

Debuff/DoT Tree. Darkness and Blight damage.

Hellfire: Flames that burn away resists, reducing all resist by -x a turn and dealing fire/darkness split damage.
Erode: Blight disease that reduces global speed. Maybe have it give back vim as well?
Erase: Deal damage over time(darkness) and remove one benficial effect (on cast). At talent level 4, remove one sustain per turn.
Doom: Extend the duration of EVERY negative effect on a target by x turns. At the same time, also apply another blight DoT.

]]
--Increase Apply power of all talents in this tree for every point put into it.
local function applyPowerBonus(self) --Directly copied scaling from mindpowerbonus in gloom.lua with a little bit of adding
	return self:combatScale(self:getTalentLevel(self.T_MIC_HOT_BURNY_FLAMES) + self:getTalentLevel(self.T_MIC_ERODE) + self:getTalentLevel(self.T_MIC_ERASE) + self:getTalentLevel(self.T_MIC_DOOOOM), 1, 1, 25, 25, 0.75)
end

--Little bit of reasoning here, these 3 talents hit Anguished's 3 main damage types (I removed mind damage as a damage type in 2.0.0).
--Erode works as vim regen
--Hellfire works as a resistance stripper, which is useful for any mage imo (though I would argue that anguished doesn't have this problem so much)
--Erase strips sustains

newTalent { --Erode
    name = "Erode", short_name = "MIC_ERODE",
    type = {"corruption/doom", 1},
    require = mag_req1,
    points = 5,
    random_ego = "attack",
    cooldown = function(self, t) return self:combatTalentLimit(t, 6, 15, 8) end,
    vim = 5,
    range = 10,
    tactical = {ATTACK = {BLIGHT = 2}, SLOW = 2},
    direct_hit = true,
    requires_target = true,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end, --Damage might be on the high end, but it does have a decent cooldown
	getDur = function(self, t) return 5 end, --I gave up on scaling this, too much work it works as a damage multiplier.and also increases GS malus
    action = function(self, t)
        local talPower = t.getPower(self, t)
        local talDam = self:spellCrit(t.getDamage(self, t))
        local talDur = t.getDur(self, t)
        local range = self:getTalentRange(t)
        local tg = {type = "hit", range = range}
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        target:setEffect(target.EFF_MIC_EROSION, talDur, {power = talPower, apply_power = self:combatSpellpower() + powerBoost, dam = talDam, src = self})
        game:playSoundNear(self, "talents/slime")
        return true
    end,
    info = function(self, t)
        local talPower = t.getPower(self, t)
        local talDam = t.getDamage(self, t)
        local talDur = t.getDur(self, t)
		powerBoost = applyPowerBonus(self)
        return([[Inflict a disease designed to ruin upon your target, dealing %0.1f blight damage per turn for %d turns.
The blight damage will additionally drain vim, scaled by the target's rank.
The damage and global speed slow will scale with your #VIOLET#spellpower.#WHITE# This talent uses spell crit, increasing the damage dealt.

Additionally, every point put into talents in the Doom tree will increase the apply power of all talents within the tree. (Currently +%d)]]):format(damDesc(self, DamageType.BLIGHT, talDam), talDur, powerBoost)
    end,
}

newTalent { --Hellfire
    name = "Hellfire", short_name = "MIC_HOT_BURNY_FLAMES",
    type = {"corruption/doom", 2},
    require = mag_req2,
    points = 5,
    random_ego = "attack",
    cooldown = 9, --static
    vim = 10,
    range = 10,
    direct_hit = true,
    requires_target = true,
    tactical = {ATTACK = {FIRE = 2}},
    getPower = function(self, t) return self:combatTalentSpellDamage(t, 4, 17) end, --power is how much all res is burned
    getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 4, 6)) end,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end, --all talents do around the same amount of damage per tick
    action = function(self, t)
        local range = self:getTalentRange(t)
        local tg = {type = "hit", range = range}
        local x, y, target = self:getTarget(tg)
        local talDur = t.getDuration(self, t)
        local talDam = self:spellCrit(t.getDamage(self, t))
        local talPower = t.getPower(self, t)
        local powerBoost = applyPowerBonus(self)
        if not target or not self:canProject(tg, x, y) then return nil end
        target:setEffect(target.EFF_MIC_BURNING_FLAMES, talDur, {power = talPower, apply_power = self:combatSpellpower() + powerBoost, dam = talDam, numOfTurns = 1, src= self, no_ct_effect = true,})
        game:playSoundNear(self, "talents/fire")
    return true
    end,
    info = function(self, t)
        local talDur = t.getDuration(self, t)
        local talDam = t.getDamage(self, t)
        local talPower = t.getPower(self, t)
        local powerBoost = applyPowerBonus(self)
        return([[Project very hot flames upon your target for %d turns, causing them to burn for half fire damage (%0.1f) and half darkness damage (%0.1f) while reducing their all resistance by %0.1f%% for each turn they burn.
The damage, apply chance and all resistance reduction will scale with your #VIOLET#spellpower.#WHITE# This talent uses spell crit, increasing the damage dealt.
The all resistance reduction will stack to a maximum of -40%%.

Additionally, every point put into talents in the Doom tree will increase the apply power of all talents within the tree. (Currently +%d)]]):format(talDur, damDesc(self, DamageType.FIRE, talDam/2), damDesc(self, DamageType.DARKNESS, talDam/2), talPower, powerBoost)
    end,
}

newTalent {
    name = "Erase", short_name = "MIC_ERASE",
    type = {"corruption/doom", 3},
    require = mag_req3,
    points = 5,
    random_ego = "attack",
    cooldown = 10,
    vim = 8,
    range = 10,
    tactical = {ATTACK = {DARKNESS = 2}},
    direct_hit = true,
    requires_target = true,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 150) end, --much higher damage, probably need to lower
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 6, 3, 5)) end,
	getEffRemoved = function(self, t) return self:combatTalentLimit(t, 4, 1, 3) end,
    action = function(self, t)
        local talDam = self:spellCrit(t.getDamage(self, t))
        local talDur = t.getDur(self, t)
        local range = self:getTalentRange(t)
        local powerBoost = applyPowerBonus(self)
		local numOfEff = t.getEffRemoved(self, t)
        local tg = {type = "hit", range = range}
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        target:setEffect(target.EFF_MIC_ERASURE, talDur, {apply_power = self:combatSpellpower() + powerBoost, dam = talDam, doErase = self:getTalentLevel(t) >= 3 and true or false, src = self})
		local effs = {}

		for eff_id, p in pairs(target.tmp) do --Check for beneficial
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" and e.status == "beneficial" then
				effs[#effs+1] = {"effect", eff_id} --Store effs
			end
		end
		if #effs == 0 then return true end
		for i=1, numOfEff do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs) --remove random eff pair
			target:removeEffect(eff[2]) --remove eff portion of eff
		end

        return true
    end,
	info = function(self, t)
		local talDam = t.getDamage(self, t)
        local talDur = t.getDur(self, t)
        local powerBoost = applyPowerBonus(self)
		local numOfEff = t.getEffRemoved(self, t)
		return([[Erase some of your target away, removing %d beneficial effects from them upon cast and dealing %0.1f darkness damage per turn for %d turns.
If the talent level is 3 or greater, Erase will also remove one sustain per turn on the affected target. The darkness damage per turn will scale with your #VIOLET#spellpower.#WHITE#

Additionally, every point put into talents in the Doom tree will increase the apply power of all talents within the tree. (Currently +%d)]]):format(numOfEff, damDesc(self, DamageType.DARKNESS, talDam), talDur, powerBoost)
	end,
}
--considering either giving an on expiration bonus or a moving the GS malus to this talent and putting something extra on erosion
newTalent {
	name = "Doom", short_name = "MIC_DOOOOM",
	type = {"corruption/doom", 4},
	require = mag_req4,
    points = 5,
    random_ego = "attack",
    cooldown = 30,
    vim = 20,
    range = 10,
    tactical = {ATTACK = {BLIGHT = 2}},
    direct_hit = true,
    requires_target = true,
	target = function(self, t) return {type = "hit", range = self:getTalentRange(t), talent = t} end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 0.1, 0.4) end, --Global speed is a double < 1.
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 170) end,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 12, 5, 8)) end, --untouched, even though im pretty sure this scaling is all sorts of wrong
	getEffectExtension = function(self, t) return self:combatTalentLimit(t, 2, 4, 6) end,
	action = function(self, t)
		local talDam = t.getDamage(self, t)
		local talDur = t.getDur(self, t)
		local powerBoost = applyPowerBonus(self)
		local talPower = t.getPower(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			for eff_id, p in pairs(target.tmp) do --Go through current effects
				local e = target.tempeffect_def[eff_id] --Get effect
				if e.type ~= "other" and e.status == "detrimental" then --Check type and status type. Only want detrimental.
					p.dur = math.min(p.dur*2, p.dur + t.getEffectExtension(self, t)) --Extend effect. Check so that it wont go too far
				end
			end
			target:setEffect(target.EFF_MIC_DOOOM, talDur, {apply_power = self:combatSpellpower() + powerBoost, dam = talDam, src = self, power = talPower})
		end)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, r=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local numOfEff = t.getEffectExtension(self, t)
		local dam = t.getDamage(self, t)
		local dur = t.getDur(self, t)
		local powerBoost = applyPowerBonus(self)
		local slowAmount = t.getPower(self, t)
		return ([[Seal your targets DOOOOOOOOOM by extending the length of all status effects on them by up to %d (but never to twice the effects duration) and applying a new debuff (after the extension, not before) that deals %0.1f blight damage per turn and reduces their global speed by %d%% for %d turns.
The damage per turn will scale with your #VIOLET#spellpower.#WHITE#

Additionally, every point put into talents in the Doom tree will increase the apply power of all talents within the tree. (Currently +%d)]]):format(numOfEff, damDesc(self, DamageType.BLIGHT, dam), slowAmount*100, dur, powerBoost)
	end,
}
