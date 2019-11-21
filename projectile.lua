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
-- Arrow entity
--

mobs:register_arrow('mobs_humans:stone', {
	visual = 'sprite',
	visual_size = {x = 0.1, y = 0.1},
	textures = {'default_stone.png'},
	velocity = 9,
	hit_player = function(self, player)
		player:punch(self.object, 1,
			{
				full_punch_interval = 0.1,
				damage_groups = {fleshy = 6},
			}
		)
	end,

	hit_node = function(self, pos, node)
		self.object:remove()
	end
})
