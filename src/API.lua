local TweenService = game:GetService("TweenService")

--[=[
    @class API
    The main API module for managing door animations.

    This API provides methods for opening and closing doors with customizable tween animations.
]=]
local API = {}

--[=[
    @function createTween
    @within API
    Creates a tween for a part's position.

    @param part BasePart -- The part to tween.
    @param goalPosition Vector3 -- The target position of the part.
    @param duration number -- The duration of the tween in seconds.
    @param easingStyle Enum.EasingStyle -- The easing style for the tween.
    @param easingDirection Enum.EasingDirection -- The easing direction for the tween.
    @return Tween -- The created Tween instance.
]=]
local function createTween(part: BasePart, goalPosition: Vector3, duration: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection): Tween
    local tweenInfo = TweenInfo.new(
        duration, -- Duration of the tween
        easingStyle, -- Easing style
        easingDirection, -- Easing direction
        0, -- Number of times to repeat the tween
        false, -- Whether the tween should reverse
        0 -- Delay before tween starts
    )

    local goal = {}
    goal.Position = goalPosition

    local tween = TweenService:Create(part, tweenInfo, goal)
    return tween
end

--[=[
    @function moveModel
    @within API
    Moves the entire model with specified easing style and duration.

    @param model Model The model containing the parts to tween.
    @param displacement Vector3 How far each part should move.
    @param duration number The duration of the tween in seconds.
    @param easingStyle Enum.EasingStyle The easing style for the tween.
    @param easingDirection Enum.EasingDirection The easing direction for the tween.
    @return Tween[] A table containing all created Tween instances.
]=]
local function moveModel(model: Model, displacement: Vector3, duration: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection): {Tween}
    local tweens = {}
    local primaryPart = model.PrimaryPart

    if not primaryPart then
        warn("PrimaryPart not set for model!")
        return {}
    end

    -- Create slide tweens for all BaseParts within the model
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local slideGoalPosition = part.Position + displacement
            local slideTween = createTween(part, slideGoalPosition, duration, easingStyle, easingDirection)
            table.insert(tweens, slideTween)
        end
    end

    return tweens
end

--[=[
    @class PassengerDoor
    A class for handling operations related to passenger doors.

    This class includes methods for automatically opening and closing passenger doors with customizable animations.
]=]

-- PassengerDoor Section
API.PassengerDoor = {}
API.PassengerDoor.__index = API.PassengerDoor

--[=[
    @function AutomaticOpen
    @within PassengerDoor
    Opens the doors with a specified duration.

    @param doorsModel Model The model containing all PassengerDoor models.
    @param openDuration number Duration of the opening tween in seconds.
]=]
function API.PassengerDoor:AutomaticOpen(doorsModel: Model, openDuration: number)
    -- Iterate over each PassengerDoor model inside the Doors model
    for _, passengerDoor in pairs(doorsModel:GetChildren()) do
        if passengerDoor:IsA("Model") and passengerDoor.Name == "PassengerDoor" then
            local leftDoorModel = passengerDoor:FindFirstChild("LeftPassengerDoor")
            local rightDoorModel = passengerDoor:FindFirstChild("RightPassengerDoor")

            if not leftDoorModel or not rightDoorModel then
                warn("LeftPassengerDoor or RightPassengerDoor model not found in PassengerDoor!")
                return
            end

            local openDisplacementLeft = Vector3.new(0, 0, 2.6) -- Distance to slide the left door open
            local openDisplacementRight = Vector3.new(0, 0, -2.6) -- Distance to slide the right door open

            -- Move the entire models with sliding effect for opening
            local openTweensLeft = moveModel(leftDoorModel, openDisplacementLeft, openDuration, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
            local openTweensRight = moveModel(rightDoorModel, openDisplacementRight, openDuration, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

            -- Play the open tweens
            for _, tween in pairs(openTweensLeft) do
                tween:Play()
            end
            for _, tween in pairs(openTweensRight) do
                tween:Play()
            end
        end
    end
end

--[=[
    @function AutomaticClose
    @within PassengerDoor
    Closes the doors with a random duration.

    @param doorsModel Model The model containing all PassengerDoor models.
]=]
function API.PassengerDoor:AutomaticClose(doorsModel: Model)
    for _, passengerDoor in pairs(doorsModel:GetChildren()) do
        if passengerDoor:IsA("Model") and passengerDoor.Name == "PassengerDoor" then
            local leftDoorModel = passengerDoor:FindFirstChild("LeftPassengerDoor")
            local rightDoorModel = passengerDoor:FindFirstChild("RightPassengerDoor")

            if not leftDoorModel or not rightDoorModel then
                warn("LeftPassengerDoor or RightPassengerDoor model not found in PassengerDoor!")
                return
            end

            local closeDisplacementLeft = Vector3.new(0, 0, -2.6) -- Distance to slide the left door closed
            local closeDisplacementRight = Vector3.new(0, 0, 2.6) -- Distance to slide the right door closed

            -- Move the entire models with sliding effect for closing
            local closeTweensLeft = moveModel(leftDoorModel, closeDisplacementLeft, math.random(2, 4), Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
            local closeTweensRight = moveModel(rightDoorModel, closeDisplacementRight, math.random(2, 4), Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

            -- Play the close tweens
            for _, tween in pairs(closeTweensLeft) do
                tween:Play()
            end
            for _, tween in pairs(closeTweensRight) do
                tween:Play()
            end
        end
    end
end

return API