	jass = require 'jass.common'
	japi = require 'jass.japi'
	runtime = require 'jass.runtime'

	--�򿪿���̨
	runtime.console = true

	--���þ���ȼ�Ϊ0(��ͼ�����еľ����ʹ��table��װ)
	runtime.handle_level = 0

	--�رյȴ�����
	runtime.sleep = false

	--�򻯰��require...
	function need(name)
		print('need', name)
		return require('lua\\' .. name .. '.lua')
	end

	--�㱨������
	function debug.info(s, this)
		local t = {}
		for name, v in pairs(this) do
			table.insert(t, ('[%s] %s'):format(name, v))
		end
		print(('%s\n=======================\n%s\n=======================\n'):format(s, table.concat(t)))
	end