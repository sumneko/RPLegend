	unit = {}

	--单位结构
	unit.__index = {
		--类型
		type = 'unit',

		--句柄
		handle = 0,

		--玩家
		player = 0,

		--生命/法力(最大,恢复速度)
		life = 0,
		life_max = 0,
		life_recover = 0,
		
		mana = 0,
		mana_max = 0,
		mana_recover = 0,

		--移动速度
		speed_move = 0,
		--倍乘移动速度%
		speed_move_2 = 100,

		--攻击速度
		speed_attack = 0,

		--获取玩家
		owner = function(this)
			return this.player
		end
		
	}

	--句柄转单位
	unit.handle = {}
	
	function unit.j_unit(jUnit)
		return unit.handle[jUnit]
	end

	--创建单位
	---参数太多,必须通过table的方式创建
	function unit.create(this)
		if not this.player or not this.id or not this.point then
			debug.info('CreateUnitFailed!!', this)
			return
		end

		local x, y = this.point:get()

		local jUnit = jass.CreateUnit(this.player.handle, this.id, x, y, this.face or 0)

		if jUnit == 0 then
			debug.info('CreateUnitFailed!!', this)
			return
		end

		local u = {}

		--初始数据
			--单位句柄
			u.handle = jUnit
			unit.handle[jUnit] = u
			
			--所属玩家
			u.player = this.player

			--最大生命值/法力值
			u.life_max = this.life_max or jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_LIFE)
			u.mana_max = this.mana_max or jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_MANA)

			--当前生命值/法力值
			u.life = this.life or u.life_max
			u.mana = this.mana or u.mana_max

			--默认移动速度
			u.speed_move = this.speed_move or jass.GetUnitMoveSpeed(jUnit)
			jass.SetUnitMoveSpeed(jUnit, u.speed_move)

			--回血回蓝
			if this.life_recover or this.mana_recover then
				u.life_recover = this.life_recover
				u.mana_recover = this.mana_recover

				unit.recover[u] = true
			end
		--

		this.unit = setmetatable(u, unit)
		--调用函数
		if this.func then
			this.func(this.unit)
		end

		--发起创建单位事件
		
		--返回单位
		return u
	end

	--回血回蓝
	unit.recover = {}

	---以0.2为周期进行回血回蓝
	timer.loop(0.2, true,
		function()
			for u in pairs(unit.recover) do
				local life = math.min(u.life + u.life_recover / 5, u.life_max)
				local mana = math.min(u.mana + u.mana_recover / 5, u.mana_max)
				if life ~= u.life then
					u.life = life
					jass.SetUnitState(u.handle, jass.UNIT_STATE_LIFE, life)
				end
				if mana ~= u.mana then
					u.mana = mana
					jass.SetUnitState(u.handle, jass.UNIT_STATE_MANA, mana)
				end
			end
		end
	)

	--一些常用事件
	local trg
	local func

	---单位发布物体目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_物体目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetFilterUnit()), to = unit.j_unit(jass.GetOrderTargetUnit())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, func)
	end

	---单位发布点目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_点目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetFilterUnit()), to = point.create(jass.GetOrderPointX(), jass.GetOrderPointY())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, func)
	end

	---单位发布无目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_无目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetFilterUnit())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_ORDER, func)
	end