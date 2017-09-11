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

--Need mindburn damage. Fire + arcane resource burn.
--Mind damage with life drain
--Darkness dam and fire dam split.

function DamageType.initState(state)
	if state == nil then return {}
	elseif state == true or state == false then return {}
	else return state end
end

-- Loads the implicit crit if one has not been passed.
function DamageType.useImplicitCrit(src, state)
	if state.crit_set then return end
	state.crit_set = true
	if not src.turn_procs then
		state.crit_type = false
		state.crit_power = 1
	else
		state.crit_type = src.turn_procs.is_crit
		state.crit_power = src.turn_procs.crit_power or 1
		src.turn_procs.is_crit = nil
		src.turn_procs.crit_power = nil
	end
end

local useImplicitCrit = DamageType.useImplicitCrit
local initState = DamageType.initState

newDamageType { --Might error out if target has no arcane resources. Mindburn damage.
    name = "mindburn", type = "MIC_MINDBURN",
    projector = function(src, x, y, type, dam, state)
        state = DamageType.initState(state)
        DamageType.useImplicitCrit(src, state)
        local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:burnArcaneResources(realdam)
        end
        return realdam
    end,
}


--[[
newDamageType{
	name = "blight fire", type = "BLIGHT_FIRE",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam/2)
		realdam = realdam + DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam/2)
		return realdam
	end
}
]]
newDamageType { --Fire and Darkness damage split.
    name = "hellfire", type = "MIC_HELLFIRE",
    projector = function(src, x, y, type, dam, state)
        --[[local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam/2)
        realdam = realdam + DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam/2)]]--
        state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2)
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam / 2)
    end,
}

--[[newDamageType {
    name = "dark darkness", type = "MIC_BLINDING_DARKNESS",
    projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(50) then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {src=src, apply_power=src:combatMindpower()})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
	end,
}--]]

newDamageType { --darkness damage with "life steal"
    name = "draining darkness", type = "MIC_DARKNESS_DRAIN", text_color = "#RED#", --Not sure if red is valid, but it should be. Who knows.
    projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, healfactor=0.25} end
		local target = game.level.map(x, y, Map.ACTOR) -- Get the target first to make sure we heal even on kill
		local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam, state)
		if target and realdam > 0 then
			src:heal(realdam * dam.healfactor, target)
			src:logCombat(target, "#CRIMSON##Source# steals life from #Target#!#CRIMSON#")
		end
		return realdam
	end,
}

--[[
newDamageType{
	name = "shadowfrost", type = "SHADOWFROST",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam / 2)
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam / 2)
	end,
}
]]
newDamageType {
    name = "footlockDam", type = "FOOTLOCKSLOW",
    projector = function(src, x, y, type, dam, state)
        state = initState(state)
        useImplicitCrit(src, state)
        --if _G.type(dam) == "number" then dam = {dam=dam} end
        local target = game.level.map(x, y, Map.ACTOR)
        if not target then return end
        if target then
            if dam.slow then
                target:setEffect(target.EFF_MIC_FOOTLOCK_DEBUFF, dam.dur, {power = dam.slow, apply_power = dam.power, no_ct_effect = true}) end
        end
    end, --No damage projection. Hopefully that works.
}
