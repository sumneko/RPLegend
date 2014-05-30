	game.army = {}
	
	--注册怪物的数据
	function game.army.init()
		--小兵类型
		game.army.types ={
			--左边的小兵类型
			[1] = |n000|,
			--右边的小兵类型
			[2] = |n000|,
			--上边的小兵类型
			[3] = |n000|,
			--下边的小兵类型
			[4] = |n000|,
		}
	end

	game.army.init()
	
	--开始刷兵
	function game.army.start()
		--注册进攻点
		local points = {
			game.points.start_A,
			game.points.start_B,
			game.points.start_C,
			game.points.start_D,
			game.points.start_player
		}

		--注册小兵类型
		local types = game.army.types
		print('army start')
		game.army.timer = timer.rep(1, 1, true,
			function()
				for i = 1, 1 do
					--随机在地图上找一个点刷兵
					local start = point(math.random(game.minx, game.maxx), math.random(game.miny, game.maxy))
					--随机从5个点中找一个进攻点
					local target  = points[math.random(1, 5)]
					--刷兵出来
					army.create{
						player = player[i + 13],
						id = types[i],
						point = start,
						point_attack = target,
						attack_acquire = 600,
					}
				end
			end
		)
		
	end