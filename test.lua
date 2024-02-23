local tipo = require "tipo"

function table.inspect(t)
	for key, value in pairs(t) do
		print(key, value)
	end
end

function table.equal(t1, t2)
	for key, value in pairs(t1) do
		if value ~= t2[key] then
			return false
		end
	end
	for key, value in pairs(t2) do
		if value ~= t1[key] then
			return false
		end
	end
	return true
end

local _true = (function()
	local ssa_0 = tipo.fn { _from = 1, _to = tipo.bind(1) }
	local ssa_1 = tipo.call { _fn = tipo.bind(0), _with = true }
	return tipo.let { _let = 0, _be = ssa_0, _in = ssa_1 }
end)()

do
	local t = tipo.infer(_true)
	assert(t)
	assert(table.equal(t[0], tipo.arrow { tipo.bool, tipo.bool }))
	assert(t[1] == tipo.bool)
end

local _or = (function()
	local lhs, rhs = tipo.bind(0), tipo.bind(1)
	local ssa_0 = tipo.ifte { _if = lhs, _then = lhs, _else = rhs }
	local ssa_1 = tipo.fn { _from = 1, _to = ssa_0 }
	return tipo.fn { _from = 0, _to = ssa_1 }
end)()

do
	local t = tipo.infer(_or)
	assert(t)
	assert(t[0] == tipo.bool)
	assert(t[1] == tipo.bool)
end

local _why = (function()
	local b = tipo.bind(0)
	local ssa_0 = tipo.call { _fn = b, _with = b }
	local ssa_1 = tipo.fn { _from = 0, _to = ssa_0 }
	return tipo.call { _fn = ssa_1, _with = true }
end)()

do
	local t = tipo.infer(_why)
	assert(not t)
end
