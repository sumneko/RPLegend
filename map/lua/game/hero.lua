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
		--随机在地图上找一个点
		local start = point(math.random(game.minx, game.maxx), math.random(game.miny, game.maxy))
		--创建英雄
		hero.create{
			player = player,
			id = game.hero.types[htype],
			point = start,
		}
		
	end