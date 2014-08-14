	point = {}

	local point = point
	setmetatable(point, point)

	--结构
	point.__index = {
		--类型
		type = 'point',

		--坐标
		[1] = 0,
		[2] = 0,
		[3] = 0,

		--获取坐标
		getXY = function(this)
			return this[1], this[2]
		end,

		getX = function(this)
			return this[1]
		end,

		getY = function(this)
			return this[2]
		end,

		--计算z轴坐标
		getZ = function(this)
			jass.MoveLocation(point.dummy, this[1], this[2])
			return jass.GetLocationZ(point.dummy)
		end,

		--距离/角度
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

	}

	--通过3种方式新建点
	---point.create(x, y, z)
	function point.create(x, y, z)
		return setmetatable({x, y, z}, point)
	end

	function point.__call(_, x, y, z)
		if type(x) == 'table' then
			---point{x, y, z}
			return setmetatable(x, point)
		else
			---point(x, y, z)
			return setmetatable({x, y, z}, point)
		end
	end

	point.dummy = jass.Location(0, 0)