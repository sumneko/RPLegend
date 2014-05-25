	army = {}

	--小兵结构
	army.__index = {
		--类型
		type = 'army',

		--继承单位结构
		unit = nil,

		--攻击移动的目标点
		point_attack = nil,

		--进行攻击移动
		attack = function(this)
			if this.point_attack then
				jass.IssuePointOrderById(this.handle, order.attack, this.point_attack:get())
			end
		end,
	}

	--继承unit结构
	setmetatable(army.__index, unit)

	--创建小兵
	function army.create(this)
		local u = unit.create(this)
		if not u then
			return
		end

		setmetatable(u, army)
		
		--初始数据
			u.point_attack = this.point_attack

			u:attack()

		--发起事件

		--返回小兵
		return u
	end

	--防止小兵回头
	event.init('指令_点目标',
		function(this)
			if this.order == order.move and this.type == 'army' then
				local a = this.from
				local point = a.point_attack
				if point then
					jass.IssuePointOrderById(a.handle, order.attack, point:get())
				end
			end
		end
	)