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

--Akin to cursed body.
--[[
Defiled Mind: Killing an enemy yields extra vim and psi.
Resilience: Mental debuff immunity. Sleep, confuse, silence.
Paranoia: If your life drops below 50%, you gain increases to movement and to global speed.
Unending Suffering: Heal for %%d of damage dealt. Very low, like 1, 2, 3, 4, 5. Maybe look at suffuse life scaling.

]]

newTalent { --dislike this ability. Very boring.
    name = "Defiled Mind", short_name = "MIC_DEFILED_MIND",
    type = {"corruption/defiled-mind", 1},
    mode = "passive",
    require = wil_req1,
    points = 5,
    vimGain = function(self, t) return self:combatTalentStatDamage(t, "wil", 0.1, 2.0) end,
    psiGain = function(self, t) return self:combatTalentStatDamage(t, "mag", 0.5, 5.0) end,
    callbackOnKill = function(self, t, death_note)
        --Put in a log message? On kill would be repetitive.
        self:incPsi(t.vimGain(self, t))
        self:incVim(t.psiGain(self, t))
    end,
    info = function(self, t)
        vim = t.vimGain(self, t)
        psi = t.psiGain(self, t)
        return ([[After every kill, your mind consumes every last bit of your enemies' life, giving you an extra %0.1f psi per kill and and extra %0.1f vim per kill.
The amount of vim per kill will scale with your willpower stat and the amount of psi per kill will scale with your magic stat.]]):format(psi, vim)
    end,
}

newTalent { --Sleep, confuse, fear and silence immunity
    name = "Resilient Mind", short_name = "MIC_RES_MIND",
    type = {"corruption/defiled-mind", 2},
    mode = "passive",
    require = wil_req2,
    points = 5,
    getImmune = function(self, t) return self:combatTalentLimit(t, 0.8, 0.1, 0.5) end,
    passives = function(self, t, p)
        self:talentTemporaryValue(p, "fear_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "sleep_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "silence_immune", t.getImmune(self, t))
    end,
    info = function(self, t)
        talImmune = t.getImmune(self, t)
        return ([[Your mind, as a result of your powers, has grown more resilent in nature, easily resisting whatever is thrown at it. Increases your fear, confusion, sleep and silence immunities by %d%%]]):format(talImmune*100)
    end,
}

newTalent { --Paranoia: If your life drops below 50%, you gain increases to movement and to global speed.
    name = "Crazed", short_name = "MIC_GOTTA_GO_FAST",
    type = {"corruption/defiled-mind", 3},
    mode = "passive",
    require = wil_req3,
    points = 5,
    getEffPower = function(self, t) return self:combatTalentLimit(t, 1.5, 0.2, 0.55) end,
    cooldown = function(self, t) return self:combatTalentLimit(t, 5, 45, 30) end,
    callbackOnActBase = function(self, t) --EFF_MIC_PARANOIA_BUFF. Duration is a flat 5.
        if self.life < self.max_life/2 and not self:isTalentCoolingDown(t) then
            self:setEffect(self.EFF_MIC_PARANOIA_BUFF, 5, {power = t.getEffPower(self, t), power2 = t.getEffPower(self, t)/2})
            self:startTalentCooldown(t)
        end
    end,

    info = function(self, t)
        talPow = t.getEffPower(self, t)
        talCool = t.cooldown(self, t)
        return ([[Your insane desire to continue living causes you to launch into a frenzy when your life dips below a certain point. Whenever your life drops below 50%%, that frenzy kicks in, increasing your movement speed by %d%% and your global speed by %d%%. This effect does have a cooldown (%d) and will last for 5 turns.]]):format(talPow*100, (talPow*100)/2, talCool)
    end,
}

newTalent { --Unending Suffering: Heal for %%d of damage dealt. Very low, like 1, 2, 3, 4, 5. use callbackOnDealDamage(self, t, val, target, dead, death_note)
    name = "Perpetual Suffering", short_name = "MIC_SUFFERING",
    type = {"corruption/defiled-mind", 4},
    mode = "passive",
    require = wil_req4,
    points = 5,
    getLifeStolen = function(self, t) return self:combatTalentStatDamage(t, "mag", 0.5, 7) end, --Would like a more interesting form of scaling.
    callbackOnDealDamage = function(self, t, val, target, dead, death_note)
        self:heal(t.getLifeStolen(self, t) * val/100, self)
    end,
    info = function(self, t)
        talHeal = t.getLifeStolen(self, t)
        return ([[You relish in the suffering of your enemies and any damage caused to them only extends your life. Heal for %0.2f%% of any damage dealt.
The amount healed will scale with your magic stat.]]):format(talHeal)
    end,
}
