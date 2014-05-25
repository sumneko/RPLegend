	game = {}

	--注册数据
	---全局点
	game.points = {}
	
	function game.init()
		--注册路径点
		game.points.start_A = rect.j_point('start_A')
		game.points.start_B = rect.j_point('start_B')
		game.points.start_C = rect.j_point('start_C')
		game.points.start_D = rect.j_point('start_D')
		game.points.start_player = rect.j_point('start_player')

		--注册地图大小
		game.minx, game.miny, game.maxx, game.maxy = rect.map:get()

		--设置玩家属性
		need 'game\\player'
	end

	game.init()
	
	--开始游戏
	function game.start()
		need 'game\\army'

		--开始出兵
		game.army.start()
	end
