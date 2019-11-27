--[[

	---

	ATTRIBUTION: 'Limit' and 'Calcule Punch Damage' have been taken
	from 'Creatures MOB-Engine (cme)', on_hitted.lua, by
	Copyright (C) 2017 Mob API Developers and Contributors
	Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

	THIS CODE HAS BEEN MODIFIED TO BE INTEGRATED AS GLOBAL FUNCTIONS
	BY Hamlet.

	See also 'Entity damage mechanism' (../minetest/doc/lua_api.txt)

	---

	= Creatures MOB-Engine (cme) =
	Copyright (C) 2017 Mob API Developers and Contributors
	Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

	on_hitted.lua

	This software is provided 'as-is', without any express or implied warranty. In no
	event will the authors be held liable for any damages arising from the use of
	this software.

	Permission is granted to anyone to use this software for any purpose, including
	commercial applications, and to alter it and redistribute it freely, subject to the
	following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software in a
	product, an acknowledgment in the product documentation is required.
	2. Altered source versions must be plainly marked as such, and must not
	be misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.

--]]


-- Limit
mobs_humans.limit = function(value, min, max)
	if value < min then
		return min
	end
	if value > max then
		return max
	end
	return value
end


-- Calcule Punch Damage
mobs_humans.calcPunchDamage = function(obj, actual_interval, tool_caps)
	local damage = 0
	if not tool_caps or not actual_interval then
		return 0
	end
	local my_armor = obj:get_armor_groups() or {}
	for group,_ in pairs(tool_caps.damage_groups) do
		damage = damage + (tool_caps.damage_groups[group] or 0) *
			mobs_humans.limit(actual_interval / tool_caps.full_punch_interval, 0.0, 1.0) *
			((my_armor[group] or 0) / 100.0)
	end
	return damage or 0
end
