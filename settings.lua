-- mods/noita_resurrection_mod/files/settings.lua

dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "noita_resurrection_mod" -- Make sure this matches your mod's folder name.
mod_settings_version = 1

mod_settings = {
    {
        id = "default_health_on_revive",
        ui_name = "Health on Revival",
        ui_description = "Amount of health restored when reviving.",
        value_default = 100,
        value_min = 1,
        value_max = 1000,
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART, -- Setting takes effect on restart
    },
    {
        id = "death_popup_text",
        ui_name = "Death Popup Text",
        ui_description = "Message displayed when player dies.",
        value_default = "You technically died. Continue?",
        text_max_length = 100,
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
    },
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
