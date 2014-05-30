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
		get = function(this)
			return this[1], this[2], this[3]
		end,

		--距离/角度
			--与单位的距离
			distanceUnit = function(this, u)
				local x1, y1 = this:get()
				local x2, y2 = u:getXY()
				return math.distance(x1, y1, x2, y2)
			end,

			--与点的距离
			distancePoint = function(this, p)
				local x1, y1 = this:get()
				local x2, y2 = p:get()
				return math.distance(x1, y1, x2, y2)
			end,
		
			--与单位的角度
			angleUnit = function(this, u)
				local x1, y1 = this:get()
				local x2, y2 = u:getXY()
				return math.atan(y2 - y1, x2 - x1)
			end,

			--与点的角度
			anglePoint = function(this, p)
				local x1, y1 = this:get()
				local x2, y2 = p:get()
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

	