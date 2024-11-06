-- death_popup.lua
local module = {}

module.pause = dofile_once("mods/noita_resurrection_mod/files/scripts/fake_pause.lua")

module.img_container = "mods/noita_resurrection_mod/files/container_simple_9piece.png"
module.img_game_over = "mods/noita_resurrection_mod/files/game_over.png"

module.response_handler = nil

module.gui = nil
module.starting_gui_id = 11510
module.gui_id = module.starting_gui_id

module.is_showing = false
module.grabbed_stats = nil

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
end

function module.set_response_handler(handler) 
    module.response_handler = handler 
end

function module.show(player)
    module.grabbed_stats = module.grab_stats(player)
    module.is_showing = true
    module.pause.pause_game(player)
    --print("Pausing game for show(), is_showing = " .. tostring(module.is_showing))
end

function module.render_if_showing()
    if module.is_showing then
        module.render()
    end
end

function module.render()
    
    if module.gui == nil then
        module.gui = GuiCreate()
    end
    
    local text_scale = 1

    local common_spacing = 10

    local screen_width, screen_height = GuiGetScreenDimensions(module.gui)

    -- Define initial panel dimensions
    local panel_width, panel_height = 154, 154

    -- List of stats with placeholders
    local stats = {
        { label = "Mods enabled:", value = "Yes" },
        { label = "Gold:", value = module.grabbed_stats["Gold"] },
        { label = "Time:", value = module.grabbed_stats["Time"] },
        { label = "Depth:", value = module.grabbed_stats["Depth"] },
        { label = "Places visited:", value = module.grabbed_stats["Places visited"] },
        { label = "Enemies slain:", value = module.grabbed_stats["Enemies slain"] },
        { label = "Max HP:", value = module.grabbed_stats["Max HP"] }, -- TODO: +"(Record!)"
        { label = "Items found:", value = module.grabbed_stats["Items found"] },
        { label = "Total deaths:", value = module.grabbed_stats["Total deaths"] },
        { label = "Total wins:", value = module.grabbed_stats["Total wins"] }
    }

    -- Calculate the maximum width of label-value pairs
    local max_text_width = 0
    for _, stat in ipairs(stats) do
        local text = stat.label .. "  " .. stat.value
        local text_width = GuiGetTextDimensions(module.gui, text, text_scale)
        if text_width > max_text_width then
            max_text_width = text_width
        end
    end

    -- Adjust panel width based on the widest label-value pair
    panel_width = math.max(panel_width, max_text_width + 20) -- Adding padding
    local panel_x = (screen_width / 2) - (panel_width / 2)
    local panel_y = (screen_height / 2) - (panel_height / 2) + 20

    -- Calculate the x position to center the longest line
    local x_text = panel_x + (panel_width - max_text_width) / 2

    module.StartGUIFrame()

    print(tostring(module.gui) .. " rendering nine piece image " .. tostring(module.gui_id))
    
    -- Draw the background panel at the centered position
    GuiImageNinePiece(module.gui, module.get_id(), panel_x, panel_y, panel_width, panel_height, 1, module.img_container)

    print("just rendered [" .. tostring(module.gui) .. "] [" .. tostring(module.get_id()) .. "] [" .. tostring(panel_x) .. "] [" .. tostring(panel_y) .. "] [" .. tostring(panel_width) .. "] [" .. tostring(panel_height) .. "] [1] [" .. tostring(module.img_container) .. "]")
    -- Draw the img_game_over JUST at the top of the background panel
    GuiImage(module.gui, module.get_id(), panel_x-46, panel_y - 58, module.img_game_over, 0.85, 1, 1, 0)


    -- Set initial y position for the labels and values
    local y_offset = panel_y + 6

    
    -- Draw the "Cause of death" label at the top, centered
    local death_cause_text = "Cause of death: " .. "'" ..  "Unknown" .. "'" -- "module.grabbed_stats["Cause of death"]" .. "'" .. " test: ".. StatsGetValue("killed_by")
    local death_cause_x = panel_x + (panel_width - GuiGetTextDimensions(module.gui, death_cause_text, text_scale)) / 2
    GuiText(module.gui, death_cause_x, y_offset, death_cause_text, text_scale)
    
    y_offset = y_offset + common_spacing + 2

    -- Draw each line of stats in the panel, aligned with the longest line
    for _, stat in ipairs(stats) do
        local text = stat.label .. "  " .. stat.value
        GuiText(module.gui, x_text, y_offset, text, text_scale)
        y_offset = y_offset + common_spacing
    end

    -- Buttons for "New Game", "Progress", "Quit" at the bottom of the panel
    y_offset = y_offset + common_spacing
    
     -- Calculate each button's centered x position individually
     local new_game_text_width = GuiGetTextDimensions(module.gui, "New Game", text_scale)
     local progress_text_width = GuiGetTextDimensions(module.gui, "Progress", text_scale)
     local quit_text_width = GuiGetTextDimensions(module.gui, "Quit", text_scale)
     local end_run_text_width = GuiGetTextDimensions(module.gui, "End Run", text_scale)
 
     local new_game_x = panel_x + (panel_width - new_game_text_width) / 2
     local progress_x = panel_x + (panel_width - progress_text_width) / 2
     local quit_x = panel_x + (panel_width - quit_text_width) / 2
     local end_run_x = panel_x + (panel_width - end_run_text_width) / 2
 
     -- Render each button centered individually
    --  if GuiButton(gui, 100, new_game_x, y_offset, "New Game", text_scale) then
    --     response_handler(player, "NewGame", gui)
    --  end
    --  if GuiButton(gui, 101, progress_x, y_offset + common_spacing, "Progress", text_scale) then
    --     response_handler(player, "Progress", gui)
    --  end
    --  if GuiButton(gui, 102, quit_x, y_offset + common_spacing * 2, "Quit", text_scale) then
    --     response_handler(player, "Quit", gui)
    --  end

     if GuiButton(module.gui, module.get_id(), end_run_x, y_offset + common_spacing, "End Run", text_scale) then
        module.response_handler("EndRun")
     end

     -- put a "Bullshit!" clickable button at the bottom right corner in really small font
    local bullshit_text = "Bullshit!"
    local bullshit_text_scale = 0.6
    local bullshit_text_width, bullshit_text_height = GuiGetTextDimensions(module.gui, bullshit_text, bullshit_text_scale)
    local bullshit_x = panel_x + panel_width - bullshit_text_width + 1
    local bullshit_y = panel_y + panel_height - bullshit_text_height + 2

    if GuiButton(module.gui, module.get_id(), bullshit_x, bullshit_y, bullshit_text, bullshit_text_scale) then
        module.response_handler("Respawn")
    end
end

function module.hide()
    module.pause.unpause_game(true)
    module.DestroyGUI()
end

-- Function to retrieve total play time
function module.get_play_time()
    return string.format("%02d:%02d:%02d", math.floor(GameGetRealWorldTimeSinceStarted() / 3600), math.floor((GameGetRealWorldTimeSinceStarted() % 3600) / 60), GameGetRealWorldTimeSinceStarted() % 60)
end

-- Function to get depth (assuming it can be derived from player position)
function module.get_depth(player)
    local _, y = StatsGetValue("death_pos")
    if y == nil or y == 0 then
        y = 0.0000001
    end
    return math.floor(y / 10) .. "m"  -- Example conversion to depth units
end

-- Retrieve end-game stats as a table (WIP)
function module.grab_stats(player)
    
    if not player then
        print("Player entity not found!")
        return {}
    end

    -- Build the stats table with actual data retrievals
    local stats = {
        ["Mods enabled"] = "Yes",
        ["Gold"] = StatsGetValue("gold"),
        --["Time"] = StatsGetValue ("playtime_str"),
        ["Time"] = module.get_play_time(),
        ["Depth"] = module.get_depth(player),
        ["Places visited"] = StatsGetValue("places_visited"),
        ["Enemies slain"] = StatsGetValue("enemies_killed"),
        ["Max HP"] = StatsGetValue("hp"),
        ["Items found"] = StatsGetValue("items"),
        ["Total deaths"] = StatsGetValue("death_count"),
        ["Total wins"] = StatsGetValue("streaks"),
        ["Cause of death"] = StatsGetValue("killed_by")
    }

    return stats
end

return module
