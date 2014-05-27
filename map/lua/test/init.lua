	test = {}

	--注册
	function test.init()
		event.init('玩家_聊天',
			function(this)
				if this.string:sub(1, 1) == '.' then
					test.start(this.player, this.string:sub(2):lower())
				end
			end
		)
	end

	--测试指令
	function test.start(player, s)
		local ss = s:split(' ')
		print('test: ', table.unpack(ss))
		if ss[1] == 'icu' then
			jass.FogEnable(false)
		elseif ss[1] == 'start' then
			game.start()
		elseif ss[1] == 'hero' then
			game.hero.start(player, 1)
		end
	end

	test.init()