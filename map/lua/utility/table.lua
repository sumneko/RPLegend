	
	--�����������,���Ƴ�ָ��ֵ
	local oldremove = table.remove
	
	function table.remove(t, p)
		if p and type(p) ~= 'number' then
			for i = 1, #t do
				local v = t[i]
				if v == p then
					oldremove(t, i)
					return
				end
			end
		else
			oldremove(t, p)
		end
	end

	--������ת��Ϊ��ϣ��
	function table.key(t, v)
		if v == nil then
			v = true
		end
		local nt = {}
		for i = 1, #t do
			nt[t[i]] = v
		end
		return nt
	end

	--��ѡ�������е�ĳ��ֵ
	
		---table.pick(��, ����, ��Ŀ)
		function table.pick(t, f1, f2)
			local count = #t
			if count == 0 then
				return
			elseif count == 1 then
				return t[1]
			end

			local y = f2 and f2(t[1]) or t[1]
			local r = 1
			for i = 2, count do
				local x = f2 and f2(t[i]) or t[i]
				if f1(x, y) then
					y = x
					r = i
				end
			end

			return t[r]
		end