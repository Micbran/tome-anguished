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
getBirthDescriptor("race", "Elf").descriptor_choices.subrace["Soulless"] = "allow"

newBirthDescriptor {
    type = "subrace",
    name = "Soulless",
    desc = {
        "Soulless are a special kind of elf. Whether their soul has been lost because of a pact with an ancient demon or simply in order to protect it, Soulless are more powerful than your average elf.",
        "Unfortunately, this power has a cost. Their physical body has a tough time withstanding any blows and their bodies are weak, making it hard for them to swing a sword fast enough to hurt.",
        "They possess the #GOLD#Power of the Eternals#WHITE# talent which allows them to boost the potency of all their attacks.",
        "#GOLD#Stat modifiers:#GOLD#",
        "#LIGHT_BLUE# * -4 Strength, +1 Dexterity, -2 Constitution",
        "#LIGHT_BLUE# * +2 Magic, +4 Willpower, +4 Cunning",
        "#GOLD#Life per level: #LIGHT_BLUE# +8",
        "#GOLD#Experience Penalty:#LIGHT_BLUE# 25%",
    },
    inc_stats = {str = -4, dex = 1, con = -2, mag = 2, wil = 4, cun = 4},
    talents_types = {["race/soulless"] = {true, 0}},
    talents = {[ActorTalents.T_MIC_POWER_OF_THE_ETERNALS]=1},
    copy = {
		moddable_tile = "elf_#sex#",
		moddable_tile_base = "base_thalore_01.png",
		moddable_tile_ornament = {female="braid_01"},
		random_name_def = "thalore_#sex#",
		default_wilderness = {"playerpop", "thaloren"},
		starting_zone = "norgos-lair",
		starting_quest = "start-thaloren",
		faction = "thalore",
		starting_intro = "thalore",
		life_rating = 8,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=70}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=12 o.inscription_data.heal=50 end, {type="scroll", subtype="infusion", name="healing infusion", ego_chance=-1000, ego_chance=-1000}}),
	},
	experience = 1.25,
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}
