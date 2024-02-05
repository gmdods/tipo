local tipo = {}

local function construct(new)
	return { __call = function(_, args) return new(args) end }
end

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

setmetatable(tipo.bind, construct(tipo.bind.new))
setmetatable(tipo.fn, construct(tipo.fn.new))
setmetatable(tipo.call, construct(tipo.call.new))
setmetatable(tipo.let, construct(tipo.let.new))
setmetatable(tipo.ifte, construct(tipo.ifte.new))

-- Types

tipo.bool = {}

tipo.arrow = {}
function tipo.arrow.new(t)
	return setmetatable({
		_from = t._from or t[1],
		_to = t._to or t[2]
	}, tipo.arrow)
end

setmetatable(tipo.arrow, construct(tipo.arrow.new))

-- Constraints

function tipo.constraints(lang)
	local n = 0
	local t = {}
	local q = {}

	local function cell()
		n = n + 1
		return n
	end

	local function unify(lhs, rhs)
		table.insert(q, { _lhs = lhs, _rhs = rhs })
	end

	local function loop(recur)
		local tag = getmetatable(recur)
		if tag == tipo.bind then
			local r = t[recur._bind]
			if r then
				return r
			else
				n = n + 1
				return n
			end
		elseif tag == tipo.let then
			t[recur._let] = loop(recur._be)
			return loop(recur._in)
		elseif tag == tipo.fn then
			local ty_from = cell()
			t[recur._from] = ty_from
			return tipo.arrow { ty_from, loop(recur._to) }
		elseif tag == tipo.call then
			local ty_ret = cell()
			unify(loop(recur._fn),
				tipo.arrow { loop(recur._with), ty_ret })
			return ty_ret
		elseif tag == tipo.ifte then
			unify(loop(recur._if), tipo.bool)
			local ty_then = loop(recur._then)
			unify(ty_then, loop(recur._else))
			return ty_then
		elseif type(recur) == "boolean" then
			return tipo.bool
		else
			assert(false)
		end
	end
	loop(lang)
	return n, t, q
end

return tipo
