	game.hero = {}

	--注册英雄数据
	function game.hero.init()
		--英雄类型
		game.hero.types = {
			[1] = |E000|,
		}
	end

	game.hero.init()

	--创建英雄上场
	function game.hero.start(player, htype)
		local i = player:get()
		--随机在地图上找一个点
		local start = point(math.random(game.minx, game.maxx), math.random(game.miny, game.maxy))
		--创建英雄
		game.hero[i] = hero.create{
			player = player,
			id = game.hero.types[htype],
			point = start,
		}

		game.hero[player] = game.hero[i]

		--选中英雄
		jass.SelectUnit(game.hero[i].handle, true)
	end