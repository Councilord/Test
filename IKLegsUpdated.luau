-- 		     		INSTRUCTIONS:
-- Put this in StarterPlayerScripts or ReplicatedFirst
-- Put a LocalScript inside StarterCharacter named "Animate." Disable it.

-- 		     	   	DESCRIPTION:
-- This shows active movement of legs based on the direction the player is moving, and uses Inverse Kinematics to bend legs based on the surrounding enviroment.

--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--
--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--
--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--
--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--
--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--
--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--{}--

-- Original script made by Scarious (derived from YouTube)
-- Appropriate changes made by iGottic

-- Changes made:
--	Script organization and optimization
--	Fixed "floating legs" issues
-- 	Fixed conflicts with current R15 joint CFrames
-- 	Made IK show for all players, rather than LocalPlayer
--	Usage of current raycasting method (WorldRoot:Raycast), rather than deprecated methods used previously (WorldRoot:FindPartOnRay)
--	Lots and lots of comments to explain how the script works, so users have a better understand of what's happening and how they can use it for future scripts

-- Updates from 4/3/21:
--	Remade the most of the module lmao
--	OOP Programming style
--	Methods to disable, enable, destroy, modify, etc.
--	Automatic delta calculating using tick()
--	Automatic disabling for characters off-screen or far away
--	Other cleanups and minor modifications to code bits not remade


-- Hakurem 7/11/21:
-- Fixed it for more general purpose of different character models so it doesnt look weird.


local Stride = 0 -- 1.5
local CycleSpeed = 14
local MaxRenderDistance = 500

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function EnableFootPlanting(Character)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Humanoid:EnableFootPlant(true)
		-- For newer APIs, you may need: Humanoid.FootPlant = true
	end
end

local function PlayerAdded(Player)
	local function CharacterAdded(Character)
		EnableFootPlanting(Character)
	end
	Player.CharacterAdded:Connect(CharacterAdded)
	if Player.Character then
		CharacterAdded(Player.Character)
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
for _, Player in pairs(Players:GetPlayers()) do
	PlayerAdded(Player)
end
