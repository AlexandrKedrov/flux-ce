--
-- Pointers for a C implementation of getenv:
--
-- * All functions must set the ENV global.
-- * Local environment should be copied to ENV global on fork.
-- * ENV global should have a __newindex metamethod to set C environement
-- variables if they are changed in the ENV global.
--

AddCSLuaFile()

ENV = ENV or {}

if !getenv then
  function getenv(key, default)
    local res = ENV[key]

    if res != nil then
      return res
    end

    return default
  end
end

if !setenv then
  function setenv(key, value)
    ENV[key] = value
    return ENV[key]
  end
end

do
  local client_vars = {}

  function add_client_env(key, value)
    if SERVER and !client_vars[key] then
      client_vars[key] = true
      File.append('lua/_flux/environment.lua', 'setenv("'..tostring(key)..'", "'..tostring(value)..'")\n')
    end
  end
end

if CLIENT then
  include '_flux/environment.lua'
else
  File.write('lua/_flux/environment.lua', '--\n-- This file is automatically generated.\n-- Do not edit this file manually!\n--\n\n')
end
