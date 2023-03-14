local wait_time = 120
timer = 0

death_swap = {
	swap = {},
	start = {},
}

minetest.register_on_joinplayer(function(player)
	table.insert(death_swap.swap, player)
end)

minetest.register_on_leaveplayer(function(player)
	table.remove(death_swap.swap, player)
end)

minetest.register_privilege("death_swap", {
	description = "Grants the ability to start a death swap.",
})

local function removeFirst(tbl, val)
	for i, v in ipairs(tbl) do
	  if v == val then
		return table.remove(tbl, i)
	  end
	end
  end

local function swap_players()
	minetest.chat_send_all("We will be swapping now.")
	for _, player in pairs(minetest.get_connected_players()) do
		table.insert(death_swap.swap, player)
	end
	repeat
		local p1 = death_swap.swap[math.random(#death_swap.swap)]
		local p2 = death_swap.swap[math.random(#death_swap.swap)]
		local p1pos = p1:get_pos()
		removeFirst(death_swap.swap, p1)
		local p2pos = p2:get_pos()
		removeFirst(death_swap.swap, p2)
		p1:set_pos(p2pos)
		p2:set_pos(p1pos)
	until #death_swap.swap < 2
end

minetest.register_chatcommand("start_swap", {
	description = "Start the death swap game.",
	privs = {death_swap = true},
	func = function(name, param)
		death_swap.start = 1
		minetest.chat_send_all("The death swap game has started!")
		swap_players()
	end,
})

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if death_swap.start ~= 1 then
		return
	end
	if timer >= wait_time then
		swap_players()
		timer = 0
	end
end)