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

	--开始刷兵
	function game.army.start()
		
		timer.loop()
	end