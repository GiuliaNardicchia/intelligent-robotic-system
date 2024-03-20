MovementType = {
    FORWARD = "forward",
    BACKWARD = "backward",
    LEFT = "left",
    RIGHT = "right",
    BACK_LEFT = "back_left",
    BACK_RIGHT = "back_right",
    STOP = "stop"
}

OrientationType = {
    VERTICAL_FRONT = {1, 2, 3, 4, 5, 6, 19, 20, 21, 22, 23, 24},
    HORIZONTAL_LEFT = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
}

--- The possible robots movements.
---@param robot any
---@param movement_type any
---@param left_v any
---@param right_v any
local function move(robot, movement_type, left_v, right_v)
    if movement_type == MovementType.FORWARD then
        robot.wheels.set_velocity(left_v, right_v)
    elseif movement_type == MovementType.BACKWARD then
        robot.wheels.set_velocity(-left_v, -right_v)
    elseif movement_type == MovementType.LEFT then
        robot.wheels.set_velocity(0, right_v)
    elseif movement_type == MovementType.RIGHT then
        robot.wheels.set_velocity(left_v, 0)
    elseif movement_type == MovementType.BACK_LEFT then
        robot.wheels.set_velocity(0, -right_v)
    elseif movement_type == MovementType.BACK_RIGHT then
        robot.wheels.set_velocity(-left_v, 0)
    elseif movement_type == MovementType.STOP then
        robot.wheels.set_velocity(0, 0)
    else
        return
    end
end

--- Search the highest value and conresponding index of the sensors of a data property, return nil in caso of empty list.
---@param robot_property any
local function searchHighestValue(robot_property)
    if #robot_property == 0 then
        return nil, nil
    end
    local value = -1
	local idx = -1
	for i=1,#robot_property do
		if value < robot_property[i].value then
			idx = i
			value = robot_property[i].value
		end
	end
    return idx, value
end


local function read_half_sensors(robot_property, orientation)
    local sum_first = 0
    local sum_second = 0

    for i, sensor in ipairs(robot_property) do
        local belongs_to_orientation = false
        for _, index in ipairs(orientation) do
            if i == index then
                belongs_to_orientation = true
                break
            end
        end

        if belongs_to_orientation then
            sum_first = sum_first + sensor.value
        else
            sum_second = sum_second + sensor.value
        end
    end

    return sum_first, sum_second
end


return {
    MovementType = MovementType,
    OrientationType = OrientationType,
    move = move,
    searchHighestValue = searchHighestValue,
    read_half_sensors = read_half_sensors
}