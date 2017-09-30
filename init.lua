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

long_name = "Anguished"
short_name = "anguish"
for_module = "tome"
version = {1,4,8}
weight = 51
author = {"Micbran", ""}
homepage = ""
description = [[Adds the Anguished class, part of the Psionic subclass. A caster Vim/Psi mix, The Anguished spend their time balancing their vim/psi and their spellpower/mindpower, mixing in spellcasts with mind powers.
The Anguished have 6 unique talent trees:
    On the mindpower side we have...
    Pain: The main darkness/blight damage attack/debuff tree. Painfully good!
    Consumption: Vim and Psi regeneration/management tree. Consume all!
    Control (Generic): Defense/utility tree. Control the area around you!
    Cleansing: High level anti-magic fire damage tree. Burn those filthy magic users!

    On the spell side we have...
    Dark Thoughts: High level attack/debuff tree. Use your insanity against your enemies!
    Balance: Tree all about the balance between Vim and Psi. Balance in all things!
    Doom: Debuffs and DoT talents. DOOOOOOOOOOOOM!
    Defiled Mind (Generic): Caster benefits, loosely based off cursed body. Kill them with your dirty* mind!

    Anguished can do well with double mindstars, short staff + mindstar or simply staff.

    Also adds a new race, the Soulless. An Elf sublcass, the Soulless specialize in offense as their life rating of 8 causes them to be a little bit weaker.

    Adds a few mind based artifacts, mostly tied to the theme of the Anguished (3 mindstars, one light armor)

    Special thanks to Razakai and StarKeep and a couple of others on the IRC channel for all the help!
    Special thanks to Dienes for helping me out with a few ideas (namely mindstaff).
    Icons for Anguished done by Zerru.

        *Not like that. Don't make me explain the pun.]]
tags = {"defiler", "psionic", "vim", "psi", "mindpower", "spellpower", "caster", "race", "elf"}
overload = true;
superload = true;
hooks = true;
data = true;
addon_version = {1,0,6}

--[[
Frumple's Overcharged idea:
Overcharged: Add extra AoE effects to spells in return for higher costs
Overcharged: Allows resources to go over limit while sustained, find some way to penalize player besides fatigue (doesn't affect vim) and turn off to release bonus resources in some sort of ball explosion.
After x number turns of being sustained, overcharged turns itself off.

astralInferno's feedback:
Choke and Cauterise Lips don't specify what damage type they do. I presume physical and fire respectively... Searing Pain is worse. Not only does it not specify a damage type, it misses the word damage.
"Unleash a ball of red, hot pain in radius %d, dealing %0.1f and attempting to apply confusion"

Something's wrong with the Dusk bringer tooltip. It currently says it does 1.0 darkness damage (+20% per turn), and I just did 58 with it after ~3 turns.

It feels off to me that they have a pure vim attack tree, but no pure psi attack tree.
Their damage types are also v variable. Darkness, mind, blight and fire, plus physical(?) on choke. On the difficulty I play this hardly matters, but they might be hard to gear later.
You did add some artifacts for them, that might help counteract that.
]]--
