-- mods/noita_resurrection_mod/files/scripts/game_info.lua

-- Required libraries, if available
dofile_once("data/scripts/lib/utilities.lua")

-- Function to retrieve Max HP (assuming 'max_hp' component is available)
function get_max_hp(player)
    local damagemodels = EntityGetComponent(player, "DamageModelComponent")
    if damagemodels ~= nil then
        for _, dmg_model in ipairs(damagemodels) do
            return ComponentGetValue2(dmg_model, "max_hp")
        end
    end
    return nil
end

-- Function to get current gold (assuming 'WalletComponent' is available)
function get_gold(player)
    local wallet = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
    if wallet ~= nil then
        return ComponentGetValue2(wallet, "money")
    end
    return 0
end

-- Function to retrieve total play time
function get_play_time()
    return GameGetRealWorldTimeSinceStarted()
end

-- Function to get depth (assuming it can be derived from player position)
function get_depth(player)
    local _, y = StatsGetValue("death_pos")
    if y == nil or y == 0 then
        y = 0.0000001
    end
    return math.floor(y / 10) .. "m"  -- Example conversion to depth units
end

-- Placeholder for total deaths; assuming this could be tracked in some component
function get_total_deaths(player)
    -- Replace with actual retrieval if the game tracks this directly
    return GlobalsGetValue("total_deaths", 0)
end

-- Placeholder for total wins; assuming this could be tracked in some component
function get_total_wins(player)
    -- Replace with actual retrieval if the game tracks this directly
    return GlobalsGetValue("total_wins", 0)
end

-- Placeholder for items found (assuming inventory tracking)
function get_items_found(player)
    return GlobalsGetValue("items_found", 0)
end

-- Function to retrieve player stats as a table
function grab_stats(player)
    
    if not player then
        print("Player entity not found!")
        return {}
    end

    -- Build the stats table with actual data retrievals
    local stats = {
        ["Mods enabled"] = "Yes",                     -- Hardcoded as example
        ["Gold"] = StatsGetValue("gold"),
        --["Time"] = StatsGetValue ("playtime_str"),
        ["Time"] = string.format("%02d:%02d:%02d", math.floor(get_play_time() / 3600), math.floor((get_play_time() % 3600) / 60), get_play_time() % 60),
        ["Depth"] = get_depth(player),
        ["Places visited"] = StatsGetValue("places_visited"),
        ["Enemies slain"] = StatsGetValue("enemies_killed"),
        ["Max HP"] = StatsGetValue("hp"),
        ["Items found"] = StatsGetValue("items"),
        ["Total deaths"] = StatsGetValue("death_count"),
        ["Total wins"] = StatsGetValue("streaks"),
        ["Cause of death"] = StatsGetValue("killed_by")  -- Placeholder
    }

    print(stats["Cause of death"])

    return stats
end
