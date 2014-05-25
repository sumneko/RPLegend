	player = {}

	setmetatable(player, player)

	--预设玩家
	for i = 1, 12 do
		player[i] = jass.Player(i - 1)
	end

	function player._call(i)
		return player[i]
	end