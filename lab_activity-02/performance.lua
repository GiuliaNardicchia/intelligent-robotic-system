local function euclidean_distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx^2 + dy^2)
end

return {
    euclidean_distance = euclidean_distance
}