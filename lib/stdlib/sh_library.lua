--- @deprecation [Libraries were replaced with modules]
-- @deprecation_version [0.8.0]
function library(lib_name)
  local parent, name = lib_name:parse_parent()

  if name[1]:is_lower() then
    error('bad module name ('..name..')\nmodule names must follow the ConstantStyle!\n')
  end

  parent[name] = parent[name] or {}

  return parent[name]
end
