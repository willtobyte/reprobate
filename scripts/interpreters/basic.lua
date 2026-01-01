local function interpreter(program, stdout, stderr, max_steps_override)
	local lines, program_counter, variables, line_index, for_stack = {}, 1, {}, {}, {}
	local steps, max_steps = 0, max_steps_override or 100

	local function wrap(text, max_length)
		local result = {}
		for line in text:gmatch("[^\r\n]+") do
			while #line > max_length do
				local break_at = line:sub(1, max_length):match(".*()%s") or max_length
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
		local protected_strings, counter = {}, 0
		expression = expression:gsub('"(.-)"', function(string)
			counter = counter + 1
			local key = "__STR" .. counter .. "__"
			protected_strings[key] = '"' .. string .. '"'
			return key
		end)
		expression = expression:gsub("([A-Z][A-Z0-9]*)", function(variable)
			if variable:match("^STR%d+$") then
				return variable
			end
			return tostring(variables[variable] or 0)
		end)
		expression = expression:gsub("(__STR%d+__)", function(key)
			return protected_strings[key] or '""'
		end)
		local chunk, error_message = load("return " .. expression)
		if not chunk then
			stderr("EVALUATION ERROR:")
			for _, message in ipairs(wrap(tostring(error_message):upper(), 60)) do
				stderr(message)
			end
			return 0
		end
		local success, result = pcall(chunk)
		if not success then
			stderr("EVALUATION ERROR:")
			for _, message in ipairs(wrap(tostring(result):upper(), 60)) do
				stderr(message)
			end
			return 0
		end
		return result
	end

	local current_line_number

	local function syntax_error()
		stderr(("SYNTAX ERROR IN LINE %d"):format(current_line_number))
	end

	local function jump_to(target)
		local index = line_index[tonumber(target)]
		if not index then
			stderr(("INVALID GOTO TARGET %s IN LINE %d"):format(tostring(target), current_line_number))
		end
		return index
	end

	local handlers = {}

	handlers.LET = function(code)
		local variable, expression = code:match("^LET%s+([A-Z][A-Z0-9]*)%s*=%s*(.+)$")
		if not variable then
			syntax_error()
			return
		end
		variables[variable] = eval(expression)
	end

	handlers.PRINT = function(code)
		local expression = code:match("^PRINT%s+(.+)$")
		if not expression then
			syntax_error()
			return
		end
		local value = eval(expression)
		stdout((type(value) == "string" and value:upper()) or tostring(value))
	end

	handlers.IF = function(code)
		local condition, target = code:match("^IF%s+(.+)%s+THEN%s+(%d+)$")
		if not condition then
			syntax_error()
			return
		end
		condition = condition:gsub("=", "=="):gsub("<>", "~=")
		if not eval(condition) then
			return
		end
		return jump_to(target)
	end

	handlers.GOTO = function(code)
		local target = code:match("^GOTO%s+(%d+)$")
		return jump_to(target)
	end

	handlers.FOR = function(code)
		local variable, start, stop, step = code:match("^FOR%s+([A-Z][A-Z0-9]*)%s*=%s*(.-)%s+TO%s+(.-)%s+STEP%s+(.+)$")
		if not step then
			variable, start, stop = code:match("^FOR%s+([A-Z][A-Z0-9]*)%s*=%s*(.-)%s+TO%s+(.+)$")
			step = "1"
		end
		if not variable then
			syntax_error()
			return
		end
		variables[variable] = eval(start)
		table.insert(for_stack, { variable = variable, stop = stop, step = step, return_to = program_counter + 1 })
	end

	handlers.NEXT = function(code)
		local variable = code:match("^NEXT%s+([A-Z][A-Z0-9]*)$")
		for index = #for_stack, 1, -1 do
			local loop = for_stack[index]
			if loop.variable == variable then
				local step_value, stop_value = eval(loop.step), eval(loop.stop)
				variables[variable] = variables[variable] + step_value
				if
					(step_value > 0 and variables[variable] <= stop_value)
					or (step_value < 0 and variables[variable] >= stop_value)
				then
					return loop.return_to
				end
				table.remove(for_stack, index)
				return
			end
		end
		stderr(("NEXT WITHOUT FOR IN LINE %d"):format(current_line_number))
		return false
	end

	handlers.RUN = function() end

	for line in program:gmatch("[^\r\n]+") do
		local number, code = line:match("^(%d+)%s+(.*)")
		if number then
			table.insert(lines, { number = tonumber(number), code = code })
		elseif line:match("%S") then
			stderr("IGNORING INVALID LINE: " .. line)
		end
	end

	table.sort(lines, function(a, b)
		return a.number < b.number
	end)
	for index, line in ipairs(lines) do
		line_index[line.number] = index
	end

	while program_counter <= #lines do
		if steps >= max_steps then
			stderr("INFINITE LOOP DETECTED")
			return
		end
		steps = steps + 1

		local line = lines[program_counter]
		current_line_number = line.number
		local code = line.code
		local command = code:match("^(%u+)")

		local handler = handlers[command]
		if handler then
			local result = handler(code)
			if result == false then
				return
			end
			if result then
				program_counter = result
			else
				program_counter = program_counter + 1
			end
		elseif #code == 0 then
			stderr(("UNKNOWN INSTRUCTION IN LINE %d: <EMPTY LINE>"):format(current_line_number))
			program_counter = program_counter + 1
		else
			stderr(("UNKNOWN INSTRUCTION IN LINE %d: %s"):format(current_line_number, code:upper()))
			program_counter = program_counter + 1
		end
	end
end

return interpreter
