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

Vim/Psi regen tree

Mind Drain: Deal mind damage and restore psi.
Life Shield: Consume 20% of your life and turn it into a shield with %0.1f effiency.
Siphon: Sustain. Draw life and vim from enemies in a radius of 5, draining psi. Kind of out of place.
Snap: Deal darkness damage in a radius 2 AoE. More damage if enemy is slowed? (For synergy with Yawning Mouth) + Yawning Mouth: Draw enemies into an area, inflicting a move speed slow in the area.
]]

local Object = require "mod.class.Object"

newTalent {
    name = "Mind Drain", short_name = "MIC_MIND_DRAIN",
    type = {"psionic/consumption", 1},
    require = wil_req1,
    points = 5,
    direct_hit = true,
    requires_target = true,
    psi = 0,
    cooldown = 5,
    range = 8,
    getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 175) end,
    getDrain = function(self, t) return self:combatTalentMindDamage(t, 0.05, 0.2) end, --A percent of max psi, up to 25%
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    action = function(self, t)
        local talDam = t.getDamage(self, t)
        local talDrain = t.getDrain(self, t)
        local tg = self:getTalentTarget(t)
        local x, y, target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        self:project(tg, x, y, DamageType.MIND, {dam=self:mindCrit(talDam)}) --Mind crit
        self.psi = math.min(self.max_psi, self.psi + self.max_psi*talDrain) --Restore a % of psi. Pretty sure resources can't go over their max in ToMe, but just in case.
        game.level.map:particleEmitter(x, y, 1, "generic_charge", {rm=130, rM=130, gm=205, gM=205, bm=240, bM=255, am=35, aM=90}) --135-206-250	light sky blue
        game:playSoundNear(self, "talents/spell_generic")
        return true
    end,
    info = function(self, t)
        talDam = t.getDamage(self, t)
        talDrain = t.getDrain(self, t)
        return ([[Drain energy from your target's mind, dealing %0.1f mind damage and restoring %d%% of your max psi.
The damage and percent drained will scale with your #GOLD#mindpower.#WHITE#]]):format(damDesc(self, DamageType.MIND, talDam), talDrain*100)
    end,
}

newTalent {
    name = "Life Shield", short_name = "MIC_LIFE_SHIELD",
    type = {"psionic/consumption", 2},
    no_energy = true,
    require = wil_req2,
    points = 5,
    getConversionRate = function(self, t) return self:combatTalentSpellDamage(t, 1, 20) end,
    getDuration = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
    cooldown = 20,
    action = function(self, t)
        local talDur = t.getDuration(self, t)
        local healthRatio = t.getConversionRate(self, t)
        local oldHealth = self.life
        local durationBoost = self.life > self.max_life/2 and true or false --Might be unecessary. Wanted it to slightly synergize with unnatural limits tho.
        local shieldStr  = (oldHealth * 0.2) * healthRatio --Get the 20% of life, then put it into the ratio to get shield strength.
        game.logSeen(self, "#RED#%s uses some of their life force to create a shield!#RED#", self.name:capitalize())
        self.life = math.max(1, oldHealth - oldHealth * 0.2) --Just in case. Should work.
        if durationBoost == true then
            talDur = talDur * 1.5
        end
        if durationBoost == false then
            shieldStr = shieldStr + healthRatio * 30
        end
        self:setEffect(self.EFF_DAMAGE_SHIELD, talDur, {power = shieldStr, src=self})
        game:playSoundNear(self, "talents/arcane")
        return true
    end,
    info = function(self, t)
        convert = t.getConversionRate(self, t)
        talDur = t.getDuration(self, t)
        currShield = self.life * 0.2 * convert
        return([[Form a wicked shield of your own life force, using 20%% of your current life and turning it into a damage shield with a conversion rate of %0.2f and lasting for %d turns.
If your life is above 50%% at the time you use the talent then the duration of the shield will be extended by 50%%, but if your life is under 50%% then the shield strength will act as if 30 more life had been converted (%d extra shield).
The conversion ratio will increase with your #VIOLET#spellpower.#WHITE#
This talent is instant.
Current Shield Strength (without bonus shield from bonus shield from being under 50%% life): %d
#RED#This talent cannot crit!#RED#]]):format(convert, talDur, 30*convert, currShield)
    end,
}


--[[
Relevant code bit for acquiring targets in an AoE. Run this in a callbackOnActBase, I guess
local targets = {}
local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
for x, yy in pairs(grids) do
    for y, _ in pairs(grids[x]) do
        local target = game.level.map(x, y, Map.ACTOR)
        if target and self:reactionToward(target) < 0 then
            targets[#targets + 1] = target
        end
    end
end

if #targets == 0 then return false end

]]
newTalent {
    name = "Siphon", short_name = "MIC_SIPHON",
    type = {"psionic/consumption", 3},
    mode = "sustained",
    require = wil_req3,
    points = 5,
    radius = function(self, t) return math.ceil(self:combatTalentLimit(t, 7, 3, 5)) end,
    cooldown = 25,
    sustain_psi = 25,
    drain_psi = 6,
    getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 75) end,
    getVimDrain = function(self, t) return self:combatTalentSpellDamage(t, 1, 8) end,
    activate = function(self, t)
        game:playSoundNear(self, "talents/spell_generic2")
        return {}
    end,

    callbackOnActBase = function(self, t)
        if self:getPsi() < 6 then self:forceUseTalent(self.T_MIC_SIPHON, {ignore_energy = true}) return end
        local p = self:isTalentActive(t.id)
        if p then
            local targets = {}
            local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRadius(t), true)
            for x, yy in next, grids do
                for y, _ in next, yy do
                    local target = game.level.map(x, y, Map.ACTOR)
                    if target and self:reactionToward(target) < 0 then
                        targets[#targets + 1] = target
                    end
                end
            end
            if #targets == 0 then return end
            local talDam = t.getDamage(self, t)
            local vimDrain = t.getVimDrain(self, t)
            for i, tar in ipairs(targets) do
                self:project({type = "hit", talent = t, x = tar.x, y = tar.y}, tar.x, tar.y, DamageType.MIC_DARKNESS_DRAIN, talDam)
                self.vim = self.vim + vimDrain
                game.level.map:particleEmitter(tar.x, tar.y, 1, "reproach", {dx = self.x - tar.x, dy = self.y - tar.y })
            end
        end
    end,


    deactivate = function(self, t, p)
        return true
    end,
    info = function(self, t)
        talDam = t.getDamage(self, t)
        talVimDrain = t.getVimDrain(self, t)
        talRadius = self:getTalentRadius(t)
        return ([[When activated, you will drain life and vim from enemies in a %d radius around you. Each turn, afflicted targets will take %0.1f darkness damage. You will heal for 25%% of the damage dealt and %0.1f vim will be restored every time a target is hit.
The damage will scale with your #GOLD#mindpower#WHITE# and the amount of vim drained will scale with your #GOLD#spellpower.#WHITE#
#RED#This talent drains 6 psi while active!#WHITE#]]):format(talRadius, damDesc(self, DamageType.DARKNESS, talDam), talVimDrain)
    end,
}
--if not self.summoner:isTalentActive(self.summoner.T_YOURTALENT). replace the temportary section of maelstrom code
newTalent { --Now the hard talent: Create a lasting map effect that lasts as long as the talent is sustained. Deactivating projects a darkness attack in the same radius.
    name = "Gaping Maw/Snap", short_name = "MIC_SNAP",
    type = {"psionic/consumption", 4},
    points = 5,
    mode = "sustained",
    require = wil_req4,
    range = 5,
    malX = nil,
    malY = nil,
    radius = function(self, t) return math.floor(self:combatTalentLimit(t, 7, 3, 5)) end,
    sustain_vim = 10,
    sustain_psi = 50,
    vim = 25,
    psi = 50,
    cooldown = 20,
    getDamage = function(self, t) return self:combatTalentMindDamage(t, 1, 250) + self:combatTalentSpellDamage(t, 1, 250) end,
    target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), nolock = true, talent=t, selffire = false} end,
    activate = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        malX = x
        malY = y
        if not x or not y then return nil end
        local _ _, x, y = self:canProject(tg, x, y)
        local oe = game.level.map(x, y, Map.TERRAIN+1)
        if (oe and oe.is_maelstrom) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

        local e = Object.new{
			old_feat = oe,
			type = "psionic", subtype = "maelstrom",
			name = self.name:capitalize().. "'s maelstrom",
			display = ' ',
			tooltip = mod.class.Grid.tooltip,
			always_remember = true,
            temporary = 1,
			is_maelstrom = true,
			x = x, y = y,
			canAct = false,
			radius = self:getTalentRadius(t),
			act = function(self)
				local tgts = {}
				local Map = require "engine.Map"
				local DamageType = require "engine.DamageType"
				local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local Map = require "engine.Map"
					local target = game.level.map(x, y, Map.ACTOR)
					local friendlyfire = false
					if target and not (friendlyfire == false and self.summoner:reactionToward(target) >= 0) then
						tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
					end
				end end
				table.sort(tgts, "sqdist")
				for i, target in ipairs(tgts) do
					self.summoner.__project_source = self
					if target.actor:canBe("knockback") then
						target.actor:pull(self.x, self.y, 1)
						target.actor.logCombat(self, target.actor, "#Source# pulls #Target# in!")
					end
					self.summoner.__project_source = nil
                    target.actor:setEffect(target.actor.EFF_MIC_MAEL_SLOW, 2, {power=0.2})
				end

				self:useEnergy()
				if not self.summoner:isTalentActive(self.summoner.T_MIC_SNAP) then
					game.level.map:removeParticleEmitter(self.particles)
					if self.old_feat then game.level.map(self.x, self.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+1) end
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
        local particle = engine.Particles.new("generic_vortex", e.radius, {radius=e.radius, rm=80, rM=90, gm=80, gM=90, bm=80, bM=90, am=35, aM=90})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", e.radius, {radius=e.radius}) end
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/lightning_loud")
        return {}
    end,

    deactivate = function(self, t)
        if malX ~= nil and malY ~= nil then
            local dam = self:mindCrit(t.getDamage(self, t))
            local tg = self:getTalentTarget(t)
            self:project(tg, malX, malY, DamageType.DARKNESS, dam)
            if core.shader.active() then
                game.level.map:particleEmitter(malX, malY, tg.radius, "starfall", {radius=tg.radius, tx=malX, ty=malY})
            else
                game.level.map:particleEmitter(malX, malY, tg.radius, "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=tg.radius})
            end
        end
        return true
    end,
    info = function(self, t)
        talDam = t.getDamage(self, t)
        talRad = self:getTalentRadius(t)
        return ([[When activated, you create a maelstorm of radius %d on the ground that draws in everyone and slows their movement speed by 20%% in its radius. When deactivated, a mouth of darkness will swallow all of those in the same radius, dealing %0.1f darkness damage.
The damage will scale with your #GOLD#mindpower#WHITE# and #VIOLET#spellpower.#WHITE#
This talent can mind crit upon deactivation.]]):format(talRad, damDesc(self, DamageType.DARKNESS, talDam))
    end,
}
