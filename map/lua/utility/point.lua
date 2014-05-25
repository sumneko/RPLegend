	point = {}

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
		end
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

	