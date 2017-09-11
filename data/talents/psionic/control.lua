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

Utility/Mobility tree

Propel: Control the air near you and use it to propel yourself in a given direction for x spaces max.
Push: Push away all enemies in radius 4, dazing them. (Mindpower check)
Footlock: Same as manip.
Choke: In other words, I've been playing too much KotOR. Phys dam over time with silence attached.


]]

newTalent {
    name = "Propel", short_name = "MIC_PROPEL",
    type = {"psionic/control", 1},
    require = wil_req1,
    points = 5,
    cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 30, 15)) end,
    psi = 10,
    range = function(self, t) return self:combatTalentScale(t, 4, 10) end,
    tactical = {CLOSEIN = 3},
    requires_target = true,
    target = function(self, t) return {type = "bolt", range = self:getTalentRange(t), nolock=true, nowarning=true, requires_knowledge=false, stop__block=true,} end,
    action = function(self, t) --Copy pasted code from rush.
        local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local linestep = self:lineFOV(x, y, block_actor)

		local tx, ty, lx, ly, is_corner_blocked
		repeat  -- make sure each tile is passable
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = linestep:step()
		until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
		if not tx or core.fov.distance(self.x, self.y, tx, ty) < 1 then
			game.logPlayer(self, "You won't be able to stop yourself in time when you're this close!")
			return
		end
		if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
        return true
    end,
    info = function(self, t)
        return ([[Manipulate the air around you and use it to propel yourself in a given direction, up to %d tiles max.]]):format(self:getTalentRange(t))
    end,
}

newTalent { --Push: Push away all enemies in radius 4, dazing them. (Mindpower check)
    name = "Push", short_name = "MIC_PUSH",
    type = {"psionic/control", 2},
    require = wil_req2,
    points = 5,
    cooldown = 15,
    psi = 25,
    range = 0,
    radius = 4,
    getDazeDuration = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 3, 6)) end,
    target = function(self, t) return {type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), talent = t, selffire = false} end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        self:project(tg, self.x, self.y, function(px, py)
            local target = game.level.map(px, py, Map.ACTOR)
            if not target then return end
            if target:canBe("knockback") then target:knockback(self.x, self.y, 3) end
            if target:canBe("stun") then target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {apply_power=self:combatMindpower()}) end
        end)
        return true
    end,
    info = function(self, t)
        return ([[Push all enemies 3 tiles away from you in a radius of 4, dazing them for %d turns if they fail a #GOLD#mindpower#WHITE# check.]]):format(t.getDazeDuration(self, t))
    end,
}

newTalent { --Footlock: Same as manip.
    name = "Footlock", short_name = "MIC_FOOTLOCK",
    type = {"psionic/control", 3},
    require = wil_req3,
    points = 5,
    cooldown = 25,
    range = 7,
    psi = 35,
    radius = function(self, t) return math.floor(self:combatTalentLimit(t, 9, 3, 6)) end,
    getMapEffDuration = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 4, 7)) end,
    getSlowPower = function(self, t) return self:combatTalentMindDamage(t, 0.15, 0.6) end,
    tactical = {DISABLE = 2},
    direct_hit = true,
    requires_target = true,
    target = function(self, t)
        return {type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), talent = t, selffire = false}
    end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        local _ _, _, _, x, y = self:canProject(tg, x, y)

        --Lasting effect
        local slowPow = t.getSlowPower(self, t)
        game.level.map:addEffect(self,
        x, y, t.getMapEffDuration(self, t),
        DamageType.FOOTLOCKSLOW, {dam = 0, dur = 1, slow = slowPow, power = self:combatMindpower()},
        self:getTalentRadius(t),
        5, nil,
        {type = "gravity_well"},
        nil, false
        )
        game:playSoundNear(self, "talents/earth")
		return true
    end,
    info = function(self, t)
        talRad = t.radius(self, t)
        talSlow = t.getSlowPower(self, t)
        talDur = t.getMapEffDuration(self, t)
        return ([[Apply a large, slowing field to terrain of your choosing for %d turns. This field will have a radius of %d and will slow entities' movement speed within it by %d%%.
        The slow amount will scale with your #GOLD#mindpower.#WHITE#]]):format(talDur, talRad, talSlow*100)
    end,
}

newTalent {
    name = "Choke", short_name = "MIC_CHOKE",
    type = {"psionic/control", 4},
    require = wil_req4,
    points = 5,
    random_ego = "attack",
    cooldown = 30,
    psi = 25,
    range = 8,
    tactical = {ATTACK = {PHSYICAL = 2}, DISABLE = {SILENCE = 2}},
    getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 80) end, --timeout dam
    getDuration = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
    requires_target = true,
    direct_hit = true,
    target = function(self, t) return {type = "hit", range = self:getTalentRange(t)} end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
        talDur = t.getDuration(self, t)
        talDam = t.getDamage(self, t)
        game:playSoundNear(self, "talents/breath")
        target:setEffect(target.EFF_MIC_CHOKED, talDur, {src = self, apply_power = self:combatMindpower(), dam = talDam})
    return true
    end,
    info = function(self, t)
        talDur = t.getDuration(self, t)
        talDam = t.getDamage(self, t)
        return([[Choke a target from a range, silencing them and dealing %d damage per turn for %d turns.
        The damage will scale with your #GOLD#mindpower.#WHITE#]]):format(damDesc(self, DamageType.PHSYICAL, talDam), talDur)
    end,
}
