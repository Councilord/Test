RunService = game:GetService('RunService')

Config = require(script.Configuration)

-- Initialize Variables --

Player = game.Players.LocalPlayer
Character = Player.Character
Humanoid = Character.Humanoid

Humanoid.MaxSlopeAngle = 50 -- Looks better imo, although can edit if you'd like, Default Roblox value is 89

Config.SetupIKControllers(Character)


Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if Humanoid.MoveDirection.Magnitude > 0 then
		Config.UpdateFootSurfaceWeights(0, .1)
	else
		Config.UpdateFootSurfaceWeights(1, .5)
	end
end)



Humanoid.FreeFalling:Connect(function(falling)
	if falling then
		Config.UpdateFootSurfaceWeights(0, .1)
	else
		Config.UpdateFootSurfaceWeights(1, .5)
	end
	
end)



RunService.RenderStepped:Connect(function()
	Config.ComputeFootSurface(Character)
end)
