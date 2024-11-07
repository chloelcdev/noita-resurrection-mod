-- modal_util.lua

local modal = {
    starting_gui_id = 1251,
    gui = nil,
    gui_id = nil,
    is_showing = false,

    message = "",

    button_yes_text = "Yes",
    button_no_text = "No",

    callback_yes = nil,
    callback_no = nil,

    img_container = "mods/noita_resurrection_mod/files/container_simple_9piece.png", -- Replace with your actual image path

    gui_style = {
        dialog_width = 300,
        dialog_height = 80,
        padding = 14,
        button_spacing = 20  -- Added button spacing
    }
}

function modal.get_id()
    modal.gui_id = modal.gui_id + 1
    return modal.gui_id
end

function modal.reset_id()
    modal.gui_id = modal.starting_gui_id
end

function modal.StartGUIFrame()
    modal.reset_id()
    GuiStartFrame(modal.gui)
end

function modal.DestroyGUI()
    modal.is_showing = false
    GuiDestroy(modal.gui)
    modal.gui = nil
    modal.reset_id()
end

function modal.open(message, button_yes_text, callback_yes, button_no_text, callback_no, gui_style)

    if gui_style ~= nil then
        modal.gui_style = gui_style
    end

    modal.is_showing = true
    modal.message = message

    modal.button_yes_text = button_yes_text or modal.button_yes_text
    modal.callback_yes = function() if callback_yes then callback_yes() end end

    modal.button_no_text = button_no_text or modal.button_no_text
    modal.callback_no = function() if callback_no then callback_no() end end

    if not modal.gui then
        modal.gui = GuiCreate()
    end
end

function modal.close()
    modal.DestroyGUI()
end

function modal.on_world_post_update()
    if not modal.is_showing then return end

    modal.render()
end

function modal.render()
    modal.StartGUIFrame()

    -- Screen dimensions
    local screen_width, screen_height = GuiGetScreenDimensions(modal.gui)

    -- Panel dimensions
    local panel_width = modal.gui_style.dialog_width
    local panel_height = modal.gui_style.dialog_height

    local panel_x = (screen_width - panel_width) / 2
    local panel_y = (screen_height - panel_height) / 2

    -- Draw the background panel
    GuiImageNinePiece(modal.gui, modal.get_id(), panel_x, panel_y, panel_width, panel_height, 0.99, modal.img_container)

    -- Centered Message
    local message_width, message_height = GuiGetTextDimensions(modal.gui, modal.message, 1)
    local text_x = panel_x + (panel_width - message_width) / 2
    local text_y = panel_y + (panel_height - message_height) / 2 - 10
    GuiText(modal.gui, text_x, text_y, modal.message, 1)

    -- Calculate button dimensions and positions
    local yes_button_width, _ = GuiGetTextDimensions(modal.gui, modal.button_yes_text, 1)
    local no_button_width, _ = GuiGetTextDimensions(modal.gui, modal.button_no_text, 1)

    local total_button_width = yes_button_width + no_button_width + modal.gui_style.button_spacing
    local buttons_x_start = panel_x + (panel_width - total_button_width) / 2
    
    local button_y = panel_y + panel_height - 20 - modal.gui_style.padding
    
    -- Yes Button
    local yes_button_x = buttons_x_start
    if GuiButton(modal.gui, modal.get_id(), yes_button_x, button_y, modal.button_yes_text, 1) then
        if modal.callback_yes then modal.callback_yes() end
        modal.close()
    end

    -- No Button
    local no_button_x = yes_button_x + yes_button_width + modal.gui_style.button_spacing
    if GuiButton(modal.gui, modal.get_id(), no_button_x, button_y, modal.button_no_text, 1) then
        if modal.callback_no then modal.callback_no() end
        modal.close()
    end
end

return modal