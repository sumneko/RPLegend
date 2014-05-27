	hero = {}

	--英雄结构
	hero.__index = {
		--类型
		type = 'hero',

		--力量
		state_str = 0,
		state_str2 = 0,
		state_str_up = 0,

		--敏捷
		state_agi = 0,
		state_agi2 = 0,
		state_agi_up = 0,

		--智力
		state_int = 0,
		state_int2 = 0,
		state_int_up = 0,

		--主要属性
		state_primary = ''
	}

	--继承unit结构
	setmetatable(hero.__index, unit)

	--创建英雄
	function hero.create(this)
		local u = unit.create(this)
		if not u then
			return
		end

		setmetatable(u, hero)

		--初始数据
			local jUnit = u.handle
			
			--力量
			if this.state_str then
				u.state_str = this.state_str
			else
				u.state_str = jass.GetHeroStr(jUnit, false)
			end
			if this.state_str_up then
				u.state_str_up = this.state_str_up
			else
				u.state_str_up = tonumber(u:slk().STRplus)
			end

			--敏捷
			if this.state_agi then
				u.state_agi = this.state_agi
			else
				u.state_agi = jass.GetHeroAgi(jUnit, false)
			end
			if this.state_agi_up then
				u.state_agi_up = this.state_agi_up
			else
				u.state_agi_up = tonumber(u:slk().AGIplus)
			end

			--智力
			if this.state_int then
				u.state_int = this.state_int
			else
				u.state_int = jass.GetHeroInt(jUnit, false)
			end
			if this.state_int_up then
				u.state_int_up = this.state_int_up
			else
				u.state_int_up = tonumber(u:slk().INTplus)
			end

			--主要属性
			u.state_primary = tostring(u:slk().Primary)
			
		--发起事件

		--返回英雄
		debug.info('create hero', this)
		return u
	end
