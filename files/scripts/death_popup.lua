-- make sure we're calling on_world_post_update

local module = {
    pause = dofile_once("mods/noita_resurrection_mod/files/scripts/fake_pause_util.lua"),
    death_stats_util = dofile_once("mods/noita_resurrection_mod/files/scripts/death_stats_util.lua"),

    img_container = "mods/noita_resurrection_mod/files/container_simple_9piece.png",
    img_game_over = "mods/noita_resurrection_mod/files/game_over.png",

    response_handler = nil,

    gui = nil,
    starting_gui_id = 11510,

    is_showing = false,
    target_player = nil,
}

module.gui_id = module.starting_gui_id

function module.get_id()
    module.gui_id = module.gui_id + 1
    return module.gui_id
end

function module.reset_id()
    module.gui_id = module.starting_gui_id
end

function module.StartGUIFrame()
    module.reset_id()
    GuiStartFrame(module.gui)
end

function module.DestroyGUI()
    module.is_showing = false
    GuiDestroy(module.gui)
    module.gui = nil
    module.reset_id() -- just for safety. the one in StartGUIFrame is more important
end

function module.set_response_handler(handler) 
    module.response_handler = handler 
end

function module.show(player, skip_pause)

    module.death_stats_util.grab_stats()

    module.is_showing = true

    if not skip_pause then
        module.pause.pause_game(player)
    end

    --print("Pausing game for show(), is_showing = " .. tostring(module.is_showing))
end

function module.on_world_post_update()

    module.death_stats_util.grab_stats()

    if module.is_showing then
        module.render()
    end
end

function module.render()
    if module.gui == nil then
        module.gui = GuiCreate()
    end

    -- lua lists don't necessarily stay ordered, so we're iterating with ipairs through this.
    -- This also, conveniently, lets us skip the "Cause of death" stat, which we handle manually above.
    local ordered_keys = {
        "Mods enabled",
        "Gold",
        "Time",
        "Depth",
        "Places visited",
        "Enemies slain",
        "Max HP",
        "Items found",
    }

    local text_scale = 1
    local common_spacing = 10
    local screen_width, screen_height = GuiGetScreenDimensions(module.gui)

    -- Define initial panel dimensions
    local min_panel_width, panel_height = 154, 154

    -- Calculate the maximum width of label-value pairs
    local max_text_width = 0
    --print(module.death_stats_util.grabbed_stats["Max HP"])
    for _, stat_name in ipairs(ordered_keys) do
        local stat_value = module.death_stats_util.grabbed_stats[stat_name]

        local text = stat_name .. ":  " .. tostring(stat_value)
        local text_width = GuiGetTextDimensions(module.gui, text, text_scale)
        if text_width > max_text_width then
            max_text_width = text_width
        end
    end

    -- Adjust panel width based on the widest label-value pair
    min_panel_width = math.max(min_panel_width, max_text_width + 40) -- Adding padding
    local panel_x = (screen_width / 2) - (min_panel_width / 2)
    local panel_y = (screen_height / 2) - (panel_height / 2) + 20

    -- Calculate the x position to center the longest line
    local x_text = panel_x + (min_panel_width - max_text_width) / 2

    module.StartGUIFrame()

    -- Draw the background panel at the centered position
    GuiImageNinePiece(module.gui, module.get_id(), panel_x, panel_y, min_panel_width, panel_height, 0.97, module.img_container)

    -- Draw the img_game_over JUST at the top of the background panel
    GuiImage(module.gui, module.get_id(), panel_x-46, panel_y - 58, module.img_game_over, 0.85, 1, 1, 0)

    -- Set initial y position for the labels and values
    local y_offset = panel_y + 6

    -- Draw the "Cause of death" label at the top, centered
    local death_cause_text = "Cause of death: " .. "'" ..  tostring(module.death_stats_util.grabbed_stats["Cause of death"]) .. "'"
    local death_cause_x = panel_x + (min_panel_width - GuiGetTextDimensions(module.gui, death_cause_text, text_scale)) / 2
    GuiText(module.gui, death_cause_x, y_offset, death_cause_text, text_scale)
    
    y_offset = y_offset + common_spacing + 2

    for _, stat_name in ipairs(ordered_keys) do
        local stat_value = module.death_stats_util.grabbed_stats[stat_name]
        
        stat_name = stat_name .. ":"
        -- Draw the label in the default color
        local label_width = GuiGetTextDimensions(module.gui, stat_name, text_scale)
        GuiText(module.gui, x_text, y_offset, stat_name, text_scale)

        -- Draw the value in yellow
        GuiColorSetForNextWidget(module.gui, 1, 1, 0, 1) -- Set color to yellow (R, G, B, A)
        GuiText(module.gui, x_text + label_width + 2, y_offset, tostring(stat_value), text_scale)

        y_offset = y_offset + common_spacing
    end

    -- Buttons for "New Game", "Progress", "Quit" at the bottom of the panel
    y_offset = y_offset + common_spacing
    
    -- Calculate each button's centered x position individually
    local new_game_text_width = GuiGetTextDimensions(module.gui, "New Game", text_scale)
    local progress_text_width = GuiGetTextDimensions(module.gui, "Progress", text_scale)
    local quit_text_width = GuiGetTextDimensions(module.gui, "Quit", text_scale)
    local end_run_text_width = GuiGetTextDimensions(module.gui, "End Run", text_scale)

    local new_game_x = panel_x + (min_panel_width - new_game_text_width) / 2
    local progress_x = panel_x + (min_panel_width - progress_text_width) / 2
    local quit_x = panel_x + (min_panel_width - quit_text_width) / 2
    local end_run_x = panel_x + (min_panel_width - end_run_text_width) / 2

    -- Render each button centered individually
    if GuiButton(module.gui, module.get_id(), end_run_x, y_offset + common_spacing, "End Run", text_scale) then
        module.response_handler("EndRun")
    end

    -- Put a clickable button at the bottom right corner in a really small font
    local respawn_text = "Noita'd!"
    local respawn_text_scale = 0.95
    local respawn_text_width, respawn_text_height = GuiGetTextDimensions(module.gui, respawn_text, respawn_text_scale)
    local respawn_x = panel_x + min_panel_width - respawn_text_width + 1
    local respawn_y = panel_y + panel_height - respawn_text_height + 2

    if GuiButton(module.gui, module.get_id(), respawn_x, respawn_y, respawn_text, respawn_text_scale) then
        module.response_handler("Respawn")
    end
end

function module.hide()
    module.pause.unpause_game(true)
    module.DestroyGUI()
end

return module


--893023750 - good first mount