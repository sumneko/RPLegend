	event = {}

	setmetatable(event, event)

	--发起事件
	---发起事件(事件1, 事件2, 事件3..., 数据)
	function event.start(...)
		local arg = {...}
		local count = #arg
		local data = arg[count]
		for i = 1, count - 1 do
			
			--当前事件的名字
			local name = arg[i]
			local t = event[name]
			if t then
				for i = 1, #t do
					--找到函数
					local f = t[i]
					local r = f(data)
					--如果事件有返回值,则直接退出
					if r then
						return r
					end
				end
			end
		end
	end

	--注册事件
	---event.get(事件1, 事件2, 事件3..., 函数)
	function event.init(...)
		local arg = {...}
		local count = #arg
		local f = arg[count]
		for i = 1, count - 1 do
			
			--当前事件的名字
			local name = arg[i]

			--检查是否是删除事件
			local flag
			if name:sub(1, 1) == '-' then
				flag = true
				name = name:sub(2)

				local t = event[name]
				if t then
					table.remove(t, f)
				end
			else

				local t = event[name]
				if not t then
					--如果事件表不存在就新建
					t = {}
					event[name] = t
				end
				table.insert(t, f)
			end
		end
	end

	---event(事件1, 事件2, 事件3..., [函数, 数据])
	function event.__call(_, ...)
		if type(arg[#arg]) == 'table' then
			return event.start(...)
		else
			return event.init(...)
		end
	end