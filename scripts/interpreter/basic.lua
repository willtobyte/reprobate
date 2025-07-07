local function interpreter(program, stdout, stderr, max_steps_override)
	local lines, pc, variables, line_index, for_stack = {}, 1, {}, {}, {}
	local steps, max_steps = 0, max_steps_override or 100

	local function wrap(text, max_len)
		local result = {}
		for line in text:gmatch("[^\r\n]+") do
			while #line > max_len do
				local break_at = line:sub(1, max_len):match(".*()%s") or max_len
				table.insert(result, line:sub(1, break_at))
				line = line:sub(break_at + 1):match("^%s*(.*)$") or ""
			end
			if #line > 0 then
				table.insert(result, line)
			end
		end
		return result
	end

	local function eval(expression)
		local protected_strings, i = {}, 0
		expression = expression:gsub('"(.-)"', function(str)
			i = i + 1
			local key = "__STR" .. i .. "__"
			protected_strings[key] = '"' .. str .. '"'
			return key
		end)
		expression = expression:gsub("([A-Z][A-Z0-9]*)", function(var)
			if var:match("^STR%d+$") then
				return var
			end
			return tostring(variables[var] or 0)
		end)
		expression = expression:gsub("(__STR%d+__)", function(key)
			return protected_strings[key] or '""'
		end)
		local chunk, err = load("return " .. expression)
		if not chunk then
			stderr("EVALUATION ERROR:")
			for _, msg in ipairs(wrap(tostring(err):upper(), 60)) do
				stderr(msg)
			end
			return 0
		end
		local ok, result = pcall(chunk)
		if not ok then
			stderr("EVALUATION ERROR:")
			for _, msg in ipairs(wrap(tostring(result):upper(), 60)) do
				stderr(msg)
			end
			return 0
		end
		return result
	end

	for line in program:gmatch("[^\r\n]+") do
		local num, code = line:match("^(%d+)%s+(.*)")
		if num then
			table.insert(lines, { num = tonumber(num), code = code })
		elseif line:match("%S") then
			stderr("IGNORING INVALID LINE: " .. line)
		end
	end

	table.sort(lines, function(a, b)
		return a.num < b.num
	end)

	for i, l in ipairs(lines) do
		line_index[l.num] = i
	end

	while pc <= #lines do
		if steps >= max_steps then
			stderr("INFINITE LOOP DETECTED")
			return
		end

		steps = steps + 1

		local line_num = lines[pc].num
		local code, should_advance = lines[pc].code, true

		repeat
			if code:match("^LET ") then
				local var, expr = code:match("^LET%s+([A-Z][A-Z0-9]*)%s*=%s*(.+)$")
				if not var or not expr then
					stderr(("SYNTAX ERROR IN LINE %d"):format(line_num))
					break
				end
				variables[var] = eval(expr)
			elseif code:match("^PRINT") then
				local expr = code:match("^PRINT%s+(.+)$")
				if not expr then
					stderr(("SYNTAX ERROR IN LINE %d"):format(line_num))
					break
				end
				local value = eval(expr)
				stdout((type(value) == "string" and value:upper()) or tostring(value))
			elseif code:match("^IF") then
				local cond, target = code:match("^IF%s+(.+)%s+THEN%s+(%d+)$")
				if not cond or not target then
					stderr(("SYNTAX ERROR IN LINE %d"):format(line_num))
					break
				end
				cond = cond:gsub("=", "=="):gsub("<>", "~=")
				if eval(cond) then
					local jump = line_index[tonumber(target)]
					if not jump then
						stderr(("INVALID GOTO TARGET %d IN LINE %d"):format(target, line_num))
						return
					end
					pc = jump
					should_advance = false
				end
			elseif code:match("^GOTO") then
				local target = tonumber(code:match("^GOTO%s+(%d+)$"))
				local jump = line_index[target]
				if not jump then
					stderr(("INVALID GOTO TARGET %d IN LINE %d"):format(target, line_num))
					return
				end
				pc = jump
				should_advance = false
			elseif code:match("^FOR") then
				local var, start, stop, step =
					code:match("^FOR%s+([A-Z][A-Z0-9]*)%s*=%s*(.-)%s+TO%s+(.-)%s+STEP%s+(.+)$")
				if not step then
					var, start, stop = code:match("^FOR%s+([A-Z][A-Z0-9]*)%s*=%s*(.-)%s+TO%s+(.+)$")
					step = "1"
				end
				if not var or not start or not stop then
					stderr(("SYNTAX ERROR IN LINE %d"):format(line_num))
					break
				end
				variables[var] = eval(start)
				table.insert(for_stack, { var = var, stop = stop, step = step, return_to = pc + 1 })
			elseif code:match("^NEXT") then
				local var = code:match("^NEXT%s+([A-Z][A-Z0-9]*)$")
				local found = false
				for i = #for_stack, 1, -1 do
					local loop = for_stack[i]
					if loop.var == var then
						local step, stop = eval(loop.step), eval(loop.stop)
						variables[var] = variables[var] + step
						if (step > 0 and variables[var] <= stop) or (step < 0 and variables[var] >= stop) then
							pc = loop.return_to
							should_advance = false
						else
							table.remove(for_stack, i)
						end
						found = true
						break
					end
				end
				if not found then
					stderr(("NEXT WITHOUT FOR IN LINE %d"):format(line_num))
					return
				end
			elseif code:match("^RUN$") then
				-- NO-OP
			else
				local shown_code = (#code > 0) and code:upper() or "<EMPTY LINE>"
				stderr(("UNKNOWN INSTRUCTION IN LINE %d: %s"):format(line_num, shown_code))
			end
		until true

		if should_advance then
			pc = pc + 1
		end
	end
end

return interpreter
