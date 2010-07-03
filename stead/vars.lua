function isForSave(k, v, s) -- k - key, v - value, s -- parent table
	local i,o
	if type(s.variables) == 'table' then
		for i,o in ipairs(s.variables) do
			if o == k then
				return true
			end
		end
	end
	if type(k) == 'function' then
		return false
	end
	if type(v) == 'function' or type(v) == 'userdata' then
		return false
	end
	return stead.string.find(k, '_') ==  1
end

function __vars_add(s, v)
	local k, o
	for k,o in pairs(v) do
		if tonumber(k) then
			stead.table.insert(s.variables, o);
		elseif s.variables[k] then
			error ("Variable overwrites variables object: "..tostring(k))
		elseif k ~= 'variable_type' then
			s.variables[k] = o 
		end
	end
end

function __vars_fill(v)
	local k,o
	if type(v) ~= 'table' then
		return
	end
	for k,o in ipairs(v) do
		if type(o) == 'table' and o.variable_type then
			if type(v.variables) ~= 'table' then v.variables = {} end
			__vars_add(v, o);
			v[k] = nil
		end
	end
	if type(v.variables) == 'table' then
		local k,o
		local vars = {}
		for k,o in pairs(v.variables) do
			if tonumber(k) and type(o) == 'string' then
				stead.table.insert(vars, o)
			else
				if v[k] then
					error ("Variable overwrites object property: "..tostring(k));
				end
				v[k] = o
				stead.table.insert(vars, k);
			end
		end
		v.variables = vars;
	end
end

vars_object = obj {
	nam = 'vars',
	ini = function(s)
		__vars_fill(_G)
		__vars_fill(pl)
		__vars_fill(game)
	end
}

obj = stead.hook(obj, 
function(f, v, ...)
	__vars_fill(v)
	return f(v, unpack(arg))
end)

stead.module_init(function()
	variables = {}
end)

function var(v)
	v.variable_type = true
	return v
end

function global(v)
	if type(v) ~= 'table' then
		error("Wrong parameter to global.", 2);
	end
	__vars_add(_G, v);
end