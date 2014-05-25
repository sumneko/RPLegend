	rect = {}

	setmetatable(rect, rect)

	--创建矩形区域
	---rect.create(最小x, 最小y, 最大x, 最大y)
	function rect.create(minx, miny, maxx, maxy)
		return setmetatable({minx, miny, maxx, maxy}, rect)
	end

	function rect.__call(_, minx, miny, maxx, maxy)
		if type(minx) == 'table' then
			---rect{最小x, 最小y, 最大x, 最大y}
			return setmetatable(minx, rect)
		else
			---rect({最小x, 最小y, 最大x, 最大y})
			return setmetatable({minx, miny, maxx, maxy}, rect)
		end
	end

	--矩形区域结构
	rect.__index = {
		--类型
		type = 'rect',

		--minx
		[1] = 0,

		--miny 
		[2] = 0,

		--maxx
		[3] = 0,

		--maxy
		[4] = 0,

		--获取4个值
		get = function(this)
			return this[1], this[2], this[3], this[4]
		end,

		--获取中心坐标
		cent = function(this)
			return (this[1] + this[3]) / 2, (this[2] + this[4]) / 2
		end,

		centPoint = function(this)
			return point.create((this[1] + this[3]) / 2, (this[2] + this[4]) / 2)
		end,
		
	}

	--转化jass中的矩形区域
	function rect.j_rect(name)
		local jRect = jass['gg_rct_' .. name]
		return rect.create(jass.GetRectMinX(jRect), jass.GetRectMinY(jRect), jass.GetRectMaxX(jRect), jass.GetRectMaxY(jRect))
	end

	--转化jass中的矩形区域为点
	function rect.j_point(name)
		local jRect = jass['gg_rct_' .. name]
		return point.create(jass.GetRectCenterX(jRect), jass.GetRectCenterY(jRect))
	end

	--注册
	function rect.init()
		rect.map = rect.create(
			jass.GetCameraBoundMinX() - jass.GetCameraMargin(jass.CAMERA_MARGIN_LEFT),
			jass.GetCameraBoundMinY() - jass.GetCameraMargin(jass.CAMERA_MARGIN_BOTTOM),
			jass.GetCameraBoundMaxX() + jass.GetCameraMargin(jass.CAMERA_MARGIN_RIGHT),
			jass.GetCameraBoundMaxY() + jass.GetCameraMargin(jass.CAMERA_MARGIN_TOP)
		)
	end

	rect.init()