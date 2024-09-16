--[[
    Main API ModuleScript

    This module provides functionality for managing "PassengerDoor" models within a "Doors" model.
    It includes methods for automatically opening and closing doors with customizable tween animations.

    The API is structured to handle a hierarchy where:
    - The "Doors" model contains multiple "PassengerDoor" models.
    - Each "PassengerDoor" model contains two sub-models: "LeftPassengerDoor" and "RightPassengerDoor".
]]

local TweenService = game:GetService("TweenService")

--- Creates a tween for a part's position.
--- @param part BasePart The part to tween.
--- @param goalPosition Vector3 The target position of the part.
--- @param duration number The duration of the tween in seconds.
--- @param easingStyle Enum.EasingStyle The easing style for the tween.
--- @param easingDirection Enum.EasingDirection The easing direction for the tween.
--- @return Tween The created Tween instance.
local function createTween(part, goalPosition, duration, easingStyle, easingDirection)
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

--- Moves the entire model with specified easing style and duration.
--- @param model Model The model containing the parts to tween.
--- @param displacement Vector3 How far each part should move.
--- @param duration number The duration of the tween in seconds.
--- @param easingStyle Enum.EasingStyle The easing style for the tween.
--- @param easingDirection Enum.EasingDirection The easing direction for the tween.
--- @return Tween[] A table containing all created Tween instances.
local function moveModel(model, displacement, duration, easingStyle, easingDirection)
    local tweens = {}
    local primaryPart = model.PrimaryPart

    if not primaryPart then
        warn("PrimaryPart not set for model!")
        return
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

--- @class PassengerDoor
--- PassengerDoor handles automatic opening and closing of train doors.
local API = {}

API.PassengerDoor = {}
API.PassengerDoor.__index = API.PassengerDoor

--- Opens the doors with a specified duration.
--- @param doorsModel Model The model containing all PassengerDoor models.
--- @param openDuration number The duration of the opening tween in seconds.
function API.PassengerDoor:AutomaticOpen(doorsModel, openDuration)
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

--- Closes the doors with a random duration.
--- @param doorsModel Model The model containing all PassengerDoor models.
function API.PassengerDoor:Close(doorsModel)
    -- Iterate over each PassengerDoor model inside the Doors model
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
            local minCloseDuration = 3 -- Minimum duration for closing
            local maxCloseDuration = 6 -- Maximum duration for closing

            -- Generate random durations for closing
            local closeDurationLeft = math.random() * (maxCloseDuration - minCloseDuration) + minCloseDuration
            local closeDurationRight = math.random() * (maxCloseDuration - minCloseDuration) + minCloseDuration

            -- Move the entire models with sliding effect for closing
            local closeTweensLeft = moveModel(leftDoorModel, closeDisplacementLeft, closeDurationLeft, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local closeTweensRight = moveModel(rightDoorModel, closeDisplacementRight, closeDurationRight, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

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