--[[
	Mobs Humans - Adds human mobs.
	Copyright © 2018, 2019 Hamlet <hamlatmesehub@riseup.net> and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the 'Licence');
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	'AS IS' basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


--
-- Global mod's namespace
--

mobs_humans = {}


--
-- Global general variables
--

mobs_humans.i_MobDifficulty = minetest.settings:get('mob_difficulty')
if (mobs_humans.i_MobDifficulty == nil) then
	mobs_humans.i_MobDifficulty = 1
end

mobs_humans.b_Dynamic = minetest.settings:get_bool('mobs_humans_dynamic')
if (mobs_humans.b_Dynamic == nil) then
	mobs_humans.b_Dynamic = false
end

mobs_humans.b_ShowNametags = minetest.settings:get_bool('mobs_humans_use_nametags')
if (mobs_humans.b_ShowNametags == nil) then
	mobs_humans.b_ShowNametags = false
end

mobs_humans.b_ShowStats = minetest.settings:get_bool('mobs_humans_show_stats')
if (mobs_humans.b_ShowStats == nil) then
	mobs_humans.b_ShowStats = false
end

mobs_humans.b_Debug = minetest.settings:get_bool('mobs_humans_debug')
if (mobs_humans.b_Debug == nil) then
	mobs_humans.b_Debug = false
end

if (mobs_humans.b_Dynamic == true) then

	-- When the mob can heal.
	mobs_humans.t_ALLOWED_STATES = {'stand', 'walk'}

	mobs_humans.t_HEAL_DELAY = 4 -- Seconds that must pass before healing.
	mobs_humans.t_HIT_POINTS = 1 -- Hit points per healing step.

	-- How many fights the mob has to survive to increment its stats.
	mobs_humans.i_FIGHTS_ARMOR = minetest.settings:get('mobs_humans_fights_armor')
	mobs_humans.i_FIGHTS_DAMAGE = minetest.settings:get('mobs_humans_fights_damage')

	if (mobs_humans.i_FIGHTS_ARMOR == nil) then
		mobs_humans.i_FIGHTS_ARMOR = 5
	end

	if (mobs_humans.i_FIGHTS_DAMAGE == nil) then
		mobs_humans.i_FIGHTS_DAMAGE = 10
	end
end

-- Local variable

local s_ModPath = minetest.get_modpath('mobs_humans')

-- Available skins (../minetest/mods/mobs_humans/textures/)
mobs_humans.t_Skins = {
	{'mobs_humans_female_01.png'},
	{'mobs_humans_female_02.png'},
	{'mobs_humans_male_01.png'},
	{'mobs_humans_male_02.png'}
}


--
-- Load
--

dofile(s_ModPath .. '/functions.lua')
dofile(s_ModPath .. '/node.lua')
dofile(s_ModPath .. '/npc.lua')
dofile(s_ModPath .. '/projectile.lua')


--
-- Minetest engine debug logging
--

local s_LogLevel = minetest.settings:get('debug_log_level')

if (s_LogLevel == nil)
or (s_LogLevel == 'action')
or (s_LogLevel == 'info')
or (s_LogLevel == 'verbose')
then
	s_LogLevel = nil
	minetest.log('action', '[Mod] Mobs Humans [v0.3.1] loaded.')
end
