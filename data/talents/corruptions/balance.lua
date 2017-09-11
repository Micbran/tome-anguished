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

Balance between Psi and Vim. Also, Mindpower and Spellpower.

Balance of Powers: The lower your vim, the higher a mindpower boost you gain. The lower your psi, the higher a spellpower boost you gain. NOTE passive
Life Shield: Consume 20% of your current life and turn it into a shield with x effiency. NOTE active:spell
Overcharged: The higher your vim, the higher a spell speed boost. The higher your psi, the higher a mind speed boost. NOTE passive
Unnatural Limits: Passively increases max psi and max vim. Can be activated to turn you over your natural limits, healing you to full, increasing all damage done, and restoring psi and vim to full. Once the effect expires, the players vim and psi are set to 10% and life to 20%.
NOTE passive and active

]]

newTalent { --Might just be more powerful just because it doesn't have a drawback like solip solipsim does.
    name = "Balance of Powers", short_name = "MIC_BALANCE",
    type = {"corruption/balance", 1},
    mode = "sustained",
    require = mag_req1,
    points = 5,
    cooldown = 5,
    no_unlearn_last = true,
    getMindpowerBoost = function(self, t) return math.min(self:combatTalentLimit(t, 70, 15, 45), self:combatTalentLimit(t, 0.6, 0.2, 0.4) * (-1*self:getVim() + self:getMaxVim())) end,
    getSpellpowerBoost = function(self, t) return math.min(self:combatTalentLimit(t, 70, 15, 45), self:combatTalentLimit(t, 0.6, 0.2, 0.4) *  (-1*self:getPsi() + self:getMaxPsi())) end,
    --(self:getMaxVim()/math.max(1, self:getVim()))) Method one. Produces very high results at low resources.
    getPowersLimit = function(self, t) return self:combatTalentLimit(t, 70, 15, 35) end, --Just an extra function for the info blurb.
    callbackOnActBase = function(self, t) --Called every base turn
        local p = self.sustain_talents[t.id]
        if not p then return end
        if p.spid then self:removeTemporaryValue("combat_spellpower", p.spid) end
        if p.mpid then self:removeTemporaryValue("combat_mindpower", p.mpid) end

        local spellPower = t.getSpellpowerBoost(self, t)
        local mindPower = t.getMindpowerBoost(self, t)

        p.spid = self:addTemporaryValue("combat_spellpower", spellPower)
        p.mpid = self:addTemporaryValue("combat_mindpower", mindPower)
    end,
    activate = function(self, t)
        return {}
    end,
    deactivate = function(self, t, p)
        if p.spid then self:removeTemporaryValue("combat_spellpower", p.spid) end
        if p.mpid then self:removeTemporaryValue("combat_mindpower", p.mpid) end
        return true
    end,
    info = function(self, t)
        mindBoost = t.getMindpowerBoost(self, t)
        spellBoost = t.getSpellpowerBoost(self, t)
        limit = t.getPowersLimit(self, t)

        return([[You maintain a balance of powers within your body, increasing your #VIOLET#spellpower#WHITE# by %d, increasing the lower your psi is. Also, your #GOLD#mindpower#WHITE# is also increased by %d, further increasing depending on how low your vim is.
The #VIOLET#spellpower#WHITE# and #GOLD#mindpower#WHITE# bonuses are limited to a maximum of %d.]]):format(spellBoost, mindBoost, limit)
    end
}

--(after casting a mind talent)Target is self or no target or AoE and is spell, generate a shield for twice talent extra dam. for the flipside, have it be a heal. Other, just do extra damage.
newTalent { --Credits to razakai. Casting a spell gives buff that makes next mind talent deal extra something (debuff or damage?) and casting a mind talent makes next spell do the same.
    name = "Weaving", short_name = "MIC_WEAVING",
    type = {"corruption/balance", 2},
    mode = "passive",
    require = mag_req2,
    points = 5,
    no_unlearn_last = true,
    cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 3, 15, 8)) end,
    getPostSpellTalent = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end, --Heal
    getPostMindTalent = function(self, t) return self:combatTalentSpellDamage(t, 10, 150) end, --Shield
    --If no buff, apply one (depending on talent type cast), then start internal cd. If buff, remove and do eff, depending on talent used. AoE or self or no target means heal/shield otherwise project damage on target.
    callbackOnTalentPost = function(self, t, ab, ret, silent) --Use self:heal(val) and self:setEffect(self.EFF_DAMAGE_SHIELD, dur, {pow, src})
        if self.turn_procs.forWeavingX ~= nil then local currX = self.turn_procs.forWeavingX end --Taken from a hook. DamageProjector:final
        if self.turn_procs.forWeavingY ~= nil then local currY = self.turn_procs.forWeavingY end--Ditto. Location of target last hit with damage. I.E. last damaging spell cast. Hopefully.
        if currX ~= nil and currY ~= nil then
            local target = game.level.map(currX, currY, Map.ACTOR)
        end
        if ab.is_mind and not self:hasEffect(self.EFF_WEAVE_MIND) and not self:isTalentCoolingDown(t) then --Checking for buff and etc.
            self:setEffect(self.EFF_WEAVE_MIND, 6, {src = self})
            self:startTalentCooldown(t)
        elseif ab.is_spell and not self:hasEffect(self.EFF_WEAVE_SPELL) and not self:isTalentCoolingDown(t) then --Ditto
            self:setEffect(self.EFF_WEAVE_SPELL, 6, {src = self})
            self:startTalentCooldown(t)
        end
        if self:hasEffect(self.EFF_WEAVE_MIND) and ab.is_spell then
            if not target then
                self:setEffect(self.EFF_DAMAGE_SHIELD, 4, {power = t.getPostSpellTalent(self, t), src = self})
            end
            --[[else
                self:project({type = "hit", range = 1}, currX, currY, DamageType.MIND, {dam = t.getPostSpellTalent(self, t)})
            end]]--
            self:removeEffect(self.EFF_WEAVE_MIND)
        elseif self:hasEffect(self.EFF_WEAVE_SPELL) and ab.is_mind then
            if not target then
                self:heal(t.getPostMindTalent(self, t), self)
            end
            --[[else
                self:project({type = "hit", range = 1}, currX, currY, DamageType.BLIGHT, {dam = t.getPostMindTalent(self, t)})
            end]]--
            self:removeEffect(self.EFF_WEAVE_SPELL)
        end
    end,
    info = function(self, t)
        talCool = t.cooldown(self, t)
        talPostMind = t.getPostMindTalent(self, t)
        talPostSpell = t.getPostSpellTalent(self, t)

        return ([[You learn to weave your spells with your mind powers. Whenever you cast a spell, you gain a buff for 5 turns that causes your next mind power to heal you for %0.1f.
Whenever you cast a mind power, you gain a buff that causes your next spell to create a shield for %0.1f around yourself.
The healing will scale with your #VIOLET#spellpower#WHITE# and the shield will scale with your #GOLD#mindpower#WHITE#.
This talent has an internal cooldown of %d.]]):format(talPostMind, talPostSpell, talCool)
    end
}

newTalent { --Overcharged. Dislike. Mirrors the first talent, but doesn't bring anything that special to the table like solipsim does. Could change to spell/mindcrit, sadly is just as boring
    name = "Overcharged", short_name = "MIC_OVERCHARGED",
    type = {"corruption/balance", 3},
    mode = "sustained",
    require = mag_req3,
    points = 5,
    cooldown = 5,
    no_unlearn_last = true,
    getSpellSpeed = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.4) * self:getVim()/self:getMaxVim() end, --Upper limit of 1
    --currVim/maxVim = 1 then full. So, values listed in the combatTalentLimit are the max speed you can get. Might have to adjust a little. Seems weak.
    getMindSpeed = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.4) * self:getPsi()/self:getMaxPsi() end,
    getMax = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.4) end, --Extra info function
    callbackOnActBase = function(self, t)
        local p = self.sustain_talents[t.id]
        if not p then return end
        if p.ssid then self:removeTemporaryValue("combat_spellspeed", p.ssid) end
        if p.msid then self:removeTemporaryValue("combat_mindspeed", p.msid) end

        local spellSpeed = t.getSpellSpeed(self, t)
        local mindSpeed = t.getMindSpeed(self, t)

        p.ssid = self:addTemporaryValue("combat_spellspeed", spellSpeed)
        p.msid = self:addTemporaryValue("combat_mindspeed", mindSpeed)
    end,
    activate = function(self, t)
        return {}
    end,
    deactivate = function(self, t, p)
        if p.ssid then self:removeTemporaryValue("combat_spellspeed", p.ssid) end
        if p.msid then self:removeTemporaryValue("combat_mindspeed", p.msid) end
        return true
    end,
    info = function(self, t)
        local spellSpeed = t.getSpellSpeed(self, t)
        local mindSpeed = t.getMindSpeed(self, t)
        local maxi = t.getMax(self, t)
        return ([[The higher your stores of vim/psi are, the more "charged" you are, increasing your spell casting speed by %d%% and your mindcasting speed by %d%%. These bonuses will scale with the percentage of vim/psi in your pools, up to a max of %d%%.]]):format(spellSpeed*100, mindSpeed*100, maxi*100)
    end,
}
--[[
Overcharge has no sustain cost. May or may not be intentional, but if you're going to make it a zero cost sustain it might be better to just make it passive,
at least for an effect that doesn't really do anything on deactivation or effect enemies.
In relation to your in-code note of it being boring, some immediate thoughts would be having it add extra AoE effects to basically everything,
that scale down until it hits a threshold (probably fairly high, 60-75%) and stops (spell shattering impact, basically; X%,
based on your resources, of the damage splashes outwards as bonus damage until you use enough resources),
having it grant effective talent level for some/all unique trees based on current resources, or having it let your resources go over their maximum,
and grant various effects based on how much they're in excess and/or (if kept as a sustain) do some effect on deactivation based on
how much excess vim/psi you have at the time.  -Frumple
]]
newTalent{
	name = "Unnatural Limits", short_name = "MIC_UNN_LIMITS",
	type = {"corruption/balance", 4},
	require = mag_req4,
	points = 5,
	random_ego = "defensive",
	cooldown = 50,
    no_npc_use = true,
    no_unlearn_last = true,
    getAllDamageInc = function(self, t) return math.max(1, self:combatTalentLimit(t, 75, 15, 30) * math.max(0.001, (1-(self:getVim()/self:getMaxVim() + self:getPsi()/self:getMaxPsi())))) end, --Looks solid to me.
    getDuration = function(self, t) return math.floor(math.max(1, (11 * (1-(self.life/self.max_life))))) end,
	action = function(self, t)
        self:setEffect(self.EFF_MIC_UNN_LIMITS, t.getDuration(self, t), {power = t.getAllDamageInc(self, t), user = self}) --Set eff first, before resources are changed
        self.vim = self.max_vim --Shouldn't need any other checks. I.E. math.max(self.life, self.max_life) like in __M:actBase()
        self.psi = self.max_psi
        self.life = self.max_life
		game:playSoundNear(self, "talents/heal")
		return true
	end,
    info = function(self, t) --TODO particles
        talAll = t.getAllDamageInc(self, t)
        talAllCap = function(self, t) return self:combatTalentLimit(t, 75, 15, 30) end
        talDur = t.getDuration(self, t)
        if talAll == nil then talAll = 0 end
        if talDur == nil then talDur = 0 end
        return ([[You can activate this talent to push yourself to the absolute limit, increasing your all damage by up to %d%%. Also, your vim, psi and life will all be set to their maximum values, but upon the effect's expiry, your vim and psi will be set to 10%% of their maximum values and your life will be set to 20%%.
The all damage bonus will increase based on how low your vim and psi are when you activate the talent.
The duration will be increased based on how low your life is upon activation.
Current all damage bonus: %d%%
Current duration: %d]]):format(talAllCap(self, t), talAll, talDur)
    end,
}
