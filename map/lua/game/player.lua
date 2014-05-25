	game.player = {}

	function game.player.init()
		--全部的16个玩家均互相敌对
		for x = 1, 16 do
			for y = 1, 16 do
				if x ~= y then
					for i = 0, 9 do
						jass.SetPlayerAlliance(player[x], player[y], i, false)
					end
				end
			end
		end
	end

	game.player.init()