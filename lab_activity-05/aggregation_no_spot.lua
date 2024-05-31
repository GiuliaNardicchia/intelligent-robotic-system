local potential_field = require "potential_field"
local vector = require "vector"
local robotUtilities = require "utilities"

local MOVE_STEPS = 15
local MAX_VELOCITY = 15
local MAXRANGE = 30

local PSmax = 0.99
local PWmin = 0.005
local alpha = 0.1
local beta = 0.05
local S = 0.01
local W = 0.1
local N = 0
local D = 1.2

RobotState = {
	WANDER = 0,
	STOP = 1
}

local n_steps = 0
local robot_state = RobotState.WANDER
local random_angle = 0
local L = 0

function CountRAB()
    local number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
    -- for each robot seen, check if it is close enough.
        if robot.range_and_bearing[i].range < MAXRANGE and
        robot.range_and_bearing[i].data[1]==1 then
        number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

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

local function random_walk()
    if n_steps % MOVE_STEPS == 0 then
        random_angle = robot.random.uniform(-math.pi/5,math.pi/5)
    end
    return potential_field.uniform_field(1, random_angle)
end

local function collision_avoidance()
    local proximity_idx = robotUtilities.search_highest_value(robot.proximity)
    local translational_v = robot.proximity[proximity_idx].value*D
    local angular_v = robot.proximity[proximity_idx].angle
    return potential_field.repulsive_field(translational_v, angular_v, D)
end

local function wander_walk()
    local result_vector = vector.vec2_polar_sum(collision_avoidance(), random_walk())
    result_vector = vector.vec2_polar_sum(result_vector, potential_field.uniform_field(2, 0))
    local left_v, right_v = converter_from_rototransational_to_differential(result_vector.length, result_vector.angle)
    local scaled_left_v, scaled_right_v =  multiplier(left_v, right_v, MAX_VELOCITY)
    robot.wheels.set_velocity(scaled_left_v, scaled_right_v)
end

local function stop()
    robot.wheels.set_velocity(0,0)
end

function init()
	n_steps = 0
    L = robot.wheels.axis_length
	robot_state = RobotState.WANDER
    robot.range_and_bearing.set_data(1,0)
end

function step()
	n_steps = n_steps + 1
    
    N = CountRAB()
    local Ps = math.min(PSmax,S+alpha*N)
    local Pw = math.max(PWmin,W-beta*N)
    local p = Ps/(Ps+Pw)

    local t = robot.random.uniform()
    if t <= p then
        robot_state = RobotState.STOP
        robot.range_and_bearing.set_data(1,1)
    else
        robot_state = RobotState.WANDER
        robot.range_and_bearing.set_data(1,0)
    end


	if robot_state == RobotState.WANDER then
		log("WANDER")
		robot.leds.set_all_colors("green")

        wander_walk()
		
	elseif robot_state == RobotState.STOP then
		log("STOP")
		robot.leds.set_all_colors("red")

        stop()
	end
end

function reset()
	n_steps = 0
    L = robot.wheels.axis_length
	robot_state = RobotState.WANDER
    robot.range_and_bearing.set_data(1,0)
end

function destroy()

end
