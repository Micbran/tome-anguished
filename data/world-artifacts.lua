-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Talents = require "engine.interface.ActorTalents"

--Artifacts can be found anywhere because they are in the WORLD artifacts file.

--[[newEntity {
    base = "",
    power_source = {}, --arcane, psionic, nature, technique, etc.
    rarity = 0,
    unique = true,
    name = "", image = "",
    unided_name = "",
    level_range = {},
    color = colors.BLACK,
    desc = ,
    cost = 200,
    require = {stat = {},},
    material_level = 1,
    wielder = {

    }
}]]

newEntity { --T4 mindstar for cleansing tree in Anguished.
    base = "BASE_MINDSTAR", --Syntax: BASE_ITEM
    define_as = "MIC_BURNY_MINDSTAR",
    power_source = {antimagic = true, psionic = true}, --arcane, psionic, nature, technique, etc.
    rarity = 350, --Any number. Higher = more rare
    unique = true, --Can only drop once, I presume.
    name = "The Purifier", image = "object/artifact/thermal_focus.png", --EIther thermal focus or core of the forge. Or get mike to make it.
    unided_name = "burning mindstar",
    level_range = {25, 50}, --Two nums
    color = colors.RED, --Not sure what its for, but it must be the color of something.
    desc = [[This mindstar burns with the fiery passion... to burn others. It especially loves burning mages.]],
    cost = 250, --Not sure. I doubt it's sale price. Somethhing to do with egos.
    require = {stat = {wil = 30, cun = 20},}, --Stats required.
    material_level = 4,
    combat = {
        dam = 20,
        apr = 32,
        physcrit = 5,
        dammod = {wil=0.5, cun=0.3},
        damtype = DamageType.MIC_MINDBURN,
    },
    wielder = { --Stats given. Used for much of the item.
        combat_mindpower = 15,
        combat_spellresist = 15,
        inc_stats = { [Stats.STAT_WIL] = 4,},
        inc_damage = {
            [DamageType.FIRE] = 25,
        },
        resists = {
            [DamageType.ARCANE] = 15,
            [DamageType.FIRE] = 15,
        },
        talents_types_mastery = {
            ["cursed/cleansing"] = 0.2,
            ["wild-gift/antimagic"] = 0.2,
            ["wild-gift/fire-drake"] = 0.2,
        },
        --Might add in mindburn (the talent). Already pretty strong for a T4.
        --Also forms a set, based off purifying.
        ms_set_harmonious = true, ms_set_resonating = true,
        set_list = {
    		multiple = true,
    		harmonious = {{"ms_set_nature", true, inven_id = other_hand,},},
    		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},
    	},
    	set_desc = {
    		purifying = "This purifying mindstar will cleanse other mindstars.",
    	},
    	on_set_complete = {
    		multiple = true,
    		harmonious = function(self, who, inven_id, set_objects)
    			for _, d in ipairs(set_objects) do
    				if d.object ~= self then
    					return d.object.on_set_complete.harmonious(self, who, inven_id, set_objects)
    				end
    			end
    		end,
    		resonating = function(self, who, inven_id, set_objects)
    			for _, d in ipairs(set_objects) do
    				if d.object ~= self then
    					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
    				end
    			end
    		end,
    	},
    	on_set_broken = {
    		multiple = true,
    		harmonious = set_broken,
    		resonating = set_broken,},
    }
}

newEntity { --T1 Light Armor with mind retaliation and bonuses for mind users.
    base = "BASE_LIGHT_ARMOR", --Syntax: BASE_ITEM
    define_as = "MIC_ANGRY_ARMOR",
    power_source = {psionic = true}, --arcane, psionic, nature, technique, etc.
    rarity = 100, --Any number. Higher = more rare
    unique = true, --Can only drop once, I presume.
    name = "Embodiment of Mar\'ruk\'s Hate", image = "object/artifact/iron_mail_of_bloodletting.png",
    unided_name = "hateful armor",
    level_range = {1, 10}, --Two nums
    color = colors.BLACK, --Not sure what its for, but it must be the color of something.
    desc = [[On the edge of death, Mar'Ruk decided to store all of his hate and power into an object. Unfortunately, the closest object on hand was a piece of armor and not a very strong one at that. Occasionally the armor will lash out at its attackers, but usually it just radiates hate.]],
    cost = 200, --Not sure. I doubt it's sale price.
    require = {stat = {str = 12, wil = 12,},}, --Stats required.
    material_level = 1,
    --Use combat = {} for weapons and such. Base stats of the weapon.
    wielder = { --Stats given. Used for much of the item.
        combat_def = 3,
        combat_armor = 1,
        combat_mentalresist = 5,
        resists = {
            [DamageType.MIND] = 10,
        },
        on_melee_hit = {
            [DamageType.MIND]  = 10,
        }
    },
    talent_on_mind = { {chance = 20, talent = Talents.T_MIC_KILL, level = 1}},
}

newEntity { --T3 Mind mindstar.
    base = "BASE_MINDSTAR",
    define_as = "MIC_SHINY_MINDSTAR",
    power_source = {psionic = true}, --arcane, psionic, nature, technique, etc.
    rarity = 150,
    unique = true,
    name = "Mind Focus", image = "object/artifact/psionic_fury.png",
    unided_name = "refulgent mindstar",
    level_range = {15, 30},
    color = colors.YELLOW,
    desc = [[Shining brightly, this mindstar almost seems to reflect your innermost thoughts. You feel more focused while holding it.]],
    cost = 200,
    require = {stat = {wil = 24, cun = 24,},},
    material_level = 3,
    combat = {
        dam = 14,
        apr = 18,
        physcrit = 5,
        dammod = {wil = 0.3, cun = 0.3},
        damtype = DamageType.MIND,
    },
    wielder = { --Stats given. Used for much of the item.
        combat_mindpower = 10,
        combat_mindcrit = 10,
        combat_mentalresist = 10,
        resists = {
            [DamageType.MIND] = 20,
        },
        inc_damage = {
            [DamageType.MIND] = 20,
        },
        talents_types_mastery = {
            ["psionic/psychic-assault"] = 0.2,
        },
        confusion_immune = 0.3,

    },

}

newEntity {
    base = "BASE_MINDSTAR",
    define_as = "MIC_STAR_OF_DARKNESS",
    power_source = {unknown = true}, --arcane, psionic, nature, technique, etc.
    rarity = 100,
    unique = true,
    name = "Star of Darkness", image = "object/artifact/orb_destruction.png", --Isn't one yet.
    unided_name = "jet-black mindstar",
    level_range = {1,10},
    color = colors.BLACK,
    desc = [[This mindstar writhes uncomfortably in your hand, trying to escape. Its jet-black appearance and semi-solid feel put you on edge.]],
    cost = 200,
    require = {stat = {wil = 12, cun = 12,},},
    material_level = 2,
    combat = {
        dam = 8,
        apr = 16,
        physcrit = 5,
        dammod = {wil = 0.35, cun = 0.35},
        damtype = DamageType.DARKNESS,
    },
    wielder = {
        combat_mentalresist = -5,
        inc_damage = {
            [DamageType.DARKNESS] = 15,
        },
        resists = {
            [DamageType.MIND] = -10,
        },
        talents_types_mastery = {
            ["psionic/pain"] = 0.2,
        },
    }
}
