local Players = game:GetService("Players")

local function setupControllerManager(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.EvaluateStateMachine = false
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                local player = Players:GetPlayerFromCharacter(character)
                if player then
                    character:Destroy()
                    player:LoadCharacter()
                end
            end
        end)
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

    -- Add per-foot sensors
    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightFoot = character:FindFirstChild("RightFoot")
    if leftFoot then
        local leftSensor = Instance.new("ControllerPartSensor")
        leftSensor.Name = "LeftFootSensor"
        leftSensor.SensorMode = Enum.SensorMode.Floor
        leftSensor.UpdateType = Enum.SensorUpdateType.Manual
        leftSensor.Parent = controllerManager
        controllerManager.LeftFootSensor = leftSensor
    end
    if rightFoot then
        local rightSensor = Instance.new("ControllerPartSensor")
        rightSensor.Name = "RightFootSensor"
        rightSensor.SensorMode = Enum.SensorMode.Floor
        rightSensor.UpdateType = Enum.SensorUpdateType.Manual
        rightSensor.Parent = controllerManager
        controllerManager.RightFootSensor = rightSensor
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupControllerManager)
end)