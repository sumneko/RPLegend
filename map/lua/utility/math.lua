
	--获取随机整数
	math.random = jass.GetRandomInt

	--求距离
	function math.distance(x1, y1, x2, y2)
		local x = x1 - x2
		local y = y1 - y2
		return math.sqrt(x * x + y * y)
	end

	function math.less(x, y)
		return x < y
	end

	function math.more(x, y)
		return x > y
	end

	--弧度去死吧
		local deg = math.deg(1)
		local rad = math.rad(1)

		--正弦
		local sin = math.sin
		
		function math.sin(r)
			return sin(r * rad)
		end

		--余弦
		local cos = math.cos

		function math.cos(r)
			return cos(r * rad)
		end

		--正切
		local tan = math.tan

		function math.tan(r)
			return tan(r * rad)
		end

		--反正弦
		local asin = math.asin

		function math.asin(v)
			return asin(v) * deg
		end

		--反余弦
		local acos = math.acos

		function math.acos(v)
			return acos(v) * deg
		end

		--反正切
		local atan = math.atan2

		function math.atan(v1, v2)
			return atan(v1, v2) * deg
		end