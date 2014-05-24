	need 'utility'
	need 'timer'

	print 'hello world!'

	timer.rep(1, 10,
		function(i, t)
			print('wumiao' .. i .. type(t))
			if i == 5 then
				return true
			end
		end
	)
