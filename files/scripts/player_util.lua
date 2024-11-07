-- Usage notes: call on_world_post_update() in OnWorldPostUpdate()

local module = {}

module.all_players = {}

module.local_player = nil
module.other_players = {}

-- must be called in OnWorldPostUpdate if you want to use the local_player, other_players, or all_players tables, otherwise you can still use the functions
module.process = function()
    module.find_all_players()
    module.filter_players(module.all_players)
end

-- returns the local player and other players in the game
module.filter_players = function(player_list)
    local others = {}

    for _, player in ipairs(player_list) do
        if module.is_local_player(player) then
            module.local_player = player
        else
            table.insert(others, player)
        end
    end

    module.other_players = others

    return module.local_player, module.other_players -- just returning these for convenience
end

-- returns a table of all player entities, which will also be stored in module.all_players
module.find_all_players = function()
    local player_units = EntityGetWithTag("player_unit")
    local polymorphed_players = EntityGetWithTag("polymorphed_player")

    local players = {}

    for _, player in ipairs(player_units) do
        table.insert(players, player)
    end

    for _, player in ipairs(polymorphed_players) do
        table.insert(players, player)
    end

    module.all_players = players
    return players
end

module.is_local_player = function(player_entity)
    
    local has_player_tag = EntityHasTag(player_entity, "player_unit") -- IS the local player if we're human

    local has_polymorphed_tag = EntityHasTag(player_entity, "polymorphed_player") -- COULD BE the local player if we're polymorphed

    local has_client_tag = EntityHasTag(player_entity, "ew_client") -- exists on all non-local players, polymorphed or not

    return (has_player_tag or has_polymorphed_tag) and not has_client_tag
end

return module