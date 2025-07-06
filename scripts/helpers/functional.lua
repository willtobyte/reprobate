-- functional.lua
-- A tiny functional‐style helper module for Lua 5.1+

local M = {}

--- Pipe an initial value through N unary functions.
-- @param value any  – the starting value
-- @param ...   function[] – one or more unary functions
-- @return  any  – the final result
function M.pipe(value, ...)
	local funcs = { ... }
	for i = 1, #funcs do
		value = funcs[i](value)
	end
	return value
end

--- Compose N unary functions right-to-left.
-- @param ... function[] – one or more unary functions
-- @return  function  – a function that applies them in R→L order
function M.compose(...)
	local funcs = { ... }
	local n = #funcs
	if n == 0 then
		return function(x)
			return x
		end
	end

	return function(input)
		for i = n, 1, -1 do
			input = funcs[i](input)
		end
		return input
	end
end

--- Map a unary function over an array-style table.
-- @param t  table  – array of values
-- @param fn function – unary function to apply
-- @return   table  – new array of results
function M.map(t, fn)
	local res = {}
	for i = 1, #t do
		res[i] = fn(t[i])
	end
	return res
end

return M
