-- Usage: 

-- only functions you need to know:

-- module.pause_game(player)
-- module.unpause_game(player)

-- it is recommended you unpause the game in OnPlayerSpawn, in case a crash happened or something while it was paused



local module = {}

module.is_paused = false

function module.get_or_add_component_storage(entity, component_name)
    local variable_storage_name = "paused_" .. component_name
    for _, comp in ipairs(EntityGetComponent(entity, "VariableStorageComponent") or {}) do
        if ComponentGetValue2(comp, "name") == variable_storage_name then
            return comp
        end
    end
    return EntityAddComponent2(entity, "VariableStorageComponent", {
        name = variable_storage_name,
        value_string = "",
    })
end

function module.store_pause_values(varStorage, entity, componentToStore, fields)

    local currentStoredVal = ComponentGetValue2(varStorage, "value_string")

    if currentStoredVal == "" or currentStoredVal == nil then

        local finalStoredVal = ""

        for i, field in ipairs(fields) do
            local field_name, field_val, should_store = unpack(field)
            local val = nil

            if field_name == "Enabled" then
                val = ComponentGetIsEnabled(componentToStore)
            else
                val = ComponentGetValue2(componentToStore, field_name)
            end

			if should_store then
            	finalStoredVal = finalStoredVal .. tostring(val)

				if i < #fields then
					finalStoredVal = finalStoredVal .. ";"
				end
			end

			if field_name == "Enabled" then
				EntitySetComponentIsEnabled(entity, componentToStore, field_val)
			else
				ComponentSetValue2(componentToStore, field_name, field_val)
			end
        end

        ComponentSetValue2(varStorage, "value_string", finalStoredVal)
    end
end

function module.do_parse(str)
    if string.lower(str) == 'true' then return true end
    if string.lower(str) == 'false' then return false end
    local asNumber = tonumber(str)
    return asNumber ~= nil and asNumber or str
end

function module.load_pause_values(varStorage, entity, componentToStore, fields)

    local currentVal = ComponentGetValue2(varStorage, "value_string")
    if currentVal ~= "" and currentVal ~= nil then

        local values = {}
        for value in string.gmatch(currentVal, "([^;]+)") do
            table.insert(values, value)
        end

        for i, field in ipairs(fields) do
            local field_name, _, should_load = unpack(field)
			
            if should_load then
                if field_name == "Enabled" then
                    EntitySetComponentIsEnabled(entity, componentToStore, module.do_parse(values[i]))
                else
                    ComponentSetValue2(componentToStore, field_name, module.do_parse(values[i]))
                end
            end
        end

        EntityRemoveComponent(entity, varStorage)
    end
end

-- fields is: name, value, should_store
function module.affect_paused_comp_field(entity, component, pause, fields)

    local varStorage = module.get_or_add_component_storage(entity, ComponentGetTypeName(component))

    if pause then
        module.store_pause_values(varStorage, entity, component, fields)
    else
        module.load_pause_values(varStorage, entity, component, fields)
    end
end








function module.comp_func_toggle_whole_component(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"Enabled", false, true}
    })
end

function module.comp_func_toggle_velocity_component(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"mVelocity_x", 0, true},
        {"mVelocity_y", 0, true},
    })
end

function module.comp_func_toggle_player_controls(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"enabled", false, true},
        {"mButtonDownAction", false, false},
		{"mButtonDownChangeItemL", false, false},
		{"mButtonDownChangeItemR", false, false},
		{"mButtonDownDig", false, false},
		{"mButtonDownDown", false, false},
		{"mButtonDownDropItem", false, false},
		{"mButtonDownEat", false, false},
		{"mButtonDownFire", false, false},
		{"mButtonDownFire2", false, false},
		{"mButtonDownFly", false, false},
		{"mButtonDownHolsterItem", false, false},
		{"mButtonDownInteract", false, false},
		{"mButtonDownInventory", false, false},
		{"mButtonDownJump", false, false},
		{"mButtonDownKick", false, false},
		{"mButtonDownLeft", false, false},
		{"mButtonDownLeftClick", false, false},
		{"mButtonDownRight", false, false},
		{"mButtonDownRightClick", false, false},
		{"mButtonDownRun", false, false},
		{"mButtonDownThrow", false, false},
		{"mButtonDownTransformDown", false, false},
		{"mButtonDownTransformLeft", false, false},
		{"mButtonDownTransformRight", false, false},
		{"mButtonDownTransformUp", false, false},
        {"mButtonDownUp", false, false}
    })
end

function module.comp_func_toggle_pathfinding(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"can_fly", false, true},
        {"can_walk", false, true},
        {"can_jump", false, true},
        {"can_dive", false, true},
        {"can_swim_on_surface", false, true}
    })
end

function module.comp_func_toggle_damage_model(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"materials_damage", false, true},
        --{"materials_that_damage", "", true},
        --{"materials_how_much_damage", "", true},
        {"fire_damage_amount", 0, true},
		{"air_needed", false, true},
		{"falling_damages", false, true},
        {"fire_probability_of_ignition", 0, true},
        {"fire_how_much_fire_generates", 0, true},
        {"in_liquid_shooting_electrify_prob", 0, true},
        {"wet_status_effect_damage", 0, true},
        {"in_liquid_shooting_electrify_prob", 0, true},

    })
end

function module.comp_func_toggle_animal_ai(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"attack_melee_enabled", false, true},
        {"attack_dash_enabled", false, true},
        {"attack_ranged_enabled", false, true},
        {"attack_landing_ranged_enabled", false, true},
        {"attack_ranged_use_message", false, true},
        {"sense_creatures", false, true},
        {"can_walk", false, true}
    })
end

function module.comp_func_toggle_char_platforming(entity, component, pause)
    module.affect_paused_comp_field(entity, component, pause, {
        {"jump_velocity_x", 0, true},
        {"jump_velocity_y", 0, true},
        {"fly_speed_mult", 0, true},
        {"accel_x", 0, true},
        {"accel_x_air", 0, true},
        {"pixel_gravity", 0, true},

		
        {"velocity_min_x", 0, true},
        {"velocity_min_y", 0, true},
        {"velocity_max_y", 0, true},
        {"velocity_max_x", 0, true},
        {"run_velocity", 0, true},
        {"fly_velocity_x", 0, true},
        {"fly_speed_max_up", 0, true},
        {"fly_speed_max_down", 0, true},
    })
end










module.disallowed_components = {
    AnimalAIComponent = module.comp_func_toggle_animal_ai,
    VelocityComponent = module.comp_func_toggle_velocity_component,
    DamageModelComponent = module.comp_func_toggle_damage_model,
    PathFindingComponent = module.comp_func_toggle_pathfinding,
	SpriteAnimatorComponent = module.comp_func_toggle_whole_component,
	CharacterPlatformingComponent = module.comp_func_toggle_char_platforming,
    ControlsComponent = module.comp_func_toggle_player_controls,
	CharacterDataComponent = module.comp_func_toggle_whole_component,
	WalletComponent = module.comp_func_toggle_whole_component,
	StatusEffectDataComponent = module.comp_func_toggle_whole_component,
	ParticleEmitterComponent = module.comp_func_toggle_whole_component,
	MaterialSuckerComponent = module.comp_func_toggle_whole_component,
	LiquidDisplacerComponent = module.comp_func_toggle_whole_component,
	KickComponent = module.comp_func_toggle_whole_component,
	ItemPickUpperComponent = module.comp_func_toggle_whole_component,
	InventoryGuiComponent = module.comp_func_toggle_whole_component,
	GunComponent = module.comp_func_toggle_whole_component,
	GameEffectComponent = module.comp_func_toggle_whole_component,
    SimplePhysicsComponent = module.comp_func_toggle_whole_component,
    PixelSpriteComponent = module.comp_func_toggle_whole_component,
    --LuaComponent = module.comp_func_toggle_whole_component, -- probably not
}

-- Recursively toggle disallowed components for an entity and its children using the registered toggle function for that component type
function module.toggle_components_recursively(entity, pause)
    if not entity then return end

    -- Toggle components for the current entity
    local all_comps = EntityGetAllComponents(entity)
    if all_comps then
        for _, component in ipairs(all_comps) do
            local component_name = ComponentGetTypeName(component)
            local toggle_func = module.disallowed_components[component_name]
            if toggle_func then
                toggle_func(entity, component, pause)
            end
        end
    end

    -- Recursively process child entities
    local children = EntityGetAllChildren(entity) or {}
    for _, child in ipairs(children) do
        module.toggle_components_recursively(child, pause)
    end
end

function module.pause_entity(entity)
    --print("pausing entity [" .. tostring(entity) .. "] " .. EntityGetName(entity))
    EntityAddTag(entity, "fake_paused_entity")
    module.toggle_components_recursively(entity, true)
end

function module.unpause_entity(entity)
    --print("unpausing entity [" .. tostring(entity) .. "] " .. EntityGetName(entity))
    module.toggle_components_recursively(entity, false)
    EntityRemoveTag(entity, "fake_paused_entity")
end

function module.pause_game(player)
    if not module.is_paused then
        module.is_paused = true
        if player then module.pause_entity(player) end
        for _, enemy in ipairs(EntityGetWithTag("enemy") or {}) do
            module.pause_entity(enemy)
        end
        for _, projectile in ipairs(EntityGetWithTag("projectile") or {}) do
            module.pause_entity(projectile)
        end
    end
end

function module.unpause_game(force)
    if module.is_paused or force then
        module.is_paused = false
        for _, paused_ent in ipairs(EntityGetWithTag("fake_paused_entity") or {}) do
            module.unpause_entity(paused_ent)
        end
    end
end


return module