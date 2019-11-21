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
-- Functions
--

mobs_humans.Boolean = function()
	local i_RandomNumber = PseudoRandom(os.time())
	local b_TrueOrFalse = false

	i_RandomNumber = i_RandomNumber:next(0, 1)

	if (i_RandomNumber == 1) then
		b_TrueOrFalse = true
	end

	return b_TrueOrFalse
end


mobs_humans.BonesTimer = function(pos, a_i_min_seconds, a_i_max_seconds)
	local i_RandomNumber = PseudoRandom(os.time())
	i_RandomNumber = i_RandomNumber:next(a_i_min_seconds, a_i_max_seconds)

	minetest.get_node_timer(pos):start(i_RandomNumber)
end


mobs_humans.DropBones = function(a_t_position)
	local i_RandomNumber = PseudoRandom(os.time())
	i_RandomNumber = i_RandomNumber:next(1, 12)

	if (i_RandomNumber <= 6) then
		local s_NodeName = minetest.get_node(a_t_position).name
		local t_Position = {
			x = a_t_position.x,
			y = (a_t_position.y - 1),
			z = a_t_position.z
		}

		if (s_NodeName == 'air') then
			minetest.set_node(t_Position, {
				name = 'mobs_humans:human_bones'
			})

		end
	end
end


mobs_humans.RandomNumber = function(a_i_min, a_i_max)
	local i_RandomNumber = PseudoRandom(os.time())
	i_RandomNumber = i_RandomNumber:next(a_i_min, a_i_max)

	return i_RandomNumber
end


mobs_humans.Speak = function(self, clicker)
	if (self.health > 0)
	and (self.state ~= 'attack')
	and (self.state ~= 'runaway')
	then
		local s_MESSAGE1 = S('Saluton ')
		local s_MESSAGE2 = S(', mia nomo estas ')
		local s_PlayerName = clicker:get_player_name()
		local s_Message = s_MESSAGE1 .. s_PlayerName .. s_MESSAGE2
			.. self.given_name .. '.\n'

		minetest.chat_send_player(s_PlayerName, s_Message)
	end
end

if (mobs_humans.b_Dynamic == true) then

	mobs_humans.HitFlag = function(self)
		if (self.b_Hit ~= true) then
			self.b_Hit = true
		end

		if (self.f_CooldownTimer ~= 10) then
			self.f_CooldownTimer = 10
			-- Seconds before gaining experience.
			-- Prevents mobs from gaining experience when hit by projectiles.
		end
	end

	mobs_humans.SurvivedFlag = function(self)
		if (self.i_SurvivedFights == nil) then
			self.i_SurvivedFights = 0
		end
	end

	mobs_humans.HurtFlag = function(self)
		if (self.b_Hurt == nil) then
			if (self.health == self.max_hp) then
				self.b_Hurt = false

			else
				self.b_Hurt = true
			end
		end
	end

	mobs_humans.Experience = function(self, dtime)

		-- Allows experience gain for mobs that have been directly hit.
		if (self.b_Hit == true) and (self.attack == nil) then
			if (self.f_CooldownTimer > 0) then
				self.f_CooldownTimer = (self.f_CooldownTimer - dtime)

			else
				self.b_Hit = false
				self.f_CooldownTimer = 10

				self.i_SurvivedFights = (self.i_SurvivedFights + 1)

				-- Sheath the sword.
				mobs_humans.SwordSheath(self)

				if (self.i_SurvivedFights % mobs_humans.i_FIGHTS_DAMAGE == 0) then
					if (self.damage < (8 * mobs_humans.i_MobDifficulty)) then
						self.damage = (self.damage + 1)
					end
				end

				if (self.i_SurvivedFights % mobs_humans.i_FIGHTS_ARMOR == 0) then
					if (self.armor > 10) then
						self.armor = (self.armor - 1)
					end
				end

				if (mobs_humans.b_ShowNametags == true)
				and (mobs_humans.b_ShowStats == true)
				then
					self.nametag = minetest.colorize("white", self.given_name
					.. " (" .. self.class .. ")" .. "\n"
					.. S("Armor: ") .. self.armor .. "\n"
					.. S("Damage: ") .. self.damage .. "\n"
					.. S("Fights: ") .. self.i_SurvivedFights)

					self.object:set_properties({ nametag = self.nametag })
				end
			end
		end
	end

	mobs_humans.Heal = function(self, dtime, a_t_states, a_i_hp, a_f_delay, a_i_max_hp)
		if (self.b_Hurt ~= nil) then
			if (self.f_HealTimer == nil) then
				self.f_HealTimer = a_f_delay
			end

			if (self.health == a_i_max_hp) then
				self.b_Hurt = false
			else
				self.b_Hurt = true
			end

			if (self.b_Hurt == true) then
				local b_CanHeal = false

				for i = 1, #a_t_states do
					if (self.state == a_t_states[i]) then
						b_CanHeal = true
					end
				end

				if (b_CanHeal == true) then
					if (self.health < a_i_max_hp) then
						if (self.f_HealTimer > 0) then
							self.f_HealTimer = (self.f_HealTimer - dtime)

						else
							self.f_HealTimer = a_f_delay
							self.health = (self.health + a_i_hp)

							if (self.health > a_i_max_hp) then
								local i_Excess = (self.health - a_i_max_hp)
								self.health = (self.health - i_Excess)
							end

							self.object:set_hp(self.health)
							--[[
							print(self.given_name .. " healing: " ..
								self.health .. "/" .. a_i_max_hp)
							--]]
						end
					end
				end
			end
		end
	end
end

mobs_humans.random_string = function(length)

	local letter = 0
	local number = 0
	local initial_letter = true
	local string = ""
	local exchanger = ""
	local forced_choice = ""
	local vowels = {"a", "e", "i", "o", "u"}
	local semivowels = {"y", "w"}

	local simple_consonants = {
		"m", "n", "b", "p", "d", "t", "g", "k", "l", "r", "s", "z", "h"
	}

	local compound_consonants = {
		"ñ", "v", "f", "ð", "þ", "ɣ", "ħ", "ɫ", "ʃ", "ʒ"
	}

	local compound_consonants_uppercase = {
		"Ñ", "V", "F", "Ð", "Þ", "Ɣ", "Ħ", "Ɫ", "Ʃ", "Ʒ"
	}

	local double_consonants = {
		"mm", "mb", "mp", "mr", "ms", "mz", "mf",
		"mʃ",
		"nn", "nd", "nt", "ng", "nk", "nr", "ns", "nz",
		"nð", "nþ", "nɣ", "nħ", "nʃ", "nʒ",
		"bb", "bl", "br", "bz",
		"bʒ",
		"pp", "pl", "pr", "ps",
		"pʃ",
		"dd", "dl", "dr", "dz",
		"dʒ",
		"tt", "tl", "tr", "ts",
		"tʃ",
		"gg", "gl", "gr", "gz",
		"gʒ",
		"kk", "kl", "kr", "ks",
		"kʃ",
		"ll", "lm", "ln", "lb", "lp", "ld", "lt", "lg", "lk", "ls", "lz",
		"lñ", "lv", "lf", "lð", "lþ", "lɣ", "lħ", "lʃ", "lʒ",
		"rr", "rm", "rn", "rb", "rp", "rd", "rt", "rg", "rk", "rs", "rz",
		"rñ", "rv", "rf", "rð", "rþ", "rɣ", "rħ", "rʃ", "rʒ",
		"ss", "sp", "st", "sk",
		"sf",
		"zz", "zm", "zn", "zb", "zd", "zg", "zl", "zr",
		"zñ", "zv",
		"vl", "vr",
		"fl", "fr",
		"ðl", "ðr",
		"þl", "þr",
		"ɣl", "ɣr",
		"ħl", "ħr",
		"ʃp", "ʃt", "ʃk",
		"ʃf",
		"ʒm", "ʒn", "ʒb", "ʒd", "ʒg", "ʒl", "ʒr",
		"ʒv"
	}

	local double_consonants_uppercase = {
		"Bl", "Br", "Bz",
		"Bʒ",
		"Pl", "Pr", "Ps",
		"Pʃ",
		"Dl", "Dr", "Dz",
		"Dʒ",
		"Tl", "Tr", "Ts",
		"Tʃ",
		"Gl", "Gr", "Gz",
		"Gʒ",
		"Kl", "Kr", "Ks",
		"Kʃ",
		"Sp", "St", "Sk",
		"Sf",
		"Zm", "Zn", "Zb", "Zd", "Zg", "Zl", "Zr",
		"Zñ", "Zv",
		"Vl", "Vr",
		"Fl", "Fr",
		"Ðl", "Ðr",
		"Þl", "Þr",
		"Ɣl", "Ɣr",
		"Ħl", "Ħr",
		"Ʃp", "Ʃt", "Ʃk",
		"Ʃf",
		"Ʒm", "Ʒn", "Ʒb", "Ʒd", "Ʒg", "Ʒl", "Ʒr",
		"Ʒv"
	}

	local previous_letter = ""

	for initial_value = 1, length do

		letter = letter + 1

		local chosen_group = math.random(1, 5)

		if (exchanger == "vowel") then
			chosen_group = math.random(3, 5)

		elseif (exchanger == "semivowel") then
			chosen_group = 1

		elseif (exchanger == "simple consonant") then
			if (letter < length) then
				chosen_group = math.random(1, 2)
			else
				chosen_group = 1
			end

		elseif (exchanger == "compound consonant") then
			chosen_group = 1

		elseif (exchanger == "double consonant") then
			chosen_group = 1

		end


		if (chosen_group == 1) then

			if (initial_letter == true) then
				initial_letter = false
				number = math.random(1, 5)
				previous_letter = string.upper(vowels[number])
				string = string .. previous_letter

			else
				number = math.random(0, 1) -- single or double vowel

				if (number == 0) then
					number = math.random(1, 5)
					previous_letter = vowels[number]
					string = string .. previous_letter

				else
					number = math.random(1, 5)
					previous_letter = vowels[number]
					string = string .. previous_letter

					number = math.random(1, 5)
					previous_letter = vowels[number]
					string = string .. previous_letter

				end
			end

			exchanger = "vowel"


		elseif (chosen_group == 2) then

			number = math.random(1, 2)

			if (letter ~= 2) then
				if (initial_letter == true) then
					initial_letter = false
					previous_letter = string.upper(semivowels[number])
					string = string .. previous_letter
				else
					previous_letter = semivowels[number]
					string = string .. previous_letter

				end

				exchanger = "semivowel"

			elseif (letter == 2) then
				if (previous_letter == "L") or (previous_letter == "R")
				or (previous_letter == "Ɫ") or (previous_letter == "Y")
				or (previous_letter == "W") or (previous_letter == "H") then
					if (number == 1) then
						previous_letter = "i"
						string = string .. previous_letter

					elseif (number == 2) then
						previous_letter = "u"
						string = string .. previous_letter

					end
				end

				exchanger = "vowel"
			end


		elseif (chosen_group == 3) then

			number = math.random(1, 13)

			if (initial_letter == true) then
				initial_letter = false
				previous_letter = string.upper(simple_consonants[number])
				string = string .. previous_letter

			else
				previous_letter = simple_consonants[number]
				string = string .. previous_letter

			end

			exchanger = "simple consonant"


		elseif (chosen_group == 4) then

			number = math.random(1, 10)

			if (initial_letter == true) then
				initial_letter = false
				previous_letter = compound_consonants_uppercase[number]
				string = string .. previous_letter

			else
				previous_letter = compound_consonants[number]
				string = string .. previous_letter
			end

			exchanger = "compound consonant"


		elseif (chosen_group == 5) then

			if (initial_letter == true) then
				initial_letter = false
				number = math.random(1, 61)
				previous_letter = double_consonants_uppercase[number]
				string = string .. previous_letter

			else
				number = math.random(1, 131)
				previous_letter = double_consonants[number]
				string = string .. previous_letter
			end

			exchanger = "double consonant"

		end
	end

	initial_letter = true

	return string
end

mobs_humans.OnSpawnNormal = function(self)
	self.class = self.type

	self.given_name = mobs_humans.random_string(math.random(2, 5))

	self.nametag = minetest.colorize("white", self.given_name ..
		" (" .. self.class .. ")")

	local t_Appearence = {'', '', '', ''}

	t_Appearence[1] = self.textures[1] -- Skin
	t_Appearence[2] = 'mobs_humans_transparent.png' -- Armor
	t_Appearence[3] = 'mobs_humans_transparent.png' -- Weapon
	t_Appearence[4] = 'mobs_humans_transparent.png' -- Shield

	self.textures = t_Appearence
	self.base_texture = self.textures

	self.object:set_properties({
		given_name = self.given_name,
		nametag = self.nametag,
		textures = self.textures,
		base_texture = self.base_texture
	})
end

if (mobs_humans.b_Dynamic == true) then

	mobs_humans.RandomSword = function(a_b_RealisticChance)
		local i_RandomNumber = nil
		local t_ChosenSword = {}

		local t_DefaultSwords = {
			{
				s_ItemString = 'default:sword_wood',
				i_Damage = 2,
				s_Texture = 'default_tool_woodsword.png'
			},

			{
				s_ItemString = 'default:sword_stone',
				i_Damage = 4,
				s_Texture = 'default_tool_stonesword.png'
			},

			{
				s_ItemString = 'default:sword_bronze',
				i_Damage = 6,
				s_Texture = 'default_tool_bronzesword.png'
			},

			{
				s_ItemString = 'default:sword_steel',
				i_Damage = 6,
				s_Texture = 'default_tool_steelsword.png'
			},

			{
				s_ItemString = 'default:sword_mese',
				i_Damage = 7,
				s_Texture = 'default_tool_mesesword.png'
			},

			{
				s_ItemString = 'default:sword_diamond',
				i_Damage = 8,
				s_Texture = 'default_tool_diamondsword.png'
			}
		}



		if (a_b_RealisticChance ~= true) then
			t_ChosenSword = t_DefaultSwords[math.random(1, 6)]

		else
			--[[
				These percentages have been collected using Ores Stats
				Mapgen = flat
				Map seed = 0123456789
				Letting the character in autowalk from surface to -31000.

				The ore's percentages sum is 50.476%
				Stone and wood percentages have been arbitrarily set:
				(100% - 50.476%) = 49.524% -- To be assigned.
				(49.524% / 6) = 8.254% -- Allows the following:

				Stone's percentage = Twice the wood's percentage
				Stone is everywhere, wood might be harder to find.

				Stone = (8.254% * 4) = 33.016%
				Wood = (8.254% * 2) = 16.508%

				(33.016% + 16.508%) = 49.524% -- Assigned.

				Ores + (Wood + Stone) = 50.476% + 49.524% = 100% Assigned.
			--]]

			-- These values have been rounded to integers due the fact
			-- that the pseudorandom number generator only produces integers.

			local i_DIAMOND_ORE_PERCENTAGE = 2
			-- Actually 1.545

			local i_MESE_ORE_PERCENTAGE = 3
			-- Actually 2.818

			local i_COPPER_ORE_PERCENTAGE = 14
			-- Actually 13.796, used for 'bronze'.

			local i_WOOD_PERCENTAGE = 17
			-- Actually 16.508

			local i_IRON_ORE_PERCENTAGE = 32
			-- Actually 32.317, used for 'steel'.

			local i_STONE_PERCENTAGE = 33
			-- Actually 33.016

			i_RandomNumber = PseudoRandom(os.time())
			i_RandomNumber = i_RandomNumber:next(1, 100)

			if (i_RandomNumber <= i_DIAMOND_ORE_PERCENTAGE) then
				t_ChosenSword = t_DefaultSwords[6] -- Diamond sword.

			elseif (i_RandomNumber > i_DIAMOND_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_MESE_ORE_PERCENTAGE)
			then
				t_ChosenSword = t_DefaultSwords[5] -- Mese sword.

			elseif (i_RandomNumber > i_MESE_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_COPPER_ORE_PERCENTAGE)
			then
				t_ChosenSword = t_DefaultSwords[3] -- Copper sword.

			elseif (i_RandomNumber > i_COPPER_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_WOOD_PERCENTAGE)
			then
				t_ChosenSword = t_DefaultSwords[1] -- Wooden sword.

			elseif (i_RandomNumber > i_WOOD_PERCENTAGE)
			and (i_RandomNumber <= i_IRON_ORE_PERCENTAGE)
			then
				t_ChosenSword = t_DefaultSwords[4] -- Steel sword.

			else
				t_ChosenSword = t_DefaultSwords[2] -- Stone sword.

			end
		end

		return t_ChosenSword
	end

	mobs_humans.UpdateWeaponTexture = function(self, a_i_damage)
		local s_WeaponTexture = 'mobs_humans_transparent.png'

		if (a_i_damage > 1) and (a_i_damage < 4) then
			s_WeaponTexture = 'default_tool_woodsword.png'

		elseif (a_i_damage >= 4) and (a_i_damage < 6)  then
			s_WeaponTexture = 'default_tool_stonesword.png'

		elseif (a_i_damage >= 6) and (a_i_damage < 7) then
			s_WeaponTexture = 'default_tool_bronzesword.png'

			local i_RandomNumber = PseudoRandom(os.time())
			i_RandomNumber = i_RandomNumber:next(0, 1)

			if (i_RandomNumber == 1) then
				s_WeaponTexture = 'default_tool_steelsword.png'
			end

		elseif (a_i_damage == 7) then
			s_WeaponTexture = 'default_tool_mesesword.png'

		elseif (a_i_damage == 8) then
			s_WeaponTexture = 'default_tool_diamondsword.png'
		end

		self.weapon_texture = s_WeaponTexture
		self.textures[3] = s_WeaponTexture
		self.base_texture = self.textures

		self.object:set_properties({
			textures = self.textures,
			base_texture = self.base_texture
		})
	end

	mobs_humans.SwordSheath = function(self)
		if (self.textures[3] ~= 'mobs_humans_transparent.png') then
			self.textures[3] = 'mobs_humans_transparent.png'
			self.base_texture = self.textures

			self.object:set_properties({
				textures = self.textures,
				base_texture = self.base_texture
			})
		end
	end

	mobs_humans.OnSpawnDynamic = function(self)
		-- Set the initial 'b_Hurt' flag.
		mobs_humans.HurtFlag(self)

		-- Set the initial 'i_SurvivedFights' flag,
		-- that is the experience modifier.
		mobs_humans.SurvivedFlag(self)

		self.class = self.type

		self.given_name = mobs_humans.random_string(math.random(2, 5))

		self.nametag = minetest.colorize("white", self.given_name ..
			" (" .. self.class .. ")")

		self.initial_hp = math.random(self.hp_min, self.hp_max)

		self.object:set_hp(self.initial_hp)

		self.weapon = mobs_humans.RandomSword(true)

		self.damage = self.weapon.i_Damage

		local t_Appearence = {'', '', '', ''}

		t_Appearence[1] = self.textures[1] -- Skin
		t_Appearence[2] = 'mobs_humans_transparent.png' -- Armor
		t_Appearence[3] = 'mobs_humans_transparent.png' -- Weapon
		t_Appearence[4] = 'mobs_humans_transparent.png' -- Shield

		self.textures = t_Appearence
		self.base_texture = self.textures

		self.object:set_properties({
			given_name = self.given_name,
			nametag = self.nametag,
			textures = self.textures,
			base_texture = self.base_texture
		})
	end
end

mobs_humans.Nametag = function(self)
	if (mobs_humans.b_ShowNametags == false) then
		self.nametag = ""
		self.object:set_properties({ nametag = self.nametag })

	else
		if (mobs_humans.b_ShowStats == false) then
			self.nametag = minetest.colorize("white", self.given_name
			.. " (" .. self.class .. ")")

			self.object:set_properties({ nametag = self.nametag })

		else
			if (mobs_humans.b_Dynamic == true) then
				self.nametag = minetest.colorize("white", self.given_name
				.. " (" .. self.class .. ")" .. "\n"
				.. S("Armor: ") .. self.armor .. "\n"
				.. S("Damage: ") .. self.damage .. "\n"
				.. S("Fights: ") .. self.i_SurvivedFights)

				self.object:set_properties({ nametag = self.nametag })

			else
				self.nametag = minetest.colorize("white", self.given_name
				.. " (" .. self.class .. ")" .. "\n"
				.. S("Armor: ") .. self.armor .. "\n"
				.. S("Damage: ") .. self.damage)

				self.object:set_properties({ nametag = self.nametag })
			end
		end
	end
end

mobs_humans.NametagDebug = function(self, hitter, time_from_last_punch,
	tool_capabilities, direction)

	local s_MobName = self.given_name
	local i_MobArmor = self.armor
	local s_PlayerName = hitter:get_player_name()
	local i_PlayerDamage = tool_capabilities.damage_groups.fleshy

	local s_Message = s_MobName .. " hit by " .. s_PlayerName
		.. "\n" .. "Weapon damage: "
		.. minetest.colorize("red", i_PlayerDamage)

	minetest.chat_send_player(s_PlayerName, s_Message)
end
