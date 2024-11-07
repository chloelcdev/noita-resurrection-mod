-- Usage notes: Call module.grab_stats(player) whenever you want it to grab the latest stats. They'll be stored in module.grabbed_stats

-- it will return the just-grabbed stats table for convenience.

local module = {
    player_util = dofile_once("mods/noita_resurrection_mod/files/scripts/player_util.lua"),

    grabbed_stats = {
        ["Cause of death"] = nil,
        ["Mods enabled"] = "Yes",
        ["Gold"] = 0,
        ["Time"] = "00:00:00",
        ["Depth"] = "0m",
        ["Places visited"] = 0,
        ["Enemies slain"] = 0,
        ["Max HP"] = 0,
        ["Items found"] = 0,
        --["Total deaths"] = 0,
        --["Total wins"] = 0,
    },

    lowest_depth = 0,
}

function module.ensure_player()

    if module.player_util.local_player == nil then
        module.player_util.process()

        -- put a LuaComponent on the player entity that gives us a damage event
        if module.player_util.local_player ~= nil then
            -- try to find an existing luacomp with that script first
            local luacomps = EntityGetComponent(module.player_util.local_player, "LuaComponent")
            if luacomps then
                for _, comp in ipairs(luacomps) do
                    if ComponentGetValue2(comp, "script_damage_received") == "mods/noita_resurrection_mod/files/scripts/res_damage_received.lua" then
                        return module.player_util.local_player
                    end
                end
            end


            EntityAddComponent2(module.player_util.local_player, "LuaComponent", {
                script_damage_received = "mods/noita_resurrection_mod/files/scripts/res_damage_received.lua",
                execute_every_n_frame = -1,
            })
        end
    end
    return module.player_util.local_player
end


function module.get_depth()
    if not module.player_util.local_player then
        print("Player entity not found! 1")
        return 0
    end

    local x, y = EntityGetTransform(module.player_util.local_player)

    if y == nil then
        return "0m"
    end

    local current_depth = math.max(0, math.floor(y/10))

    module.lowest_depth = math.max(current_depth, module.lowest_depth)

    return tostring(current_depth) .. "m"
end

function module.get_gold()
-- check the players WalletComponent
    local wallet = EntityGetFirstComponentIncludingDisabled(module.player_util.local_player, "WalletComponent")
    local gold = 0
    
    if wallet then
        gold = ComponentGetValue2(wallet, "money")
    end

    return gold
end

function module.get_max_hp()
    
    local damage_model = EntityGetFirstComponentIncludingDisabled(module.player_util.local_player, "DamageModelComponent")

    if damage_model then
        
        -- every 4 numbers = 100 health
        return ComponentGetValue2(damage_model, "max_hp") * (100/4)
    end

    return 0
end

function module.get_death_cause()
    -- Retrieve last attacker information
    local storages = EntityGetComponent(GameGetWorldStateEntity(), "VariableStorageComponent")

    if storages == nil then
        return nil
    end

    for _, storage in ipairs(storages) do
        if ComponentGetValue2(storage, "name") == "last_hit_info" then
            
            local info_string = ComponentGetValue2(storage, "value_string")

            local raw_info = {}

            for piece in string.gmatch(info_string, "([^;]+)") do
                table.insert(raw_info, piece)
            end



            local is_fatal = string.lower(raw_info[4]) == "true"
            local damage = tonumber(raw_info[1])

            local message = raw_info[2]
            local trans_msg = GameTextGetTranslatedOrNot(message)


            local attacker_name = ""

            local attacker_id = tonumber(raw_info[3])
            local attacker_ent_name = EntityGetName(attacker_id)
            if attacker_ent_name ~= nil and attacker_id ~= 0 then
                attacker_name = GameTextGetTranslatedOrNot(attacker_ent_name)
                --print(attacker_name)
            end

            local div = "'"
            
            local projectile_name = ""

            local projectile_id = tonumber(raw_info[5])
            local projectile_ent_name = EntityGetName(projectile_id)
            if projectile_ent_name ~= nil and projectile_id ~= 0 then
                projectile_name = GameTextGetTranslatedOrNot(projectile_ent_name)
                --print(projectile_name)
            end

            if string.sub(attacker_name, -1) ~= "s" then div = div .. "s" end
            div = div .. " "
            
            -- to avoid                           Cause of death: ''s explosion'
            if attacker_name == "" then
                div = ""
            end

            return attacker_name .. div .. trans_msg .. projectile_name

        end
    end

    return nil
end

-- Function to split the string into a table
function split_to_table(input, separator)
    local t = {}
    
    -- Iterate through each segment divided by sep
    for str in string.gmatch(input, "([^"..separator.."]+)") do
        table.insert(t, str)
    end
    
    return t
end


-- Retrieve (as many as possible) end-game stats as a table
function module.grab_stats()
    module.ensure_player()


    -- Update the stats table with actual data retrievals

    module.grabbed_stats["Cause of death"] = module.get_death_cause() or module.grabbed_stats["Cause of death"]

    module.grabbed_stats["Mods enabled"] = "Yes"
    module.grabbed_stats["Gold"] = module.get_gold()
    module.grabbed_stats["Time"] = StatsGetValue("playtime_str")
    module.grabbed_stats["Depth"] = module.get_depth()
    module.grabbed_stats["Places visited"] = StatsGetValue("places_visited")
    module.grabbed_stats["Enemies slain"] = StatsGetValue("enemies_killed")
    module.grabbed_stats["Max HP"] = module.get_max_hp()
    module.grabbed_stats["Items found"] = StatsGetValue("items")
    --stats["Total deaths"] = StatsGetValue("death_count")
    --stats["Total wins"] = StatsGetValue("streaks")

    --print(#module.grabbed_stats .. "  " .. module.grabbed_stats["Mods enabled"])

    return module.grabbed_stats
end

return module