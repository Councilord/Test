local Players = game:GetService("Players")

local function setupControllerManager(character)
    -- Wait for all critical parts
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    local leftFoot = character:WaitForChild("LeftFoot", 5)
    local rightFoot = character:WaitForChild("RightFoot", 5)
    if not (humanoid and root and leftFoot and rightFoot) then
        warn("Character missing critical parts for ControllerManager setup", character)
        return
    end

    -- Disable default state machine
    humanoid.EvaluateStateMachine = false

    -- Manual death/respawn
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                character:Destroy()
                player:LoadCharacter()
            end
        end
    end)

    -- Setup controllers
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

    local leftSensor = Instance.new("ControllerPartSensor")
    leftSensor.Name = "LeftFootSensor"
    leftSensor.SensorMode = Enum.SensorMode.Floor
    leftSensor.UpdateType = Enum.SensorUpdateType.Manual
    leftSensor.Parent = controllerManager
    controllerManager.LeftFootSensor = leftSensor

    local rightSensor = Instance.new("ControllerPartSensor")
    rightSensor.Name = "RightFootSensor"
    rightSensor.SensorMode = Enum.SensorMode.Floor
    rightSensor.UpdateType = Enum.SensorUpdateType.Manual
    rightSensor.Parent = controllerManager
    controllerManager.RightFootSensor = rightSensor

    print("[ControllerManager] Setup complete for", character.Name)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupControllerManager)
end)