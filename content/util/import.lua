return function (module_name)
  -- replace the environment with one that imported
  -- stuff will go in to
  if getfenv (2) == _G then
    setfenv (2, setmetatable ({}, {
      -- these modules will be checked for looked up values
      imported = {},
      -- looked up values check in modules, then global environment
      __index = function (env, k)
        for _, module in ipairs (getmetatable (env).imported) do
          if module.import_flags [k] then
            assert (rawget (env, k) == nil)
            rawset (env, k, module [k])
          end
        end
        return rawget (env, k) or rawget (_G, k) or
          error ('variable \''.. tostring (k) ..'\' is not declared', 2)
      end,
      -- please don't assign to globals in a module environment
      __newindex = function (env, k)
        error ('variable \'' .. tostring (k) .. '\' is not declared', 2)
      end,
    }))
  end
  table.insert (getmetatable (getfenv (2)).imported, require (module_name))
end
