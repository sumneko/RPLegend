	mover = {}
	setmetatable(mover, mover)

	local mover = mover
	
	--移动器结构
	mover.__index = {
		type = 'mover'
		
		--移动单位的句柄
		handle = 0,

		--模型(路径)
		model = '',

		--模型(特效)
		effect = nil,

		--移动器的来源
		from = nil,

		--移动器的目标
		target = nil,

		--移动器的目标(单位)
		to = nil,

		--移动器的目标(点)
		point = nil,

		--移动器是在跟踪点还是单位
		target_type = nil,

		--移动速度
		speed = 100,

		--移动时间
		time = nil,

		--已经移动的时间
		time_past = 0,

		--移动距离
		distance = nil,

		--已经移动的距离
		distance_past = 0,

		--移动进度
		sch = 0,

		--加速度
		acc = 0,

		--移动方向
		angle = 0,

		--转弯速度
		turn = -1,

		--存在周期
		count = 0,

		--周期回调函数
		flash = nil,

		--击中时回调函数
		hit = nil,

		--结束时回调函数
		finish = nil,

		--创建位置(额外)
		source = nil,

		--创建偏移/当前坐标
		x, y, z = 0, 0, 0,

		--命中偏移/命中坐标
		tx, ty, tz = 0, 0, 0,

		--曲线高度
		high = nil,

		--准备移动的距离
		cx, cy, cz = 0, 0, 0,

		--生命值
		life = 100,

		--回收保护时间
		show = 10,

		--挂载的其他移动器(需要的时候创建表)
		movers = nil,

		--获取坐标
			getXY = function(this)
				return this.x, this.y
			end,

			getX = function(this)
				return this.x
			end,

			getY = function(this)
				return this.y
			end,

			getZ = function(this)
				return this.z
			end,

			setXY = function(this, x, y)
				jass.SetUnitX(this.handle, x)
				jass.SetUnitY(this.handle, y)
			end,

			setZ = function(this, z)
				jass.MoveLocation(point.dummy, this:getXY())
				local lz = jass.GetLocationZ(point.dummy)
				if lz > z then
					this:setFly(0)
					return false
				else
					this:setFly(z - lz)
					return true
				end
			end,

		--计算距离/角度
			--与单位的距离
			distance = function(this, u)
				local x1, y1 = this:getXY()
				local x2, y2 = u:getXY()
				return math.distance(x1, y1, x2, y2)
			end,
		
			--与单位的角度
			angle = function(this, u)
				local x1, y1 = this:getXY()
				local x2, y2 = u:getXY()
				return math.atan(y2 - y1, x2 - x1)
			end,

		--改变移动器朝向
			faceTo = function(this)
				SetUnitLookAt(this.handle, "chest", 0, this.cx * 100, this.cy * 100, this.cz * 100)
			end,
		
	}

	--存放所有空闲移动器马甲(数组)
	mover.idles = {}

	--存放所有正在使用的移动器(数组)
	mover.movers = {}

	--存放此次摧毁的移动器在上面那个移动器中的索引(数组)
	mover.removes = {}

	--存放正在等待进入空闲的移动器(哈希)
	mover.temp = {}

	--创建移动器马甲
	function mover.createDummy()
		local i = #mover.idles + 1
		mover.idles[i] = jass.CreateUnit(player[15], |e001|, 0, 0, 0)
		jass.SetUnitPosition(mover.idles[i], 0, 0)
		jass.UnitAddAbility(mover.idles[i], |Arav|)
		jass.UnitRemoveAbility(mover.idles[i], |Arav|)
		jass.ShowUnit(mover.idles[i], false)
	end

	--先创建100个预留的弹道
	for i = 1, 100 do
		mover.creaetDummy()
	end

	function mover.__call(_, this)
		--取出一个移动器马甲
		if mover.idleCount == 0 then
			mover.createDummy()
		end
		local i = #mover.idles
		this.handle = mover.idles[i]
		mover.idles[i] = nil

		table.insert(mover.movers, this)

		--设置目标
		if this.target then
			if this.target.type == 'point' then
				this.target_type = 'point'
				this.point = this.target
			else
				this.target_type = 'unit'
				this.to = this.target
			end
			this.distance = this:distance(this.target)
			this.angle = this:angle(this.target)
			this.tx, this.ty, this.tz = this.target:getX() + this.tx, this.target:getY() + this.ty, this.target:getZ() + this.tz
		else
			if not this.distance then
				this.distance = this.speed * this.time
			end
			this.tx, this.ty = this.distance * math.cos(this.angle) + this.tx, this.distance * math.sin(this.angle) + this.ty
			this.tx = point.create(this.tx, this.ty):getZ() + this.tz
		end

		--添加特效
		this.effect = jass.AddSpecialEffectTarget(this.model, this.handle, 'chest')

		--计算创建位置
		this.source = this.source or this.from
		this.x, this.y, this.z = this.source:getX() + this.x, this.source:getY() + this.y, this.source:getZ() + this.z
		this:setXY(this.x, this.y)
		this:setZ(this.z)
		
		this:faceTo()
		jass.ShowUnit(this.handle, true)

		return this
	end

	--移动器马甲动起来
	timer.loop(0.02,
		function()
			for i = 1, #mover.movers do
				local this = mover.movers[i]

				this.count = this.count + 1
				this.time_past = this.count * 0.02

				--计算速度
				this.speed = this.speed + this.acc * 0.02
				
				if this.target_type then
					--跟踪型
					this.distance = this:distance(this.target)
					local direction = this:angle(this.target)
					if this.turn == -1 then
						--表示瞬间转弯
						this.angle = angle
					else
						local angle = math.angle(this.angle, direction) --夹角
						local turn = this.turn * 0.02
						if angle > turn then
							--转弯速度不够转弯
							local a1, a2 = this.angle + turn, this.angle - turn
							if math.angle(a1, angle) < math.angle(a2, angle) then
								this.angle = a1
							else
								this.angle = a2
							end
						else
							this.angle = angle
						end
					end
					this.tx, this.ty, this.tz = this.target:getX(), this.target:getY(), this.target:getZ()
				else
					--直线型
					
				end

				--移动
				local move = this.speed * 0.02
				this.distance_past = this.distance_past + move

				--更新移动进度
				this.sch = this.sch + (1 - this.sch) * move / this.distance
				
				this.cx, this.cy, this.cz = move * math.cos(this.angle), move * math.sin(this.angle), (this.tz - this.z) * move / this.distance

				--
				
				--确定移动后的坐标
				this.x, this.y, this.z = this:getX() + this.cx, this:getY() + this.cy, this:getZ() + this.cz

				this:setXY(this.x, this,y)
				this:setZ(this.z)

				--检查是否移动结束
				if this.sch >= 1 or (this.time and this.time_past >= this.time) then
					table.insert(mover.removes, i)
				end
			end

			local time = timer.time()
			for i = 1, #mover.removes do
				local i = mover.removes[i]
				local this = mover.movers[i]
				jass.DestroyEffect(this.effect)
				--等待回收
				mover.temp[this] = time
			end

			table.removes(mover.movers, mover.removes)
			mover.removes = {}
		end
	)

	--回收移动器马甲
	timer.loop(10,
		function()
			local ntime = timer.time()
			for this, time in pairs(mover.temp) do
				if ntime > time + this.show then
					table.insert(mover.idles, this.handle)
					mover.temp[this] = nil

					jass.ShowUnit(this.handle, false)
				end
			end
		end
	)