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

local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local Effects = require "engine.interface.ActorTemporaryEffects"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local chat = require "engine.Chat"
local PartyLore = require "mod.class.interface.PartyLore"


class:bindHook("ToME:load", function(self, data)
	DamageType:loadDefinition("/data-anguish/damage_types.lua")
	ActorTalents:loadDefinition("/data-anguish/talents/corruptions/corruptions.lua")
    ActorTalents:loadDefinition("/data-anguish/talents/psionic/psionic.lua")
    ActorTalents:loadDefinition("/data-anguish/talents/misc/races.lua")
	Birther:loadDefinition("/data-anguish/birth/birth.lua")
    Birther:loadDefinition("/data-anguish/birth/elf.lua")
	Effects:loadDefinition("/data-anguish/effects.lua")
end)

class:bindHook("Entity:loadList", function(self, data)
    if data.file == "/data/general/objects/world-artifacts.lua" then
        self:loadList("/data-anguish/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
	end
end)

class:bindHook("DamageProjector:final", function(self, data)

	if data.src.knowTalent and data.src:knowTalent(data.src.T_MIC_WEAVING) then
    	data.src.turn_procs.forWeavingX = data.x
    	data.src.turn_procs.forWeavingY = data.y
	end
end)
