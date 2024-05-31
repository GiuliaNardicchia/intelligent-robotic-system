
-- | l_v | = | 1 -L/2 | | v |
-- | r_v | = | 1  L/2 | | w |
--- Converter from roto-transational movement to differential movement.
---@param translational_v any
---@param angular_v any
local function converter_from_rototransational_to_differential(translational_v, angular_v)
    local left_v = (1 * translational_v) + (- L/2 * angular_v)
    local right_v = (1 * translational_v) + (L/2 * angular_v)
    return left_v, right_v
end

--- Multiplier factor to increase the velocity mantaining the proportion between the two wheels.
---@param velocity1 any
---@param velocity2 any
---@param multiplier_factor any
local function multiplier(velocity1, velocity2, multiplier_factor)
    local max = math.max(velocity1, velocity2)
    local multiplier = multiplier_factor / max
    return velocity1 * multiplier, velocity2 * multiplier
end

--- Behaviour: obstacle avoidance --> Potential field: repulsive.
---@param distance any
---@param angle any
---@param D any
local function repulsive_field(distance, angle, D)
    local length = 0
    if distance <= D then
        length = (D - distance) / D
    end
    return { length = length, angle = -angle }
end

--- Behaviour: phototaxis --> Potential field: attractive.
---@param distance any
---@param angle any
---@param D any
local function attractive_field(distance, angle, D)
    local length = 0
    if distance <= D then
        length = (D - distance) / D
    end
    return { length = length, angle = angle }
end

--- Behaviour: directing the robot around an obstacle --> Potential field: tangential.
---@param distance any
---@param angle any
local function tangential_field(distance, angle)
    return { length = distance, angle = angle + math.pi/2 }
end

--- Behaviour: directing the robot in a certain direction --> Potential field: uniform.
---@param distance any
---@param angle any
local function uniform_field(distance, angle)
    return { length = distance, angle = angle }
end

return {
    converter_from_rototransational_to_differential = converter_from_rototransational_to_differential,
    multiplier = multiplier,
    repulsive_field = repulsive_field,
    attractive_field = attractive_field,
    tangential_field = tangential_field,
    uniform_field = uniform_field
}