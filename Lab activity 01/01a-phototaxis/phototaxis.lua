-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end

--- Turn left.
---@param right_v any
local function turnLeft(right_v)
	left_v = 0
	robot.wheels.set_velocity(left_v,right_v)
end

--- Turn right.
--- @param left_v any
local function turnRight(left_v)
	right_v = 0
	robot.wheels.set_velocity(left_v,right_v)
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end
	robot.wheels.set_velocity(left_v,right_v)
	log("robot.position.x = " .. robot.positioning.position.x)
	log("robot.position.y = " .. robot.positioning.position.y)
	log("robot.position.z = " .. robot.positioning.position.z)
	light_front = robot.light[1].value + robot.light[24].value
	log("robot.light_front = " .. light_front)

	--[[ Check if close to light 
	(note that the light threshold depends on both sensor and actuator characteristics) ]]
	light = false
	sum_right = 0
	sum_left = 0
	half = #robot.light/2
	for i=1,#robot.light do
		if i >= half+1 and i<= #robot.light then
			sum_right = sum_right + robot.light[i].value
		elseif i >= 1 and i <= half then
			sum_left = sum_left + robot.light[i].value
		end
	end
	log("light sum_right "..sum_right)
	log("light sum_left "..sum_left)

	if sum_right + sum_left > LIGHT_THRESHOLD then
		light = true
		left_v = MAX_VELOCITY
		right_v = MAX_VELOCITY
		robot.wheels.set_velocity(left_v,right_v)
		robot.leds.set_all_colors("red")
	else
		robot.leds.set_all_colors("black")

		if sum_right > sum_left then
			turnRight(MAX_VELOCITY)
		else
			turnLeft(MAX_VELOCITY)
		end
	end

end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
