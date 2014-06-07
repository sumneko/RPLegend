	unit = {}

	local unit = unit	
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
				--攻击速度为0时,每秒攻击0.5次(2秒);大于0时,每点攻击速度使每秒攻击次数提升0.005次;小于0时,每点攻击速度使攻击间隔增加0.02秒
				attack_speed = 0,
				attack_speed_freq = 0.5,
				attack_speed_per = 2,
				--攻击动作倍率(影响攻击前摇)
				attack_speed_rate = 1,
				--基础攻击前摇(最终需要除以动作倍率)
				attack_delay = 0,

				--刷新攻击速度
				attackSpeedFresh = function(this)
					if this.attack_speed == 0 then
						this.attack_speed_freq = 0.5
						this.attack_speed_per = 2
					elseif this.attack_speed > 0 then
						this.attack_speed_freq = 0.5 + this.attack_speed * 0.005
						this.attack_speed_per = 1 / this.attack_speed_freq
					else
						this.attack_speed_per = 2 - this.attack_speed * 0.02
						this.attack_speed_freq = 1 / this.attack_speed_per
					end
					this.attack_speed_rate = this.attack_speed_freq / 0.5
				end,

			--攻击范围
			attack_range = 150,

			--主动攻击范围
			attack_acquire = 0,

			--是否是近战
			attack_melee = true,

			--正在攻击的目标
			attack_target = nil,

			--正在攻击自己的单位们
			attack_froms = {},

			--上次攻击的时间
			attack_last_hit_time = 0,

			--下次开始攻击的时间(开始前摇)
			attack_next_delay_time = 0,

			--下次击中的时间(前摇结束命中)
			attack_next_hit_time = 0,

			--攻击计时器
			attack_timer = nil,

			--标记
			attack_flag_do_not_stop = false,

			--下次进行追击判定的时间
			attack_next_arrive_time = 0,

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

			--单位是否能攻击到(在攻击范围内)
			isInAttackRange = function(from, to)
				return from.attack_range + from.collision + to.collision >= from:distanceUnit(to)
			end,

			--是否在主动攻击范围内
			isInAttackAcquire = function(from, to)
				return from.attack_acquire + from.collision + to.collision >= from:distanceUnit(to)
			end,

			--攻击目标
			attackUnit = function(from, to, lock)
				--锁定目标;自动攻击不锁定
				if lock then
					from.attack_target = to
					to.attack_froms[from] = true
				end

				--获取攻击图标的等级
				local lv = from:skillLevel(|A001|)
				if lv == 1 then
					if from:isInAttackRange(to) then
						--在攻击范围内
						local time = timer.time()
						if time < from.attack_next_delay_time then
							--不能攻击,加入单位组循环检查
							unit.attack_unit_arrive_group[from] = to
						else
							--可以攻击,则开始攻击
							from:skill(|A001|, 0)
							from:skill(|A001|, 2)
							from.attack_flag_do_not_stop = true
							from:issue(order.attack, to)
							from.attack_flag_do_not_stop = false
						end
					else
						--不在攻击范围内,循环检查
						unit.attack_unit_inway_group[from] = to
					end
				end
			end,

			attackUnitStart = function(from, to)
				local attackhit
				local attackdelay
				--已经在攻击
				local time = timer.time()
				
				--攻击出手函数
				function attackdelay()
					print('attack delay')
					event.start('攻击_准备')
					--动画
					from:playAttack(to)
													
					--计算攻击命中的时间
					local delay = from.attack_delay / from.attack_speed_rate
					from.attack_next_hit_time = from.attack_next_delay_time + delay
					from.attack_timer:start(delay, false, attackhit)
					--从检查距离的单位组中移除
					unit.attack_unit_after_hit_group[from] = nil
				end
				
				--攻击命中函数
				function attackhit()
					print('attack hit')
					event.start('攻击_出手')
					
					--计算下次出手的时间
					from.attack_last_hit_time = from.attack_next_hit_time
					from.attack_next_delay_time = from.attack_last_hit_time + from.attack_speed_per
					from.attack_timer:start(from.attack_speed_per, false, attackdelay)
					
					--加入距离检查单位组
					unit.attack_unit_after_hit_group[from] = to

					--造成伤害
					if from.attack_melee then
						from:attackDamage(to)
					end

				end
				
				--计算一下攻击出手的时间
				if from.attack_next_delay_time > time then
					from.attack_timer:start(from.attack_next_delay_time - time, false, attackdelay)
				else
					from.attack_next_delay_time = time
					attackdelay()
				end
			end,

			--中断攻击
			attackStop = function(this)
				if this.attack_flag_do_not_stop then
					return
				end
				this.auto_attack_point = nil
				local to = this.attack_target or this.auto_attack_target
				if to then
					print('attack stop')
					this.attack_target, this.auto_attack_target, auto_attack_point = nil
					to.attack_froms[this] = nil
					this.attack_timer:pause()
					this:skill(|A001|, 0)
					this:skill(|A001|, 1)
					this:playSpeed(1)
					this:play('stop')
					unit.attack_point_group[this], unit.attack_unit_inway_group[this], unit.attack_unit_arrive_group[this], unit.attack_unit_after_hit_group[this] = nil
				end
			end,

			--攻击命中造成伤害
			attackDamage = function(from, to)
				local d_min, d_max = from.attack_base + from.attack_add - from.attack_float, from.attack_base + from.attack_add + from.attack_float
				local d = math.random(d_min, d_max)
				damage{
					from = from,
					to = to,
					damage = d,
					def = true,
					reason = '攻击'
				}
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

		--碰撞体积
			collision = 0,

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

			--正在自动攻击的目标
			auto_attack_target = nil,

			--正在自动攻击的点
			auto_attack_point = nil,			

			--获取当前命令
			getOrder = function(this)
				return this.order
			end,

			--发布命令
			issue = function(this, o, to, flag)
				local r
				--是否是玩家发布的指令
				if flag then
					order.flag = not flag
					if to.type == 'point' then
						r = jass.IssuePointOrderById(this.handle, o, to:get())
					else
						r = jass.IssueTargetOrderById(this.handle, o, to.handle)
					end
				elseif to then
					if type(to) == 'boolean' then
						order.flag = not to
						r = jass.IssueImmediateOrderById(this.handle, o)
					else
						order.flag = true
						if to.type == 'point' then
							r = jass.IssuePointOrderById(this.handle, o, to:get())
						else
							r = jass.IssueTargetOrderById(this.handle, o, to.handle)
						end
					end
				else
					r = jass.IssueImmediateOrderById(this.handle, o)
				end
				order.flag = false
				return r
			end,

		--自动攻击
			--攻击地面
			autoAttackPoint = function(this, p)
				if this:owner():isPlayer() then
					--先检测目标点附近100范围内有没有敌方英雄
					local t = pick.range{
						from = this,
						point = p,
						range = 100,
						filter = unit.filter_1,
					}
					if #t > 0 then
						--有敌方英雄,找出血量最少的一个,进行攻击
						local u = table.pick(t, math.less,
							function(u)
								return u.life
							end
						)

						--如果攻击成功则跳过之后
						if this:issue(order.attack, u) then
							return true
						end
					end
				end

				--攻击移动处理
				this.auto_attack_point = p
				unit.attack_point_group[this] = p
				this:autoAttackFind()
			end,

			--寻找自动攻击目标
			autoAttackFind = function(this)
				local t = pick.range{
					point = this:getPoint(),
					from = this,
					range = this.attack_acquire,
					collision = true,
					filter = unit.filter_2,
				}
				print(#t)
				if #t == 0 then
					return
				else
					--从索敌单位组中移除
					unit.attack_point_group[this] = nil
					
					--按照优先级找出攻击目标
					local u = table.pick(t, math.more, this:auto_attack_rule())
					this.auto_attack_target = u
					u.attack_froms[this] = true
					if this:isInAttackRange(u) then
						this:attackUnit(u)
					else
						this.attack_flag_do_not_stop = true
						this:issue(order.attack, u)
						this.attack_flag_do_not_stop = false
					end
				end
			end,

			--自动攻击优先级
			auto_attack_rule = function(this)
				return function(u)
					local pt = 1
					
					--正在攻击自己的单位优先度为100
					if u.auto_attack_target == this or u.attack_target == this then
						pt = pt * 100
					end

					--攻击血量最少的单位
					pt = pt * u.life

					--英雄的优先度为0.1
					if u.type == 'hero' then
						pt = pt / 10
					end
					print('attack rule: ' .. pt)
					return pt
				end
			end,

		--护甲
			def = 0,
					
		--技能
			--添加/移除技能
			skill = function(this, sid, lv)
				lv = lv or 1
				if lv == 0 then
					jass.UnitRemoveAbility(this.handle, sid)
				elseif not jass.UnitAddAbility(this.handle, sid) or lv > 1 then 
					jass.SetUnitAbilityLevel(this.handle, sid, lv)
				end
			end,

			skillLevel = function(this, sid)
				return jass.GetUnitAbilityLevel(this.handle, sid)
			end,

		--添加类别
		addType = function(this, t)
			return jass.UnitAddType(this.handle, t)
		end,

		--获取位置
			getPoint = function(this)
				return point.create(jass.GetUnitX(this.handle), jass.GetUnitY(this.handle))
			end,

			getXY = function(this)
				return jass.GetUnitX(this.handle), jass.GetUnitY(this.handle)
			end,

		--距离/角度
			--与单位的距离
			distanceUnit = function(this, u)
				local x1, y1 = this:getXY()
				local x2, y2 = u:getXY()
				return math.distance(x1, y1, x2, y2)
			end,

			--与点的距离
			distancePoint = function(this, p)
				local x1, y1 = this:getXY()
				local x2, y2 = p:get()
				return math.distance(x1, y1, x2, y2)
			end,

			--与单位的角度
			angleUnit = function(this, u)
				local x1, y1 = this:getXY()
				local x2, y2 = u:getXY()
				return math.atan(y2 - y1, x2 - x1)
			end,

			--与点的角度
			anglePoint = function(this, p)
				local x1, y1 = this:getXY()
				local x2, y2 = p:get()
				return math.atan(y2 - y1, x2 - x1)
			end,

			--设置单位面向
				--面向单位
				faceUnit = function(this, u)
					jass.SetUnitFacing(this.handle, this:angleUnit(u))
				end,
				
				--面向点
				facePoint = function(this, p)
					jass.SetUnitFacing(this.handle, this:anglePoint(p))
				end,

		--可见度
			--是否对指定玩家可见
			isVisible = function(this, p)
				return jass.IsUnitVisible(this.handle, p.handle)
			end,

		--动画
			--播放动画
			play = function(this, name)
				jass.SetUnitAnimation(this.handle, name)
			end,

			--加入动画队列
			playList = function(this, name)
				jass.QueueUnitAnimation(this.handle, name)
			end,

			--设置动画速率
			playSpeed = function(this, x)
				jass.SetUnitTimeScale(this.handle, x)
			end,

			--播放攻击动画
			playAttack = function(this, to)
				this:playSpeed(this.attack_speed_rate / 1.5)
				this:play('attack')
				this:playList('stand')
				this:faceUnit(to)
			end,

		--是否死亡
		dead = false,

		--死亡时间
		death = 3,

		--击杀
			kill = function(from, to)
				event.start('单位_击杀', {from = from, to = to})
				
				--自己停止攻击
				to:attackStop()
				
				--设置生命值
				jass.SetUnitState(to.handle, jass.UNIT_STATE_LIFE, 0)
				to.dead = true
				event.start('单位_死亡', {from = from, to = to})
				
				--卸载全部的数据,准备移除单位
					--让那些正在攻击自己的人停下
					for from in pairs(to.attack_froms) do
						if from.auto_attack_point then
							from:issue(order.attack, from.auto_attack_point, true)
						elseif from.attack_target then
							from:issue(order.move, to:getPoint(), true)
						else
							from:issue(order.stop, true)
						end
					end
					
					--停止回血回蓝
					unit.recover[to] = nil

					--删除计时器
					to.attack_timer:destroy()

				--准备删除单位
				--jass.UnitSuspendDecay(to.handle, true)
				unit.wait_to_remove_group[to] = 0
			end,

			remove = function(to)
				event.start('单位_移除', {to = to})
				jass.RemoveUnit(to.handle)
				unit.handle[to.handle] = nil
				to.handle = nil
			end,

		--颜色
			red = 255, green = 255, blue = 255, alpha = 255,

			setColor = function(this, red, green, blue, alpha)
				this.red, this.green, this.blue, this.alpha = red or this.red, green or this.green, blue or this.blue, alpha or this.alpha
				jass.SetUnitVertexColor(this.handle, this.red, this.green, this.blue, this.alpha)
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

			--主动攻击范围
			u.attack_acquire = this.attack_acquire or u.attack_range

			--攻击前摇
			u.attack_delay = this.attack_delay or tonumber(u:slk().dmgpt1)

			--攻击计时器
			u.attack_timer = timer.create()

			--攻击速度
			u.attack_speed = this.attack_speed
			u:attackSpeedFresh()

			--自动攻击优先级
			u.auto_attack_rule = this.auto_attack_rule

			--正在攻击自己的单位
			u.attack_froms = {}

			--护甲
			if this.def then
				u.def = this.def
				jass.SetUnitState(u.handle, 0x20, u.def)
			else
				u.def = jass.GetUnitState(u.handle, 0x20)
			end

			--禁止单位主动攻击
			u:skill(|A000|)

			--添加一个攻击按钮
			u:skill(|A001|)
			
			--默认移动速度
			u:moveSpeed(this.move_speed or jass.GetUnitMoveSpeed(u.handle))

			--回血回蓝
			u:recover(this.life_recover, this.mana_recover)
			unit.recover[u] = true

			--碰撞体积
			u.collision = this.collision or tonumber(u:slk().collision)

			--死亡时间
			u.death = this.death or tonumber(u:slk().death)
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
	timer.loop(0.2,
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

	------------------------------------------准备删除单位------------------------------------------------
	unit.wait_to_remove_group = {}

	--以0.1秒为周期判定
	timer.loop(0.1,
		function()
			for u, time in pairs(unit.wait_to_remove_group) do
				time = time + 0.1
				local al = 255 - 255 * time / u.death
				if al > 0 then
					u:setColor(255, 255, 255, al)
					unit.wait_to_remove_group[u] = time
				else
					unit.wait_to_remove_group[u] = nil
					u:remove()
				end
			end
		end
	)

	-----------------------------------------检查当前指令-----------------------------------------------

		timer.loop(0.1,
			function()
				for handle, u in pairs(unit.handle) do
					if u.order_type ~= '空闲' and jass.GetUnitCurrentOrder(handle) == 0 then
						event.start('单位_空闲', {from = u})
					end
				end
			end
		)

	------------------------------------------事件回应---------------------------------------------------

		--无目标指令
		event.init('指令_无目标',
			function(this)
				local u = this.from
				
				if this.order == order.stop then
					--如果是stop指令,则直接视为空闲
					if u.order_type ~= '空闲' then
						event.start('单位_空闲', {from = u})
					end

					--中断攻击
					u:attackStop()
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

				--中断攻击
				u:attackStop()

				--模拟attack
				if this.order == order.attack then
					--将单位放入攻击地面的单位组
					return u:autoAttackPoint(this.point)
				end				
			end
		)

		--单位目标指令
		event.init('指令_单位目标',
			function(this)
				local u = this.from
				local to = this.to
				
				--如果是smart指令切为敌人,则转化为attack指令
				if this.isplayer and this.order == order.smart and to:isEnemy(u:owner()) then
					u:issue(order.attack, to, true)
					return true
				end

				u.order_type = '单位目标'
				u.order = this.order
				u.order_to = to

				--中断攻击
				if this.order ~= order.attack or (this.auto_attack_target ~= to and this.attack_target ~= to) or u:skillLevel(|A001|) == 1 then
					u:attackStop()
				end
				
				--以单位为目标发布attack指令
				if this.order == order.attack then
					u:attackUnit(to, this.isplayer)
				end
			end
		)

		--发动技能效果
		event.init('技能_发动',
			function(this)
				--攻击按钮
				if this.id == |A001| then
					local lv = this.from:skillLevel(|A001|)
					if lv == 1 then
						if this.from.attack_target then
							--足够接近
							local time = timer.time()
							if this.from.attack_next_delay_time > time then
								--但还不能攻击
								unit.attack_unit_arrive_group[this.from] = this.from.attack_target
							else
								--认为是一次攻击
								this.from:attackUnitStart(this.to)
							end
						else
							--攻击地面后抵达命令发布点
						end
					elseif lv == 2 then
						if this.to then
							--足够接近,可以进行攻击
							this.from:attackUnitStart(this.to)
						else
							--攻击地面
						end
					end
				else
					this.from:attackStop()
				end
			end
		)

		--停止技能效果
		event.init('技能_停止',
			function(this)
				--攻击
				if this.id == |A001| then
					unit.attack_point_group[this.from] = nil
				end
			end
		)

		--进入空闲
		event.init('单位_空闲',
			function(this)
				local u = this.from

				u.order_type = '空闲'
				u.order = 0
				--重置动画播放速度
				u:playSpeed(1)
			end
		)

	------------------------------------------模拟attack------------------------------------------------
		--filter
		---攻击地面时查询附近的敌方英雄
		unit.filter_1 = pick.filter('敌人,英雄,可见')

		---攻击地面时周期寻找附近可攻击单位
		unit.filter_2 = pick.filter('敌人,可见')
		
		--攻击地面的单位组
		unit.attack_point_group = {}

		timer.loop(0.2,
			function()
				for u in pairs(unit.attack_point_group) do
					u:autoAttackFind()
				end
			end
		)

		--攻击单位,但还在路上的单位组
		unit.attack_unit_inway_group = {}

		--攻击单位,已经抵达目的地但是还不能攻击的单位组
		unit.attack_unit_arrive_group = {}

		--刚刚命中单位,继续检查攻击范围的单位组
		unit.attack_unit_after_hit_group = {}

		timer.loop(0.02,
			function()
				local time = timer.time()
				
				for from, to in pairs(unit.attack_unit_inway_group) do
					if from.attack_target or from:isInAttackAcquire(to) then
						if from:isInAttackRange(to) and time >= from.attack_next_delay_time then
							unit.attack_unit_inway_group[from] = nil
							--进入攻击范围,开始攻击
							from:skill(|A001|, 2)
							from.attack_flag_do_not_stop = true
							from:issue(order.attack, to)
							from.attack_flag_do_not_stop = false
						end
					elseif from.auto_attack_point then
						--不在主动攻击范围内,放弃
						unit.attack_unit_inway_group[from] = nil
						from:issue(order.attack, from.auto_attack_point, true)
					end
				end

				for from, to in pairs(unit.attack_unit_arrive_group) do
					if from.auto_attack_target then
						--攻击到地面
						if from:isInAttackAcquire(to) then
							--在主动攻击范围内
							if time < from.attack_next_delay_time then
								--不能攻击?
								if from:isInAttackRange(to) then
									--打得到就呆着别动
									--这有可能导致单位在攻击间隔内攻击移动时无视附近的单位
								else
									--打不到就贴上去
									if time >= from.attack_next_arrive_time then
										--离得远
										--避免连续触发移动
										from.attack_next_arrive_time = math.min(from.attack_next_delay_time, time + 0.5)
										--进行移动
										from.attack_flag_do_not_stop = true
										from:issue(order.move, to:getPoint())
										from.attack_flag_do_not_stop = false
									end
								end
							else
								unit.attack_unit_arrive_group[from] = nil
								if from:isInAttackRange(to) then
									--可以攻击就攻击呗
									from:skill(|A001|, 2)
									from.attack_flag_do_not_stop = true
									from:issue(order.attack, to)
									from.attack_flag_do_not_stop = false
								else
									--够不着怎么办
									from:skill(|A001|, 0)
									from:skill(|A001|, 1)
									from.attack_flag_do_not_stop = true
									from:issue(order.attack, to)
									from.attack_flag_do_not_stop = false
								end
							end
						else
							--不在主动攻击范围内,放弃,继续攻击移动
							unit.attack_unit_arrive_group[from] = nil
							from:issue(order.attack, from.auto_attack_point, true)
						end
					else
						--锁定攻击
						if time < from.attack_next_delay_time then
							--还不能攻击
							if from:distanceUnit(to) > from.collision + to.collision and time >= from.attack_next_arrive_time then
								--离得远
								--避免连续触发移动
								from.attack_next_arrive_time = math.min(from.attack_next_delay_time, time + 0.5)
								--进行移动
								from.attack_flag_do_not_stop = true
								from:issue(order.move, to:getPoint())
								from.attack_flag_do_not_stop = false
							end
						else
							--可以攻击
							unit.attack_unit_arrive_group[from] = nil
							if from:isInAttackRange(to) then
								--够得着
								--终于可以攻击了
								from:skill(|A001|, 2)
								from.attack_flag_do_not_stop = true
								from:issue(order.attack, to)
								from.attack_flag_do_not_stop = false
							else
								--够不着
								from:issue(order.attack, to)
							end
						end
					end
				end
				
				for from, to in pairs(unit.attack_unit_after_hit_group) do
					if not from:isInAttackRange(to) then
						from:skill(|A001|, 0)
						from:skill(|A001|, 1)
						unit.attack_unit_after_hit_group[from] = nil
						if from.attack_target then
							--如果单位有锁定攻击的目标,则继续攻击
							from:issue(order.attack, from.attack_target)
						elseif from.auto_attack_point then
							--如果单位有攻击地面的目标,则继续移动
							from:issue(order.attack, from.auto_attack_point, true)
						end
					end
				end
			end
		)

	------------------------------------------一些常用事件------------------------------------------------
	local trg
	local func

	---单位发布物体目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_单位目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit()), to = unit.j_unit(jass.GetOrderTargetUnit()), isplayer = not order.flag})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))

	---单位发布点目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_点目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit()), point = point.create(jass.GetOrderPointX(), jass.GetOrderPointY()), isplayer = not order.flag})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))

	---单位发布无目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('指令_无目标', {order = jass.GetIssuedOrderId(), from = unit.j_unit(jass.GetTriggerUnit()), isplayer = not order.flag})
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

	--单位停止技能
	trg = jass.CreateTrigger()

	function func()
		event.start('技能_停止',{
			from = unit.j_unit(jass.GetTriggerUnit()),
			id = jass.GetSpellAbilityId()
		})
	end

	for i = 1, 16 do
		jass.TriggerRegisterPlayerUnitEvent(trg, player[i].handle, jass.EVENT_PLAYER_UNIT_SPELL_ENDCAST, 0)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))