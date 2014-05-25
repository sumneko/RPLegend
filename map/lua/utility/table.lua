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