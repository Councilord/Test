--VERSION 1.0.0, Find current version here: https://create.roblox.com/marketplace/asset/15932581915/R15-IK-FootPlanting%3Fkeyword=&pageNumber=&pagePosition=

local config = {}

config.Settings = {}

-- EDITABLE SETTINGS --

config.Settings.FootPlanting = true -- Useful if you need to run an animation and stop foot-planting

config.Settings.FootSurfaceOffset = Vector3.new(0, .15, 0) -- The height offset from the surface
config.Settings.FootMaxDistanceDown = -10 
config.Settings.ShouldAdjustHipHeight = true 


-- more later maybe? if I feel like it...



















-- WARNING: Only edit if you know what you're doing or want to make me look bad

TS = game:GetService('TweenService')

config._var = {}

config._var.FootSurfaceCalculation = true -- Internal reference for if the calculations should take place.


-- Setup player rig to be controlled by IK.
config.SetupIKControllers = function(PlayerCharacter)
	DefaultHipHeight = PlayerCharacter.Humanoid.HipHeight
	-- Create IK Controllers
	config.RightFootIKController = Instance.new('IKControl')
	config.LeftFootIKController = Instance.new('IKControl')
	
	config.RightFootIKController.Parent = PlayerCharacter.Humanoid
	config.LeftFootIKController.Parent = PlayerCharacter.Humanoid
	--Setup Bone Structure
	config.RightFootIKController.ChainRoot = PlayerCharacter.RightUpperLeg
	config.RightFootIKController.EndEffector =  PlayerCharacter.RightFoot
	
	config.LeftFootIKController.ChainRoot = PlayerCharacter.LeftUpperLeg
	config.LeftFootIKController.EndEffector =  PlayerCharacter.LeftFoot
	-- Create Targets
	config.RightFootIK = Instance.new('Attachment')
	config.LeftFootIK = Instance.new('Attachment')
	
	config.RightFootIK.Parent =  PlayerCharacter.RightFoot
	config.LeftFootIK.Parent =  PlayerCharacter.LeftFoot
	
	config.RightFootIK.WorldPosition = PlayerCharacter.RightFoot.Position + config.Settings.FootSurfaceOffset
	config.LeftFootIK.WorldPosition = PlayerCharacter.LeftFoot.Position + config.Settings.FootSurfaceOffset
	-- Assign Targets to Controllers
	config.RightFootIKController.Target = config.RightFootIK
	config.LeftFootIKController.Target =  config.LeftFootIK
	
	--Constraint IK Joints
	local LeftConstraint = Instance.new('HingeConstraint')
	LeftConstraint.Parent = PlayerCharacter.LeftUpperLeg
	local RightConstraint = Instance.new('HingeConstraint')
	RightConstraint.Parent = PlayerCharacter.RightUpperLeg
	
	LeftConstraint.Attachment0 = (function() local a = Instance.new('Attachment') a.Position = PlayerCharacter.LeftUpperLeg.LeftKneeRigAttachment.Position a.Parent = PlayerCharacter.LeftUpperLeg return a end)()
	LeftConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LeftLowerLeg a.WorldPosition = PlayerCharacter.LeftUpperLeg.LeftKneeRigAttachment.WorldPosition return a end)()
	
	RightConstraint.Attachment0 = (function() local a = Instance.new('Attachment') a.Position = PlayerCharacter.RightUpperLeg.RightKneeRigAttachment.Position a.Parent = PlayerCharacter.RightUpperLeg return a end)()
	RightConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.RightLowerLeg a.WorldPosition = PlayerCharacter.RightUpperLeg.RightKneeRigAttachment.WorldPosition return a end)()
	
	local LeftFootConstraint = Instance.new('BallSocketConstraint')
	LeftFootConstraint.Parent = PlayerCharacter.LeftFoot
	local RightFootConstraint = Instance.new('BallSocketConstraint')
	RightFootConstraint.Parent = PlayerCharacter.RightFoot
	
	LeftFootConstraint.Attachment0 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LeftLowerLeg  a.Position = PlayerCharacter.LeftLowerLeg.LeftAnkleRigAttachment.Position return a end)()
	LeftFootConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LeftFoot  a.Position = PlayerCharacter.LeftFoot.LeftAnkleRigAttachment.Position return a end)()
	
	RightFootConstraint.Attachment0 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.RightLowerLeg  a.Position = PlayerCharacter.RightLowerLeg.RightAnkleRigAttachment.Position return a end)()
	RightFootConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.RightFoot  a.Position = PlayerCharacter.RightFoot.RightAnkleRigAttachment.Position return a end)()
	
	LeftFootConstraint.LimitsEnabled = true
	LeftFootConstraint.TwistLimitsEnabled = true
	LeftFootConstraint.TwistLowerAngle = -40
	LeftFootConstraint.TwistUpperAngle = 70
	RightFootConstraint.LimitsEnabled = true
	RightFootConstraint.TwistLimitsEnabled = true
	RightFootConstraint.TwistLowerAngle = -40
	RightFootConstraint.TwistUpperAngle = 70
	
	local LeftHipConstraint = Instance.new('BallSocketConstraint')
	LeftHipConstraint.Parent = PlayerCharacter.LowerTorso
	local RightHipConstraint = Instance.new('BallSocketConstraint')
	RightHipConstraint.Parent = PlayerCharacter.LowerTorso
	
	LeftHipConstraint.Attachment0 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LowerTorso a.Position = PlayerCharacter.LowerTorso.LeftHipRigAttachment.Position return a end)()
	LeftHipConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LeftUpperLeg  a.Position = PlayerCharacter.LeftUpperLeg.LeftHipRigAttachment.Position return a end)()

	RightHipConstraint.Attachment0 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.LowerTorso a.Position = PlayerCharacter.LowerTorso.RightHipRigAttachment.Position return a end)()
	RightHipConstraint.Attachment1 = (function() local a = Instance.new('Attachment')  a.Parent = PlayerCharacter.RightUpperLeg  a.Position = PlayerCharacter.RightUpperLeg.RightHipRigAttachment.Position return a end)()
	
	LeftHipConstraint.LimitsEnabled = true
	LeftHipConstraint.TwistLimitsEnabled = true
	LeftHipConstraint.TwistLowerAngle = -70
	LeftHipConstraint.TwistUpperAngle = 70
	RightHipConstraint.LimitsEnabled = true
	RightHipConstraint.TwistLimitsEnabled = true
	RightHipConstraint.TwistLowerAngle = -70
	RightHipConstraint.TwistUpperAngle = 70
	
	
	config.UpdateFootSurfaceWeights = function(weight, Duration) -- dont call it if it doesn't exist (sorry)
		TS:Create(config.LeftFootIKController, TweenInfo.new(Duration), {Weight = weight}):Play()
		TS:Create(config.RightFootIKController, TweenInfo.new(Duration), {Weight = weight}):Play()
		
	end
	
end



config.ComputeFootSurface = function(PlayerCharacter) -- Calculates the IK positions ONCE, call on renderstepped to achieve full functionality.
	if config._var.FootSurfaceCalculation == true and config.Settings.FootPlanting then
		
		local Velocity =  PlayerCharacter.HumanoidRootPart.Velocity.magnitude -- Unused, might bring back later.



		local RayParams = RaycastParams.new() 
		
		RayParams.FilterDescendantsInstances = {PlayerCharacter}
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		
		-- cast downwards ray from each foot
		local RightRay = workspace:Raycast(PlayerCharacter.RightFoot.Position + Vector3.new(0,1,0), Vector3.new(0, config.Settings.FootMaxDistanceDown,0), RayParams)
		local LeftRay = workspace:Raycast(PlayerCharacter.LeftFoot.Position + Vector3.new(0,1,0), Vector3.new(0, config.Settings.FootMaxDistanceDown,0), RayParams)
		
		-- this is for visuals, I think it looks weird when a player just sits halfway on a ledge, this was an attempt to rectify that
		if RightRay and LeftRay then
			if (RightRay.Position - PlayerCharacter.RightFoot.Position).Magnitude > 4.4 or (LeftRay.Position - PlayerCharacter.LeftFoot.Position).Magnitude > 4.4 and config.Settings.ShouldAdjustHipHeight  then
				PlayerCharacter.Humanoid.HipHeight = DefaultHipHeight - .4
			else
				PlayerCharacter.Humanoid.HipHeight = DefaultHipHeight
			end
		end
		
		
		-- A whole lot of vector math that I barely understand, good luck.
		-- Foot IKTarget at the Position of the RayHit (the ground), and rotate based on the surface normal
		if RightRay then
			config.RightFootIK.WorldCFrame = CFrame.fromMatrix(RightRay.Position + config.Settings.FootSurfaceOffset, RightRay.Normal:Cross(PlayerCharacter.HumanoidRootPart.CFrame.RightVector), PlayerCharacter.HumanoidRootPart.CFrame.RightVector, RightRay.Normal) * CFrame.Angles(0,math.rad(90),math.rad(90))
		end
		if LeftRay then
			config.LeftFootIK.WorldCFrame = CFrame.fromMatrix(LeftRay.Position + config.Settings.FootSurfaceOffset, LeftRay.Normal:Cross(PlayerCharacter.HumanoidRootPart.CFrame.RightVector), PlayerCharacter.HumanoidRootPart.CFrame.RightVector, LeftRay.Normal) * CFrame.Angles(0,math.rad(90),math.rad(90))
		end
	
		
	else
		
	end
	

end


return config
