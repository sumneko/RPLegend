	point = {}

	setmetatable(point, point)

	--通过3种方式新建点
	---point.create(x, y, z)
	function point.create(x, y, z)
		return setmetatable({x, y, z}, point.meta)
	end

	function point.__call(x, y, z)
		if type(x) == 'table' then
			---point{x, y, z}
			return setmetatable(x, point.meta)
		else
			---point(x, y, z)
			return setmetatable({x, y, z}, point)
		end
	end

	--结构
	point.__index = {
		type = 'point',
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}