	jass = require 'jass.common'
	japi = require 'jass.japi'
	runtime = require 'jass.runtime'

	--打开控制台
	runtime.console = true

	--设置句柄等级为0(地图中所有的句柄均使用table封装)
	runtime.handle_level = 0

	--关闭等待功能
	runtime.sleep = false

	--简化版的require...
	function need(name)
		print('need', name)
		return require('lua\\' .. name .. '.lua')
	end

	--汇报错误啦
	function debug.info(s, this)
		local t = {}
		for name, v in pairs(this) do
			table.insert(t, ('[%s] %s'):format(name, v))
		end
		print(('%s\n=======================\n%s\n=======================\n'):format(s, table.concat(t)))
	end