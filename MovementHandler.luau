local MovementHandler = {}
local Client = shared.Client
local PlayerCamera = Client.Require("PlayerCamera")
local AnimationHandler = Client.Require("AnimationHandler")
local SpringPhysics = Client.Require("SpringPhysics").new

local Services = {
	PlayerService = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	Debris = game:GetService("Debris"),
	TweenService = game:GetService("TweenService"),
	SoundService = game:GetService("SoundService"),
	GuiService = game:GetService("GuiService"),
	Lighting = game:GetService("Lighting"),
	StarterGui = game:GetService("StarterGui"),
}

local LocalPlayer = Services.PlayerService.LocalPlayer
local ReplicationEvents = Services.ReplicatedStorage:WaitForChild("MovementEvents")
local FootstepSounds = Services.ReplicatedStorage:WaitForChild("FootstepSounds")
local Events = {
	Main = ReplicationEvents:WaitForChild("MainEvent"),
}

local SprintEase = SpringPhysics(0)
SprintEase.Speed = 14
SprintEase.Damper = 0.74

local Character = {
	Rig = nil,
	RootPart = nil,
	Humanoid = nil,
	Loaded = nil,
	DefaultSpeeds = {
		Walk = 7.5,
		Run = 21,
		Crouch = 4.6,
	},
	Cooldowns = {
		Jump = 0.3,
		CD = false
	},
	DefaulAnimations = {
		IdleTrack = "rbxassetid://13964340832",
		WalkTrack = "rbxassetid://7077114175",
		RunTrack = "rbxassetid://13964345505",
		CrouchTrack = "rbxassetid://7077120548",
		JumpTrack = "rbxassetid://13964350275",
		LandTrack = "rbxassetid://13964352546",
		SeatedTrack = "rbxassetid://13964354578",
		StrafeRightForwardsTrack = "rbxassetid://10404404615",  
		StrafeRightBackwardsTrack = "rbxassetid://10847107747",  
		StrafeLeftForwardsTrack = "rbxassetid://10404377900",  
		StrafeLeftBackwardsTrack = "rbxassetid://10847061332", 
		WalkBackwardsTrack = "rbxassetid://10358505520",  
	},
	Animations = {},
}

function SetConstantsFalse()
	Character.Jumping = false
	Character.Running = false
	Character.Falling = false
	Character.Seated = false
	Character.Landing = false
	Character.Crouching = false
end

function Character.Velocity()
	return Character.RootPart.CFrame:inverse() * (Character.RootPart.Position + Character.RootPart.Velocity)
end

function Character.Added(CharacterRig)
	SetConstantsFalse()
	Character.Rig,Character.RootPart,Character.Humanoid = CharacterRig,CharacterRig:WaitForChild("HumanoidRootPart", 1),CharacterRig:WaitForChild("Humanoid", 1)
	Character.NewSpeeds = {
		Walk = Character.DefaultSpeeds.Walk,
		Run = Character.DefaultSpeeds.Run,
		Crouch = Character.DefaultSpeeds.Crouch,
	}
	script:SetAttribute("CanRun",true);script:SetAttribute("CanCrouch",true);script:SetAttribute("Seated",false)
	Character.Humanoid.WalkSpeed = Character.NewSpeeds.Walk
	pcall(function()
		Services.Debris:AddItem(Character.Rig:FindFirstChild("Animate"),0)
	end)
	Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
	Character.Humanoid.JumpPower = 42
	Character.Animations = AnimationHandler:Create(Character.DefaulAnimations,Character.Humanoid:WaitForChild("Animator"))
	Character.LoadFootstep()
	Character.Loaded = true
	Character.Humanoid.Died:Connect(Character.Removed)
	Character.Humanoid.StateChanged:Connect(function(OldState,NewState)
		if OldState == NewState then
			return
		end
		if OldState == Enum.HumanoidStateType.Freefall and NewState == Enum.HumanoidStateType.Landed then
			Character.Falling,Character.Landing = false,true
			AnimationHandler:StopAnimationsInTable(Character.Animations,.2)
			AnimationHandler:Play(Character.Animations,"LandTrack")
			local Finished,Material = false,nil
			local Params = RaycastParams.new()
			local Ignore = {Character.Rig,workspace.Ignore}
			Params.FilterDescendantsInstances = Ignore
			while not Finished do
				local Raycast = workspace:Raycast(Character.RootPart.Position, Vector3.new(0,-20,0),Params)
				if not Raycast or Raycast.Instance.CanCollide then
					Finished = true
					if Raycast then
						Material = Raycast.Material.Name
					end
				else
					table.insert(Ignore,Raycast.Instance)
					Params.FilterDescendantsInstances = Ignore
				end
			end
			if Material == nil then
				return
			end
			local SoundFolder = FootstepSounds[Material]:GetChildren()
			local ImpactSound = SoundFolder[math.random(1,#SoundFolder)]:Clone()
			Events.Main:FireServer("ReplicateSound",Material,.94)
			ImpactSound.Parent = Character.RootPart
			ImpactSound.PlaybackSpeed *= .7
			ImpactSound.PlayOnRemove = true
			Services.Debris:AddItem(ImpactSound,0)
			local Function = nil
			Function = Character.Animations.LandTrack.Stopped:Connect(function()
				Function:Disconnect()
				Character.Landing = false
			end)
			
		end
		if NewState == Enum.HumanoidStateType.Seated then
			Character.Seated = true
			script:SetAttribute("Seated",true)
			AnimationHandler:StopAnimationsInTable(Character.Animations)
			AnimationHandler:Play(Character.Animations,"SeatedTrack",1)
			script:SetAttribute("CanCrouch",false)
			if Character.Crouching then
				Character.Crouching = false
				PlayerCamera:SetOffset(Vector3.new(PlayerCamera:GetOffset().X, PlayerCamera:GetOffset().Y == 0 and 0 or PlayerCamera:GetOffset().Y+1, PlayerCamera:GetOffset().Z))
				Character.Humanoid.WalkSpeed = Character.Running and Character.NewSpeeds.Run or Character.NewSpeeds.Walk
			end
		end
		if OldState == Enum.HumanoidStateType.Seated then
			Character.Seated = false
			script:SetAttribute("Seated",false)
			AnimationHandler:Stop(Character.Animations,"SeatedTrack",.4)
			script:SetAttribute("CanCrouch",true)
			
		end
	end)
	Character.Humanoid.FreeFalling:Connect(function(Bool)
		if Bool then
			Character.Falling = true
		else
			Character.Jumping,Character.Falling = false,false
		end
	end)
	Character.Humanoid.Jumping:Connect(function()
		AnimationHandler:StopAnimationsInTable(Character.Animations,.05)
		Character.Jumping = true
		AnimationHandler:Play(Character.Animations,"JumpTrack",.2)
		local Function = nil
		Function = Character.Animations.JumpTrack.Stopped:Connect(function()
			Function:Disconnect()
			Character.Jumping = false
		end)
	end)
end

function Character.Removed()
	SetConstantsFalse()
	Character.Loaded = false
	Character.Rig,Character.RootPart,Character.Humanoid = nil
	Character.Animations = {}
end


function Character.Stepped()
	if not Character.Loaded then
		return
	end
	if not Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local Velocity = Character.HumanoidRootPart.CFrame:VectorToWorldSpace(Character.Velocity) * Vector3.new(1,0,1)
	local VelocitySpeed = Velocity.Magnitude
	if not Character.Jumping and not Character.Falling then
		if Character.Crouching then
			AnimationHandler:Stop(Character.Animations,"WalkTrack",0.2)
			AnimationHandler:Stop(Character.Animations,"RunTrack",0.2)
			AnimationHandler:Play(Character.Animations,"CrouchTrack",0.2)
			local Neg = 0
			if VelocitySpeed > 0.05 then
				if Velocity.Z > 0.15 then
					Neg = -1
				else
					Neg = 1
				end
			end
			Character.Animations.CrouchTrack:AdjustSpeed(VelocitySpeed * 0.065 * Neg)
		else
			if VelocitySpeed > 0.05 then
				AnimationHandler:Stop(Character.Animations,"WalkBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeRightBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeRightForwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeLeftBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeLeftForwardsTrack",0.2)
				if Velocity.X > 0.05 then
					if Velocity.Z > 0.15 then
						-- Character is moving to the right backwards
						AnimationHandler:Play(Character.Animations,"StrafeRightBackwardsTrack",0.2)
					else
						-- Character is moving to the right forwards
						AnimationHandler:Play(Character.Animations,"StrafeRightForwardsTrack",0.2)
					end
				elseif Velocity.X < -0.05 then
					if Velocity.Z > 0.15 then
						-- Character is moving to the left backwards
						AnimationHandler:Play(Character.Animations,"StrafeLeftBackwardsTrack",0.2)
					else
						-- Character is moving to the left forwards
						AnimationHandler:Play(Character.Animations,"StrafeLeftForwardsTrack",0.2)
					end
				end

				if Velocity.Z > 0.15 and Velocity.X > -0.05 and Velocity.X < 0.05 then
					-- Character is moving backwards
					AnimationHandler:Play(Character.Animations,"WalkBackwardsTrack",0.2)
				elseif not Character.Running then
					local Reverse = 1
					if Velocity.Z > 0.15 then
						Reverse = -1
					end
					Character.Humanoid.WalkSpeed = Character.NewSpeeds.Walk
					AnimationHandler:Stop(Character.Animations,"IdleTrack",0.1)
					AnimationHandler:Stop(Character.Animations,"CrouchTrack",0.3)
					AnimationHandler:Stop(Character.Animations,"RunTrack",0.2)
					AnimationHandler:Play(Character.Animations,"WalkTrack",  0.5, 1.5)
					Character.Animations.WalkTrack:AdjustWeight(VelocitySpeed / 12 * 1.5)
					Character.Animations.WalkTrack:AdjustSpeed(VelocitySpeed / 12 * 1.6 * Reverse)
				else
					if Character.Jumping or Character.Falling and not Character.Landing then
						return
					end
					AnimationHandler:Stop(Character.Animations,"IdleTrack",0.1)
					AnimationHandler:Stop(Character.Animations,"WalkTrack",0.20)
					AnimationHandler:Stop(Character.Animations,"CrouchTrack",0.1)
					AnimationHandler:Play(Character.Animations,"RunTrack",0)
					Character.Animations.RunTrack:AdjustSpeed((VelocitySpeed * 1.5 / 22) * SprintEase.Position)
					Character.Animations.RunTrack:AdjustWeight((VelocitySpeed * 1.5 / 24) * SprintEase.Position)
				end
			else
				AnimationHandler:Stop(Character.Animations,"WalkBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeRightBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeRightForwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeLeftBackwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"StrafeLeftForwardsTrack",0.2)
				AnimationHandler:Stop(Character.Animations,"WalkTrack",0.3)
				AnimationHandler:Stop(Character.Animations,"CrouchTrack",0.3)
				AnimationHandler:Stop(Character.Animations,"RunTrack",0.2)
				AnimationHandler:Play(Character.Animations,"IdleTrack",0.1)
			end
		end
	end
end




function MovementHandler.Sprint(Bool)
	if not Character.Humanoid then
		return
	end
	if Bool then
		if Character.Crouching then
			PlayerCamera:SetOffset(Vector3.new(PlayerCamera:GetOffset().x,PlayerCamera:GetOffset().y == 0 and 0 or PlayerCamera:GetOffset().Y + 1,PlayerCamera:GetOffset().Z))
		end
		SprintEase.Target = 1
		Character.Crouching,Character.Running = false,true
		Character.Humanoid.WalkSpeed = Character.NewSpeeds.Run
	else
		Character.Running = false
		SprintEase.Target = 0
		if Character.Crouching then
			Character.Humanoid.WalkSpeed = Character.NewSpeeds.Crouch
		else
			Character.Humanoid.WalkSpeed = Character.NewSpeeds.Walk
		end
	end
end

function MovementHandler.SetSlow(Bool)
	Character.Humanoid.WalkSpeed = Bool and Character.NewSpeeds.Crouch or Character.NewSpeeds.Walk
	Character.Crouching = Bool
end

function Character.LoadFootstep()
	Character.Animations.WalkTrack:GetMarkerReachedSignal("Step1"):Connect(function(k)
		Character.Footstep()
	end)
	Character.Animations.WalkTrack:GetMarkerReachedSignal("Step2"):Connect(function(k)
		Character.Footstep()
	end)
	Character.Animations.RunTrack:GetMarkerReachedSignal("Step1"):Connect(function(k)
		Character.Footstep()
	end)
	Character.Animations.RunTrack:GetMarkerReachedSignal("Step2"):Connect(function(k)
		Character.Footstep()
	end)
	Character.Animations.CrouchTrack:GetMarkerReachedSignal("Step1"):Connect(function(k)
		Character.Footstep()
	end)
	Character.Animations.CrouchTrack:GetMarkerReachedSignal("Step2"):Connect(function(k)
		Character.Footstep()
	end)
end

function Character.Footstep()
	if Character.Humanoid and not Character.Seated then
		local FloorMaterial = Character.Humanoid.FloorMaterial.Name
		local SoundFolder = FootstepSounds[FloorMaterial]:GetChildren()
		local FootstepSound = SoundFolder[math.random(1,#SoundFolder)]:Clone()
		Events.Main:FireServer("ReplicateSound",FloorMaterial)
		FootstepSound.Parent = Character.RootPart
		FootstepSound.PlayOnRemove = true
		Services.Debris:AddItem(FootstepSound,0)
	end
end

function UserInput(Type, Input, Typing)
	if not Character.Rig or Typing then
		return
	end
	if Type == "Started" then
		if Input.KeyCode == Enum.KeyCode.LeftShift and script:GetAttribute("CanRun") then
			MovementHandler.Sprint(true)
		elseif Input.KeyCode == Enum.KeyCode.C or Input.KeyCode == Enum.KeyCode.LeftControl then
			if Character.Crouching and script:GetAttribute("CanCrouch") then
				Character.Crouching = false
				PlayerCamera:SetOffset(Vector3.new(PlayerCamera:GetOffset().X, PlayerCamera:GetOffset().Y == 0 and 0 or PlayerCamera:GetOffset().Y+1, PlayerCamera:GetOffset().Z))
				Character.Humanoid.WalkSpeed = Character.Running and Character.NewSpeeds.Run or Character.NewSpeeds.Walk
			else
				if not Character.Running and script:GetAttribute("CanCrouch") then
					if Character.Loaded then
						Character.Humanoid.WalkSpeed = Character.NewSpeeds.Crouch
						Character.Crouching = true
						PlayerCamera:SetOffset(Vector3.new(PlayerCamera:GetOffset().X == 0 and 0 or PlayerCamera:GetOffset().X, PlayerCamera:GetOffset().Y-1, PlayerCamera:GetOffset().Z == 0 and 0 or PlayerCamera:GetOffset().Z))
					end
				end
			end
			
		end
	elseif Type == "Ended" then
		if Input.KeyCode == Enum.KeyCode.LeftShift then
			MovementHandler.Sprint(false)
		end
	end
end

function MovementHandler:Initialize()
	script.Parent.GunHandler:GetAttributeChangedSignal("Aiming"):Connect(function()
		if script.Parent.GunHandler:GetAttribute("Aiming") then
			script:SetAttribute("CanRun",false)
		else
			script:SetAttribute("CanRun",true)
		end
	end)
	script:SetAttribute("Seated",false)
	LocalPlayer.CharacterAdded:Connect(function(CharacterRig)
		Character.Added(CharacterRig)
	end)
	Services.RunService.RenderStepped:Connect(Character.Stepped)
	Services.UserInputService.InputBegan:Connect(function(Input, Typing)
		UserInput("Started", Input, Typing)
	end)
	Services.UserInputService.InputEnded:Connect(function(Input)
		UserInput("Ended", Input)
	end)
	Services.UserInputService.JumpRequest:Connect(function()
		if Character.Cooldowns.CD then
			if Character.Humanoid then
				Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
			end
		else
			Character.Cooldowns.CD = true
			if Character.Humanoid then
				Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
			end
			task.delay(1.5, function()
				Character.Cooldowns.CD = false
			end)
		end
	end)
end

Events.Main.OnClientEvent:Connect(function(Player,Type,Arg1,Arg2,Arg3)
	if Type == "ReplicateSound" and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		local SoundFolder = FootstepSounds[Arg1]:GetChildren()
		local ImpactSound = SoundFolder[math.random(1,#SoundFolder)]:Clone()
		ImpactSound.Parent = Player.Character.HumanoidRootPart
		if Arg2 then
			ImpactSound.PlaybackSpeed = .7
		end
		ImpactSound.PlayOnRemove = true
		Services.Debris:AddItem(ImpactSound,0)
	elseif Type == "SpeedChange" then
		print(Arg1)
		print(Arg1[1])
		print(Character.NewSpeeds)
		Character.NewSpeeds = {
			Walk = Arg1.WS,
			Run = Arg1.RS,
			Crouch = Arg1.CS,
		}
	end
end)


return MovementHandler
