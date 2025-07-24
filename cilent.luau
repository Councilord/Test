-- VERSION: 2.0.0 (pure physics ragdoll)
-- THIS IS A RAGDOLL CILENT
-- EUPHORIA RAGDOLL V0.1 MADE BY PS_LOL2020

wait(0.5)

local VERSION = "2.0.0"

local char = script.Parent
local hum = char:WaitForChild("Humanoid")

-- Store original Motor6Ds for possible restoration
local originalJoints = {}

local function storeOriginalJoints()
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Motor6D") then
            table.insert(originalJoints, desc:Clone())
        end
    end
end

storeOriginalJoints()

local function ragdollify(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Motor6D") and desc.Enabled ~= false then
            local part0 = desc.Part0
            local part1 = desc.Part1
            if part0 and part1 then
                -- Create attachments
                local att0 = Instance.new("Attachment", part0)
                att0.Name = desc.Name .. "_A0"
                local att1 = Instance.new("Attachment", part1)
                att1.Name = desc.Name .. "_A1"
                att0.CFrame = desc.C0
                att1.CFrame = desc.C1
                -- Create BallSocketConstraint
                local socket = Instance.new("BallSocketConstraint")
                socket.Attachment0 = att0
                socket.Attachment1 = att1
                socket.Parent = part0
                socket.LimitsEnabled = true
                socket.TwistLimitsEnabled = true
                socket.UpperAngle = 45
                socket.TwistLowerAngle = -45
                socket.TwistUpperAngle = 45
            end
            desc.Enabled = false
        end
    end
end

local function restoreJoints(char)
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BallSocketConstraint") then
            desc:Destroy()
        end
        if desc:IsA("Attachment") and (desc.Name:find("_A0") or desc.Name:find("_A1")) then
            desc:Destroy()
        end
    end
    for _,joint in ipairs(originalJoints) do
        local parent = char:FindFirstChild(joint.Parent.Name)
        if parent and not parent:FindFirstChild(joint.Name) then
            joint:Clone().Parent = parent
        end
    end
    for _,desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Motor6D") then
            desc.Enabled = true
        end
    end
end

-- Listen for ragdoll state
script.ragdoll:GetPropertyChangedSignal("Value"):Connect(function()
    if script.ragdoll.Value == true then
        ragdollify(char)
    else
        restoreJoints(char)
    end
end)

-- On respawn, restore joints
local player = game:GetService("Players").LocalPlayer
if player then
    player.CharacterAdded:Connect(function(newChar)
        char = newChar
        hum = char:WaitForChild("Humanoid")
        storeOriginalJoints()
        restoreJoints(char)
    end)
end