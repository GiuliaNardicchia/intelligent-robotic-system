local robotUtilities = require "utilities"

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 3.5
PROXIMITY_THRESHOLD = 0.6
NOISE_THRESHOLD = 0.05

local n_steps = 0

local function identify_objects_competence()
    log("REACHED_TARGET")
    robot.leds.set_all_colors("yellow")
    -- stop the robot
    robotUtilities.move(robot, robotUtilities.MovementType.STOP, nil, nil)
end

local function explore_competence()
    local sum_light_left, sum_light_right = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.HORIZONTAL_LEFT)
    local sum_light_front, sum_light_back = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.VERTICAL_FRONT)
    local total_light = sum_light_right + sum_light_left
    -- if the total light intensity reading exceeds a certain threshold
    if total_light > LIGHT_THRESHOLD then
        return identify_objects_competence()
    else
        log("SEARCHING_TARGET")
        robot.leds.set_all_colors("black")
        -- if the light intensity in front is greater than the light intensity at the back
        -- and there is no light detected at the back
        -- if sum_light_front > 1 and sum_light_back == 0 then
        if sum_light_front > 0 and sum_light_back < NOISE_THRESHOLD then
            -- move the robot forward at maximum velocity
            robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, MAX_VELOCITY, MAX_VELOCITY)
        else
            -- if the light intensity on the right side is greater than the left side
            if sum_light_right > sum_light_left then
                -- move the robot to the right at maximum velocity
                robotUtilities.move(robot, robotUtilities.MovementType.RIGHT, MAX_VELOCITY, nil)
            else
                -- move the robot to the left at maximum velocity
                robotUtilities.move(robot, robotUtilities.MovementType.LEFT, nil, MAX_VELOCITY)
            end
        end
    end
end

local function wander_competence()
    local sum_light_left, sum_light_right = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.HORIZONTAL_LEFT)
    local sum_light_front, sum_light_back = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.VERTICAL_FRONT)
    local total_light = sum_light_right + sum_light_left
    local proximity_front = robot.proximity[1].value + robot.proximity[24].value
    -- if neither the right nor left side detects any light
    -- and there are no obstacles detected in front
    local difference = math.abs(sum_light_front - sum_light_back)
    log("difference "..difference)
    log("sum_light_front "..sum_light_front)
    --if sum_light_left == 0 and sum_light_right == 0 and not(proximity_front > PROXIMITY_THRESHOLD) then
    if total_light < NOISE_THRESHOLD and not(proximity_front > PROXIMITY_THRESHOLD) then
        log("RANDOM_WALK")
        robot.leds.set_all_colors("green")

        if n_steps % MOVE_STEPS == 0 then
            -- generate random velocities for left and right wheels
            left_v = robot.random.uniform(0,MAX_VELOCITY)
            right_v = robot.random.uniform(0,MAX_VELOCITY)
        end
        -- move the robot forward with the calculated velocities
        robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
    else
        return explore_competence()
    end
end

local function obstacle_avoidance_competence()
    local sum_proximity_left, sum_proximity_right = robotUtilities.read_half_sensors(robot.proximity, robotUtilities.OrientationType.HORIZONTAL_LEFT)
    local total_proximity = sum_proximity_right + sum_proximity_left
    -- if the total proximity reading exceeds a certain threshold
    if total_proximity > PROXIMITY_THRESHOLD then
        log("OBSTACLE_AVOIDANCE")
        robot.leds.set_all_colors("red")
        -- if the proximity on the right side is greater than the left side
        if sum_proximity_right > sum_proximity_left then
            -- move the robot to the left at maximum velocity
            robotUtilities.move(robot, robotUtilities.MovementType.LEFT, nil, MAX_VELOCITY)
        else
            -- move the robot to the right at maximum velocity
            robotUtilities.move(robot, robotUtilities.MovementType.RIGHT, MAX_VELOCITY, nil)
        end
    else
        return wander_competence()
    end
end

function init()
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
    robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
    n_steps = 0
end


function step()
    n_steps = n_steps + 1
    obstacle_avoidance_competence()
    --[[log("robot.position.x = " .. robot.positioning.position.x)
    log("robot.position.y = " .. robot.positioning.position.y)
    log("robot.position.z = " .. robot.positioning.position.z)]]--
end


function reset()
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
    robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
    n_steps = 0
end


function destroy()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    d = math.sqrt((x-1.5)^2 + y^2)
    print('f_distance ' .. d)
end
