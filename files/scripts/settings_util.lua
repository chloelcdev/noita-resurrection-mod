--- === ||| vvv [[[ USAGE EXAMPLE ]]] vvv ||| === ---


-- the keys in the settings table will be grabbed from settings every unpause (so long as you're calling on_paused_changed)

-- local settings_util = dofile_once("files/scripts/settings_util.lua")("YOUR_MOD_ID_HERE", 
-- {
--     my_first_setting = 1,
--     my_second_setting = "string",
-- })

-- function OnPausedChanged( is_paused, is_inventory_pause )
--     settings_util.on_paused_changed(is_paused, is_inventory_pause)
-- end


--- === ||| ^^^ [[[ USAGE EXAMPLE ]]] ^^^ ||| === ---


local module = {
    settings = {}, -- you pass this in when you dofile_once() the file, don't change it here
    mod_name_key = "mod_name_not_found", -- you pass this in when you dofile_once() the file, don't change it here
}

-- must be called from OnPausedChanged if you want settings to stay updated at runtime
module.on_paused_changed = function( is_paused, is_inventory_pause )

    if module._old_pause_changed_func ~= nil then
        module._old_pause_changed_func(is_paused, is_inventory_pause)
    end

    module.load_settings()
end

module.get_setting = function(setting_key)
    return ModSettingGet(module.mod_name_key .. "." .. setting_key)
end

module.load_settings = function()
    for key, _ in pairs(module.settings) do
        module.settings[key] = module.get_setting(key)
    end
end

-- MUST be called
module.setup = function(mod_name_key, starting_settings)
    module.mod_name_key = mod_name_key
    module.settings = starting_settings

    module.load_settings()

    return module
end

return module.setup