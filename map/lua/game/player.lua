	game.player = {}

	function game.player.init()
		--全部的16个玩家均互相敌对
		for x = 1, 16 do
			for y = 1, 16 do
				if x ~= y then
					for i = 0, 9 do
						jass.SetPlayerAlliance(player[x].handle, player[y].handle, i, false)
					end
				end
			end
		end
		
		--设置野怪的颜色
		player[13]:setColor(0)
		player[14]:setColor(1)
		player[15]:setColor(2)
	end

	game.player.init()