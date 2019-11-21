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
-- Entity definition
--

mobs:register_mob('mobs_humans:human_npc', {
	nametag = 'Human',
	type = 'npc',
	hp_min = 15,
	hp_max = 20,
	armor = 100,
	walk_velocity = 2,
	run_velocity = 4,
	stand_chance = 50,
	walk_chance = 50,
	jump = true,
	jump_height= 1.1,
	stepheight = 1.1,
	pushable = true,
	view_range = 14,
	damage = 1,
	knock_back = true,
	fear_height = 5,
	fall_damage = true,
	lava_damage = 9999,
	suffocation = true,
	floats = false,
	reach = 4,
	attack_chanche = 12,
	attack_monsters = true,
	attack_animals = false,
	attack_npcs = false,
	attack_players = true,
	group_attack = false,
	attack_type = 'dogfight',
	runaway_from = {
		'mobs_banshee:banshee',
		'mobs_ghost_redo:ghost',
		'mobs_others:snow_walker'
	},
	pathfinding = 1,
	makes_footstep_sound = true,
	sounds = {
		attack = 'default_punch',
		shoot_attack = 'mobs_swing'
	},
	drops = {
	},
	visual = 'mesh',
	visual_size = {x = 1, y = 1},
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.75, 0.3},
	selectionbox = {-0.3, -1.0, -0.3, 0.3, 0.75, 0.3},
	textures = mobs_humans.t_Skins,
	mesh = 'mobs_humans_character.b3d',
	animation = {
		stand_start = 0,
		stand_end = 79,
		stand_speed = 30,
		walk_start = 168,
		walk_end = 187,
		walk_speed = 15,
		run_start = 168,
		run_end = 187,
		run_speed = 30,
		punch_start = 189,
		punch_end = 198,
		punch_speed = 30,
		die_start = 162,
		die_end = 166,
		die_speed = 0.8
	},

	on_spawn = function(self, pos)
		if (mobs_humans.b_Dynamic == true) then
			if (self.nametag == 'Human')
			or (self.class == nil) -- For backward compatibility.
			then
				mobs_humans.OnSpawnDynamic(self)

			end

		else
			if (self.nametag == 'Human')
			or (self.class == nil) -- For backward compatibility.
			then
				mobs_humans.OnSpawnNormal(self)

			end

		end

		mobs_humans.Nametag(self) -- Set the nametag accordingly to settings.
	end,

	do_punch = function(self, hitter, time_from_last_punch, tool_capabilities,
		direction)

		if (mobs_humans.b_Dynamic == true) then
			mobs_humans.HitFlag(self) -- Used for experience gain.
		end

		if (mobs_humans.b_Debug == true) then -- Debug mode nametag.
			mobs_humans.NametagDebug(self, hitter, time_from_last_punch,
				tool_capabilities, direction)
		end
	end,

	do_custom = function(self, dtime)
		if (mobs_humans.b_Dynamic == true) then

			-- Heal if possible.
			mobs_humans.Heal(self, dtime, mobs_humans.t_ALLOWED_STATES,
				mobs_humans.t_HIT_POINTS, mobs_humans.t_HEAL_DELAY,
				self.initial_hp)

			-- Gain experience if possible.
			mobs_humans.Experience(self, dtime)

			-- Draw the sword if needed.
			if (self.state == 'attack') then
				if (self.textures[3] == 'mobs_humans_transparent.png') then
					mobs_humans.UpdateWeaponTexture(self, self.damage)
				end
			end
		end
	end,

	on_rightclick = function(self, clicker)
		mobs_humans.Speak(self, clicker)
	end,

	on_die = function(self, pos)
		mobs_humans.DropBones(pos)
	end
})


--
-- Entity spawner
--

mobs:spawn({
	name = 'mobs_humans:human_npc',
	nodes = {'group:crumbly'},
	neighbors = {'air'},
	max_light = 15,
	min_light = 0,
	interval = 60,
	chance = 7500,
	active_object_count = 2,
	min_height = 1,
	max_height = 240,
	day_toggle = nil
})


-- Spawn Egg

mobs:register_egg('mobs_humans:human_npc', S('Spawn Human NPC'),
	'mobs_humans_icon.png')


-- Alias

mobs:alias_mob('mobs:human_npc', 'mobs_humans:human_npc')
