local robotUtilities = dofile("utilities.lua")

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 1.9 -- 1.5
MAX_PROXIMITY = 0

local n_steps = 0
local robot_state = 0

RobotState = {
	SEARCHING_TARGET = 0,
	OBSTACLE_AVOIDANCE = 1,
	REACHED_TARGET = 2
}

function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
	n_steps = 0
	robot_state = RobotState.SEARCHING_TARGET
	robot.leds.set_all_colors("black")
end


function step()
	n_steps = n_steps + 1

	local sum_light_left, sum_light_right = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.HORIZONTAL_LEFT)
	local sum_light_front, sum_light_back = robotUtilities.read_half_sensors(robot.light, robotUtilities.OrientationType.VERTICAL_FRONT)
	local sum_proximity_left, sum_proximity_right = robotUtilities.read_half_sensors(robot.proximity, robotUtilities.OrientationType.HORIZONTAL_LEFT)
	local proximity_front = robot.proximity[1].value + robot.proximity[24].value

	log("light sum_light_right "..sum_light_right)
	log("light sum_light_left "..sum_light_left)
	log("proximity sum_proximity_right "..sum_proximity_right)
	log("proximity sum_proximity_left "..sum_proximity_left)

	local total_light = sum_light_right + sum_light_left
	local total_proximity = sum_proximity_right + sum_proximity_left

	if total_light > LIGHT_THRESHOLD then
		robot_state = RobotState.REACHED_TARGET
	elseif total_proximity > MAX_PROXIMITY then
		robot_state = RobotState.OBSTACLE_AVOIDANCE
	else
		robot_state = RobotState.SEARCHING_TARGET
	end



	------------------------------------------------------ ROBOT STATE: SEARCHING_TARGET
	if robot_state == RobotState.SEARCHING_TARGET then
		log("SEARCHING_TARGET")
		robot.leds.set_all_colors("black")

		if sum_light_front > sum_light_back and sum_light_back == 0 then
			robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, MAX_VELOCITY, MAX_VELOCITY)
		else
			if sum_light_right > sum_light_left then
				robotUtilities.move(robot, robotUtilities.MovementType.RIGHT, MAX_VELOCITY, nil)
			else
				robotUtilities.move(robot, robotUtilities.MovementType.LEFT, nil, MAX_VELOCITY)
			end
		end

	

	------------------------------------------------------ ROBOT STATE: OBSTACLE_AVOIDANCE
	elseif robot_state == RobotState.OBSTACLE_AVOIDANCE then
		log("OBSTACLE_AVOIDANCE")
		robot.leds.set_all_colors("red")
		
		if sum_proximity_right > sum_proximity_left then
			robotUtilities.move(robot, robotUtilities.MovementType.LEFT, nil, MAX_VELOCITY)
		else
			robotUtilities.move(robot, robotUtilities.MovementType.RIGHT, MAX_VELOCITY, nil)
		end


	------------------------------------------------------ ROBOT STATE: REACHED_TARGET
	elseif robot_state == RobotState.REACHED_TARGET then
		log("REACHED_TARGET")
		robot.leds.set_all_colors("green")
		robotUtilities.move(robot, robotUtilities.MovementType.STOP, nil, nil)
	end




	if sum_light_right==0 and sum_light_left==0 and not(proximity_front > MAX_PROXIMITY) then
		-- almeno una delle due non abbia rilevato qualcosa
		-- che non abbia rilevato qualche oggetto frontalmente
		log("RANDOM")
		if n_steps % MOVE_STEPS == 0 then
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end
		robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
	end

	log("robot.position.x = " .. robot.positioning.position.x)
	log("robot.position.y = " .. robot.positioning.position.y)
	log("robot.position.z = " .. robot.positioning.position.z)

end


function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robotUtilities.move(robot, robotUtilities.MovementType.FORWARD, left_v, right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end


function destroy()

end
