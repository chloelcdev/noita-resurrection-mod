local player = nil
local death_popup = dofile_once("mods/noita_resurrection_mod/files/scripts/death_popup.lua")
local health_util = dofile_once("mods/noita_resurrection_mod/files/scripts/health_util.lua")
local player_util = dofile_once("mods/noita_resurrection_mod/files/scripts/player_util.lua")
modal = dofile_once("mods/noita_resurrection_mod/files/scripts/modal_util.lua")

local settings_util = dofile_once("mods/noita_resurrection_mod/files/scripts/settings_util.lua")("noita_resurrection_mod", {
    default_health = 33,
    use_percentage_health = false,
    mod_disabled = false,
    pause_disabled = false,
    entangled_worlds_mode = false
})

local function call_module_on_world_post_updates()
    death_popup.on_world_post_update()
    player_util.process()
    modal.on_world_post_update()
end

function OnPausedChanged( is_paused, is_inventory_pause )
    settings_util.on_paused_changed(is_paused, is_inventory_pause)
end

-- Check if resurrection has been declined. 
-- If so, we've clicked the "End Run" button, and we need to make sure the player DIES dies. 
-- This is more a safety check than anything and can likely be taken out eventually
local function has_declined_resurrection()
    return GlobalsGetValue("resurrection_declined", "false") == "true"
end

-- Set if resurrection has been declined
local function set_declined_resurrection(value)
    GlobalsSetValue("resurrection_declined", tostring(value))
end


-- Health check and popup trigger
local function check_for_player_death()

    if not player_util.local_player or has_declined_resurrection() then return end

    local hp = ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(player_util.local_player, "DamageModelComponent"), "hp")
    if hp ~= nil and hp <= 0 then
        --print("health dropped below 0")
        health_util.set_health(player_util.local_player, 1) -- just keep us alive
        death_popup.show(player_util.local_player, settings_util.settings.pause_disabled)
    end
end

-- keeps our player variable up to date each WorldUpdate
local function grant_player_immunity()
    if player_util.local_player ~= nil then
        local damage_model = EntityGetFirstComponent(player_util.local_player, "DamageModelComponent")
        if damage_model and not has_declined_resurrection() then
            ComponentSetValue2(damage_model, "wait_for_kill_flag_on_death", true)
        end
    end
end


function OnWorldPostUpdate()
    if settings_util.settings.mod_disabled then
        return
    end

    call_module_on_world_post_updates()
    grant_player_immunity()
    
    if not death_popup.is_showing then
        check_for_player_death()
    end
end



function OnPlayerSpawned(player)

    -- unpause the game when we start, in case a crash happened or something while it was paused
    death_popup.pause.unpause_game(true)
 
    death_popup.set_response_handler( function (response)

        --print("button clicked: " .. tostring(response))

        if response == "Respawn" then
            are_you_sure_continue()
        elseif response == "EndRun" then
            do_endrun()
        end
    end)

end

function do_respawn()
    player_util.process() -- just for safety, make sure we have the local player grabbed
    death_popup.hide()
    set_declined_resurrection(false)
    health_util.set_health(player_util.local_player, settings_util.settings.default_health)
end

function do_endrun()
    player_util.process() -- just for safety, make sure we have the local player grabbed
    death_popup.hide()
    set_declined_resurrection(true)
    local damage_model = EntityGetFirstComponent(player_util.local_player, "DamageModelComponent")
    ComponentSetValue2(damage_model, "kill_now", true)
    ComponentSetValue2(damage_model, "wait_for_kill_flag_on_death", false)
    EntityInflictDamage(player_util.local_player, 1000000, "DAMAGE_CURSE", tostring(death_popup.stats.grabbed_stats["Cause of death"]), "NONE", 0, 0, GameGetWorldStateEntity())
    GameTriggerGameOver()
end

function are_you_sure_continue()
    player_util.process() -- just for safety, make sure we have the local player
    print("continue")
    modal.open(
        "Are you sure you want to resurrect? This is Noita blasphemy.",
        "The gods can burn.",
        do_respawn,
        "No.",
        nil
    )
end