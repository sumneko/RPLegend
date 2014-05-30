	pick = {}

	local pick = pick
	--队列顶部
	pick.top = 0
	pick.top_max = 100
	
	--预设单位组
	pick.groups = {}

	for i = 1, pick.top_max do
		pick.groups[i] = jass.CreateGroup()
	end

	--预设
	pick.tables = {}

	--预设condition
		pick.range_condition_1 = jass.Condition(
			function()
				local u = unit.j_unit(jass.GetFilterUnit())
				local top = pick.top
				local this = pick.tables[top]
				local from = this.from
				if this.range + from.collision + u.collision > this.point:distanceUnit(u) then
					if (not this.filter or this.filter(from, u)) and (not this.func or not this.func(u)) then
						table.insert(this.table, u)
					end
				end
			end
		)

		pick.range_condition_2 = jass.Condition(
			function()
				local u = unit.j_unit(jass.GetFilterUnit())
				local top = pick.top
				local this = pick.tables[top]
				local from = this.from
				print(u)
				if (not this.filter or this.filter(from, u)) and (not this.func or not this.func(u)) then
					table.insert(this.table, u)
				end
			end
		)

	--筛选器
		function pick.filter(str, filter)
			local fi = table.key(str:split ',')
			return function(this, u)
				--检查敌对性
				if fi['敌人'] and not u:isEnemy(this:owner()) then
					return
				end

				--检查英雄
				if fi['英雄'] and u.type ~= 'hero' then
					return
				end

				--检查可见度
				if fi['可见'] and not u:isVisible(this:owner()) then
					return
				end
				
				--检查自定义条件
				if filter then
					return filter(this, u)
				end
				
				return true
			end
		end
	
	--选取圆形范围内的单位
	function pick.range(this)
		--[[结构
			point = 选取位置
			from = 选取来源
			range = 选取半径
			collision = 是否计算碰撞
			filter = 筛选器
			table = 添加组
			func = 执行函数
		--]]

		--增加顶部技术
		local top = pick.top + 1
		pick.top = top
		--debug
		if top > pick.top_max then
			print('create pick.group !! ' .. top)
			pick.groups[top] = jass.CreateGroup()
		end

		--开始选取
		local x, y = this.point:get()
		this.table = this.table or {}

		pick.tables[top] = this
		if this.collision then
			--计算碰撞
			jass.GroupEnumUnitsInRange(pick.groups[top], x, y, this.range + 100, pick.range_condition_1)
		else
			--不计算碰撞
			jass.GroupEnumUnitsInRange(pick.groups[top], x, y, this.range, pick.range_condition_2)
		end

		pick.top = top - 1
		return this.table
	end