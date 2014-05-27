	unit = {}
	
	--单位结构
	unit.__index = {
		--类型
		type = 'unit',
		
		--句柄
		handle = 0,

		--单位类型
		id = 0,
		
		--玩家
			player = 0,

			--获取所有者
			owner = function(this)
				return this.player
			end,

			--是否是敌人
			isEnemy = function(this, player)
				return jass.IsUnitEnemy(this.handle, player.handle)
			end,

		--生命/法力
			--生命/最大生命
			life = 0,
			life_max = 0,

			--当前生命恢复/固定值/倍率
			life_recover = 0,
			life_recover_1 = 0,
			life_recover_2 = 100,

			--法力/最大法力
			mana = 0,
			mana_max = 0,

			--当前法力恢复/固定值/倍率
			mana_recover = 0,
			mana_recover_1 = 0,
			mana_recover_2 = 100,

			recover = function(this, life, mana, life2, mana2)
				if life then
					this.life_recover_1 = this.life_recover_1 + life
				end
				if mana then
					this.mana_recover_1 = this.mana_recover_1 + mana
				end
				if life2 then
					this.life_recover_2 = this.life_recover_2 + life2
				end
				if mana2 then
					this.mana_recover_2 = this.mana_recover_2 + mana2
				end
				life_recover = this.life_recover_1 * this.life_recover_2 / 100
				mana_recover = this.mana_recover_1 * this.mana_recover_2 / 100
				return life_recover, mana_recover
			end,

		--武器
			--攻击力
			attack_base = 0,

			--攻击浮动
			attack_float = 0,

			--附加攻击(绿字)
			attack_add = 0,

			--攻击速度
			---攻击速度为0时,每秒攻击0.5次(2秒);大于0时,每点攻击速度使每秒攻击次数提升0.005次;小于0时,每点攻击速度使攻击间隔增加0.02秒
			attack_speed = 0,
			attack_speed_freq = 0.5,
			attack_speed_per = 2,

			--攻击范围
			attack_range = 128,

			--刷新攻击力
			attack_fresh = function(this, a, b)
				--白字部分
				if a then
					--设置基础攻击
					japi.SetUnitState(this.handle, 0x12, this.attack_base - this.attack_float - 1)
					--设置骰子数量
					japi.SetUnitState(this.handle, 0x10, 1)
					--设置骰子面数
					japi.SetUnitState(this.handle, 0x11, this.attack_float * 2 + 1)
				end
				--绿字部分
				if b then
				end
			end,

		--移动速度
			--当前移动速度/固定值/倍率
			move_speed = 0,
			move_speed_1 = 0,
			move_speed_2 = 100,

			moveSpeed = function(this, ms, ms2)
				if ms or ms2 then
					if ms then
						this.move_speed_1 = this.move_speed_1 + ms
					end
					if ms2 then
						this.move_speed_2 = this.move_speed_2 + ms2
					end
					this.move_speed = this.move_speed_1 * this.move_speed_2 / 100
					jass.SetUnitMoveSpeed(this.handle, this.move_speed)
				end
				return this.move_speed
			end,

		--获取slk数据
		---unit:slk()
		----返回table
		slk = function(this)
			return slk.unit[_id(this.id)]
		end,

		
		--命令
			--当前命令
			order = 0,

			--命令类型
			order_type = '空闲',
			
			--当前命令目标(点)
			order_point = nil,

			--当前命令目标(单位)
			order_to = nil,

			--获取当前命令
			getOrder = function(this)
				return this.order
			end,

		--添加/移除技能
		skill = function(this, sid, lv)
			lv = lv or 1
			if lv == 0 then
				jass.UnitRemoveAbility(this.handle, sid)
			elseif not jass.UnitAddAbility(this.handle, sid) or lv > 1 then 
				jass.SetUnitAbilityLevel(this.handle, sid, lv)
			end
		end,	

		--添加类别
		addType = function(this, t)
			return jass.UnitAddType(this.handle, t)
		end,

		
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

		this.unit = setmetatable(u, unit)

		--初始数据
			--单位句柄
			u.handle = jUnit
			unit.handle[jUnit] = u

			--单位类型
			u.id = this.id
			
			--所属玩家
			u.player = this.player

			--最大生命值/法力值
			if this.life_max then
				u.life_max = this.life_max
			else
				u.life_max = jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_LIFE)
			end
			if this.mana_max then
				u.mana_max = this.mana_max
			else
				u.mana_max = jass.GetUnitState(jUnit, jass.UNIT_STATE_MAX_MANA)
			end

			--当前生命值/法力值
			if this.life then
				u.life = this.life
				jass.SetUnitState(jUnit, jass.UNIT_STATE_LIFE, this.life)
			else
				u.life = u.life_max
			end
			if this.mana then
				u.mana = this.mana
				jass.SetUnitState(jUnit, jass.UNIT_STATE_MANA, this.mana)
			else
				u.mana = u.mana_max
			end

			--攻击力
			u.attack_base = this.attack_base or tonumber(u:slk().dmgplus1)
			u.attack_float = this.attack_float or tonumber(u:slk().dice1)
			u.attack_add = this.attack_add or tonumber(u:slk().sides1)
			u:attack_fresh(true, true)

			--攻击范围
			u.attack_range = this.attack_range or tonumber(u:slk().rangeN1)

			--禁止单位主动攻击
			u:skill(|A000|)

			--添加一个攻击按钮
			u:skill(|A001|)
			
			--默认移动速度
			u:moveSpeed(this.move_speed or jass.GetUnitMoveSpeed(u.handle))

			--回血回蓝
			u:recover(this.life_recover, this.mana_recover)
			unit.recover[u] = true
		--

		--调用函数
		if this.func then
			this.func(this.unit)
		end

		--发起创建单位事件
		
		--返回单位
		return u
	end

	-------------------------------------------回血回蓝--------------------------------------------
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

	------------------------------------------指令转化---------------------------------------------------

		--无目标指令
		event.init('指令_无目标',
			function(this)
				local u = this.from
				
				if this.order == order.stop then
					--如果是stop指令,则直接视为空闲
					u.order_type = '空闲'
					u.order = 0
				else
					--否则记录指令
					u.order_type = '无目标'
					u.order = this.order
				end
			end
		)

		--点目标指令
		event.init('指令_点目标',
			function(this)
				local u = this.from

				u.order_type = '点目标'
				u.order = this.order
				u.order_point = this.point
			end
		)

		--单位目标指令
		event.init('指令_单位目标',
			function(this)
				local u = this.from
				local to = this.to
				
				--如果是smart指令切为敌人,则转化为attack指令
				if this.order == order.smart and to:isEnemy(u:owner()) then
					jass.IssueTargetOrderById(u.handle, order.attack, to.handle)
					return true
				end

				u.order_type = '单位目标'
				u.order = this.order
				u.order_to = to
			end
		)

	------------------------------------------模拟attack------------------------------------------------
		--攻击地面的单位组
		unit.attack_point_group = {}

		--攻击单位的单位组
	

	------------------------------------------一些常用事件------------------------------------------------
	local trg
	local func

	---单位发布物体目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_单位目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit()), to = unit.j_unit(jass.GetOrderTargetUnit())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))

	---单位发布点目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_点目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit()), point = point.create(jass.GetOrderPointX(), jass.GetOrderPointY())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))

	---单位发布无目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_无目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit())})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_ORDER, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))

	---单位发动技能
	trg = jass.CreateTrigger()

	function func()
		event.start('技能_发动',{
			from = unit.j_unit(jass.GetTriggerUnit()),
			point = point.create(jass.GetSpellTargetX(), jass.GetSpellTargetY()),
			to = unit.j_unit(jass.GetSpellTargetUnit()),
			id = jass.GetSpellAbilityId()
		})
	end

	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_SPELL_EFFECT, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))