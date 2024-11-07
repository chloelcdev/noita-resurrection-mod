-- mods/noita_resurrection_mod/files/settings.lua

dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "noita_resurrection_mod" -- Make sure this matches your mod's folder name.
mod_settings_version = 1

mod_settings = {
    {
        id = "default_health",
        ui_name = "Health on Resurrection",
        ui_description = "Amount of health revert when reviving.",
        value_default = 33,
        value_min = 1,
        value_max = 1000,
        scope = MOD_SETTING_SCOPE_RUNTIME, -- Setting takes effect on restart
    },
    -- one for whether default health is percentage based
    {
        id = "use_percentage_health",
        ui_name = "Percentage-based Health",
        ui_description = "Whether the health on resurrection is a percentage of max health.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    -- a general purpose mod disable for runtime
    {
        id = "mod_disabled",
        ui_name = "Disable",
        ui_description = "Used for effectively disabling the mod without having to restart.",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    -- a general purpose pause disable 
    {
        id = "pause_disabled",
        ui_name = "[PROBLEMATIC] Disable Faux-Pause",
        ui_description = "Used to disable the fake pause feature when the popup comes up. Be prepared for the consequences of that :p (I figure people can use-at-their-own-risk with entangled worlds maybe, though I don't use this in e.w.)",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },


    
    -- {
    --     id = "string_field_example",
    --     ui_name = "Example of a text field for strings",
    --     ui_description = "Blah",
    --     value_default = "hmmm",
    --     text_max_length = 100,
    --     scope = MOD_SETTING_SCOPE_RUNTIME,
    -- },
}

-- Update function for settings
function ModSettingsUpdate(init_scope)
    local old_version = mod_settings_get_version(mod_id)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

-- GUI Count function
function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

-- GUI Render function
function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
