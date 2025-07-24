-- THIS IS A RAGDOLL CILENT
-- EUPHORIA RAGDOLL V0.1 MADE BY PS_LOL2020

-- PLEASE SUPPORT ME, BECAUSE I DID THIS FOR HARDWORK A YEARLY MADE EVERY RAGDOLL PROJECT

-- THIS SCRIPT ARE NO ERRORS SOMETHING
-- IF U FOUND A ERROR TELL ME IN VIA DISCORD SERVER FOUND IN MY YOUTUBE

wait(0.5) -- starts

local USERINPUT = game:GetService("UserInputService")
local char = script.Parent
local hum = char:WaitForChild("Humanoid")

local parasm = RaycastParams.new()
parasm.FilterType = Enum.RaycastFilterType.Blacklist
parasm.FilterDescendantsInstances = {char}

-- Auto ragdoll on death
hum.Died:Connect(function()
	print("Character died - activating ragdoll")
	script.ragdoll.Value = true
	startShake(2) -- strong shake on death

	BALANCE = false -- Disable balancing on death
	ONLYBALANCEONETIME = false

	-- Clean up ragdoll state after respawn delay
	-- Let Roblox handle respawn naturally
	local function waitForRespawn()
		-- Wait for new character to spawn
		local player = game:GetService("Players").LocalPlayer
		if player then
			player.CharacterAdded:Connect(function()
				print("Character respawned - resetting ragdoll state")
				-- Reset ragdoll state for new character
				if script:FindFirstChild("ragdoll") then
					script.ragdoll.Value = false
				end
			end)
		end
	end
	-- Start respawn monitoring
	waitForRespawn()
end)

local tween = game:GetService("TweenService")

-- Camera Shake
local Camera = workspace.CurrentCamera
local baseCamOffset = Vector3.new(0.55,0,0)
local shakeMag = 0 -- current shake magnitude
local shakeDecay = 0.85 -- how quickly shake fades each frame (slower decay = longer shake)
local shakeDuration = 0 -- how long the shake should last
local shakeTime = 0 -- timer for shake
local onGroundPrev = false -- tracks if ragdoll was on ground last frame

local function startShake(mag, duration)
	shakeMag = math.max(shakeMag, mag)
	shakeDuration = duration or 0.3
	shakeTime = 0
	print("Camera shake started with magnitude:", mag, "duration:", shakeDuration, "Total shake:", shakeMag)
end

-- Trigger shake whenever ragdoll becomes true
script.ragdoll:GetPropertyChangedSignal("Value"):Connect(function()
	if script.ragdoll.Value == true then
		startShake(1.2) -- initial shake strength (increased)
	end
end)

--Folders
local physicsFolder
local behaviorpropertiesFolder
local constraintsFolder

--Attachment For Behavior





--BALANCE's
local leftfootbalanceattach = Instance.new("Attachment")
local rightfootbalanceattach = Instance.new("Attachment")

leftfootbalanceattach.Name = "leftfootbalanceattach"
rightfootbalanceattach.Name = "rightfootbalanceattach"

local lefthandbalanceattach = Instance.new("Attachment")
local righthandbalanceattach = Instance.new("Attachment")

lefthandbalanceattach.Name = "lefthandbalanceattach"
righthandbalanceattach.Name = "righthandbalanceattach"




--GROUND's
local leftupperleggroundattach = Instance.new("Attachment")
local rightupperleggroundattach = Instance.new("Attachment")

leftupperleggroundattach.Name = "leftupperleggroundattach"
rightupperleggroundattach.Name = "rightupperleggroundattach"

local leftfootgroundattach = Instance.new("Attachment")
local rightfootgroundattach = Instance.new("Attachment")

leftfootgroundattach.Name = "leftfootgroundattach"
rightfootgroundattach.Name = "rightfootgroundattach"

local leftupperarmgroundattach = Instance.new("Attachment")
local rightupperarmgroundattach = Instance.new("Attachment")

leftupperarmgroundattach.Name = "leftupperarmgroundattach"
rightupperarmgroundattach.Name = "rightupperarmgroundattach"

local leftlowerarmgroundattach = Instance.new("Attachment")
local rightlowerarmgroundattach = Instance.new("Attachment")

leftlowerarmgroundattach.Name = "leftlowerarmgroundattach"
rightlowerarmgroundattach.Name = "rightlowerarmgroundattach"




--FALL's
local leftfootfallattach = Instance.new("Attachment")
local rightfootfallattach = Instance.new("Attachment")

leftfootfallattach.Name = "leftfootfallattach"
rightfootfallattach.Name = "rightfootfallattach"

local leftupperarmfallattach = Instance.new("Attachment")
local rightupperarmfallattach = Instance.new("Attachment")

leftupperarmfallattach.Name = "leftupperarmfallattach"
rightupperarmfallattach.Name = "rightupperarmfallattach"

local leftlowerarmfallattach = Instance.new("Attachment")
local rightlowerarmfallattach = Instance.new("Attachment")

leftlowerarmfallattach.Name = "leftlowerarmfallattach"
rightlowerarmfallattach.Name = "rightlowerarmfallattach"


--ATTACHMENT VISIBLE
footbalanceattachvisible = false






--VALUES

FallVelocityActivate = -50 -- to activate the fall of velocity
GettingCrashByObjectSpeed = 35
GettingCrashByObjectOrientationSpeed = 6.25
GettingCrashByPlayerRagdolledSpeed = 20


--BALANCE's
BalanceWalkTimeLoop = 0.02  
BalanceFootStepDist = 0.25 
BalanceFootStepDistHeight = 0.22 

BalanceFootStepCurrentDist = 0
BalanceFootStepCurrentDistHeight = 0
BalanceFootStepCurrentDistHeight2 = 0

DontBalanceInOver25velocity = false

CurrentWideLeg = 0.65

BalanceWalkInReverse = true

BalanceD = 20000 -- increased damping for better balance
BalanceMaxForce = 200 -- increased force for stronger balance 

InFallMaxFrictionConstraints = 25
InBalanceMaxFrictionConstraints = 50 -- increased for better joint stability
InGroundMaxFrictionConstraints = 15
OutBehaviourMaxFrictionConstraints = 0

if not script:FindFirstChild("UPPERBG") then
	local bg = Instance.new("BodyGyro")
	bg.Name = "UPPERBG"
	bg.MaxTorque = Vector3.new(0,0,0) 
	bg.P = 6000 
	bg.D = 0    
	bg.CFrame = CFrame.new()
	bg.Parent = script
end

if not script:FindFirstChild("LOWERBG") then
	local bg = Instance.new("BodyGyro")
	bg.Name = "LOWERBG"
	bg.MaxTorque = Vector3.new(0,0,0)
	bg.P = 6000
	bg.D = 0
	bg.CFrame = CFrame.new()
	bg.Parent = script
end

-- cached references for performance
local upperBG = script:FindFirstChild("UPPERBG")
local lowerBG = script:FindFirstChild("LOWERBG")

local upperAttach = char:FindFirstChild("UpperTorso"):FindFirstChild("UPPER_ORIENT_ATTACH") or Instance.new("Attachment",char:FindFirstChild("UpperTorso"))
upperAttach.Name = "UPPER_ORIENT_ATTACH"

local lowerAttach = char:FindFirstChild("LowerTorso"):FindFirstChild("LOWER_ORIENT_ATTACH") or Instance.new("Attachment",char:FindFirstChild("LowerTorso"))
lowerAttach.Name = "LOWER_ORIENT_ATTACH"

local function makeAO(name,attach)
	local ao = char:FindFirstChild(name) or Instance.new("AlignOrientation")
	ao.Name = name
	ao.Attachment0 = attach
	ao.RigidityEnabled = true
	ao.MaxTorque = 0
	ao.Responsiveness = 50
	ao.Parent = attach.Parent
	return ao
end

local upperAO = makeAO("UPPERAO", upperAttach)
local lowerAO = makeAO("LOWERAO", lowerAttach)

-- continually update the target orientation while balancing
local RunService = game:GetService("RunService")
local SPRING_STIFFNESS = 350 -- Tune for realism
local DAMPING = 60 -- Tune for realism
local RANDOM_TORQUE = 10 -- Small random torque for instability

RunService.Heartbeat:Connect(function(dt)
	if script.ragdoll.Value == true and BALANCE == true and upperBG.Parent and lowerBG.Parent then
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
		if root then
			-- Calculate upright vector and deviation
			local up = root.CFrame.UpVector
			local deviation = up:Cross(Vector3.new(0,1,0))
			local angle = math.acos(math.clamp(up:Dot(Vector3.new(0,1,0)), -1, 1))

			-- Spring force: proportional to angle
			local springTorque = Vector3.new(0,0,0)
			if deviation.Magnitude > 0 then
				springTorque = deviation.Unit * angle * SPRING_STIFFNESS
			end

			-- Damping: proportional to angular velocity
			local angularVel = root.RotVelocity
			local dampingTorque = -angularVel * DAMPING

			-- Random instability
			local randomTorque = Vector3.new(
				(math.random()-0.5)*2*RANDOM_TORQUE,
				0,
				(math.random()-0.5)*2*RANDOM_TORQUE
			)

			-- Total torque
			local totalTorque = springTorque + dampingTorque + randomTorque

			-- Apply to BodyGyro (upperBG and lowerBG)
			upperBG.MaxTorque = Vector3.new(50000, 0, 50000)
			upperBG.D = 0 -- Let us handle damping
			-- Set CFrame upright
			upperBG.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0,1,0))
			-- Optionally, you can apply torque directly if you use constraints

			lowerBG.MaxTorque = Vector3.new(50000, 0, 50000)
			lowerBG.D = 0
			lowerBG.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0,1,0))
		end
	end
end)






--GROUND's
GroundMAXTORQUEINVELOCITY = 100 -- Ground's Max Torque is Likely a Stiffness if u want to make it Stronger Stiffness
GroundMAXTORQUEOUTVELOCITY = 25 -- when the ragdoll is on low velocity

LeftShoulderOrienCurrentGround = Vector3.new(70, 180, -145)
RightShoulderOrienCurrentGround = Vector3.new(70, 180, 145)

LeftElbowOrienCurrentGround = Vector3.new(130, 0, -0)
RightElbowOrienCurrentGround = Vector3.new(130, 0, 0)

LeftHipOrienCurrentGround = Vector3.new(90, -180, -160)
RightHipOrienCurrentGround = Vector3.new(60, 180, 160)

LeftKneeOrienCurrentGround = Vector3.new(-120,0,0)
RightKneeOrienCurrentGround = Vector3.new(-120,0,0)



--FALL's

FallTimeLoop = 0.001 -- if is lower will make it more faster, NOTICE:It Won't Work Make it Faster Under 0.0016

FallKneeRotation = 10

FallKneeRotationCurrent = -90
FallKneeRotationCurrent2 = 0

local falldontloop = false

LeftShoulderOrienCurrentFall = Vector3.new(0, -50, -120)
RightShoulderOrienCurrentFall = Vector3.new(0, 50, 120)

LeftElbowOrienCurrentFall = Vector3.new(60,0,0)
RightElbowOrienCurrentFall = Vector3.new(60,0,0)



--BEHAVIOUR BOOLS
local BALANCE = false
local ONLYBALANCEONETIME = false

local GROUND = false
local GETTINGSHOOTBY = false

--BOOLS
local RequireSprinting = true -- if u have Sprint Script so Disable this as false.
local RagdollButtonRequire = true -- Pressing a Keycode to Activate the Ragdoll.
local RagdollFallRequire = true -- Going to Fall.
local RagdollByGettingCrashByObjectsRequire = true -- Getting Crashed By Objects or Vehicles.

local TiltAroundCharacter = true -- to make ur character looks realistic when turning around

local ResistanceSitCurrent = false

local DontRagdollCD = false

--VALUES AGAIN

local tiltaroundvalue = Instance.new("NumberValue")
tiltaroundvalue.Parent = script

USERINPUT.InputBegan:Connect(function(input,ingameprocess)
	if not ingameprocess then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			if RequireSprinting == true then
				-- hum.WalkSpeed = 30 
			end
		end
	end
end)

USERINPUT.InputEnded:Connect(function(input,ingameprocess)
	if not ingameprocess then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			if RequireSprinting == true then
				-- hum.WalkSpeed = 16 
			end
		end
	end
end)






--KEYCODES RAGDOLL

KEYCODERAGDOLL = Enum.KeyCode.R

USERINPUT.InputBegan:Connect(function(input,ingameprocess)
	if not ingameprocess then
		if input.KeyCode == KEYCODERAGDOLL then
			if script.ragdoll.Value == false then
				if RagdollButtonRequire == true then
					hum:ChangeState(Enum.HumanoidStateType.Physics)
					hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

					--VALUES
					ONLYBALANCEONETIME = true

					--EVENTS
					char:FindFirstChild("events").ragdollOn:FireServer()

					wait(0.001)

					script.ragdoll.Value = true
				end
			end
		end
	end
end)

USERINPUT.InputBegan:Connect(function(input,ingameprocess)
	if not ingameprocess then
		if input.KeyCode == KEYCODERAGDOLL then
			if script.ragdoll.Value == true then
				if RagdollButtonRequire == true then
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
					hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)

					--VALUES
					ONLYBALANCEONETIME = false

					--EVENTS
					char:FindFirstChild("events").ragdollOff:FireServer()

					wait(0.001)

					DontRagdollCD = true

					script.ragdoll.Value = false

					wait(0.1)

					DontRagdollCD = false
				end
			end
		end
	end
end)


game:GetService("RunService").RenderStepped:Connect(function()
	--TILT CHARACTER
	if TiltAroundCharacter == true then
		local tiltaroundvaluetween = tween:Create(tiltaroundvalue,TweenInfo.new(0.5),{Value = char.HumanoidRootPart.RotVelocity.Y * 0.02})
		tiltaroundvaluetween:Play()
		char.LowerTorso.Root.C0 = CFrame.new(char.LowerTorso.Root.C0.Position) * CFrame.Angles(0,0,0 + tiltaroundvalue.Value)
	end

	--FIX COLLIDES

	if char:FindFirstChild("HumanoidRootPart") then
		char:FindFirstChild("HumanoidRootPart").CanCollide = false
		char:FindFirstChild("HumanoidRootPart").CollisionGroupId = 31
	end

	if char:FindFirstChild("Head") then
		char:FindFirstChild("Head").CanCollide = true
		char:FindFirstChild("Head").CollisionGroupId = 21
	end

	hum = char:FindFirstChildOfClass("Humanoid")

	-- cam offset with procedural camera shake
	local shakeOffset = Vector3.new()
	if shakeMag > 0.01 and shakeTime < shakeDuration then
		-- GTA-style: more intense, rapid shake at start, then fade
		local intensity = shakeMag * (1 - (shakeTime/shakeDuration))
		shakeOffset = Vector3.new(
			(math.random()-0.5)*16*intensity,
			(math.random()-0.5)*12*intensity,
			(math.random()-0.5)*8*intensity
		)
		shakeTime = shakeTime + (game:GetService("RunService").RenderStepped:Wait() or 1/60)
		if shakeTime >= shakeDuration then
			shakeMag = 0
			shakeDuration = 0
			shakeTime = 0
		end
	else
		shakeMag = shakeMag * shakeDecay
	end
	hum.CameraOffset = baseCamOffset + shakeOffset
	
	-- Direct camera shake to bypass Humanoid.CameraOffset limitations
	if Camera.CameraType == Enum.CameraType.Custom then
		local camShake = Vector3.new()
		if shakeMag > 0.01 and shakeTime < shakeDuration then
			local intensity = shakeMag * (1 - (shakeTime/shakeDuration))
			camShake = Vector3.new(
				(math.random()-0.5)*0.2*intensity,
				(math.random()-0.5)*0.2*intensity,
				(math.random()-0.5)*0.1*intensity
			)
			Camera.CFrame = Camera.CFrame * CFrame.new(camShake)
		end
	end

	--SEATED

	if hum.Sit == true then
		ResistanceSitCurrent = true
	else
		ResistanceSitCurrent = false
	end

	--set custom properties physics

	physicsFolder = char:FindFirstChild("properties"):FindFirstChild("physics")
	behaviorpropertiesFolder = char:FindFirstChild("behaviorproperties")
	constraintsFolder = char:FindFirstChild("constraints")

	for _,BodyPart in pairs(char:GetChildren()) do
		if BodyPart:IsA("MeshPart") then
			if BodyPart:FindFirstChildOfClass("Motor6D") then -- If is it the Limbs Meshpart on the Character
				BodyPart.CustomPhysicalProperties = PhysicalProperties.new(physicsFolder.Density.Value,physicsFolder.Friction.Value,physicsFolder.Elasticity.Value,physicsFolder.FrictionWeight.Value,physicsFolder.ElasticityWeight.Value)
			end
		end
	end

	--IN RAGDOLL STATES

	for _,BodyPart in pairs(char:GetChildren()) do
		if BodyPart:IsA("MeshPart") then
			if BodyPart:FindFirstChildOfClass("Motor6D") then -- If is it the Limbs Meshpart on the Character
				if script.ragdoll.Value == true then
					game.Workspace.CurrentCamera.CameraSubject = char:FindFirstChild("LowerTorso")
					BodyPart:FindFirstChildOfClass("Motor6D").Part1 = nil
				else
					game.Workspace.CurrentCamera.CameraSubject = hum
					BodyPart:FindFirstChildOfClass("Motor6D").Part1 = BodyPart
				end
			end
		end
	end

	--RAGDOLL ACTIVATE

	--FALLING
	if char:FindFirstChild("LowerTorso").Velocity.Y < FallVelocityActivate then
		if ResistanceSitCurrent == false then
			if script.ragdoll.Value == false then
				if RagdollFallRequire == true then
					hum:ChangeState(Enum.HumanoidStateType.Physics)
					hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

					--VALUES
					ONLYBALANCEONETIME = true

					--EVENTS
					char:FindFirstChild("events").ragdollOn:FireServer()

					script.ragdoll.Value = true
				end
			end
		end
	end

	--ACTIVATED IF STUNNED IS ON TRUE
	if script.stunned.Value == true then
		if ResistanceSitCurrent == false then
			if script.ragdoll.Value == false then
				if RagdollFallRequire == true then
					hum:ChangeState(Enum.HumanoidStateType.Physics)
					hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

					--VALUES
					ONLYBALANCEONETIME = true

					--EVENTS
					char:FindFirstChild("events").ragdollOn:FireServer()

					script.ragdoll.Value = true
				end
			end
		end
	end

	--RAYCAST
	local RAYHEIGHT = workspace:Raycast(char:FindFirstChild("LowerTorso").Position,Vector3.new(0,-hum.HipHeight - 0.45,0),parasm)

	-- Camera shake on landing impact
	if script.ragdoll.Value == true then
		local currentlyGrounded = RAYHEIGHT ~= nil
		if currentlyGrounded and not onGroundPrev then
			local impactVel = char:FindFirstChild("UpperTorso").Velocity.Magnitude
			-- GTA-style: strong, short shake for hard landings, softer for light
			local shakeAmount = math.clamp(impactVel/12, 1, 10)
			local shakeDur = math.clamp(impactVel/40, 0.15, 0.5)
			print("Landing impact! Velocity:", impactVel, "Shake amount:", shakeAmount, "Duration:", shakeDur)
			startShake(shakeAmount, shakeDur)
		end
		onGroundPrev = currentlyGrounded
	else
		onGroundPrev = false
	end

	local RAYHIGHHEIGHT = workspace:Raycast(char:FindFirstChild("LowerTorso").Position,Vector3.new(0,-hum.HipHeight - 7,0),parasm)

	--BEHAVIOR
	local RAYHIGHHEIGHT = workspace:Raycast(char:FindFirstChild("LowerTorso").Position,Vector3.new(0,-hum.HipHeight - 7,0),parasm)

	-- Skip all balancing when character is dead
	if hum:GetState() == Enum.HumanoidStateType.Dead then
		return -- Don't apply balancing forces when dead
	end
	
	--BEHAVIOR

	--GRABBING

	behaviorpropertiesFolder.grabbing.LeftHand.Attachment0 = char:FindFirstChild("LeftHand").LeftGripAttachment
	behaviorpropertiesFolder.grabbing.RightHand.Attachment0 = char:FindFirstChild("RightHand").RightGripAttachment

	--if the grab is in the object, it will automaticly activated

	if script.ragdoll.Value == true then

		if char:FindFirstChild("LeftHand").Velocity.Magnitude <= 4 then
			behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 = nil
		end
		if char:FindFirstChild("RightHand").Velocity.Magnitude <= 4 then
			behaviorpropertiesFolder.grabbing.RightHand.Attachment1 = nil
		end


		if behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 ~= nil then
			behaviorpropertiesFolder.grabbing.LeftHand.Enabled = true
		else
			behaviorpropertiesFolder.grabbing.LeftHand.Enabled = false
		end
		if behaviorpropertiesFolder.grabbing.RightHand.Attachment1 ~= nil then
			behaviorpropertiesFolder.grabbing.RightHand.Enabled = true
		else
			behaviorpropertiesFolder.grabbing.RightHand.Enabled = false
		end
	else
		behaviorpropertiesFolder.grabbing.LeftHand.Enabled = false
		behaviorpropertiesFolder.grabbing.RightHand.Enabled = false

		--stop grabbing when is not ragdolling
		behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 = nil
		behaviorpropertiesFolder.grabbing.RightHand.Attachment1 = nil
	end

	--BULLET SHOT

	if script.ragdoll.Value == true then
		if GETTINGSHOOTBY == true then
			behaviorpropertiesFolder.bulletshot.LeftHandAlign.Enabled = true
		else
			behaviorpropertiesFolder.bulletshot.LeftHandAlign.Enabled = false
		end
	else
		behaviorpropertiesFolder.bulletshot.LeftHandAlign.Enabled = false
	end

	behaviorpropertiesFolder.bulletshot.LeftHandAlign.Attachment0 = char:FindFirstChild("LeftHand").LeftGripAttachment
	if char:FindFirstChild("UpperTorso"):FindFirstChild("bulletshotattach") then
		GETTINGSHOOTBY = true
		behaviorpropertiesFolder.bulletshot.LeftHandAlign.Attachment1 = char:FindFirstChild("UpperTorso"):FindFirstChild("bulletshotattach")
	else
		GETTINGSHOOTBY = false
	end



	--FALL

	if script:FindFirstChild("air") then
		script.air.Parent = char:FindFirstChild("UpperTorso")
	end	

	if script.ragdoll.Value == true then
		if ResistanceSitCurrent == false then
			if char:FindFirstChild("LowerTorso") then
				if char.UpperTorso.Velocity.Y <= -40 then
					if char.UpperTorso:FindFirstChild("air") then
						char.UpperTorso:FindFirstChild("air").MaxTorque = Vector3.new(40,0,40)
						char.UpperTorso:FindFirstChild("air").P = 10000
					end
				else
					if char.UpperTorso:FindFirstChild("air") then
						char.UpperTorso:FindFirstChild("air").MaxTorque = Vector3.new(0,0,0)
						char.UpperTorso:FindFirstChild("air").P = 0
					end
				end
			end
		else
			if char:FindFirstChild("LowerTorso") then
				if char.UpperTorso:FindFirstChild("air") then
					char.UpperTorso:FindFirstChild("air").MaxTorque = Vector3.new(0,0,0)
					char.UpperTorso:FindFirstChild("air").P = 0
				end
			end
		end
	else -- false
		if char:FindFirstChild("LowerTorso") then
			if char.UpperTorso:FindFirstChild("air") then
				char.UpperTorso:FindFirstChild("air").MaxTorque = Vector3.new(0,0,0)
				char.UpperTorso:FindFirstChild("air").P = 0
			end
		end
	end

	if GROUND == false then

		if script.ragdoll.Value == true then
			char:FindFirstChild("LowerTorso").RotVelocity = Vector3.new(-3,0,0)
		end

		constraintsFolder.Waist.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Neck.MaxFrictionTorque = InFallMaxFrictionConstraints

		constraintsFolder.Shoulders.Right.Shoulder.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Shoulders.Right.Elbow.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Shoulders.Right.Wrist.MaxFrictionTorque = InFallMaxFrictionConstraints

		constraintsFolder.Shoulders.Left.Shoulder.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Shoulders.Left.Elbow.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Shoulders.Left.Wrist.MaxFrictionTorque = InFallMaxFrictionConstraints

		constraintsFolder.Hips.Right.Hip.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Hips.Right.Knee.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Hips.Right.Ankle.MaxFrictionTorque = InFallMaxFrictionConstraints

		constraintsFolder.Hips.Left.Hip.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Hips.Left.Knee.MaxFrictionTorque = InFallMaxFrictionConstraints
		constraintsFolder.Hips.Left.Ankle.MaxFrictionTorque = InFallMaxFrictionConstraints

	end

	if script.ragdoll.Value == true then
		if BALANCE == false then
			if GROUND == false then

				behaviorpropertiesFolder.fall.LeftFootOrienAlign.Enabled = true
				behaviorpropertiesFolder.fall.RightFootOrienAlign.Enabled = true

				behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Enabled = true

			else

				behaviorpropertiesFolder.fall.LeftFootOrienAlign.Enabled = false
				behaviorpropertiesFolder.fall.RightFootOrienAlign.Enabled = false

				behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Enabled = false

			end

		else

			behaviorpropertiesFolder.fall.LeftFootOrienAlign.Enabled = false
			behaviorpropertiesFolder.fall.RightFootOrienAlign.Enabled = false

			behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Enabled = false

		end
	else
		behaviorpropertiesFolder.fall.LeftFootOrienAlign.Enabled = false
		behaviorpropertiesFolder.fall.RightFootOrienAlign.Enabled = false

		behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Enabled = false
	end

	leftfootfallattach.Orientation = Vector3.new(FallKneeRotationCurrent,0,0)
	rightfootfallattach.Orientation = Vector3.new(FallKneeRotationCurrent2,0,0)

	leftupperarmfallattach.Orientation = LeftShoulderOrienCurrentFall
	rightupperarmfallattach.Orientation = RightShoulderOrienCurrentFall

	leftlowerarmfallattach.Orientation = LeftElbowOrienCurrentFall
	rightlowerarmfallattach.Orientation = RightElbowOrienCurrentFall

	leftfootfallattach.Parent = char:FindFirstChild("LowerTorso")
	rightfootfallattach.Parent = char:FindFirstChild("LowerTorso")

	leftupperarmfallattach.Parent = char:FindFirstChild("UpperTorso")
	rightupperarmfallattach.Parent = char:FindFirstChild("UpperTorso")

	leftlowerarmfallattach.Parent = char:FindFirstChild("LeftUpperArm")
	rightlowerarmfallattach.Parent = char:FindFirstChild("RightUpperArm")


	--GROUND

	if char:FindFirstChild("UpperTorso").Velocity.Magnitude >= 20 then
		for _,v in pairs(behaviorpropertiesFolder:FindFirstChild("ground"):GetChildren()) do
			if v:IsA("AlignOrientation") then
				v.MaxTorque = GroundMAXTORQUEINVELOCITY
			end
		end
	else
		for _,v in pairs(behaviorpropertiesFolder:FindFirstChild("ground"):GetChildren()) do
			if v:IsA("AlignOrientation") then
				v.MaxTorque = GroundMAXTORQUEOUTVELOCITY
			end
		end
	end

	if RAYHIGHHEIGHT then

		GROUND = true

		if BALANCE == false then

			if script.ragdoll.Value == true then
				char:FindFirstChild("LowerTorso").RotVelocity = char:FindFirstChild("LowerTorso").RotVelocity * 1.25
			end

			constraintsFolder.Waist.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Neck.MaxFrictionTorque = InGroundMaxFrictionConstraints

			constraintsFolder.Shoulders.Right.Shoulder.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Elbow.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Wrist.MaxFrictionTorque = InGroundMaxFrictionConstraints

			constraintsFolder.Shoulders.Left.Shoulder.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Elbow.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Wrist.MaxFrictionTorque = InGroundMaxFrictionConstraints

			constraintsFolder.Hips.Right.Hip.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Hips.Right.Knee.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Hips.Right.Ankle.MaxFrictionTorque = InGroundMaxFrictionConstraints

			constraintsFolder.Hips.Left.Hip.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Hips.Left.Knee.MaxFrictionTorque = InGroundMaxFrictionConstraints
			constraintsFolder.Hips.Left.Ankle.MaxFrictionTorque = InGroundMaxFrictionConstraints

		end

	else

		GROUND = false

	end

	if script.ragdoll.Value == true then
		if BALANCE == false then
			if GROUND == true then

				behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.LeftFootOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.RightFootOrienAlign.Enabled = true

				behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Enabled = true
				behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Enabled = true

			else

				behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.LeftFootOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.RightFootOrienAlign.Enabled = false

				behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Enabled = false
				behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Enabled = false

			end

		else

			behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.LeftFootOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.RightFootOrienAlign.Enabled = false

			behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Enabled = false
			behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Enabled = false

		end
	else
		behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.LeftFootOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.RightFootOrienAlign.Enabled = false

		behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Enabled = false
		behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Enabled = false
	end

	leftupperleggroundattach.Orientation = LeftHipOrienCurrentGround
	rightupperleggroundattach.Orientation = RightHipOrienCurrentGround

	leftfootgroundattach.Orientation = LeftKneeOrienCurrentGround
	rightfootgroundattach.Orientation = RightKneeOrienCurrentGround

	leftupperarmgroundattach.Orientation = LeftShoulderOrienCurrentGround
	rightupperarmgroundattach.Orientation = RightShoulderOrienCurrentGround

	leftlowerarmgroundattach.Orientation = LeftElbowOrienCurrentGround
	rightlowerarmgroundattach.Orientation = RightElbowOrienCurrentGround

	leftupperleggroundattach.Parent = char:FindFirstChild("UpperTorso")
	rightupperleggroundattach.Parent = char:FindFirstChild("UpperTorso")

	leftfootgroundattach.Parent = char:FindFirstChild("LeftUpperLeg")
	rightfootgroundattach.Parent = char:FindFirstChild("RightUpperLeg")

	leftupperarmgroundattach.Parent = char:FindFirstChild("UpperTorso")
	rightupperarmgroundattach.Parent = char:FindFirstChild("UpperTorso")

	leftlowerarmgroundattach.Parent = char:FindFirstChild("LeftUpperArm")
	rightlowerarmgroundattach.Parent = char:FindFirstChild("RightUpperArm")

	--BALANCE

	local RAYIFTHEPLAYERDOWN = workspace:Raycast(char:FindFirstChild("UpperTorso").Position,Vector3.new(0,-1.75,0),parasm)


	if char:FindFirstChild("UpperTorso").Velocity.Magnitude >= 25 then
		DontBalanceInOver25velocity = true
	else
		DontBalanceInOver25velocity = false
	end

	if RAYHEIGHT then
		if DontBalanceInOver25velocity == false then
			if ONLYBALANCEONETIME == true then
				BALANCE = true
				ONLYBALANCEONETIME = false

				constraintsFolder.Waist.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Neck.MaxFrictionTorque = InBalanceMaxFrictionConstraints

				constraintsFolder.Shoulders.Right.Shoulder.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Shoulders.Right.Elbow.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Shoulders.Right.Wrist.MaxFrictionTorque = InBalanceMaxFrictionConstraints

				constraintsFolder.Shoulders.Left.Shoulder.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Shoulders.Left.Elbow.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Shoulders.Left.Wrist.MaxFrictionTorque = InBalanceMaxFrictionConstraints

				constraintsFolder.Hips.Right.Hip.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Hips.Right.Knee.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Hips.Right.Ankle.MaxFrictionTorque = InBalanceMaxFrictionConstraints

				constraintsFolder.Hips.Left.Hip.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Hips.Left.Knee.MaxFrictionTorque = InBalanceMaxFrictionConstraints
				constraintsFolder.Hips.Left.Ankle.MaxFrictionTorque = InBalanceMaxFrictionConstraints

			end
		end
		if DontBalanceInOver25velocity == true then
			ONLYBALANCEONETIME = false
		end
	end

	if RAYIFTHEPLAYERDOWN then
		if BALANCE == true then

			constraintsFolder.Shoulders.Right.Shoulder.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Elbow.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Wrist.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Shoulders.Left.Shoulder.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Elbow.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Wrist.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Hips.Right.Hip.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Right.Knee.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Right.Ankle.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Hips.Left.Hip.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Left.Knee.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Left.Ankle.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			ONLYBALANCEONETIME = false
			BALANCE = false
		end
	end

	if not RAYHIGHHEIGHT then
		ONLYBALANCEONETIME = false

		if BALANCE == true then
			constraintsFolder.Shoulders.Right.Shoulder.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Elbow.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Right.Wrist.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Shoulders.Left.Shoulder.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Elbow.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Shoulders.Left.Wrist.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Hips.Right.Hip.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Right.Knee.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Right.Ankle.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints

			constraintsFolder.Hips.Left.Hip.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Left.Knee.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			constraintsFolder.Hips.Left.Ankle.MaxFrictionTorque = OutBehaviourMaxFrictionConstraints
			BALANCE = false
		end
	end

	if script.ragdoll.Value == true then
		if BALANCE == true then
			behaviorpropertiesFolder.balancing.LeftFootAlign.Enabled = true
			behaviorpropertiesFolder.balancing.LeftFootOrienAlign.Enabled = true
			behaviorpropertiesFolder.balancing.RightFootAlign.Enabled = true
			behaviorpropertiesFolder.balancing.RightFootOrienAlign.Enabled = true

			behaviorpropertiesFolder.balancing.LeftHandAlign.Enabled = true
			behaviorpropertiesFolder.balancing.RightHandAlign.Enabled = true
		else
			behaviorpropertiesFolder.balancing.LeftFootAlign.Enabled = false
			behaviorpropertiesFolder.balancing.LeftFootOrienAlign.Enabled = false
			behaviorpropertiesFolder.balancing.RightFootAlign.Enabled = false
			behaviorpropertiesFolder.balancing.RightFootOrienAlign.Enabled = false

			behaviorpropertiesFolder.balancing.LeftHandAlign.Enabled = false
			behaviorpropertiesFolder.balancing.RightHandAlign.Enabled = false
		end
	else
		behaviorpropertiesFolder.balancing.LeftFootAlign.Enabled = false
		behaviorpropertiesFolder.balancing.LeftFootOrienAlign.Enabled = false
		behaviorpropertiesFolder.balancing.RightFootAlign.Enabled = false
		behaviorpropertiesFolder.balancing.RightFootOrienAlign.Enabled = false

		behaviorpropertiesFolder.balancing.LeftHandAlign.Enabled = false
		behaviorpropertiesFolder.balancing.RightHandAlign.Enabled = false
	end

	if script:FindFirstChild("UPPERBG") then
		script.UPPERBG.Parent = char:FindFirstChild("UpperTorso")
	end

	if script:FindFirstChild("LOWERBG") then
		script.LOWERBG.Parent = char:FindFirstChild("LowerTorso")
	end

	leftfootbalanceattach.Parent = char:FindFirstChild("LowerTorso")
	rightfootbalanceattach.Parent = char:FindFirstChild("LowerTorso")

	lefthandbalanceattach.Parent = char:FindFirstChild("LowerTorso")
	righthandbalanceattach.Parent = char:FindFirstChild("LowerTorso")

	--leftfootbalanceattach.Position = Vector3.new(-0.5,-hum.HipHeight + BalanceFootStepCurrentDistHeight,BalanceFootStepCurrentDist)
	--rightfootbalanceattach.Position = Vector3.new(0.5,-hum.HipHeight - BalanceFootStepCurrentDistHeight,-BalanceFootStepCurrentDist)

	local RightVel = char:FindFirstChild("UpperTorso").Velocity:Dot(char:FindFirstChild("UpperTorso").CFrame.RightVector * 0.05)
	local FrontVel = char:FindFirstChild("UpperTorso").Velocity:Dot(char:FindFirstChild("UpperTorso").CFrame.LookVector * 0.05) + 1

	if BalanceWalkInReverse == false then
		leftfootbalanceattach.Position = Vector3.new(-CurrentWideLeg + BalanceFootStepCurrentDist * RightVel,-hum.HipHeight + BalanceFootStepCurrentDistHeight + 0.65,BalanceFootStepCurrentDist * FrontVel)
		rightfootbalanceattach.Position = Vector3.new(CurrentWideLeg - BalanceFootStepCurrentDist * RightVel,-hum.HipHeight + BalanceFootStepCurrentDistHeight2 + 0.65,-BalanceFootStepCurrentDist * FrontVel)
	else
		leftfootbalanceattach.Position = Vector3.new(-CurrentWideLeg + BalanceFootStepCurrentDist * RightVel,-hum.HipHeight - BalanceFootStepCurrentDistHeight + 0.65,-BalanceFootStepCurrentDist * FrontVel)
		rightfootbalanceattach.Position = Vector3.new(CurrentWideLeg - BalanceFootStepCurrentDist * RightVel,-hum.HipHeight - BalanceFootStepCurrentDistHeight2 + 0.65,BalanceFootStepCurrentDist * FrontVel)
	end

	lefthandbalanceattach.Position = Vector3.new(-1.4,0.2,-0.4 - char:FindFirstChild("UpperTorso").Velocity:Dot(char:FindFirstChild("UpperTorso").CFrame.LookVector * 0.1))
	righthandbalanceattach.Position = Vector3.new(1.4,0.2,-0.4 - char:FindFirstChild("UpperTorso").Velocity:Dot(char:FindFirstChild("UpperTorso").CFrame.LookVector * 0.1))

	if script.ragdoll.Value == true then
		if BALANCE == true then
			char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").D = BalanceD
			char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").D = BalanceD

			char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").MaxTorque = Vector3.new(BalanceMaxForce,BalanceMaxForce,BalanceMaxForce)
			char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").MaxTorque = Vector3.new(BalanceMaxForce,BalanceMaxForce,BalanceMaxForce)
		else
			char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").D = 0
			char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").D = 0

			char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").MaxTorque = Vector3.new(0,0,0)
			char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").MaxTorque = Vector3.new(0,0,0)
		end
	else
		char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").D = 0
		char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").D = 0

		char:FindFirstChild("UpperTorso"):FindFirstChild("UPPERBG").MaxTorque = Vector3.new(0,0,0)
		char:FindFirstChild("LowerTorso"):FindFirstChild("LOWERBG").MaxTorque = Vector3.new(0,0,0)
	end

	if GETTINGSHOOTBY == true then
		behaviorpropertiesFolder.balancing.LeftHandAlign.MaxForce = 0
		behaviorpropertiesFolder.balancing.LeftHandAlign.MaxVelocity = 0
	else
		behaviorpropertiesFolder.balancing.LeftHandAlign.MaxForce = 450
		behaviorpropertiesFolder.balancing.LeftHandAlign.MaxVelocity = 50
	end

	--SET ATTACHMENT ALIGNS FOR BEHAVOIUR

	--BALANCE's

	behaviorpropertiesFolder.balancing.LeftFootAlign.Attachment0 = char:FindFirstChild("LeftFoot").LeftAnkleRigAttachment
	behaviorpropertiesFolder.balancing.LeftFootAlign.Attachment1 = char:FindFirstChild("LowerTorso").leftfootbalanceattach

	behaviorpropertiesFolder.balancing.RightFootAlign.Attachment0 = char:FindFirstChild("RightFoot").RightAnkleRigAttachment
	behaviorpropertiesFolder.balancing.RightFootAlign.Attachment1 = char:FindFirstChild("LowerTorso").rightfootbalanceattach

	behaviorpropertiesFolder.balancing.LeftFootOrienAlign.Attachment0 = char:FindFirstChild("LeftFoot").LeftAnkleRigAttachment
	behaviorpropertiesFolder.balancing.LeftFootOrienAlign.Attachment1 = char:FindFirstChild("LowerTorso").WaistRigAttachment

	behaviorpropertiesFolder.balancing.RightFootOrienAlign.Attachment0 = char:FindFirstChild("RightFoot").RightAnkleRigAttachment
	behaviorpropertiesFolder.balancing.RightFootOrienAlign.Attachment1 = char:FindFirstChild("LowerTorso").WaistRigAttachment


	behaviorpropertiesFolder.balancing.LeftHandAlign.Attachment0 = char:FindFirstChild("LeftHand").LeftWristRigAttachment
	behaviorpropertiesFolder.balancing.LeftHandAlign.Attachment1 = char:FindFirstChild("LowerTorso").lefthandbalanceattach

	behaviorpropertiesFolder.balancing.RightHandAlign.Attachment0 = char:FindFirstChild("RightHand").RightWristRigAttachment
	behaviorpropertiesFolder.balancing.RightHandAlign.Attachment1 = char:FindFirstChild("LowerTorso").righthandbalanceattach

	--GROUND's
	behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Attachment0 = char:FindFirstChild("LeftUpperLeg").LeftHipRigAttachment
	behaviorpropertiesFolder.ground.LeftUpperLegOrienAlign.Attachment1 = leftupperleggroundattach

	behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Attachment0 = char:FindFirstChild("RightUpperLeg").RightHipRigAttachment
	behaviorpropertiesFolder.ground.RightUpperLegOrienAlign.Attachment1 = rightupperleggroundattach

	behaviorpropertiesFolder.ground.LeftFootOrienAlign.Attachment0 = char:FindFirstChild("LeftLowerLeg").LeftKneeRigAttachment
	behaviorpropertiesFolder.ground.LeftFootOrienAlign.Attachment1 = leftfootgroundattach

	behaviorpropertiesFolder.ground.RightFootOrienAlign.Attachment0 = char:FindFirstChild("RightLowerLeg").RightKneeRigAttachment
	behaviorpropertiesFolder.ground.RightFootOrienAlign.Attachment1 = rightfootgroundattach


	behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Attachment0 = char:FindFirstChild("LeftLowerArm").LeftElbowRigAttachment
	behaviorpropertiesFolder.ground.LeftLowerArmOrienAlign.Attachment1 = leftlowerarmgroundattach

	behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Attachment0 = char:FindFirstChild("RightLowerArm").RightElbowRigAttachment
	behaviorpropertiesFolder.ground.RightLowerArmOrienAlign.Attachment1 = rightlowerarmgroundattach

	behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Attachment0 = char:FindFirstChild("LeftUpperArm").LeftShoulderRigAttachment
	behaviorpropertiesFolder.ground.LeftUpperArmOrienAlign.Attachment1 = leftupperarmgroundattach

	behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Attachment0 = char:FindFirstChild("RightUpperArm").RightShoulderRigAttachment
	behaviorpropertiesFolder.ground.RightUpperArmOrienAlign.Attachment1 = rightupperarmgroundattach

	--FALL's
	behaviorpropertiesFolder.fall.LeftFootOrienAlign.Attachment0 = char:FindFirstChild("LeftLowerLeg").LeftKneeRigAttachment
	behaviorpropertiesFolder.fall.LeftFootOrienAlign.Attachment1 = leftfootfallattach

	behaviorpropertiesFolder.fall.RightFootOrienAlign.Attachment0 = char:FindFirstChild("RightLowerLeg").RightKneeRigAttachment
	behaviorpropertiesFolder.fall.RightFootOrienAlign.Attachment1 = rightfootfallattach


	behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Attachment0 = char:FindFirstChild("LeftLowerArm").LeftElbowRigAttachment
	behaviorpropertiesFolder.fall.LeftLowerArmOrienAlign.Attachment1 = leftlowerarmfallattach

	behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Attachment0 = char:FindFirstChild("RightLowerArm").RightElbowRigAttachment
	behaviorpropertiesFolder.fall.RightLowerArmOrienAlign.Attachment1 = rightlowerarmfallattach

	behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Attachment0 = char:FindFirstChild("LeftUpperArm").LeftShoulderRigAttachment
	behaviorpropertiesFolder.fall.LeftUpperArmOrienAlign.Attachment1 = leftupperarmfallattach

	behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Attachment0 = char:FindFirstChild("RightUpperArm").RightShoulderRigAttachment
	behaviorpropertiesFolder.fall.RightUpperArmOrienAlign.Attachment1 = rightupperarmfallattach

	--VISIBLES ATTACHMENT

	leftfootbalanceattach.Visible = footbalanceattachvisible
	rightfootbalanceattach.Visible = footbalanceattachvisible

	lefthandbalanceattach.Visible = footbalanceattachvisible
	righthandbalanceattach.Visible = footbalanceattachvisible


	--FALL CODED

	if falldontloop == false then
		falldontloop = true
		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent + FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 - FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		FallKneeRotationCurrent = FallKneeRotationCurrent - FallKneeRotation
		FallKneeRotationCurrent2 = FallKneeRotationCurrent2 + FallKneeRotation

		task.wait(FallTimeLoop)

		falldontloop = false
	end
end)

--GRABBING ON OBJECTS
char:FindFirstChild("RightHand").Touched:Connect(function(hit)
	if not hit.Parent:IsA("Tool") then -- not to detect the tool
		if script.ragdoll.Value == true then
			if not hit.Parent:IsA("Accesories") then -- not to detect accesories unless
				if hit.CanCollide == true then --not to detect the non collide
					if hit.Anchored == false then --dont detect the anchored part
						if hit.Velocity.Magnitude >= 10 then --detecting up to velocity magnitude
							if not hit.Parent:FindFirstChildOfClass("Humanoid") then -- not to detect players
								if not hit.Parent.Name ~= script.Parent.Name then

									if behaviorpropertiesFolder.grabbing.RightHand.Attachment1 == nil then -- if is not already here

										local attachgrab = Instance.new("Attachment")
										attachgrab.Parent = hit
										attachgrab.Name = "GRABBINGATTACH"
										attachgrab.WorldPosition = char:FindFirstChild("RightHand").Position

										behaviorpropertiesFolder.grabbing.RightHand.Attachment1 = attachgrab
										wait(5) --after delay and destroy attachment
										behaviorpropertiesFolder.grabbing.RightHand.Attachment1 = nil
										attachgrab:Destroy()
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
char:FindFirstChild("LeftHand").Touched:Connect(function(hit)
	if not hit.Parent:IsA("Tool") then -- not to detect the tool
		if script.ragdoll.Value == true then
			if not hit.Parent:IsA("Accesories") then -- not to detect accesories unless
				if hit.CanCollide == true then --not to detect the non collide
					if hit.Anchored == false then --dont detect the anchored part
						if hit.Velocity.Magnitude >= 10 then --detecting up to velocity magnitude
							if not hit.Parent:FindFirstChildOfClass("Humanoid") then -- not to detect players
								if not hit.Parent.Name ~= script.Parent.Name then

									if behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 == nil then -- if is not already here

										local attachgrab = Instance.new("Attachment")
										attachgrab.Parent = hit
										attachgrab.Name = "GRABBINGATTACH"
										attachgrab.WorldPosition = char:FindFirstChild("LeftHand").Position

										behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 = attachgrab
										wait(5) --after delay and destroy attachment
										behaviorpropertiesFolder.grabbing.LeftHand.Attachment1 = nil
										attachgrab:Destroy()
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)

--GETTING CRASH BY OBJECTS
char:FindFirstChildOfClass("Humanoid").Touched:Connect(function(hit)
	if not hit.Parent:IsA("Tool") then -- not to detect the tool
		if DontRagdollCD == false then
			if not hit.Parent:IsA("Accessory") then
				if ResistanceSitCurrent == false then
					if RagdollByGettingCrashByObjectsRequire == true then
						if script.ragdoll.Value == false then
							if not hit.Parent:FindFirstChildOfClass("Humanoid") then
								if hit.Velocity.Magnitude >= GettingCrashByObjectSpeed then
									hum:ChangeState(Enum.HumanoidStateType.Physics)
									hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

									--VALUES
									ONLYBALANCEONETIME = true

									--EVENTS
									char:FindFirstChild("events").ragdollOn:FireServer()

									script.ragdoll.Value = true
								end
								if hit.RotVelocity.Magnitude >= GettingCrashByObjectOrientationSpeed then
									hum:ChangeState(Enum.HumanoidStateType.Physics)
									hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

									--VALUES
									ONLYBALANCEONETIME = true

									--EVENTS
									char:FindFirstChild("events").ragdollOn:FireServer()

									script.ragdoll.Value = true
								end
							end
							if hit.Parent:FindFirstChildOfClass("Humanoid") then
								if hit.Velocity.Magnitude >= GettingCrashByPlayerRagdolledSpeed then
									if not hit.Parent:IsA("Accessory") then
										if hit.Parent:FindFirstChild("server").ragdoll.Value == true then
											hum:ChangeState(Enum.HumanoidStateType.Physics)
											hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

											--VALUES
											ONLYBALANCEONETIME = true

											--EVENTS
											char:FindFirstChild("events").ragdollOn:FireServer()

											script.ragdoll.Value = true
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)

while task.wait(BalanceWalkTimeLoop) do
	CurrentWideLeg = math.random(65,105) * 0.01

	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)

	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)

	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight

	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist - BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)

	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight - BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 + BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
	BalanceFootStepCurrentDist = BalanceFootStepCurrentDist + BalanceFootStepDist

	BalanceFootStepCurrentDistHeight2 = BalanceFootStepCurrentDistHeight2 - BalanceFootStepDistHeight

	BalanceFootStepCurrentDistHeight = BalanceFootStepCurrentDistHeight + BalanceFootStepDistHeight
	task.wait(BalanceWalkTimeLoop)
end