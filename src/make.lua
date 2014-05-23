local file_dir
local test_dir

local function git_fresh(fname)
	local f = io.open((test_dir / fname):string())
	local test_file = f:read('*a')
	f:close()
	local map_file
	f = io.open((file_dir / fname):string())
	if f then
		map_file = f:read('*a')
		f:close()
	end
	if test_file ~= map_file then
		f = io.open((file_dir / fname):string(), 'w')
		f:write(test_file)
		f:close()
		print('[更新]: ' .. fname)
	end
end

local function main()

	--检查参数 arg[1]为地图, arg[2]为本地路径
	local flag_newmap
	
	if (not arg) or (#arg < 2) then
		flag_newmap = true
	end
	
	local input_map  = flag_newmap and (arg[1] .. 'src\\RPLegend.w3x') or arg[1]
	local root_dir   = flag_newmap and arg[1] or arg[2]
	
	--添加require搜寻路径
	package.path = package.path .. ';' .. root_dir .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. root_dir .. 'build\\?.dll'
	require 'luabind'
	require 'filesystem'
	require 'utility'

	--保存路径
	git_path = root_dir
	local input_map    = fs.path(input_map)
	local root_dir     = fs.path(root_dir)
	file_dir           = root_dir / 'map'
	
	fs.create_directories(root_dir / 'test')

	test_dir           = root_dir / 'test'
	local output_map   = test_dir / input_map:filename():string()
	
	--复制一份地图
	pcall(fs.copy_file, input_map, output_map, true)

	--打开地图
	local inmap = mpq_open(output_map)
	if inmap then
		print('[成功]: 打开 ' .. input_map:string())
	else
		print('[失败]: 打开 ' .. input_map:string())
		return
	end

	local fname

	if not flag_newmap then
		--导出listfile
		fname = '(listfile)'
		if inmap:extract(fname, test_dir / fname) then
			print('[成功]: 导出 ' .. fname)
		else
			print('[失败]: 导出 ' .. fname)
			return
		end

		--打开listfile	
		for line in io.lines((test_dir / fname):string()) do
			--导出并更新listfile中列举的每一个文件
			if inmap:extract(line, test_dir / line) then
				print('[成功]: 导出 ' .. line)
				git_fresh(line)
			else
				print('[失败]: 导出 ' .. line)
				return
			end
		end
	end
	

	--搜索dir下的所有文件,导入地图
	local files = {}
	
	local function dir_scan(dir)
		for full_path in dir:list_directory() do
			if fs.is_directory(full_path) then
				-- 递归处理
				dir_scan(full_path)
			else
				local name = full_path:string():gsub(file_dir:string() .. '\\', '')
				--将文件名保存在files中
				table.insert(files, name)
			end
		end
	end

	dir_scan(file_dir)

	--生成新的listfile
	fname = '(listfile)'
	local listfile_path = test_dir / fname
	local listfile = io.open(listfile_path:string(), 'w')
	listfile:write(table.concat(files, '\n') .. "\n")
	listfile:close()
	git_fresh(fname)

	--将文件全部导入回去
	table.insert(files, '(listfile)')
	for _, name in ipairs(files) do
		inmap:import(name, file_dir / name)
	end

	inmap:close()

	if not flag_newmap then
		pcall(fs.copy_file, output_map, input_map:parent_path() / ('new_' .. input_map:filename():string()), true)
	end
	
	print('[完毕]: 用时 ' .. os.clock() .. ' 秒') 

end

main()