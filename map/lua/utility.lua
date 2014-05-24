	--转换256进制整数
	function _id(a)
		local s1 = math.floor(a/256/256/256)%256
		local s2 = math.floor(a/256/256)%256
		local s3 = math.floor(a/256)%256
		local s4 = a%256
		return string.char(s1, s2, s3, s4)
	end

	function __id(a)
		local n1 = string.byte(a, 1)
		local n2 = string.byte(a, 2)
		local n3 = string.byte(a, 3)
		local n4 = string.byte(a, 4)
		return n1*256*256*256+n2*256*256+n3*256+n4
	end

	--打印文本
	local oldprint = print
	function print(...)
		return oldprint('[' .. timer.time(true) .. ']', ...)
	end