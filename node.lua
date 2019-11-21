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


-- Used for localization

local S = minetest.get_translator('mobs_humans')


--
-- Local variables
--

local i_MIN_BONES_TIME = 60 -- One minute.
local i_MAX_BONES_TIME = 300 -- Five minutes.


--
-- Custom bones node
--

minetest.register_node('mobs_humans:human_bones', {
	description = S('Human Bones'),
	drawtype = 'mesh',
	mesh = 'mobs_humans_bones_model.obj',
	tiles = {'mobs_humans_bones.png'},
	inventory_image = 'mobs_humans_bones_inv.png',
	wield_image = 'mobs_humans_bones_inv.png',
	selection_box =  {
		type = 'fixed',
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}
			},
	},
	walkable = false,
	pointable = true,
	diggable = true,
	buildable_to = true,
	paramtype = 'light',
	paramtype2 = 'facedir',
	groups = {dig_immediate = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults(),

	on_construct = function(pos)
		mobs_humans.BonesTimer(pos, i_MIN_BONES_TIME, i_MAX_BONES_TIME)
		minetest.check_single_for_falling(pos)
	end,

	on_timer = function(pos, elapsed)
		minetest.get_node_timer(pos):stop()
		minetest.swap_node(pos, {name = 'air'})
	end
})


--
-- Bonemeal support
--

if (minetest.get_modpath("bonemeal") ~= nil) then
	minetest.register_craft({
		output = 'bonemeal:bone 8',
		type = 'shapeless',
		recipe = {'mobs_humans:human_bones'}
	})
end
