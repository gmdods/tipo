local tipo = {}

-- Syntax

tipo.bind = {}
function tipo.bind.new(t)
	return setmetatable({ _bind = t }, tipo.bind)
end

tipo.fn = {}
function tipo.fn.new(t)
	return setmetatable({
		_from = t._from or t[1],
		_to = t._to or t[2]
	}, tipo.fn)
end

tipo.call = {}
function tipo.call.new(t)
	return setmetatable({
		_fn = t._fn or t[1],
		_with = t._with or t[2],
	}, tipo.call)
end

tipo.let = {}
function tipo.let.new(t)
	return setmetatable({
		_let = t._let or t[1],
		_be = t._be or t[2],
		_in = t._in or t[3]
	}, tipo.let)
end

tipo.ifte = {}
function tipo.ifte.new(t)
	return setmetatable({
		_if = t._if or t[1],
		_then = t._then or t[2],
		_else = t._else or t[3]
	}, tipo.ifte)
end

setmetatable(tipo.bind, { __call = tipo.bind.new })
setmetatable(tipo.fn, { __call = tipo.fn.new })
setmetatable(tipo.call, { __call = tipo.call.new })
setmetatable(tipo.let, { __call = tipo.let.new })
setmetatable(tipo.ifte, { __call = tipo.ifte.new })

-- Types

tipo.bool = {}

tipo.arrow = {}
function tipo.arrow.new(t)
	return setmetatable({
		_from = t._from or t[1],
		_to = t._to or t[2]
	}, tipo.arrow)
end

setmetatable(tipo.arrow, { __call = tipo.arrow.new })

return tipo
