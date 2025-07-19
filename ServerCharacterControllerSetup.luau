local Players = game:GetService("Players")

local function setupControllerManager(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.EvaluateStateMachine = false
    end
    local root = character:WaitForChild("HumanoidRootPart")
    local controllerManager = Instance.new("ControllerManager")
    controllerManager.Name = "ControllerManager"
    controllerManager.Parent = character
    controllerManager.RootPart = root
    local groundController = Instance.new("GroundController")
    groundController.Parent = controllerManager
    controllerManager.GroundController = groundController
    local airController = Instance.new("AirController")
    airController.Parent = controllerManager
    controllerManager.AirController = airController
    local groundSensor = Instance.new("ControllerPartSensor")
    groundSensor.Name = "GroundSensor"
    groundSensor.SensorMode = Enum.SensorMode.Floor
    groundSensor.UpdateType = Enum.SensorUpdateType.Manual
    groundSensor.Parent = controllerManager
    controllerManager.GroundSensor = groundSensor
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupControllerManager)
end)