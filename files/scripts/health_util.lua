local module = {}

-- These are human readable versions. 
-- Health normally follows a 4:100 ratio, so 1 = 25 hp, 4 = 100 hp.
-- These account for that so we don't have to deal with it (doing the math each time looks ugly)

module.get_health = function(entity)
    local damage_model = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if damage_model == nil then return end
    return ComponentGetValue2(damage_model, "hp")
end

module.get_max_hp = function(entity)
    local damage_model = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if damage_model == nil then return end
    return ComponentGetValue2(dmg_model, "max_hp")
end

module.set_health = function(entity, health)
    local damage_model = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if damage_model == nil then return end
    ComponentSetValue2(damage_model, "hp", health)
end

module.set_max_hp = function(entity, max_hp)
    local damage_model = EntityGetFirstComponentIncludingDisabled(entity, "DamageModelComponent")
    if damage_model == nil then return end
    ComponentSetValue2(damage_model, "max_hp", max_hp)
end

return module