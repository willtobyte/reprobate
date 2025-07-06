local function interpreter(program, stdout, stderr)
	local lines = {}
	local pc = 1
	local variables = {}
	local line_index = {}
	local for_stack = {}

	local function eval(expression)
		local protected_strings = {}
		local i = 0

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

		local chunk, load_err = load("return " .. expression)
		if not chunk then
			stderr("EVALUATION ERROR: " .. tostring(load_err):upper())
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
		local code = lines[pc].code
		local should_advance = true

		repeat
			if code:match("^LET ") then
				local var, expr = code:match("^LET%s+([A-Z][A-Z0-9]*)%s*=%s*(.+)$")
				if not var or not expr then
					stderr(("SYNTAX ERROR IN LINE %d"):format(lines[pc].num))
					break
				end
				variables[var] = eval(expr)
			elseif code:match("^PRINT") then
				local expr = code:match("^PRINT%s+(.+)$")
				if not expr then
					stderr(("SYNTAX ERROR IN LINE %d"):format(lines[pc].num))
					break
				end
				local value = eval(expr)
				stdout((type(value) == "string" and value:upper()) or tostring(value))
			elseif code:match("^IF") then
				local condition, target = code:match("^IF%s+(.+)%s+THEN%s+(%d+)$")
				if not condition or not target then
					stderr(("SYNTAX ERROR IN LINE %d"):format(lines[pc].num))
					break
				end
				condition = condition:gsub("=", "=="):gsub("<>", "~=")
				if eval(condition) then
					local jump = line_index[tonumber(target)]
					if not jump then
						stderr(("INVALID GOTO TARGET %d IN LINE %d"):format(tonumber(target), lines[pc].num))
						return
					end
					pc = jump
					should_advance = false
				end
			elseif code:match("^GOTO") then
				local target = tonumber(code:match("^GOTO%s+(%d+)$"))
				local jump = line_index[target]
				if not jump then
					stderr(("INVALID GOTO TARGET %d IN LINE %d"):format(target, lines[pc].num))
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
					stderr(("SYNTAX ERROR IN LINE %d"):format(lines[pc].num))
					break
				end
				variables[var] = eval(start)
				table.insert(for_stack, { var = var, stop = stop, step = step, return_to = pc + 1 })
			elseif code:match("^NEXT") then
				local var = code:match("^NEXT%s+([A-Z][A-Z0-9]*)$")
				local loop = for_stack[#for_stack]
				if not loop then
					stderr(("NEXT WITHOUT FOR IN LINE %d"):format(lines[pc].num))
					return
				end
				if loop.var ~= var then
					stderr(("MISMATCHED NEXT VARIABLE '%s' IN LINE %d"):format(var, lines[pc].num))
					return
				end
				local step = eval(loop.step)
				local stop = eval(loop.stop)
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
				stderr(("UNKNOWN INSTRUCTION IN LINE %d: %s"):format(lines[pc].num, code:upper()))
			end
		until true

		if should_advance then
			pc = pc + 1
		end
	end
end

return interpreter
