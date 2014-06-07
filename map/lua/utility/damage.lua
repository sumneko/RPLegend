	damage = {}
	setmetatable(damage, damage)

	local damage = damage
	--伤害系统结构
	damage.__index = {
		--伤害来源
		from = nil,

		--伤害目标
		to = nil,

		--伤害值
			--当前伤害
			damage = 0,
			--初始伤害
			damage_start = 0,
			--最大伤害
			damage_max = 0,

		--是否计算护甲
		def = false,

		--是否计算抗性
		ant = false,

		--伤害原因
		reason = '未知',

		--时间
		time = 0,

		--检查护甲
		toDef = function(this)
			
		end,

		--检查抗性
		toAnt = function(this)
		end,
	}

	--发起
	function damage.__call(_, this)
		--添加模板
		setmetatable(this, damage)

		this.time = timer.time()

		this.damage_start, this.damage_max = this.damage, this.damage

		--检查伤害有效性,返回true表示无效
		if event.start('伤害_有效性', this) then
			return
		end

		--检查护甲与抗性
		if this.def then
			this:toDef()
		end
		if this.ant then
			this:toAnt()
		end

		--计算伤害加成
		event.start('伤害_加成')
		this.damage_max = this.damage

		--计算伤害减免
		event.start('伤害_减免')

		--伤害值确定
		event.start('伤害_确定')

		--扣血
			local life = this.to.life - this.damage
			if life < 1 then
				--致命伤害
				life = event.start('伤害_致命') or 0
			end
			if life == 0 then
				this.from:kill(this.to)
			else
				jass.SetUnitState(this.to.handle, jass.UNIT_STATE_LIFE, life)
			end
			this.to.life = life
		--伤害效果
		event.start('伤害_效果')

		--伤害结算
		event.start('伤害_结算')
		
	end