	game = {}

	--ע������
	---ȫ�ֵ�
	game.points = {}
	
	function game.init()
		--ע��·����
		game.points.start_A = rect.j_point('start_A')
		game.points.start_B = rect.j_point('start_B')
		game.points.start_player = rect.j_point('start_player')

		--ע���ͼ��С
		game.minx, game.miny, game.maxx, game.maxy = rect.map:get()
	end

	game.init()
	
	--��ʼ��Ϸ
	function game.start()
		need 'game\\army'
	end
