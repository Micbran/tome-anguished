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

--High level AM tree with fire damage. Or maybe lightning.
--[[

    Mindburn: Fill your target's mind with burning pain, dealing fire damage and burning arcane resources while also reducing all of their saves.
    Cauterize Lips: Inflict arcane burn damage over time and silence an enemy.
    Purifying Fire: Remove up to x status effects, positive and negative.
    Cleanse: Remove up to x magical sustains from the target while also dealing tons of fire damage.

]]

newTalent {
    name = "Mindburn", short_name = "MIC_BURNY_MIND",
    type = {"psionic/cleansing", 1},
    require = highWil_req1,
    points = 5,
    cooldown = 10,
    psi = 1,
    vim = 15,
    range = 10,
    requires_target = true,
    direct_hit = true,
    target = function(self, t)
        return {type = "hit", range = self:getTalentRange(t)}
    end,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 120) end,
    getDuration = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
    getPower = function(self, t) return self:combatTalentMindDamage(t, 1, 25) end,
    action = function(self, t)
        local talDam = t.getDamage(self, t)
        local talDur = t.getDuration(self, t)
        local talPow = t.getPower(self, t)
        local tg = self:getTalentTarget(t)
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        target:setEffect(target.EFF_MIC_MINDBURN_DEBUFF, talDur, {src = self, apply_power = self:combatMindpower(), dam = talDam, power = talPow})
        game:playSoundNear(self, "talents/fire")
        return true
    end,
    info = function(self, t)
        talDam = t.getDamage(self, t)
        talDur = t.getDuration(self, t)
        talPow = t.getPower(self, t)
        return ([[Set your target's mind alight, dealing %0.1f mindburn damage per turn and reducing the target's powers by %d for %d turns. Mindburn damage not only deals fire damage but also burns away arcane resources equal to the damage dealt.
The damage will scale with your #VIOLET#spellpower#WHITE# and the saves reduction and apply power will scale with your #GOLD#mindpower.#WHITE#
This talent can crit and will use spell crit.]]):format(damDesc(self, DamageType.FIRE, talDam), talPow, talDur)
    end,
}

newTalent { --Cauterize Lips: Inflict instant fire damage and inflict a lasting silence on target.
    name = "Cauterize Lips", short_name = "MIC_CAUT_LIPS",
    type = {"psionic/cleansing", 2},
    require = highWil_req2,
    points = 5,
    cooldown = 25,
    vim = 18,
    psi = 5,
    range = 10,
    requires_target = true,
    direct_hit = true,
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 250) end,
    getDuration = function(self, t) return self:combatTalentLimit(t, 8, 3, 4) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        talDur = t.getDuration(self, t)
        talDam = self:spellCrit(t.getDamage(self, t))
        self:project(tg, x, y, DamageType.FIRE, talDam)
        target:setEffect(target.EFF_MIC_CAUTERIZE_LIPS_DEBUFF, talDur, {src = self, apply_power = self:combatMindpower(), dam = talDam/5})
        return true
    end,

    info = function(self, t)
        talDam = t.getDamage(self, t)
        talDur = t.getDuration(self, t)
        return ([[Attempt to cauterize your target's lips, dealing %0.1f fire damage when you first cast the talent. After that, the target will take %0.1f fire damage per turn and be silenced for %d turns.
The damage will scale with your #VIOLET#spellpower#WHITE# and the apply power will scale with your #gold#mindpower.#WHITE#
This talent can crit and will use spell crit.]]):format(damDesc(self, DamageType.FIRE, talDam), damDesc(self, DamageType.FIRE, talDam/5), talDur)
    end,
}

newTalent { --Purifying Fire: Remove up to x status effects, positive and negative.
    name = "Purifying Fire", short_name = "MIC_PURIFYING_FIRE",
    points = 5,
    type = {"psionic/cleansing", 3},
    require = highWil_req3,
    cooldown = 40,
    vim = 30,
    psi = 30,
    range = 0,
    getEffRemoved = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 1, 5)) end,
    action = function(self, t)
        talEff = t.getEffRemoved(self, t)
        local effs = {}

        for eff_id, p in pairs(self.tmp) do --check for all effs
            local e = self.tempeffect_def[eff_id]
            if e.type ~= "other" then --ALL EFFS
                effs[#effs+1] = {"effect", eff_id} --store eff
            end
        end
        if #effs == 0 then
            game.logSeen(self, "The only reason you're seeing this message is because you're bad/weren't paying attention and you used this talent when you shouldn't have and I'm to lazy to put in a pre_use function.")
            return true
        end
        for i=1, talEff do
            if #effs == 0 then break end
            local eff = rng.tableRemove(effs)
            self:removeEffect(eff[2])
        end
        return true
    end,

    info = function(self, t)
        local talEff = t.getEffRemoved(self, t)
        return ([[Allow flames to engulf to you, removing %d any effects (except of type other), positive and negative.]]):format(talEff)
    end,
}

newTalent { --Cleanse: Remove up to x magical sustains from the target while also dealing tons of fire damage.
    name = "Cleanse", short_name = "MIC_CLEANSE",
    type = {"psionic/cleansing", 4},
    points = 5,
    require = highWil_req4,
    cooldown = 35,
    vim = 25,
    psi = 10,
    range = 9,
    requires_target = true,
    direct_hit = true,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 500) end,
    getSustainLimit = function(self, t) return math.floor(self:combatTalentMindDamage(t, 1, 9)) end,

    action = function(self, t)
        local remove = 0
        local talLimit = t.getSustainLimit(self, t)
        local talDam = t.getDamage(self, t)
        local tg = {type="hit", range = range}
        local x,y,target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        for tid, active in pairs(target.sustain_talents) do
            if active and remove < talLimit then
                local talent = target:getTalentFromId(tid)
                if talent.is_spell then
                     target:forceUseTalent(tid, {ignore_energy=true})
                     remove = remove + 1
                 end
            end
        end
        self:project(tg, x, y, DamageType.FIRE, self:spellCrit(talDam)) --Spell
        game.level.map:particleEmitter(x, y, 1, "fireflash", {radius=1})
        game:playSoundNear(self, "talents/fire")
        return true
    end,

    info = function(self, t)
        talDam = t.getDamage(self, t)
        talLimit = t.getSustainLimit(self, t)
        return ([[Attempt to burn away magic on your target, removing up to %d magical sustains and dealing %0.1f fire damage to them.
The number of sustains removed will scale with your #GOLD#mindpower#WHITE# while the damage dealt will scale with your #VIOLET#spellpower.#WHITE#
#RED#This talent can crit and uses spell crit!]]):format(talLimit, damDesc(self, DamageType.FIRE, talDam))
    end,
}
