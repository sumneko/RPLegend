	unit = {}

	--单位结构
	unit.__index = {
		--类型
		type = 'unit',

		--句柄
		handle = 0,

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

		--
		
	}

	--创建单位
	---参数太多,必须通过table的方式创建
	function unit.create(this)
		if not this.player or not this.id or not this.point then
			debug.info('CreateUnitFailed!!', this)
			return
		end

		local x, y = this.point:get()

		local jUnit = jass.CreateUnit(this.player, this.id, x, y, this.face)

		if jUnit == 0 then
			debug.info('CreateUnitFailed!!', this)
			return
		end

		local u = {}

		--初始数据
		do
			--单位句柄
			u.handle = jUnit

			--最大生命值/法力值
			u.life_max = this.life_max or jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_LIFE)
			u.mana_max = this.mana_max or jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_MANA)

			--当前生命值/法力值
			u.life = this.life or u.life_max
			u.mana = this.mana or u.mana_max

			--默认移动速度
			u.speed_move = this.speed_move or jass.GetUnitMoveSpeed(jUnit)

			--回血回蓝
			if this.life_recover or this.mana_recover then
				u.life_recover = this.life_recover
				u.mana_recover = this.mana_recover

				unit.recover[u] = true
			end
		end

		this.unit = setmetatable(u, unit)
		--调用函数
		if this.func then
			this.func(this.unit)
		end

		--发起创建单位事件
		
		
	end

	--回血回蓝
	unit.recover = {}

	---以0.2为周期进行回血回蓝
	timer.loop(0.2, true,
		function()
			for u in pairs(unit.recover)
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