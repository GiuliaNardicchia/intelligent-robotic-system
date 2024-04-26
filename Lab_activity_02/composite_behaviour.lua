local robotUtilities = dofile("utilities.lua")
local performance = dofile("performance.lua")

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 1.8
PROXIMITY_THRESHOLD = 0.1
NOISE_THRESHOLD = 0.06
FRONTAL_THRESHOLD = 0.05

RobotState = {
	RANDOM_WALK = 0,
	SEARCHING_TARGET = 1,
	OBSTACLE_AVOIDANCE = 2,
	REACHED_TARGET = 3
}

local n_steps = 0
local robot_state = RobotState.RANDOM_WALK

function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
	n_steps = 0
	robot_state = RobotState.RANDOM_WALK
end


function step()
	n_steps = n_steps + 1

	-- sensors readings
	local sum_light_left, sum_light_right = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.HORIZONTAL_LEFT)
	local sum_light_front, sum_light_back = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.VERTICAL_FRONT)
	local sum_proximity_left, sum_proximity_right = robotUtilities.read_half_sensors(robot.proximity, robotUtilities.OrientationType.HORIZONTAL_LEFT)
	local proximity_front = robot.proximity[1].value + robot.proximity[24].value

	local total_light = sum_light_right + sum_light_left
	local total_proximity = sum_proximity_right + sum_proximity_left

	-- if the total light intensity reading exceeds a certain threshold
	if total_light > LIGHT_THRESHOLD then
		robot_state = RobotState.REACHED_TARGET
		-- if the total proximity reading exceeds a certain threshold
	elseif total_proximity > PROXIMITY_THRESHOLD then
		robot_state = RobotState.OBSTACLE_AVOIDANCE
		-- if no light detected and there are no obstacles detected in front
	elseif total_light < NOISE_THRESHOLD and proximity_front < PROXIMITY_THRESHOLD then
		robot_state = RobotState.RANDOM_WALK
		-- otherwise
	else
		robot_state = RobotState.SEARCHING_TARGET
	end

	-- robot state: SEARCHING_TARGET
	if robot_state == RobotState.SEARCHING_TARGET then
		log("SEARCHING_TARGET")
		robot.leds.set_all_colors("black")
		-- if the light intensity in front is greater than the light intensity at the back
		-- and there is no light detected at the back
		if sum_light_front > 0 and sum_light_back < FRONTAL_THRESHOLD then
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

		-- robot state: OBSTACLE_AVOIDANCE
	elseif robot_state == RobotState.OBSTACLE_AVOIDANCE then
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

		-- robot state: RANDOM_WALK
	elseif robot_state == RobotState.RANDOM_WALK then
		log("RANDOM_WALK")
		robot.leds.set_all_colors("green")

		if n_steps % MOVE_STEPS == 0 then
			-- generate random velocities for left and right wheels
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end
		-- move the robot forward with the calculated velocities
		robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)


		-- robot state: REACHED_TARGET
	elseif robot_state == RobotState.REACHED_TARGET then
		log("REACHED_TARGET")
		robot.leds.set_all_colors("yellow")
		-- stop the robot
		robotUtilities.move(robot, robotUtilities.MovementType.STOP, nil, nil)
	end
end


function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
	n_steps = 0
	robot_state = RobotState.RANDOM_WALK
end



function destroy()
	local light_position = {x = 0, y = 0}
	local robot_position = {x = robot.positioning.position.x, y = robot.positioning.position.y, z = robot.positioning.position.z}
	local euclidean_distance = performance.euclidean_distance(robot_position.x, robot_position.y, light_position.x, light_position.y)

	log("euclidean_distance: " .. euclidean_distance)
	log("n_steps: " .. n_steps)
	log("robot.position.x = " .. robot_position.x)
	log("robot.position.y = " .. robot_position.y)
	log("robot.position.z = " .. robot_position.z)
end
