-- block_death.lua

-- Load the popup module
local popup = dofile_once("mods/noita_resurrection_mod/files/scripts/death_popup.lua")

local player = nil
local default_health = ModSettingGet("noita_resurrection_mod.default_health_on_revive") or 100


function get_max_hp(player)
    local damagemodels = EntityGetComponent(player, "DamageModelComponent")
    if damagemodels ~= nil then
        for _, dmg_model in ipairs(damagemodels) do
            return ComponentGetValue2(dmg_model, "max_hp")
        end
    end
    return nil
end

-- Check if resurrection has been declined
local function has_declined_resurrection()
    return GlobalsGetValue("resurrection_declined", "false") == "true"
end

-- Set resurrection declined status
local function set_declined_resurrection(value)
    GlobalsSetValue("resurrection_declined", tostring(value))
end

-- Set player health
local function set_health(entity, health)
    local damage_model = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if damage_model then
        ComponentSetValue2(damage_model, "hp", health)
    end
end

-- Health check and popup trigger
local function check_player_health()

    if not player or has_declined_resurrection() then return end

    local hp = ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent"), "hp")
    if hp ~= nil and hp <= 0 then

        print("health dropped below 0")
        
        set_health(player, 4 / get_max_hp(player) * default_health)
        
        popup.show(player)-- Initialize player settings on load
    end
end

-- Update player reference on load
local function update_player_ref()
    local ply = EntityGetWithTag("player_unit")[1]
    if ply and ply ~= player then
        player = ply
        local damage_model = EntityGetFirstComponent(player, "DamageModelComponent")
        if damage_model and not has_declined_resurrection() then
            ComponentSetValue2(damage_model, "wait_for_kill_flag_on_death", true)
        end
    end
end

-- Event handling
function OnWorldPostUpdate()
    update_player_ref()

    popup.render_if_showing()
    
    -- checking the module isn't the BEST way but eh
    if not popup.is_showing then
        check_player_health()
    end
end

function OnPlayerSpawned()
    update_player_ref()

    -- unpause the game when we start, in case a crash happened or something while it was paused
    popup.pause.unpause_game(true)
 
    popup.set_response_handler( function (response)

        print("button clicked: " .. tostring(response))

        if response == "Respawn" then
            set_declined_resurrection(false)
            popup.hide()
            set_health(player, 4 / get_max_hp(player) * default_health)
        elseif response == "EndRun" then
            print("try to end run")
            popup.hide()
            set_declined_resurrection(true)
            local damage_model = EntityGetFirstComponent(player, "DamageModelComponent")
            ComponentSetValue2(damage_model, "kill_now", true)
            ComponentSetValue2(damage_model, "wait_for_kill_flag_on_death", false)
            EntityInflictDamage(player, 1000000, "DAMAGE_CURSE", popup.grabbed_stats["Cause of death"], "NONE", 0, 0, GameGetWorldStateEntity())
            GameTriggerGameOver()
        end
    end)

end

-- 1297461439 - easy LC