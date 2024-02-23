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

tipo.bool = { _type = "bool" }
setmetatable(tipo.bool, tipo.bool)

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
		local tag = getmetatable(lhs)
		if type(lhs) == "number" or type(rhs) == "number"
		    or tag ~= getmetatable(rhs) then
			table.insert(q, { _lhs = lhs, _rhs = rhs })
			return
		end
		if tag == tipo.arrow then
			unify(lhs._from, rhs._from)
			unify(lhs._to, rhs._to)
		elseif tag == tipo.bool then
			return
		else
			assert(false)
		end
	end

	local function loop(recur)
		local tag = getmetatable(recur)
		if tag == tipo.bind then
			return t[recur._bind] or cell()
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

local function solver(ref, q, eq)
	if not eq then return 1 end
	local lhs, rhs = eq._lhs, eq._rhs
	if type(lhs) == "number" and type(rhs) == "number" then
		if ref[lhs] and ref[rhs] then
			return solver(ref, q, { _lhs = ref[lhs], _rhs = ref[rhs] })
		elseif ref[lhs] then
			ref[rhs] = ref[lhs]
			return 0
		elseif ref[rhs] then
			ref[lhs] = ref[rhs]
			return 0
		else
			q.first = q.first + 1
			q[q.first] = eq
			return 1
		end
	elseif type(lhs) == "number" then
		ref[lhs] = rhs
		return 1
	elseif type(rhs) == "number" then
		ref[rhs] = lhs
		return 1
	else
		q.first = q.first + 1
		q[q.first] = eq
		return 0
	end
end



local function rewrite(tbl, ref)
	local types = {}

	local function concrete(v)
		local tag = getmetatable(v)
		if tag == tipo.arrow then
			return tipo.arrow { concrete(v._from), concrete(v._to) }
		elseif tag == tipo.bool then
			return tipo.bool
		elseif type(v) == "number" then
			assert(ref[v] ~= nil, string.format("%d is nil at ref", v))
			return ref[v]
		else
			assert(false)
		end
	end
	for k, v in pairs(tbl) do
		types[k] = concrete(v)
	end
	return types
end

function tipo.infer(lang)
	local _, tbl, q = tipo.constraints(lang)
	q.first = #q
	q.last = 1

	local ref = {}
	local retries = #q
	while retries > 0 do
		local elt = q[q.last]
		q.last = q.last + 1
		retries = retries - solver(ref, q, elt)
	end
	if q.last > q.first then
		return rewrite(tbl, ref), tbl, q
	else
		return nil, tbl, q
	end
end

return tipo
