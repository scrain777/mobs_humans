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
	local i_RandomNumber = mobs_humans.RandomNumber(0, 1)
	local b_TrueOrFalse = false

	if (i_RandomNumber == 1) then
		b_TrueOrFalse = true
	end

	return b_TrueOrFalse
end


mobs_humans.BonesTimer = function(pos, a_i_min_seconds, a_i_max_seconds)
	local i_RandomNumber = mobs_humans.RandomNumber(a_i_min_seconds, a_i_max_seconds)

	minetest.get_node_timer(pos):start(i_RandomNumber)
end


mobs_humans.DropBones = function(self, a_t_position)
	if (a_t_position ~= nil) then
		local i_RandomNumber = mobs_humans.RandomNumber(1, 12)

		if (i_RandomNumber <= 6) then
			local t_Position = {
				x = a_t_position.x,
				y = (a_t_position.y - 1),
				z = a_t_position.z
			}

			local s_NodeName = minetest.get_node(t_Position).name

			if (s_NodeName == 'air') then

				minetest.set_node(t_Position, {
					name = 'mobs_humans:human_bones'
				})

				local s_Meta = minetest.get_meta(t_Position)
				local s_MobName = self.given_name
				local s_BonesInfotext = S('Bones of ') .. s_MobName
				s_Meta:set_string('owner', s_BonesInfotext)
				s_Meta:set_string('infotext', s_BonesInfotext)
			end
		end
	end
end


mobs_humans.RandomAttackType = function()
	local s_AttackName = ''
	local i_RandomNumber = mobs_humans.RandomNumber(1, 3)

	if (i_RandomNumber == 1) then
		s_AttackName = 'dogfight'

	elseif (i_RandomNumber == 2) then
		s_AttackName = 'shoot'

	else
		s_AttackName = 'dogshoot'

	end

	return s_AttackName
end


mobs_humans.RandomNumber = function(a_i_min, a_i_max)
	local i_RandomNumber = PseudoRandom(os.time())
	i_RandomNumber = i_RandomNumber:next(a_i_min, a_i_max)

	return i_RandomNumber
end


mobs_humans.Speak = function(self, clicker)
	if (minetest.is_player(clicker) == true) then
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
end


if (mobs_humans.b_DynamicMode == true) then
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
			if (self.health == self.hp_max) then
				self.b_Hurt = false

			else
				self.b_Hurt = true
			end
		end
	end


	mobs_humans.PlayerHitFlag = function(self, hitter)

		if (minetest.is_player(hitter) == true) then
			self.b_HitByPlayer = true
			--print("Hit by player.")
		else
			self.b_HitByPlayer = false
			--print("Hit by something else.")
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

				if (self.i_SurvivedFights % mobs_humans.i_FIGHTS_DAMAGE == 0) then
					if (self.damage < (8 * mobs_humans.i_MobDifficulty)) then
						self.damage = (self.damage + 1)

						mobs_humans.SwordUpdate(self) -- If needed.

						mobs_humans.TextureCreator(self, self.weapon.s_Texture)

						self.b_hold_sword = true -- Due the textures update.
					end
				end

				if (self.i_SurvivedFights % mobs_humans.i_FIGHTS_ARMOR == 0) then
					if (self.armor > 10) then
						self.armor = (self.armor - 1)

						self.object:set_armor_groups({fleshy = self.armor})
					end
				end

				mobs_humans.Nametag(self) -- Update the nametag.
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
							print(self.given_name .. ' healing: ' ..
								self.health .. '/' .. a_i_max_hp)
							--]]
						end
					end
				end
			end
		end
	end


	mobs_humans.DropWeapon = function(self, a_t_position)
		if (self.attack_type ~= 'shoot')
		and (self.b_HitByPlayer == true)
		then
			local s_MobSword = self.weapon.s_ItemString
			local i_NumberMax = 100

			-- Drop chances.
			if (s_MobSword == 'default:sword_diamond') then
				i_NumberMax = 50 -- Chance: 2%

			elseif (s_MobSword == 'default:sword_mese') then
				i_NumberMax = 33 -- Chance: 3%

			elseif (s_MobSword == 'default:sword_steel') then
				i_NumberMax = 3 -- Chance: ~32%

			elseif (s_MobSword == 'default:sword_bronze') then
				i_NumberMax = 7 -- Chance: 14%

			elseif (s_MobSword == 'default:sword_stone') then
				i_NumberMax = 3 -- Chance: 33%

			elseif (s_MobSword == 'default:sword_wood') then
				i_NumberMax = 6 -- Chance: ~17%
			end

			local i_RandomNumber = mobs_humans.RandomNumber(1, i_NumberMax)

			-- If the number is 1, then choose a tool wear level.
			if (i_RandomNumber == 1) then
				local i_UNWORN = 0
				local i_BROKEN = 65535
				local i_RandomNumber = mobs_humans.RandomNumber(1, 100)
				local i_WearLevel = nil

				-- Chance: 2% - Brand new
				if (i_RandomNumber >= 99) then
					i_WearLevel = i_UNWORN

				-- Chance: 3% - Almost new
				elseif (i_RandomNumber < 99)
				and (i_RandomNumber >= 96)
				then
					i_WearLevel = (i_BROKEN / 20) -- 5% worn

				-- Chance: 20% - Not much used
				elseif (i_RandomNumber < 96)
				and (i_RandomNumber >= 76)
				then
					i_WearLevel = (i_BROKEN / 5) -- 20% worn

				-- Chance: 50% - Used
				elseif (i_RandomNumber > 26)
				and (i_RandomNumber < 76)
				then
					i_WearLevel = (i_BROKEN / 2) -- 50% worn

				-- Chance: 20% - Very much used
				elseif (i_RandomNumber > 5)
				and (i_RandomNumber <= 26)
				then
					i_WearLevel = ((i_BROKEN / 2) + (i_BROKEN / 5)) -- 70% worn

				-- Chance: 3% - Almost broken
				elseif (i_RandomNumber > 2)
				and (i_RandomNumber <= 5)
				then
					i_WearLevel = (i_BROKEN - (i_BROKEN / 20)) -- 95% worn

				-- Chance: 2% - Broken
				elseif (i_RandomNumber <= 2)
				then
					i_WearLevel = i_BROKEN
				end


				-- Actually drop the sword.
				local t_Position = {
					x = a_t_position.x,
					y = (a_t_position.y + 1),
					z = a_t_position.z
				}

				local s_ItemString = s_MobSword .. ' 1 ' .. i_WearLevel

				minetest.add_item(t_Position, s_ItemString)
			end
		end
	end
end


mobs_humans.RandomString = function(a_i_Length)

	local i_Letter = 0
	local i_Number = 0
	local b_InitialLetter = true
	local s_String = ''
	local s_Exchanger = ''
	local s_ForcedChoice = ''
	local t_Vowels = {'a', 'e', 'i', 'o', 'u'}
	local t_Semivowels = {'y', 'w'}

	local t_SimpleConsonants = {
		'm', 'n', 'b', 'p', 'd', 't', 'g', 'k', 'l', 'r', 's', 'z', 'h'
	}

	local t_CompoundConsonants = {
		'ñ', 'v', 'f', 'ð', 'þ', 'ɣ', 'ħ', 'ɫ', 'ʃ', 'ʒ'
	}

	local t_CompoundConsonantsUppercase = {
		'Ñ', 'V', 'F', 'Ð', 'Þ', 'Ɣ', 'Ħ', 'Ɫ', 'Ʃ', 'Ʒ'
	}

	local t_DoubleConsonants = {
		'mm', 'mb', 'mp', 'mr', 'ms', 'mz', 'mf',
		'mʃ',
		'nn', 'nd', 'nt', 'ng', 'nk', 'nr', 'ns', 'nz',
		'nð', 'nþ', 'nɣ', 'nħ', 'nʃ', 'nʒ',
		'bb', 'bl', 'br', 'bz',
		'bʒ',
		'pp', 'pl', 'pr', 'ps',
		'pʃ',
		'dd', 'dl', 'dr', 'dz',
		'dʒ',
		'tt', 'tl', 'tr', 'ts',
		'tʃ',
		'gg', 'gl', 'gr', 'gz',
		'gʒ',
		'kk', 'kl', 'kr', 'ks',
		'kʃ',
		'll', 'lm', 'ln', 'lb', 'lp', 'ld', 'lt', 'lg', 'lk', 'ls', 'lz',
		'lñ', 'lv', 'lf', 'lð', 'lþ', 'lɣ', 'lħ', 'lʃ', 'lʒ',
		'rr', 'rm', 'rn', 'rb', 'rp', 'rd', 'rt', 'rg', 'rk', 'rs', 'rz',
		'rñ', 'rv', 'rf', 'rð', 'rþ', 'rɣ', 'rħ', 'rʃ', 'rʒ',
		'ss', 'sp', 'st', 'sk',
		'sf',
		'zz', 'zm', 'zn', 'zb', 'zd', 'zg', 'zl', 'zr',
		'zñ', 'zv',
		'vl', 'vr',
		'fl', 'fr',
		'ðl', 'ðr',
		'þl', 'þr',
		'ɣl', 'ɣr',
		'ħl', 'ħr',
		'ʃp', 'ʃt', 'ʃk',
		'ʃf',
		'ʒm', 'ʒn', 'ʒb', 'ʒd', 'ʒg', 'ʒl', 'ʒr',
		'ʒv'
	}

	local t_DoubleConsonantsUppercase = {
		'Bl', 'Br', 'Bz',
		'Bʒ',
		'Pl', 'Pr', 'Ps',
		'Pʃ',
		'Dl', 'Dr', 'Dz',
		'Dʒ',
		'Tl', 'Tr', 'Ts',
		'Tʃ',
		'Gl', 'Gr', 'Gz',
		'Gʒ',
		'Kl', 'Kr', 'Ks',
		'Kʃ',
		'Sp', 'St', 'Sk',
		'Sf',
		'Zm', 'Zn', 'Zb', 'Zd', 'Zg', 'Zl', 'Zr',
		'Zñ', 'Zv',
		'Vl', 'Vr',
		'Fl', 'Fr',
		'Ðl', 'Ðr',
		'Þl', 'Þr',
		'Ɣl', 'Ɣr',
		'Ħl', 'Ħr',
		'Ʃp', 'Ʃt', 'Ʃk',
		'Ʃf',
		'Ʒm', 'Ʒn', 'Ʒb', 'Ʒd', 'Ʒg', 'Ʒl', 'Ʒr',
		'Ʒv'
	}

	local s_PreviousLetter = ''

	for i_InitialValue = 1, a_i_Length do

		i_Letter = i_Letter + 1

		--[[
			1: vowel
			2: semivowel
			3: simple consonant
			4: compound consonant
			5: double consonant
		--]]
		local i_ChosenGroup = math.random(1, 5)

		-- Previously used group type
		if (s_Exchanger == 'vowel') then
			--[[
				3: simple consonant
				4: compound consonant
				5: double consonant
			--]]
			i_ChosenGroup = math.random(3, 5)

		elseif (s_Exchanger == 'semivowel') then
			-- 1: vowel
			i_ChosenGroup = 1

		elseif (s_Exchanger == 'simple consonant') then
			if (i_Letter < a_i_Length) then
				--[[
					1: vowel
					2: semivowel
				--]]
				i_ChosenGroup = math.random(1, 2)
			else
				-- Vowel
				i_ChosenGroup = 1
			end

		elseif (s_Exchanger == 'compound consonant') then
			-- Vowel
			i_ChosenGroup = 1

		elseif (s_Exchanger == 'double consonant') then
			-- Vowel
			i_ChosenGroup = 1

		end

		-- Vowels
		if (i_ChosenGroup == 1) then

			-- Uppercase vowel
			if (b_InitialLetter == true) then
				b_InitialLetter = false
				i_Number = math.random(1, #t_Vowels)
				s_PreviousLetter = string.upper(t_Vowels[i_Number])
				s_String = s_String .. s_PreviousLetter

			-- Lowercase vowel
			else
				i_Number = math.random(0, 1) -- single or double vowel

				if (i_Number == 0) then
					i_Number = math.random(1, #t_Vowels)
					s_PreviousLetter = t_Vowels[i_Number]
					s_String = s_String .. s_PreviousLetter

				else
					i_Number = math.random(1, #t_Vowels)
					s_PreviousLetter = t_Vowels[i_Number]
					s_String = s_String .. s_PreviousLetter

					i_Number = math.random(1, #t_Vowels)
					s_PreviousLetter = t_Vowels[i_Number]
					s_String = s_String .. s_PreviousLetter

				end
			end

			s_Exchanger = 'vowel'

		-- Semivowels
		elseif (i_ChosenGroup == 2) then

			i_Number = math.random(1, 2) -- single or double semivowel

			-- Uppercase semivowel
			if (i_Letter ~= 2) then
				if (b_InitialLetter == true) then
					b_InitialLetter = false
					s_PreviousLetter = string.upper(t_Semivowels[i_Number])
					s_String = s_String .. s_PreviousLetter

				-- Lowercase semivowel
				else
					s_PreviousLetter = t_Semivowels[i_Number]
					s_String = s_String .. s_PreviousLetter

				end

				s_Exchanger = 'semivowel'

			-- Lowercase semivowel
			elseif (i_Letter == 2) then
				if (s_PreviousLetter == 'L') or (s_PreviousLetter == 'R')
				or (s_PreviousLetter == 'Ɫ') or (s_PreviousLetter == 'Y')
				or (s_PreviousLetter == 'W') or (s_PreviousLetter == 'H')
				then
					if (i_Number == 1) then
						s_PreviousLetter = 'i'
						s_String = s_String .. s_PreviousLetter

					elseif (i_Number == 2) then
						s_PreviousLetter = 'u'
						s_String = s_String .. s_PreviousLetter

					end
				end

				s_Exchanger = 'vowel'
			end

		-- Simple consonants
		elseif (i_ChosenGroup == 3) then

			i_Number = math.random(1, #t_SimpleConsonants)

			-- Uppercase consonant
			if (b_InitialLetter == true) then
				b_InitialLetter = false
				s_PreviousLetter = string.upper(t_SimpleConsonants[i_Number])
				s_String = s_String .. s_PreviousLetter

			-- Lowercase consonant
			else
				s_PreviousLetter = t_SimpleConsonants[i_Number]
				s_String = s_String .. s_PreviousLetter

			end

			s_Exchanger = 'simple consonant'

		-- Compound consonants
		elseif (i_ChosenGroup == 4) then

			i_Number = math.random(1, #t_CompoundConsonantsUppercase)

			-- Uppercase compound consonant
			if (b_InitialLetter == true) then
				b_InitialLetter = false
				s_PreviousLetter = t_CompoundConsonantsUppercase[i_Number]
				s_String = s_String .. s_PreviousLetter

			-- Lowercase compound consonant
			else
				s_PreviousLetter = t_CompoundConsonants[i_Number]
				s_String = s_String .. s_PreviousLetter
			end

			s_Exchanger = 'compound consonant'

		-- Double consonants
		elseif (i_ChosenGroup == 5) then

			-- Uppercase double consonant
			if (b_InitialLetter == true) then
				b_InitialLetter = false
				i_Number = math.random(1, #t_DoubleConsonantsUppercase)
				s_PreviousLetter = t_DoubleConsonantsUppercase[i_Number]
				s_String = s_String .. s_PreviousLetter

			-- Lowercase double consonant
			else
				i_Number = math.random(1, #t_DoubleConsonants)
				s_PreviousLetter = t_DoubleConsonants[i_Number]
				s_String = s_String .. s_PreviousLetter
			end

			s_Exchanger = 'double consonant'

		end
	end

	b_InitialLetter = true

	return s_String
end


mobs_humans.OnSpawnNormal = function(self)
	self.class = self.type

	self.floats = mobs_humans.Boolean()
	self.attack_animals = mobs_humans.Boolean()
	self.group_attack = mobs_humans.Boolean()
	self.attack_type = mobs_humans.RandomAttackType()

	if (self.class == 'animal') then
		self.passive = mobs_humans.Boolean()
		self.runaway = mobs_humans.Boolean()
		self.attack_animals = mobs_humans.Boolean()
	end

	self.given_name = mobs_humans.RandomString(mobs_humans.RandomNumber(3, 5))

	mobs_humans.TextureCreator(self, nil)
end


if (mobs_humans.b_DynamicMode == true) then
	mobs_humans.NametagColor = function(a_i_armor)
		local s_White = '#FFFFFF'
		local s_Green = '#00FF00'
		local s_Yellow = '#FFFF00'
		local s_Orange = '#FF8000'
		local s_Red = '#FF0000'
		local s_Blue = '#0000FF'
		local s_Indigo = '#4B0082'
		local s_Violet = '#8000FF'
		local s_ColorToAppy = ''
		--print("Armor: " .. a_i_armor)

		if (a_i_armor > 100)
		or (a_i_armor <= 100) and (a_i_armor >= 89) then
			s_ColorToAppy = s_White
			--print("Color: white")

		elseif (a_i_armor < 89) and (a_i_armor >= 78) then
			s_ColorToAppy = s_Green
			--print("Color: green")

		elseif (a_i_armor < 78) and (a_i_armor >= 66) then
			s_ColorToAppy = s_Yellow
			--print("Color: yellow")

		elseif (a_i_armor < 66) and (a_i_armor >= 55) then
			s_ColorToAppy = s_Orange
			--print("Color: orange")

		elseif (a_i_armor < 55) and (a_i_armor >= 44) then
			s_ColorToAppy = s_Red
			--print("Color: red")

		elseif (a_i_armor < 44) and (a_i_armor >= 33) then
			s_ColorToAppy = s_Blue
			--print("Color: blue")

		elseif (a_i_armor < 33) and (a_i_armor >= 21) then
			s_ColorToAppy = s_Indigo
			--print("Color: indigo")

		elseif (a_i_armor < 21) then
			s_ColorToAppy = s_Violet
			--print("Color: violet")

		end

		return s_ColorToAppy
	end


	mobs_humans.RandomArmorLevel = function()
		local i_ChosenLevel = nil

		if (mobs_humans.b_REALISTIC_CHANCE == false) then
			i_ChosenLevel = math.random(mobs_humans.i_MAX_ARMOR_LEVEL, 100)

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

			local i_RandomNumber = mobs_humans.RandomNumber(1, 100)

			if (i_RandomNumber <= i_DIAMOND_ORE_PERCENTAGE) then
				i_ChosenLevel = mobs_humans.RandomNumber(10, 24)

			elseif (i_RandomNumber > i_DIAMOND_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_MESE_ORE_PERCENTAGE)
			then
				i_ChosenLevel = mobs_humans.RandomNumber(25, 39)

			elseif (i_RandomNumber > i_MESE_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_COPPER_ORE_PERCENTAGE)
			then
				i_ChosenLevel = mobs_humans.RandomNumber(40, 54)

			elseif (i_RandomNumber > i_COPPER_ORE_PERCENTAGE)
			and (i_RandomNumber <= i_WOOD_PERCENTAGE)
			then
				i_ChosenLevel = mobs_humans.RandomNumber(55, 69)

			elseif (i_RandomNumber > i_WOOD_PERCENTAGE)
			and (i_RandomNumber <= i_IRON_ORE_PERCENTAGE)
			then
				i_ChosenLevel = mobs_humans.RandomNumber(70, 84)

			else
				i_ChosenLevel = mobs_humans.RandomNumber(85, 100)

			end
		end

		if (i_ChosenLevel < mobs_humans.i_MAX_ARMOR_LEVEL) then
			i_ChosenLevel = mobs_humans.i_MAX_ARMOR_LEVEL
		end

		return i_ChosenLevel
	end


	mobs_humans.RandomSword = function()
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

		if (mobs_humans.b_REALISTIC_CHANCE == false) then
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

			local i_RandomNumber = mobs_humans.RandomNumber(1, 100)

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


	mobs_humans.SwordDraw = function(self)
		if (self.b_hold_sword == false) then
			local s_MobSword = self.weapon.s_Texture

			mobs_humans.TextureCreator(self, s_MobSword)

			self.b_hold_sword = true
		end
	end


	mobs_humans.SwordSheath = function(self)
		if (self.b_hold_sword == true) then
			mobs_humans.TextureCreator(self, nil)

			self.b_hold_sword = false
		end
	end


	mobs_humans.SwordUpdate = function(self)
		if (self.attack_type ~= 'shoot') then -- Not for 'ranged only' mobs.
			local s_CurrentSword = self.weapon.s_ItemString
			local i_CurrentDamage = self.damage

			if (i_CurrentDamage > 1)
			and (i_CurrentDamage < 4)
			then
				if (s_CurrentSword ~= 'default:sword_wood') then
					self.weapon = {
						s_ItemString = 'default:sword_wood',
						i_Damage = 2,
						s_Texture = 'default_tool_woodsword.png'
					}

					--[[
					print(self.given_name .. " new sword: "
						.. dump(self.weapon))
					--]]
				end

			elseif (i_CurrentDamage >= 4)
			and (i_CurrentDamage < 6)
			then
				if (s_CurrentSword ~= 'default:sword_stone') then
					self.weapon = {
						s_ItemString = 'default:sword_stone',
						i_Damage = 4,
						s_Texture = 'default_tool_stonesword.png'
					}

					--[[
					print(self.given_name .. " new sword: "
						.. dump(self.weapon))
					--]]
				end

			elseif (i_CurrentDamage == 6) then
				if (s_CurrentSword ~= 'default:sword_bronze')
				or (s_CurrentSword ~= 'default:sword_steel')
				then
					local i_RandomNumber = mobs_humans.RandomNumber(0, 1)

					if (i_RandomNumber == 0) then
						self.weapon = {
							s_ItemString = 'default:sword_bronze',
							i_Damage = 6,
							s_Texture = 'default_tool_bronzesword.png'
						}

					else
						self.weapon = {
							s_ItemString = 'default:sword_steel',
							i_Damage = 6,
							s_Texture = 'default_tool_steelsword.png'
						}
					end

					--[[
					print(self.given_name .. " new sword: "
						.. dump(self.weapon))
					--]]
				end

			elseif (i_CurrentDamage == 7) then
				if (s_CurrentSword ~= 'default:sword_mese') then
					self.weapon = {
						s_ItemString = 'default:sword_mese',
						i_Damage = 7,
						s_Texture = 'default_tool_mesesword.png'
					}

					--[[
					print(self.given_name .. " new sword: "
						.. dump(self.weapon))
					--]]
				end

			elseif (i_CurrentDamage == 8) then
				if (s_CurrentSword ~= 'default:sword_diamond') then
					self.weapon = {
						s_ItemString = 'default:sword_diamond',
						i_Damage = 8,
						s_Texture = 'default_tool_diamondsword.png'
					}

					--[[
					print(self.given_name .. " new sword: "
						.. dump(self.weapon))
					--]]
				end
			end
		end
	end


	mobs_humans.SwordToggle = function(self)
		if (self.attack_type ~= 'shoot') -- Not for 'ranged only' mobs.
		and (self.state == 'attack')
		then
			if (self.b_hold_sword == false) then
				mobs_humans.SwordDraw(self)
			end

		else
			mobs_humans.SwordSheath(self)

		end
	end


	mobs_humans.OnSpawnDynamic = function(self)
		self.class = self.type

		self.floats = mobs_humans.Boolean()
		self.attack_animals = mobs_humans.Boolean()
		self.group_attack = mobs_humans.Boolean()
		self.attack_type = mobs_humans.RandomAttackType()

		if (self.class == 'animal') then
			self.passive = mobs_humans.Boolean()
			self.runaway = mobs_humans.Boolean()
			self.attack_animals = mobs_humans.Boolean()
		end

		if (self.class == 'monster') then
			self.docile_by_day = mobs_humans.Boolean()
		end

		self.armor = mobs_humans.RandomArmorLevel()

		self.object:set_armor_groups({fleshy = self.armor})

		self.initial_hp = mobs_humans.RandomNumber(self.hp_min, self.hp_max)

		self.hp_max = self.initial_hp

		self.health = self.initial_hp

		self.weapon = mobs_humans.RandomSword()

		self.damage = self.weapon.i_Damage

		self.b_hold_sword = false

		self.given_name = mobs_humans.RandomString(mobs_humans.RandomNumber(3, 5))

		mobs_humans.TextureCreator(self, nil)

		--print("Initial hp: " .. self.initial_hp)
		--print("Max hp: " .. self.hp_max)
		--print("Current hp: " .. self.health)
		--print("Armor level: " .. self.armor)

		-- Set the initial 'b_Hurt' flag.
		mobs_humans.HurtFlag(self)

		--print("Hurt: " .. tostring(self.b_Hurt))

		-- Set the initial 'i_SurvivedFights' flag,
		-- that is the experience modifier.
		mobs_humans.SurvivedFlag(self)
	end
end


mobs_humans.Nametag = function(self)
	if (mobs_humans.b_ShowNametags == false) then
		self.nametag = ''
		self.object:set_properties({ nametag = self.nametag })

	else
		if (mobs_humans.b_ShowStats == false) then
			if (mobs_humans.b_DynamicMode == true) then
				local s_NametagColor = mobs_humans.NametagColor(self.armor)

				self.nametag = minetest.colorize(s_NametagColor,
					self.given_name)

				self.object:set_properties({ nametag = self.nametag })

			else
				self.nametag = minetest.colorize('white', self.given_name)

				self.object:set_properties({ nametag = self.nametag })

			end

		else
			if (mobs_humans.b_DynamicMode == true) then
				local s_NametagColor = mobs_humans.NametagColor(self.armor)

				if (self.i_SurvivedFights == nil) then
					self.i_SurvivedFights = 0
				end

				self.nametag = minetest.colorize(s_NametagColor,
					self.given_name
					.. ' (' .. self.class .. ')' .. '\n'
					.. S('Armor: ') .. self.armor .. '\n'
					.. S('Damage: ') .. self.damage .. '\n'
					.. S('Attack: ') .. self.attack_type .. '\n'
					.. S('Fights: ') .. self.i_SurvivedFights)

				self.object:set_properties({ nametag = self.nametag })

			else
				self.nametag = minetest.colorize('white',
					self.given_name
					.. ' (' .. self.class .. ')' .. '\n'
					.. S('Armor: ') .. self.armor .. '\n'
					.. S('Damage: ') .. self.damage ..  '\n'
					.. S('Attack: ') .. self.attack_type)

				self.object:set_properties({ nametag = self.nametag })
			end
		end
	end
end


mobs_humans.NametagDebug = function(self, hitter, time_from_last_punch,
	tool_capabilities, direction)
	if (minetest.is_player(hitter) == true) then
		--[[
		print('Self: ' .. dump(self))
		print('Hitter: ' .. dump(hitter))
		print('Time from last punch: ' .. dump(time_from_last_punch))
		print('Tool capabilities: ' .. dump(tool_capabilities))
		print('Direction: ' .. dump(direction))
		--]]

		local s_MobName = self.given_name
		local i_MobArmor = self.armor
		local s_PlayerName = hitter:get_player_name()
		local i_PlayerDamage = tool_capabilities.damage_groups.fleshy
		local i_ActualDamage = mobs_humans.calcPunchDamage(self.object,
			time_from_last_punch, tool_capabilities)

		local s_Message = s_MobName .. S(' hit by ') .. s_PlayerName
			.. '\n' .. S('Armor level: ')
			.. minetest.colorize('red', i_MobArmor)
			.. '\n' .. S('Weapon damage: ')
			.. minetest.colorize('red', i_PlayerDamage)
			.. '\n' .. S('Effective damage: ')
			.. minetest.colorize('red', i_ActualDamage)

		minetest.chat_send_player(s_PlayerName, s_Message)
	end
end


mobs_humans.NormalizeStats = function(self)
	if (self.armor ~= 100) then
		self.armor = 100

		self.object:set_armor_groups({fleshy = self.armor})
	end

	if (self.damage ~= 1) then
		self.damage = 1

		self.object:set_properties({damage = self.damage})
	end
end


mobs_humans.TextureCreator = function(self, a_s_Weapon)
	local s_Transparent = 'mobs_humans_transparent.png'
	local t_Appearence = {
		s_Transparent, -- Skin
		s_Transparent, -- Armor
		s_Transparent, -- Weapon
		s_Transparent  -- Shield (?)
	}

	t_Appearence[1] = self.base_texture[1] -- Skin

	if (a_s_Weapon ~= nil) then
		t_Appearence[3] = a_s_Weapon
	end

	self.textures = t_Appearence
	self.base_texture = t_Appearence

	self.object:set_properties({
		textures = self.textures
	})
end
