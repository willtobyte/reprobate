local function interpreter(program, stdout, stderr)
	local lines, pc, variables, line_index, for_stack = {}, 1, {}, {}, {}
	local steps, max_steps, line_exec_count, max_line_hits = 0, 100, {}, 100

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
			stderr("EVALUATION ERROR: " .. tostring(err):upper())
			return 0
		end
		local ok, result = pcall(chunk)
		if not ok then
			stderr("EVALUATION ERROR: " .. tostring(result):upper())
			return 0
		end
		return result
	end

	for line in program:gmatch("[^\r\n]+") do
		local num, code = line:match("^(%d+)%s+(.*)")
		if num then
			table.insert(lines, { num = tonumber(num), code = code })
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
			stderr("INFINITE LOOP DETECTED: EXECUTION STEP LIMIT EXCEEDED")
			return
		end
		local line_num = lines[pc].num
		line_exec_count[line_num] = (line_exec_count[line_num] or 0) + 1
		if line_exec_count[line_num] > max_line_hits then
			stderr(("INFINITE LOOP DETECTED: LINE %d EXECUTED TOO MANY TIMES"):format(line_num))
			return
		end
		steps = steps + 1

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
				local loop = for_stack[#for_stack]
				if not loop then
					stderr(("NEXT WITHOUT FOR IN LINE %d"):format(line_num))
					return
				end
				if loop.var ~= var then
					stderr(("MISMATCHED NEXT VARIABLE '%s' IN LINE %d"):format(var, line_num))
					return
				end
				local step, stop = eval(loop.step), eval(loop.stop)
				variables[var] = variables[var] + step
				if (step > 0 and variables[var] <= stop) or (step < 0 and variables[var] >= stop) then
					pc = loop.return_to
					should_advance = false
				else
					table.remove(for_stack)
				end
			elseif code:match("^RUN$") then
				-- NO-OP
			else
				stderr(("UNKNOWN INSTRUCTION IN LINE %d: %s"):format(line_num, code:upper()))
			end
		until true
		if should_advance then
			pc = pc + 1
		end
	end
end

return interpreter
