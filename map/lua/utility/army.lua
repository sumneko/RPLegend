	army = {}

	local army = army
	--小兵结构
	army.__index = {
		--类型
		type = 'army',

		--攻击移动的目标点
		army_point_attack = nil,

		--进行攻击移动
		army_attack = function(this)
			if this.army_point_attack then
				this:issue(order.attack, this.army_point_attack, true)
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
			u.army_point_attack = this.army_point_attack

			u:army_attack()

		--发起事件

		--返回小兵
		return u
	end
