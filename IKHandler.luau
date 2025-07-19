--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--||	
--**--**--**--**--**--||	INTRODUCTION AND EXPLANATION
--**--**--**--**--**--||	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

--[[
"In computer animation and robotics, inverse kinematics is the mathematical process of calculating the variable joint parameters needed to place the end of a kinematic chain,
such as a robot manipulator or animation Character's skeleton, in a given position and orientation relative to the start of the chain. Given joint parameters, the position and
orientation of the chain's end, e.g. the hand of the Character or robot, can typically be calculated directly using multiple applications of trigonometric formulas, a process
known as forward kinematics. However, the reverse operation is, in general, much more challenging."
		(Definition provided via Wikipedia)

Inverse Kinematics requires profecient knowledge of trig and some minor aspects of calculus (a.k.a "precal").
This is because we are manipulating Coordinate Frames (CFrames); CFrames are matrixes, meaning we can only do calculations via multiplication.
We use trig functions to create fluid movement animation.

-- This IK_HANDLER is derived from a deprecated script. Find it here: https://www.youtube.com/watch?v=XfedvejJBGY
-- Please watch the video for a better understanding of IK!
--]]

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--||	
--**--**--**--**--**--||	CONSTANT VARIABLES AND CLASS DECLARATION
--**--**--**--**--**--||	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

local IK_HANDLER = {}
IK_HANDLER.__index = IK_HANDLER




local player = game.Players.LocalPlayer
local Pi = math.pi -- We are using radian-based angles (rather than degree), so we use Pi! Pi radians = 180 degrees
local HalfPi = Pi/2 -- Pi/2 radians = 90 degrees.
local Tau = 2*Pi -- 2pi radians = 360 degrees. And yes, Tau is a word! Represented by symbol 't'



local ForwardVector = Vector3.new(0,0,-1) -- Get a forward-directional Vector3
local YAxisExclusion = Vector3.new(0,0,0) -- This will be used later; Vector3*YAxisExclusion will remove the middle value, or the y-value.
local Camera = workspace.CurrentCamera



--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--||	
--**--**--**--**--**--||	PRIVATE FUNCTIONS
--**--**--**--**--**--||	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--


local function SolveLegIK(OriginCFrame,TargetPosition,a,b) -- Does the major math calculations for IK | OriginCFrame, TargetPosition, ClampA, ClampB
	-- Make the position local relative to the origin
	local l = OriginCFrame:pointToObjectSpace(TargetPosition) -- World space to local space
	local lu = l.Unit -- Get normalized unit for future math
	
	local c = l.Magnitude -- Get the length from the position to the target
	-- Make a CFrame pointing from the shoulder position directing to the second position
	local x = ForwardVector:Cross(-lu) -- Cross the forward vector with the negative of the normalized unit
	local g = math.acos(-lu.Z) -- Get the arc-cosine of the negative normalized unit
	local p = OriginCFrame*CFrame.fromAxisAngle(x,g):Inverse() -- Get the IK plane
	
	-- In a self.RightRotationAngle-triangle, we have the hypotenuse and the two shorter legs.
	-- In a self.RightRotationAngle triangle, the hypotenuse is side "c," and the legs are a and b.
	-- This information will be helpful later on.
	
	if c < math.max(b,a)-math.min(b,a) then
		-- If c is between the lengths of a and b then return an offsetted plane so that one of the lengths reaches the goal,
		-- but the other length is folded so it looks natural
		-- This cacluation is done when a position comes before the end of the leg, and may look a bit... odd
		
		return p*CFrame.new(0,0,math.max(b,a)-math.min(b,a)-c),-HalfPi,Pi
	elseif c > a+b then
		-- If c > a + b then return flat angles and an offsetted plane which reaches its target
		-- Basically, this makes the leg flat if there is nothing to place it on
		
		return p,HalfPi,0
	else
		-- Otherwise, use the law of cosines
		-- This is going to be all cases where the leg actually bends
		
		local Theta1 = -math.acos((-(b*b)+(a*a)+(c*c))/(2*a*c))
		local Theta2 = math.acos(((b*b)-(a*a)+(c*c))/(2*b*c))
		return p,HalfPi-Theta1,-(Theta2-Theta1)
	end
end

local function lerpNumber(a,b,t)return (a+(b-a)*t)end  -- Get a number between a and b, given the alpha (t, which can be a number anywhere between 0-1).

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--||	
--**--**--**--**--**--||	CLASS CONSTRUCTOR, VARIABLES, AND METHODS
--**--**--**--**--**--||	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

local RaycastParameters = RaycastParams.new()
RaycastParameters.IgnoreWater = true
RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist

local ParamBlacklist = {}

IK_HANDLER.ActiveInstances = {}
	
function IK_HANDLER.New(Character, Stride, CycleSpeed, MaxRenderDistance, RaycastOffset)	
	
	
	
	local Stride = Stride or 2.6
	local CycleSpeed = CycleSpeed or 10
	local MaxRenderDistance = MaxRenderDistance or 150
	local RaycastOffset = RaycastOffset or 0.3
	
	local self = {}
	
	
	
	self.Character = Character
	self.Humanoid = Character:WaitForChild("Humanoid")
	self.HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	self.TargetBaseBart	= Character:WaitForChild("LowerTorso")
	self.WaistJoint = Character:WaitForChild("UpperTorso"):WaitForChild("Waist")
	self.RootJoint = self.TargetBaseBart:WaitForChild("Root")
	self.WaistCFrame1 = self.WaistJoint.C1
	
	
	self.RightHip = Character:WaitForChild("RightUpperLeg"):WaitForChild("RightHip")
	self.RightKnee = Character:WaitForChild("RightLowerLeg"):WaitForChild("RightKnee")
	self.RightAnkle = Character:WaitForChild("RightFoot"):WaitForChild("RightAnkle")
	
	self.LeftHip = Character:WaitForChild("LeftUpperLeg"):WaitForChild("LeftHip")
	self.LeftKnee = Character:WaitForChild("LeftLowerLeg"):WaitForChild("LeftKnee")
	self.LeftAnkle = Character:WaitForChild("LeftFoot"):WaitForChild("LeftAnkle")
	
	
	self.RootJointCFrame0 = self.RootJoint.C0
	
	self.RightHipCFrame0 = self.RightHip.C0
	self.RightKneeCFrame0 = self.RightKnee.C0
	self.RightAnkleCFrame0 = self.RightAnkle.C0
	
	self.LeftHipCFrame0 = self.LeftHip.C0
	self.LeftKneeCFrame0 = self.LeftKnee.C0
	self.LeftAnkleCFrame0 = self.LeftAnkle.C0
	
	
	self.LeftRotationAngle = 0
	self.RightRotationAngle	= Pi
	self.Direction = YAxisExclusion -- This will be changed
	self.CycleSpeed = CycleSpeed -- How fast the leg-movement cycle is. Change this to suit your needs!
	self.StrideCFrame = CFrame.new(0,0,-Stride/2) -- Turn the Stride number into a CFrame we can use for animation
	self.PreviousTick = tick()
	self.Enabled = true
	self.MaxRenderDistance = MaxRenderDistance
	self.RaycastOffset = RaycastOffset
	
	
	IK_HANDLER.ActiveInstances[self] = true
	
	IK_HANDLER.UpdateRaycastBlacklist()
	
	return setmetatable(self, IK_HANDLER) -- We have made an I N S T A N C E (*laughs in programming*)
end

function IK_HANDLER.UpdateRaycastBlacklist(Blacklist)	
	local FilterList = {}
	
	if Blacklist and type(Blacklist) == "table" then
		--ParamBlacklist = Blacklist
		FilterList = Blacklist
	end
	
	--local Mod = {}
	for self,_ in pairs(IK_HANDLER.ActiveInstances) do
		if self.Character then
			table.insert(FilterList, self.Character)
		end
	end
	
	
	RaycastParameters.FilterDescendantsInstances = FilterList --{unpack(Mod),unpack(ParamBlacklist)}
end

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--||	
--**--**--**--**--**--||	INSTANCE METHODS
--**--**--**--**--**--||	
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

function IK_HANDLER:IsActive()
	if not IK_HANDLER.ActiveInstances[self] then
		return false
	end
	
	if not self.Character or not self.Character.Parent then
		IK_HANDLER.ActiveInstances[self] = nil
		IK_HANDLER.UpdateRaycastBlacklist()
		return false
	end
	
	return true
end

function IK_HANDLER:Destroy()
	if IK_HANDLER.ActiveInstances[self] then
		IK_HANDLER.ActiveInstances[self] = nil
	end
	
	for Index, _ in pairs(self) do
		self[Index] = nil
	end
	
	self = nil
	
	IK_HANDLER.UpdateRaycastBlacklist()
end

function IK_HANDLER:Enable()
	self.Enabled = true
end

function IK_HANDLER:Disable()
	self.Enabled = false
end


function IK_HANDLER:Update()
	if not self.Enabled then
		return
	end
	
	if not self.Character or not self.Character.Parent then
		IK_HANDLER.ActiveInstances[self] = nil
		IK_HANDLER.UpdateRaycastBlacklist()
		return
	end
	
	--if not player.Character then 
	--	return
	--end
	
	
	local CurrentTick = tick()
	local Delta = math.clamp(CurrentTick - self.PreviousTick,0.00001,0.5)
	local Delta10 = math.min(Delta*10,1) -- Modify Delta for our needs
	

	local lowercf = self.TargetBaseBart.CFrame -- Our position
	local rootcf = self.HumanoidRootPart.CFrame -- Another position
	local rootvel0 = self.HumanoidRootPart.Velocity -- Our movement velocity
	local rootvel,rootvelm
	local climbing	= self.Humanoid:GetState() == Enum.HumanoidStateType.Climbing -- Are we climbing?

	
	local CameraPosition = Camera.CFrame.Position
	local RootPosition = rootcf.Position
	
	local _,IsOnScreen = Camera:WorldToScreenPoint(RootPosition)
	if not IsOnScreen or (CameraPosition - RootPosition).Magnitude > self.MaxRenderDistance then
		return
	end

	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	self.PreviousTick = CurrentTick

	if climbing then -- Don't animate if we are climbing, it looks weird
		rootvel = rootvel0
		rootvel = rootvel.Magnitude
		self.Direction = rootcf.lookVector
	else
		rootvel		=rootvel0*YAxisExclusion
		rootvelm	=rootvel.Magnitude

		if rootvelm > 0.1 then
			self.Direction = self.Direction:Lerp(rootvel.Unit, Delta10)
		end
	end

	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	if not rootvelm then return end
	local up =rootvelm/20
	local cycle = up * Delta * self.CycleSpeed
	
	self.RightRotationAngle = (self.RightRotationAngle+cycle)%Tau
	self.LeftRotationAngle = (self.LeftRotationAngle+cycle)%Tau
	local down = -rootcf.upVector
	
	-- By using modulus and Tau (Tau is a full circle roation), we keep rotations within our imaginary circle. Without this we get really weird joint movement.

	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

	if rootvelm > 0.1 then--0.1 then --// When moving
		local relv0 = lowercf:vectorToObjectSpace(rootvel)-- Object space is nice yes?
		local relv1 = relv0*0.2
		local relvx = relv0.X/rootvel.Magnitude

		
		local hpmod = HalfPi/20
		local kneeRot = 2
		local hipAlpha = Delta10*1.5 --Delta10*1.5
		local kneeAlpha = Delta10*1.5 --Delta10*1.5
		
		local rSY = self.HumanoidRootPart.Size.Y/2 -- half of root size y
		local rSX = self.HumanoidRootPart.Size.X/4 -- half of root size x
		
		
		do -- Right Leg
			
			------ dynamic scale to fit any character ------
			local hipMCF = self.RightHip.Part0.CFrame:ToWorldSpace(self.RightHipCFrame0)
			local KneeMCF = self.RightKnee.Part0.CFrame:ToWorldSpace(self.RightKneeCFrame0)
			local AnkleMCF = self.RightAnkle.Part0.CFrame:ToWorldSpace(self.RightAnkleCFrame0)
			
			local A = (KneeMCF.p-hipMCF.p).magnitude
			local B = (AnkleMCF.p-KneeMCF.p).magnitude
			local CenterHeight = (A+B)/2
			
			local hip = hipMCF.Position
			local ground = (hip + down*(self.Humanoid.HipHeight))
			------------------------------------------------
		
			local desiredPos = (CFrame.new(ground, ground+self.Direction)*CFrame.Angles(-self.RightRotationAngle, 0, 0)*self.StrideCFrame*CFrame.new(0,CenterHeight,0)).Position
			local offset = (desiredPos-hip)
			local raycastResult = workspace:Raycast(hip,offset.Unit*(offset.magnitude+0.6),RaycastParameters)
			local footPos = raycastResult and raycastResult.Position or (hip + offset.Unit*(offset.magnitude+self.RaycastOffset))
			
			local OriginCFrame = lowercf * self.RightHipCFrame0
			local Plane,HipAngle, KneeAngle = SolveLegIK(OriginCFrame,footPos,A,B)
			
			
			local NewRightHip = self.RightHipCFrame0 * OriginCFrame:ToObjectSpace(Plane) * CFrame.Angles(HipAngle, 0, 0)
			local NewRightKnee = self.RightKneeCFrame0 * CFrame.Angles(KneeAngle, 0, 0)	
			
			self.RightHip.C0 = self.RightHip.C0:Lerp(NewRightHip,hipAlpha)
			self.RightKnee.C0 = self.RightKnee.C0:Lerp(NewRightKnee,kneeAlpha)
			
		end
		

		do-- Left Leg
			
			------ dynamic scale to fit any character ------
			local hipMCF = self.LeftHip.Part0.CFrame:ToWorldSpace(self.LeftHipCFrame0)
			local KneeMCF = self.LeftKnee.Part0.CFrame:ToWorldSpace(self.LeftKneeCFrame0)
			local AnkleMCF = self.LeftAnkle.Part0.CFrame:ToWorldSpace(self.LeftAnkleCFrame0)

			local A = (KneeMCF.p-hipMCF.p).magnitude
			local B = (AnkleMCF.p-KneeMCF.p).magnitude
			local CenterHeight = (A+B)/2
			
			local hip = hipMCF.Position
			local ground = (hip + down*(self.Humanoid.HipHeight))
			---------------------------------------
			
			local desiredPos = (CFrame.new(ground, ground+self.Direction)*CFrame.Angles(-self.LeftRotationAngle, 0, 0)*self.StrideCFrame*CFrame.new(0,CenterHeight,0)).Position
			local offset = (desiredPos-hip)
			local raycastResult = workspace:Raycast(hip,offset.Unit*(offset.magnitude+0.6),RaycastParameters)
			
			local footPos = raycastResult and raycastResult.Position or desiredPos --  (hip + offset.Unit*(offset.magnitude+self.RaycastOffset))
			
			
			local OriginCFrame = lowercf * self.LeftHipCFrame0
			local Plane,HipAngle, KneeAngle = SolveLegIK(OriginCFrame,footPos,A,B)


			local NewLeftHip = self.LeftHipCFrame0 * OriginCFrame:ToObjectSpace(Plane) * CFrame.Angles(HipAngle, 0, 0)
			local NewLeftKnee = self.LeftKneeCFrame0 * CFrame.Angles(KneeAngle, 0, 0)	

			self.LeftHip.C0 = self.LeftHip.C0:Lerp(NewLeftHip,hipAlpha)
			self.LeftKnee.C0 = self.LeftKnee.C0:Lerp(NewLeftKnee,kneeAlpha)
			
			
		end
	
	else --// When not moving
		-- Upper Torso
		self.WaistJoint.C1 = self.WaistJoint.C1:Lerp(self.WaistCFrame1, Delta10)
		
		
		do -- Right Leg
			
			------ dynamic scale to fit any character ------
			local hipMCF = self.RightHip.Part0.CFrame:ToWorldSpace(self.RightHipCFrame0)
			local KneeMCF = self.RightKnee.Part0.CFrame:ToWorldSpace(self.RightKneeCFrame0)
			local AnkleMCF = self.RightAnkle.Part0.CFrame:ToWorldSpace(self.RightAnkleCFrame0)
			local A = (KneeMCF.p-hipMCF.p).magnitude 
			local B = (AnkleMCF.p-KneeMCF.p).magnitude/2
			local hip = hipMCF.Position
			------------------------------------------------
			
			local desiredPos = (hip + down*(self.Humanoid.HipHeight)) 
			local offset =(desiredPos-hip)
			local raycastResult = workspace:Raycast(hip,offset.Unit*(offset.magnitude+1),RaycastParameters)
			local footPos = raycastResult and raycastResult.Position or (hip + offset.Unit*(offset.magnitude+self.RaycastOffset))
			
			
			local OriginCFrame = lowercf * self.RightHipCFrame0
			local Plane,HipAngle, KneeAngle = SolveLegIK(OriginCFrame,footPos,A,B)
			
			
			local NewRightHip = self.RightHipCFrame0 * OriginCFrame:ToObjectSpace(Plane) * CFrame.Angles(HipAngle, 0, 0)
			local NewRightKnee = self.RightKneeCFrame0 * CFrame.Angles(KneeAngle, 0, 0)	
			
			self.RightHip.C0 = self.RightHip.C0:Lerp(NewRightHip,Delta10)
			self.RightKnee.C0 = self.RightKnee.C0:Lerp(NewRightKnee,Delta10)
			
			
		end

		do -- Left Leg
			
			------ dynamic scale to fit any character ------
			local hipMCF = self.LeftHip.Part0.CFrame:ToWorldSpace(self.LeftHipCFrame0)
			local KneeMCF = self.LeftKnee.Part0.CFrame:ToWorldSpace(self.LeftKneeCFrame0)
			local AnkleMCF = self.LeftAnkle.Part0.CFrame:ToWorldSpace(self.LeftAnkleCFrame0)
			local A = (KneeMCF.p-hipMCF.p).magnitude
			local B = (AnkleMCF.p-KneeMCF.p).magnitude/2
			local hip = hipMCF.Position
			------------------------------------------------
			
			local desiredPos = (hip + down*(self.Humanoid.HipHeight)) 
			local offset = (desiredPos-hip)
			local raycastResult = workspace:Raycast(hip,offset.Unit*(offset.magnitude+1),RaycastParameters)
			local footPos = raycastResult and raycastResult.Position or (hip + offset.Unit*(offset.magnitude+self.RaycastOffset))

			local OriginCFrame = lowercf * self.LeftHipCFrame0
			local Plane,HipAngle, KneeAngle = SolveLegIK(OriginCFrame,footPos,A,B)
			
			
			local NewLeftHip = self.LeftHipCFrame0 * OriginCFrame:ToObjectSpace(Plane) * CFrame.Angles(HipAngle, 0, 0)
			local NewLeftKnee = self.LeftKneeCFrame0 * CFrame.Angles(KneeAngle, 0, 0)	

			self.LeftHip.C0 = self.LeftHip.C0:Lerp(NewLeftHip,Delta10)
			self.LeftKnee.C0 = self.LeftKnee.C0:Lerp(NewLeftKnee,Delta10)
			
		end
		
	end
end

return IK_HANDLER