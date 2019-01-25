-- usage:
--   
--   import 'util'
--
--   return library (...,
--     'SomeClassToExport',
--     'some_module_to_export',
--     'as_many_as_you_want')

return function (library_name, ...)
  local modnames = { ... }

  -- libraries auto-require things you try to get from them
  local library = setmetatable ({}, {
    __index = function (t, k)
      t [k] = assert (require (library_name .. '.' .. k))
      return t [k]
    end
  })

  -- import_flags indicates which modules are seen by `import`
  library.import_flags = {}
  for i = 1, #modnames do
    library.import_flags [modnames [i]] = true
  end

  return library
end 
