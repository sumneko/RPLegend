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
		return require('lua\\' .. name .. '.lua')
	end