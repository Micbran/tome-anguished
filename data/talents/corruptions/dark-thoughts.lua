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

--High level debuff and self buff tree
--[[
"Dark thoughts seethe deep within your mind. Why not release them?"

Mangle: Reach into your target's mind, inflicting high darkness damage. It's okay... but could use more. After a delay maybe?
Chaos: Sustain. Killing an actor releases a burst of their last thoughts, dealing mind damage in a radius of 3 and inflicting confusion.
Death Field: Consume oppenents life in a radius of 3, dealing darkness damage and healing for half of it. Changed to darkness damage.
True Darkness: Darkness dam% + and darkness pen. All darkness damage has a chance to blind? Kinda weak. Maybe just flat pen and damage, as boring as it is.

]]

newTalent {
    name = "Mangle", short_name = "MIC_MANGLE",
    type = {"corruption/dark-thoughts", 1},
    points = 5,
    require = highmag_req1,
    requires_target = true,
    direct_hit = true,
    random_ego = "attack",
    cooldown = function(self, t) return self:combatTalentLimit(t, 10, 25, 17) end,
    vim = 10,
    psi = 20,
    range = function(self, t) return math.ceil(self:combatTalentLimit(t, 11, 5, 9)) end,
    tactical = {ATTACK = {DARKNESS = 2}},
    getDamage = function(self, t) return self:combatTalentMindDamage(t, 1, 300) + self:combatTalentSpellDamage(t, 1, 300, 2.00) end,
    action = function(self, t)
        local talDam = t.getDamage(self, t)
        local range = self:getTalentRange(t)
        local tg = {type="hit", range = range, radius = 1}
        local x,y,target = self:getTarget(tg)
        if not target or not self:canProject(tg, x, y) then return nil end
        self:project(tg, x, y, DamageType.DARKNESS, self:mindCrit(talDam))
        game.level.map:particleEmitter(x, y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=12, speed=5, img="demon_flames_circle", radius=tg.radius})
        game:playSoundNear(self, "talents/fire")
        return true
    end,
    info = function(self, t)
        local damage = t.getDamage(self, t)
        return ([[Reach deep into oppenents mind and pull at something. Hard. Deals %0.1f darkness damage.
The range and cooldown will increase/decrease with talent level.
The damage will scale off your #GOLD#mindpower#WHITE# and #VIOLET#spellpower#WHITE#.
This talent uses mind crit.]]):format(damDesc(self, DamageType.DARKNESS, damage))
    end,
}

newTalent { --Chaos: Sustain. Killing an actor releases a burst of their last thoughts, dealing mind damage in a radius of %d.
    name = "Chaos", short_name = "MIC_CHAOS",
    type = {"corruption/dark-thoughts", 2},
    points = 5,
    require = highmag_req2,
    mode = "sustained",
    sustain_psi = 30,
    cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 1, 10, 5)) end,
    radius = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 1, 2)) end,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) + self:combatTalentMindDamage(t, 10, 100) end,
    getPen = function(self, t) return self:combatTalentScale(t, 10, 50) end,
    target = function(self, t) return {type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), selffire = false} end,
    callbackOnKill = function(self, t, corpse, death_note)
        if self:isTalentActive(t.id) and not self:isTalentCoolingDown(t) then
            local tg = self:getTalentTarget(t)
            local dam = t.getDamage(self, t)
            self:project(tg, corpse.x, corpse.y, DamageType.DARKNESS, {dam = dam})
            game.level.map:particleEmitter(corpse.x, corpse.y, 2, "generic_sploom", {rm=0, rM=10, gm=0, gM=10, bm=0, bM=20, am=80, aM=150, radius=t.radius(self, t), basenb=120})
            self:startTalentCooldown(t)
        end

    end,
    activate = function(self, t)
        return {
            resPen = self:addTemporaryValue("resists_pen", {[DamageType.DARKNESS] = t.getPen(self, t)}),
            particle = self:addParticles(engine.Particles.new("generic_power", 1, {rm=0, rM=20, gm=0, gM=20, bm=0, bM=20, am=200, aM=255}))
        }
	end,

    deactivate = function(self, t, p)
        self:removeTemporaryValue("resists_pen", p.resPen)
        self:removeParticles(p.particle)
        return true
    end,

    info = function(self, t)
        talDam = t.getDamage(self, t)
        talRad = t.radius(self, t)
        talCool = t.cooldown(self, t)
        talPen = t.getPen(self, t)
        return ([[With this talent active, killing an actor will cause it to "explode" in a mess of dark energy. This explosion will deal %0.1f darkness damage in a radius of %d. Also, the potency of your darkness will be increased while this talent is active, giving you %d%% darkness resistance penetration.
This effect does have a cooldown. (%d)
The damage will scale with both your #GOLD#mindpower#WHITE# and #VIOLET#spellpower.#WHITE#]]):format(damDesc(self, DamageType.MIND, talDam), talRad, talPen, talCool)
    end,

}

newTalent { --Change to a life steal beam using the same damtype. Life Beam.
    name = "Devouring Ray", short_name = "MIC_LIFE_BEAM",
    type = {"corruption/dark-thoughts", 3},
    points = 5,
    require = highmag_req3,
    random_ego = "attack",
    cooldown = 10,
    vim = 10,
    psi = 10,
    tactical = {ATTACKAREA = {DARKNESS = 2}},
    range = 10,
    requires_target = true,
    getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) + self:combatTalentMindDamage(t, 10, 230) end,
    target = function(self, t) return {type = "beam", range = self:getTalentRange(t), talent = t,} end,
    action = function(self, t)
        local talDam = self:spellCrit(t.getDamage(self, t))
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        local grids = nil
        self:project(tg, x, y, DamageType.MIC_DARKNESS_DRAIN, talDam, nil)
        game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "life_beam", {tx=x-self.x, ty=y-self.y})
        game:playSoundNear(self, "talents/arcane")
        return true
    end,
    info = function(self, t)
        local talDam = t.getDamage(self, t)
        return ([[Fire a beam that steals the life of targets hit. Deals %0.1f darkness damage and 25%% of the damage dealt comes back to you as healing.
The damage will scale with both your #GOLD#mindpower#WHITE# and #VIOLET#spellpower#WHITE# equally.
This talent uses spell crit.]]):format(damDesc(self, DamageType.DARKNESS, talDam))
    end,
}

newTalent { --Mindblast: stun in AoE.
        name = "Mindblast", short_name = "MIC_BLAST",
        type = {"corruption/dark-thoughts", 4},
        points = 5,
        require = highmag_req4,
        random_ego = "attack",
        cooldown = 20,
        psi = 20,
        --No vim cost
        radius = 3,
        range = 7,
        tactical = {ATTACKAREA = {MIND = 2}, DISABLE = 2},
        requires_target = true,
        getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 275) end,
        target = function(self, t) return {type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), pass_terrain=false, friendly_fire=false, nowarning=true, selffire = false} end,
        action = function(self, t)
            local talDam = self:mindCrit(t.getDamage(self, t))
            local tg = self:getTalentTarget(t)
            local x, y = self:getTarget(tg)
            if not x or not y then return nil end
            local _ _, _, _, x, y = self:canProject(tg, x, y)
            local grids = self:project(tg, x, y, function(px, py)
    			local target = game.level.map(px, py, Map.ACTOR)
    			if target then
    				self:project({type="hit"}, px, py, DamageType.MIND, talDam)
                    game.level.map:particleEmitter(x, y, tg.radius, "force_blast", {radius=tg.radius})
    				if target:canBe("stun") then
    					target:setEffect(target.EFF_STUNNED, 3, {apply_power=100})
    				end
    			end
    		end)
            return true
        end,
        info = function(self, t)
            local talDam = t.getDamage(self, t)
            return ([[Send out a blast of mind energy that stuns all caught in the blast for 3 turns and deals %0.1f mind damage.
The damage will scale with your #GOLD#mindpower.#WHITE#]]):format(damDesc(self, DamageType.MIND, talDam))
        end,

}
