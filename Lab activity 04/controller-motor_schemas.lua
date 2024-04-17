local vector = require "vector"
local robotUtilities = require "utilities"
local performance = require "performance"
local potential_field = require "potential_field"

local MOVE_STEPS = 10
local MAX_VELOCITY = 15
local LIGHT_THRESHOLD = 0.01
local PROXIMITY_THRESHOLD = 0.1
local NOISE_THRESHOLD = 0.01
local L = 0
local D = 5

local n_steps = 0
local random_angle = 0

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


function init()
    L = robot.wheels.axis_length -- distance between the two wheels
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
    robot.wheels.set_velocity(left_v,right_v)
    n_steps = 0
end


function step()
    n_steps = n_steps + 1

    -- read the sensors and look for the highest value
    local light_idx = robotUtilities.search_highest_value(robot.light)
    local proximity_idx = robotUtilities.search_highest_value(robot.proximity)

    log("L: "..robot.light[light_idx].value)
    log("P:"..robot.proximity[proximity_idx].value)

    -- ATTRACTIVE_FIELD
    local light_vector = potential_field.attractive_field(robot.light[light_idx].value*D, robot.light[light_idx].angle, D)
    -- REPULSIVE FIELD
    local proximity_vector = potential_field.repulsive_field(robot.proximity[proximity_idx].value*D, robot.proximity[proximity_idx].angle, D)
    -- TANGENTIAL FIELD
    local tangential_vector = potential_field.tangential_field(2, robot.proximity[proximity_idx].angle)

    -- sum of the potential field
    local result_vector = vector.vec2_polar_sum(light_vector, proximity_vector)
    result_vector = vector.vec2_polar_sum(result_vector, tangential_vector)

    -- if the light is detected and there are no obstacle in the proximity
    if robot.light[light_idx].value > LIGHT_THRESHOLD and robot.proximity[proximity_idx].value < PROXIMITY_THRESHOLD then
        -- UNIFORM FIELD
        local uniform_vector = potential_field.uniform_field(2, robot.light[light_idx].angle)
        result_vector = vector.vec2_polar_sum(result_vector, uniform_vector)
        -- if the linght is not detected
    elseif robot.light[light_idx].value < NOISE_THRESHOLD then
        -- RANDOM FIELD
        if n_steps % MOVE_STEPS == 0 then
            random_angle = robot.random.uniform(-math.pi/5,math.pi/5)
        end
        local random_vector = potential_field.uniform_field(1, random_angle)
        result_vector = vector.vec2_polar_sum(result_vector, random_vector)
    end

    -- conversion from roto-transactional to differential movement
    local left_v, right_v = converter_from_rototransational_to_differential(result_vector.length, result_vector.angle)

    -- left and right velocity multiplied for a multiplier factor
    local scaled_left_v, scaled_right_v = multiplier(left_v, right_v, MAX_VELOCITY)
    -- set velocities for the attuators
    robot.wheels.set_velocity(scaled_left_v, scaled_right_v)
end


function reset()
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
    robot.wheels.set_velocity(left_v,right_v)
    n_steps = 0
end


function destroy()
    local light_position = {x = 2, y = 0}
    local robot_position = {x = robot.positioning.position.x, y = robot.positioning.position.y, z = robot.positioning.position.z}
    local euclidean_distance = performance.euclidean_distance(robot_position.x, robot_position.y, light_position.x, light_position.y)

    log("euclidean_distance: " .. euclidean_distance)
    log("n_steps: " .. n_steps)
    log("robot.position.x = " .. robot_position.x)
    log("robot.position.y = " .. robot_position.y)
    log("robot.position.z = " .. robot_position.z)
end
