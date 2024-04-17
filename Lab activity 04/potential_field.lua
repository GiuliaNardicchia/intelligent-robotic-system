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
    repulsive_field = repulsive_field,
    attractive_field = attractive_field,
    tangential_field = tangential_field,
    uniform_field = uniform_field
}