-- VERSION: 2.1.0 (improved euphoria ragdoll)
-- THIS IS A RAGDOLL CILENT
-- EUPHORIA RAGDOLL V0.1 MADE BY PS_LOL2020

wait(0.5)

local VERSION = "2.1.0"

local char = script.Parent
local hum = char:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

-- Euphoria-style ragdoll: IKControl for feet, VectorForce for torso, dynamic stepping, density reduction

-- IKControl setup for R15 feet
local leftFootIK, rightFootIK
local function setupIKControls()
    if not hum:FindFirstChild("Animator") then return end
    if leftFootIK then leftFootIK:Destroy() end
    if rightFootIK then rightFootIK:Destroy() end
    leftFootIK = Instance.new("IKControl")
    leftFootIK.Name = "LeftFootIK"
    leftFootIK.Type = Enum.IKControlType.Position
    leftFootIK.ChainRoot = char:FindFirstChild("LeftUpperLeg")
    leftFootIK.EndEffector = char:FindFirstChild("LeftFoot")
    leftFootIK.Target = Instance.new("Attachment", char:FindFirstChild("LeftFoot"))
    leftFootIK.Target.Name = "LeftFootTarget"
    leftFootIK.Enabled = false
    leftFootIK.Parent = hum
    rightFootIK = Instance.new("IKControl")
    rightFootIK.Name = "RightFootIK"
    rightFootIK.Type = Enum.IKControlType.Position
    rightFootIK.ChainRoot = char:FindFirstChild("RightUpperLeg")
    rightFootIK.EndEffector = char:FindFirstChild("RightFoot")
    rightFootIK.Target = Instance.new("Attachment", char:FindFirstChild("RightFoot"))
    rightFootIK.Target.Name = "RightFootTarget"
    rightFootIK.Enabled = false
    rightFootIK.Parent = hum
end
setupIKControls()
hum:GetPropertyChangedSignal("Parent"):Connect(function()
    if hum.Parent == nil then return end
    setupIKControls()
end)

-- VectorForce-based balancing setup
local root = char:FindFirstChild("HumanoidRootPart")
local balanceForce = Instance.new("VectorForce")
balanceForce.Name = "BalanceForce"
balanceForce.Attachment0 = Instance.new("Attachment", root)
balanceForce.Force = Vector3.new(0,0,0)
balanceForce.RelativeTo = Enum.ActuatorRelativeTo.World
balanceForce.Parent = root

-- Density reduction for floatier ragdoll
local originalDensities = {}
local function setCharacterDensity(density)
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("MeshPart") then
            if not originalDensities[part] then
                originalDensities[part] = part.CustomPhysicalProperties and part.CustomPhysicalProperties.Density or 1
            end
            local props = part.CustomPhysicalProperties or PhysicalProperties.new(1,0.3,0.5)
            part.CustomPhysicalProperties = PhysicalProperties.new(density, props.Friction, props.Elasticity, props.FrictionWeight, props.ElasticityWeight)
        end
    end
end

-- Dynamic stepping logic
local time = 0
RunService.Heartbeat:Connect(function(dt)
    if script.ragdoll.Value == true then
        -- Enable IKControl
        if leftFootIK and rightFootIK then
            leftFootIK.Enabled = true
            rightFootIK.Enabled = true
            -- Get support midpoint and COM
            local leftPos, rightPos = leftFootIK.Target.Position, rightFootIK.Target.Position
            local supportMid = (leftPos + rightPos) / 2
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local comGround = Vector3.new(root.Position.X, leftPos.Y, root.Position.Z)
                -- Dynamic stepping
                time = time + dt
                local stepRadius = 0.4
                local stepSpeed = 2.5
                local phase = math.sin(time * stepSpeed)
                local comOffset = (comGround - supportMid)
                local stepDir = Vector3.new(0,0,0)
                if comOffset.Magnitude > 0.1 then
                    stepDir = comOffset.Unit * math.min(comOffset.Magnitude, 0.7)
                end
                leftFootIK.Target.Position = supportMid + Vector3.new(-0.5, 0, 0) + stepDir + Vector3.new(0, 0, phase * stepRadius)
                rightFootIK.Target.Position = supportMid + Vector3.new(0.5, 0, 0) + stepDir + Vector3.new(0, 0, -phase * stepRadius)
                -- VectorForce: pull torso toward supportMid
                local forceDir = (supportMid - root.Position)
                forceDir = Vector3.new(forceDir.X, 0, forceDir.Z)
                local forceStrength = 2500
                balanceForce.Force = forceDir * forceStrength
            end
        end
    else
        if leftFootIK then leftFootIK.Enabled = false end
        if rightFootIK then rightFootIK.Enabled = false end
        if balanceForce then balanceForce.Force = Vector3.new(0,0,0) end
    end
end)

-- Density change on ragdoll
script.ragdoll:GetPropertyChangedSignal("Value"):Connect(function()
    if script.ragdoll.Value == true then
        setCharacterDensity(0.25)
    else
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("MeshPart") and originalDensities[part] then
                local props = part.CustomPhysicalProperties or PhysicalProperties.new(1,0.3,0.5)
                part.CustomPhysicalProperties = PhysicalProperties.new(originalDensities[part], props.Friction, props.Elasticity, props.FrictionWeight, props.ElasticityWeight)
            end
        end
    end
end)

-- On respawn, restore density and IK
local player = game:GetService("Players").LocalPlayer
if player then
    player.CharacterAdded:Connect(function(newChar)
        char = newChar
        hum = char:WaitForChild("Humanoid")
        setupIKControls()
        originalDensities = {}
        setCharacterDensity(1)
    end)
end