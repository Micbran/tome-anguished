-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Astar = require "engine.Astar"


--[[

burn away all resist, deal hellfire dam type.
Blight disease that reduces global speed
deal darkness damage over time and remove sustain if talent level is high enough.
generic blight DoT


]]

newEffect { --Hellfire eff
    name = "MIC_BURNING_FLAMES", image = "talents/MIC_HOT_BURNY_FLAMES.png",
    desc = "Hellfire",
    long_desc = function(self, eff) return("The target is burning with flames straight from hell, or whatever its closest equivalent is in Maj'Eyal. This reduces their all resistance by %d%% and deals %0.1f darkness damage and %0.1f fire damage"):format(eff.power, eff.dam/2, eff.dam/2) end,
    type = "magical",
    subtype = {fire = true, darkness = true},
    status = "detrimental",
    parameters = {power = 3, dam = 20, numOfTurns = 1, src = nil},
    on_gain = function(self, err) return "Things are getting hot in here!", "+Hellfire" end,
    on_lose = function(self, err) return "#Target# no longer feels the need to repent for their sins.", "-Hellfire" end,
    activate = function(self, eff)
        eff.particle1 = self:addParticles(Particles.new("inferno", 1))
    end,
    on_timeout = function(self, eff)
        if eff.resid then self:removeTemporaryValue("resists", eff.resid) end
        eff.resid = self:addTemporaryValue("resists", {all = math.max(-eff.power * eff.numOfTurns, -40)}) --Still not sure.Capped at 40
        eff.numOfTurns = eff.numOfTurns + 1
        DamageType:get(DamageType.MIC_HELLFIRE).projector(eff.src, self.x, self.y, DamageType.MIC_HELLFIRE, eff.dam)
    end,
    on_merge = function(self, old_eff, new_eff)
        self:removeTemporaryValue("resists", old_eff.resid)
        return new_eff
    end,
    deactivate = function(self, eff)
        self:removeParticles(eff.particle1)
        self:removeTemporaryValue("resists", eff.resid)
    end,
}

newEffect {
    name = "MIC_EROSION", image = "talents/MIC_ERODE.png",
    desc = "Erosion",
    long_desc = function(self, eff) return("The target is inflicted with a eroding curse, reducing global speed by %d%% and dealing %0.1f blight damage per turn."):format(eff.power*100, eff.dam) end,
    type = "magical",
    subtype = {blight = true},
    status = "detrimental",
    parameters = {power = 0.1, dam = 20, src = nil},
    on_gain = function(self, err) return "#Target# is slowing down.", "+Erosion" end,
    on_lose = function(self, err) return "#Target# is back to normal.", "-Erosion" end,
    activate = function(self, eff)
        eff.speedid = self:addTemporaryValue("global_speed_add", -eff.power)
        eff.particles = self:addParticles(engine.Particles.new("generic_power", 1, {rm=30, rM=40, gm=200, gM=225, bm=5, bM=10, am=200, aM=255}))    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.DRAIN_VIM).projector(eff.src, self.x, self.y, DamageType.DRAIN_VIM, eff.dam)
    end,
    deactivate = function(self, eff)
        self:removeParticles(eff.particles)
        self:removeTemporaryValue("global_speed_add", eff.speedid)
    end,
}

newEffect {
    name = "MIC_ERASURE", image = "talents/MIC_ERASE.png",
    desc = "Erasure",
    long_desc = function(self, eff) return ("The target is being erased from reality. Deals %0.1f darkness damage per turn."):format(eff.dam) end,
    type = "magical",
    subtype = {darkness = true},
    status = "detrimental",
    parameters = {dam = 20, doErase = false, src = nil},
    on_gain = function(self, err) return "#Target# is being erased from reality!", "+Erasure" end,
    on_lose = function(self, err) return "#Target# feels more in touch with reality.", "-Erasure" end,
    activate = function(self, eff)
        --particles
        --eff.particles = self:addParticles(engine.Particles.new())
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
        if doErase then
            self:removeSustainsFilter(nil, 1)
        end
    end,
    deactivate = function(self, eff)
        --self:removeParticles(eff.particles)
    end,

}

newEffect {
    name = "MIC_DOOOM", image = "talents/MIC_DOOOOM.png",
    desc = "Doom",
    long_desc = function(self, eff) return ("The target has been doomed! They are taking %0.1f blight damage per turn and the length of all neagtive effects on them have been extended."):format(eff.dam) end,
    type = "magical",
    subtype = {blight = true},
    status = "detrimental",
    parameters = {dam = 20, src = nil},
    on_gain = function(self, err) return "DOOOOOOOOOOOOOOOOOM", "+DOOOOOOOOOM" end,
    on_lose = function(self, err) return "#Target# feels less doomed.", "-Doom" end,
    activate = function(self, eff)
        --eff.particles = self:addParticles(engine.Particles.new())
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam)
    end,
    deactivate = function(self, eff)
        --self:removeParticles(eff.particles)
    end,
}

newEffect {
    name = "MIC_POWER_OF_THE_ETERNALS", image = "talents/mic_power_of_the_eternals.png",
    desc = "Power of the Eternals",
    long_desc = function(self, eff) return ("You're surging with ancient power! All powers increased by %d and all damage increased by %d%%."):format(eff.power, eff.power2) end,
    type = "magical",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {power = 1, power2 = 1},
    on_gain = function(self, err) return "#Target# is surging with ancient power!", "+Power of the Eternals" end,
    on_lose = function(self, err) return "#Target# feels normal again.", "-Power of the Eternals" end,
    activate = function(self, eff)
        eff.mental = self:addTemporaryValue("combat_mindpower", eff.power)
        eff.spell = self:addTemporaryValue("combat_spellpower", eff.power)
        eff.physical = self:addTemporaryValue("combat_dam", eff.power)
        eff.dam = self:addTemporaryValue("inc_damage", {all=eff.power2})
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("combat_mindpower", eff.mental)
        self:removeTemporaryValue("combat_spellpower", eff.spell)
        self:removeTemporaryValue("combat_dam", eff.physical)
        self:removeTemporaryValue("inc_damage", eff.dam)
    end,
}

--[[

silence+impending doom like damage [debuff]
'transfer'. All resist + and all damage + and all damage - and all resist - [buff and debuff]
-heal mod + DoT [debuff]
pin + mind dam DoT [debuff]
mind resist reduction [debuff]
global speed + movement speed + [buff]
fire DoT + silence [debuff]
mindburn DoT + save reduction [debuff]
stacking mind damage +% [buff]
Mind speed increase stacking buff

]]

--[[

newEffect { --Template
    name = "", image = "",
    desc = "",
    long_desc = function(self, eff) return("") end,
    type = "mental",
    subtype = {},
    status = "",
    parameters = {},
    on_gain = function(self, err) return "", "" end,
    on_lose = function(self, err) return "", "" end,
    activate = function(self, eff)

    end,
    on_timeout = function(self, eff)

    end,
    deactivate = function(self, eff)

    end,
}

]]


newEffect { --Gonna last 5 turns.
    name = "MIC_CHOKING_DARKNESS_DEBUFF", image = "effects/silenced.png",
    desc = "Choking Darkness",
    long_desc = function(self, eff) return ("The target is being choked by darkness, silencing it and dealing %d% per turn"):format(eff.dam) end,
    type = "mental",
    subtype = {silence=true, darkness = true },
    status = "detrimental",
    parameters = {dam = 10},
    on_gain = function(self, err) return "#Target# is being choked by darkness!", "+Choking" end,
    on_lose = function(self, err) return "#Target# is no longer being choked.", "-Choking" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("silence", 1)
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("silence", eff.tmpid)
    end,

}

newEffect { --Transfer Malus
    name = "MIC_TRANSFER_MALUS",  image = "talents/MIC_SOUL_STEAL.png",
    desc = "Stolen Soul",
    long_desc = function(self, eff) return ("Some of the target's power has been stolen! All damage is reduced by %d%% and all resist is reduced by %d%%."):format(eff.power, eff.power2) end,
    type = "mental",
    subtype = {debuff = true},
    status = "detrimental",
    parameters = {power = 10, power2 = 8},
    on_gain = function(self, err) return "#Target#\'s powers are being stolen!", "+Transfer Malus" end,
    on_lose = function(self, err) return "#Target#\'s powers have returned to them.", "-Transfer Malus" end,
    activate = function(self, eff)
        eff.damageid = self:addTemporaryValue("inc_damage", {all=-eff.power})
        eff.resistid = self:addTemporaryValue("resists", {all=-eff.power2})
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("inc_damage", eff.damageid)
        self:removeTemporaryValue("resists", eff.resistid)
    end,

}

newEffect {  --Transfer Buff. Used Copy-Paste so there might be errors.
    name = "MIC_TRANSFER_BUFF", image = "talents/MIC_SOUL_STEAL.png",
    desc = "Soul Steal",
    long_desc = function(self, eff) return("You have stolen your target's power! Your all damage is being increased by %d%% and your all resist is being increased by %d%%."):format(eff.power, eff.power2) end,
    type = "mental",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {power = 10, power2 = 8},
    on_gain = function(self, err) return "#Target#\'s power has increased!", "+Transfer" end,
    on_lose = function(self, err) return "#Target#\'s stolen power returns to its owner.", "-Transfer" end,
    activate = function(self, eff)
        eff.damageid = self:addTemporaryValue("inc_damage", {all=eff.power})
        eff.resistid = self:addTemporaryValue("resists", {all=eff.power2})
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("inc_damage", eff.damageid)
        self:removeTemporaryValue("resists", eff.resistid)
    end,
}


newEffect { --Paranoia: Movement spd + global spd boost
    name = "MIC_PARANOIA_BUFF", image = "effects/insomnia.png",
    desc = "Paranoia",
    long_desc = function(self, eff) return("Your fear of death increases your movement speed by %d%% and your global speed by %d%%."):format(eff.power*100, eff.power2*100) end,
    type = "mental",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {power = .3, power2 = .3},
    on_gain = function(self, err) return "#Target# is afraid of death!", "+Paranoia" end,
    on_lose = function(self, err) return "#Target#\'s adrenaline rush subsides.", "-Paranoia" end,
    activate = function(self, eff)
        eff.gspdid = self:addTemporaryValue("global_speed_add", eff.power2)
        eff.mvspdid = self:addTemporaryValue("movement_speed", eff.power)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("global_speed_add", eff.gspdid)
        self:removeTemporaryValue("movement_speed", eff.mvspdid)
    end,
}

newEffect { --Cauterize Lips
    name = "MIC_CAUTERIZE_LIPS_DEBUFF", image = "effects/silenced.png",
    desc = "Cauterized Lips",
    long_desc = function(self, eff) return("The target's lips have been cauterized, silencing them and dealing %d% fire damage per turn."):format(eff.dam) end,
    type = "mental",
    subtype = {silence = true},
    status = "detrimental",
    parameters = {dam = 10},
    on_gain = function(self, err) return "#Target#\'s lips have been cauterized!", "+Cauterized Lips" end,
    on_lose = function(self, err) return "#Target#\'s managed to unseal their lips.", "-Cauterized Lips" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("silence", 1)
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.dam)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("silence", eff.tmpid)
    end,
}


newEffect {
    name = "MIC_MINDBURN_DEBUFF", image = "talents/MIC_BURNY_MIND.png",
    desc = "Mindburn",
    long_desc = function(self, eff) return("The target's mind is alight, reducing all of their saves by %d and dealing %d arcane resource burn damage per turn."):format(eff.power, eff.dam) end,
    type = "mental",
    subtype = {debuff = true},
    status = "detrimental",
    parameters = {power = 1, dam = 1},
    on_gain = function(self, err) return "#Target#\'s mind is on fire!", "+Mindburn" end,
    on_lose = function(self, err) return "#Target#\'s mind has cooled down.", "-Mindburn" end,
    activate = function(self, eff)
        eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.MIC_MINDBURN).projector(eff.src, self.x, self.y, DamageType.MIC_MINDBURN, eff.dam)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
    end,
}

newEffect {
    name = "MIC_ANGUISH_EFF", image = "talents/MIC_ANGUISH",
    desc = "Anguish",
    long_desc = function(self, eff) return("The target is experiencing pain like no other, reducing its ability to focus. Reduces all powers by %d."):format(eff.power) end,
    type = "mental",
    subtype = {debuff = true},
    status = "detrimental",
    parameters = {power = 10},
    on_gain = function(self, err) return "#Target# is feeling pain greater than anything else!", "+Anguish" end,
    on_lose = function(self, err) return "#Target# feels normal again.", "-Anguish" end,
    activate = function(self, eff)
        eff.mental = self:addTemporaryValue("combat_mindpower", -eff.power)
        eff.spell = self:addTemporaryValue("combat_spellpower", -eff.power)
        eff.physical = self:addTemporaryValue("combat_dam", -eff.power)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("combat_mindpower", eff.mental)
        self:removeTemporaryValue("combat_spellpower", eff.spell)
        self:removeTemporaryValue("combat_dam", eff.physical)
    end,
}


--[[

Just need two buffs: Magic Weaving and Mind Weaving.
Mind makes next spell cast have an extra effect.
Magic makes next mind cast have an extra effect.

]]

newEffect { --Exists only to keep track of casting
    name = "WEAVE_MIND", image = "effects/summon_destabilization.png",
    desc = "Mind Weaving",
    long_desc = function(self, eff) return ("Your next spell cast will have a bonus effect added on to it.") end,
    type = "other",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {},
    on_gain = function(self, err) return "#Target#'s next spell will be empowered!", "+Mind Weaving" end,
    on_lose = function(self, err) return "#Target# is no longer weaving their mind powers with their spells.", "-Mind Weaving" end,
    activate = function(self, eff) end,
    deactivate = function(self, eff) end,


}

newEffect { --See above
    name = "WEAVE_SPELL", image = "effects/spacetime_stability.png",
    desc = "Spell Weaving",
    long_desc = function(self, eff) return ("Your next mind power will have a bonus effect added on to it.") end,
    type = "other",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {},
    on_gain = function(self, err) return "#Target#'s next mind power will be empowered!", "+Spell Weaving" end,
    on_lose = function(self, err) return "#Target# is no longer weaving their spells with their mind powers.", "-Spell Weaving" end,
    activate = function(self, eff) end,
    deactivate = function(self, eff) end,

}

newEffect { --Unnatural Limits other buff. Increases all damage and on deactivate (which hopefully also happens when buff is canceled) sets vim and psi to 10% and life to 20%
    name = "MIC_UNN_LIMITS", image = "effects/free_action.png",
    desc = "Unnatural Limits",
    long_desc = function(self, eff) return ("Your power has been increased. All damage you deal is increased by %0.2f%%. This effect will greatly cripple the user when it deactivates."):format(eff.power*100) end,
    type = "other",
    subtype = {buff = true},
    status = "beneficial",
    parameters = {power = 0.2, user = nil},
    on_gain = function(self, err) return "#Target# has found a sudden burst of energy!", "+Unnatural Limits" end,
    on_lose = function(self, err) return "#Target# is exhausted.", "-Unnatural Limits" end,
    activate = function(self, eff)
        eff.damid = self:addTemporaryValue("inc_damage", {all = eff.power})
        eff.particle1 = self:addParticles(Particles.new("nova", 1))
        eff.particle2 = self:addParticles(Particles.new("overwhelmed", 1))
    end,
    deactivate = function(self, eff) --Pass in self as a parameter for user. Should be able to manipulate self's variables.
        --Reduce life, vim and psi. Remove all dam buff.
        self:removeTemporaryValue("inc_damage", eff.damid)
        self:removeParticles(eff.particle1)
        self:removeParticles(eff.particle2)
        eff.user.life = eff.user.max_life*0.2
        eff.user.psi = eff.user.max_psi*0.1
        eff.user.vim = eff.user.max_vim*0.1 --Pray this works.

    end,
}

--[[

movement speed slow [debuff]

]]


newEffect { --Footlock, slows mvspeed
    name = "MIC_FOOTLOCK_DEBUFF", image = "talents/slow.png",
    desc = "Footlocked",
    long_desc = function(self, eff) return("The target is having trouble picking up their feet, reducing their movement speed by %d%%."):format(eff.power * 100) end,
    type = "physical",
    subtype = {slow = true},
    status = "detrimental",
    parameters = {power = 0.1},
    on_gain = function(self, err) return "#Target#\'s feet (or other foot-like appendages) feel much heavier!", "+Footlock" end,
    on_lose = function(self, err) return "#Target#\'s feet (or whatever) feel normal again.", "-Footlock" end,
    activate = function(self, eff)
        eff.movid = self:addTemporaryValue("movement_speed", -1*eff.power)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("movement_speed", eff.movid)
    end,
}

newEffect { --Choke Debuff. Pin and phys damage on timeout
    name = "MIC_CHOKED", image = "effects/silenced.png",
    desc = "Choke",
    long_desc = function(self, eff) return ("The target is being choked by an unknown force, silencing it and dealing %d physical damage per turn."):format(eff.dam) end,
    type = "physical",
    subtype = {silence=true, physical = true },
    status = "detrimental",
    parameters = {dam = 10},
    on_gain = function(self, err) return "#Target# is being choked!", "+Choking" end,
    on_lose = function(self, err) return "#Target# is no longer being choked.", "-Choking" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("silence", 1)
    end,
    on_timeout = function(self, eff)
        DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.dam)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("silence", eff.tmpid)
    end,
}

newEffect {
    name = "MIC_MAEL_SLOW", image = "talents/slow.png",
    desc = "Slowed",
    long_desc = function(self, eff) return ("The target is having trouble escaping the maelstrom. Their movement speed has been reduced by %d%%."):format(eff.power*100) end,
    type = "physical",
    subtype = {slow = true},
    status = "detrimental",
    parameters = {power = 0.1},
    on_gain = function(self, err) return "#Target# can barely move in the ongoing storm!", "+Slow" end,
    on_lose = function(self, err) return "#Target# feels like it can move normally again.", "-Slow" end,
    activate = function(self, eff)
        eff.movid = self:addTemporaryValue("movement_speed", -1*eff.power)
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("movement_speed", eff.movid)
    end,
}
