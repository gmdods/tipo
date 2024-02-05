local tipo = require "tipo"

function table.inspect(t)
	for key, value in pairs(t) do
		print(key, value)
	end
end

local _true = (function()
	local ssa_0 = tipo.fn { _from = 1, _to = tipo.bind(1) }
	local ssa_1 = tipo.call { _fn = tipo.bind(0), _with = true }
	return tipo.let { _let = 1, _be = ssa_0, _in = ssa_1 }
end)()

-- assert(tipo.infer(_true) == { tipo.arrow { tipo.bool, tipo.bool }, tipo.bool })

local _or = (function()
	local lhs, rhs = tipo.bind(0), tipo.bind(1)
	local ssa_0 = tipo.ifte { _if = lhs, _then = rhs, _else = rhs }
	local ssa_1 = tipo.fn { _from = 1, _to = ssa_0 }
	return tipo.fn { _from = 1, _to = ssa_1 }
end)()

-- assert(tipo.infer(_or) == { tipo.bool, tipo.bool })
