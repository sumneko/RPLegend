	game = {}

	--ע������
	---ȫ�ֵ�
	game.points = {}
	
	function game.init()
		--ע��·����
		game.points.start_A = rect.j_point('start_A')
		game.points.start_B = rect.j_point('start_B')
<<<<<<< HEAD
		game.points.start_C = rect.j_point('start_C')
		game.points.start_D = rect.j_point('start_D')
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
		game.points.start_player = rect.j_point('start_player')

		--ע���ͼ��С
		game.minx, game.miny, game.maxx, game.maxy = rect.map:get()
<<<<<<< HEAD

		--�����������
		need 'game\\player'
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
	end

	game.init()
	
	--��ʼ��Ϸ
	function game.start()
		need 'game\\army'
<<<<<<< HEAD

		--��ʼ����
		game.army.start()
=======
>>>>>>> 2877daddfb4bcde80006a0d4aaed0298809f7a30
	end
