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

local psionic = getBirthDescriptor('class', 'Psionic').descriptor_choices.subclass
psionic.Anguished = 'allow'

newBirthDescriptor {
     type = 'subclass',
     name = 'Anguished',
     desc = {
             "Battered, broken and totured, Anguished are those who have experienced extensive pain. As a result of this affliction, they understand pain better than anyone else, and as a result, know how to inflict it best.",
             "They seek to inflict pain upon their enemies in a multitude of ways.",
             "Darkness stems from them, swallowing all who oppose them.",
             "Intense hatred for mages leads to \"cleansing\" of them, with intense flames.",
             'Their most important stats are Willpower and Cunning.',
             '#GOLD#Stat modifiers:',
             '#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution',
             '#LIGHT_BLUE# * +4 Magic, +5 Willpower, +2 Cunning',
             '#GOLD#Life per level:#LIGHT_BLUE# +1',},
             power_source = {psionic=true, arcane=true}, --Power Source
             stats = {mag = 4, wil = 5, cun = 2}, --stat mod
             talents_types = {
                 --class
                 --4 unlocked, 2 locked. An okay balance. Always perfered 5 unlocked.
                 ["psionic/pain"]={true, 0.3}, --Low range darkness/blight damage
                 ["corruption/balance"]={true, 0.3}, --Thematic tree. Psi/Vim benefits
                 ["corruption/doom"] = {true, 0.3}, --Blight debuff tree.
                 ["psionic/consumption"] = {true, 0.3}, --Vim/Psi regen tree
                 ["psionic/cleansing"] = {false, 0.3}, --Antimagic fire damage tree
                 ["corruption/dark-thoughts"]={false, 0.3}, --High level darkness/blight damage tree
                 --generic
                 --2 unlocked, 1 locked. Plus racial makes 3. Pretty good.
                 ["corruption/defiled-mind"]={true, 0.3}, --Redo of cursed mind. More focused on casting.
                 ["psionic/control"]={true, 0.3}, --Possible mobility tree, using some of manipulation's ideas.
                 ["corruption/torment"] = {false, 0.2}, --Locked
                 ['cunning/survival'] = {false, 0.0},
                   },
                   talents = {
                       [ActorTalents.T_MIC_BALANCE] = 1, --class
                       [ActorTalents.T_MIC_KILL] = 1,
                       [ActorTalents.T_MIC_ERODE] = 1,
                       [ActorTalents.T_MIC_DEFILED_MIND] = 1, --generic
                   },
                   copy = {
                       max_life=110,
                       resolvers.equipbirth{
                           id=true,
                           {type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
                           {type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
                           {type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000,},
                       },
                       resolvers.inventorybirth{
                           id = true,
                           {type = "weapon", subtype = "staff", name = "elm staff", autoreq = true, ego_chance = -1000},
                       },
                   },
                   copy_add = {
                   life_rating = 1,},}
