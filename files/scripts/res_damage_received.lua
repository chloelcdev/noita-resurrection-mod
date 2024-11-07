
local storage_comp = nil

function damage_received( damage, message, attacker, is_fatal, projectile )

    local info = {damage, message, attacker, tostring(is_fatal), projectile} -- pack all the args in a table
    local info_string = table.concat(info, ";") -- divide the args with ;

    local entity_id = GameGetWorldStateEntity()
    
    local storage = get_or_add_variable_storage( entity_id )

    ComponentSetValue2( storage, "name", "last_hit_info")
    ComponentSetValue2( storage, "value_string", info_string)
end

function get_or_add_variable_storage( entity_id )

    if storage_comp ~= nil then
        return storage_comp
    end

    -- if we can't find (and return) a variable storage component with the name "lastAttacker", create one and return that
    local components = EntityGetComponent( entity_id, "VariableStorageComponent" )

    if components ~= nil then
        for i, component in ipairs(components) do
            if ComponentGetValue2( component, "name" ) == "last_hit_info" then
                storage_comp = component
                return storage_comp
            end
        end
    end

    storage_comp = EntityAddComponent2( entity_id, "VariableStorageComponent", {
        name = "last_hit_info",
        value_string = ""
    })

    return storage_comp
end

-- luacomps being added too much
--675646335