	game = {}

	--注册数据
	---全局点
	game.points = {}
	
	function game.init()
		--注册路径点
		game.points.start_A = rect.j_point('start_A')
		game.points.start_B = rect.j_point('start_B')
<<<<<<< HEAD
		game.points.start_C = rect.j_point('start_C')
		game.points.start_D = rect.j_point('start_D')
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
		game.points.start_player = rect.j_point('start_player')

		--注册地图大小
		game.minx, game.miny, game.maxx, game.maxy = rect.map:get()
<<<<<<< HEAD

		--设置玩家属性
		need 'game\\player'
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
	end

	game.init()
	
	--开始游戏
	function game.start()
		need 'game\\army'
<<<<<<< HEAD

		--开始出兵
		game.army.start()
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
	end
