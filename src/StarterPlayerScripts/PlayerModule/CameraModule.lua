local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local SENSITIVITY = 0.2 * math.pi

local pos = Vector3.zero -- Position of the camera
local x, y = 0, 0
local zoom = 10 -- How many studs away the camera is from the subject

local Camera = {}

RunService.PreRender:Connect(function(deltaTimeRender)
	local camera = Workspace.CurrentCamera
	local subject = camera.CameraSubject

	if subject and subject:IsA("Humanoid") then
		local rootPart = subject.RootPart

		pos = rootPart.Position
	end

	Workspace.CurrentCamera.CFrame =
		CFrame.new(pos - (zoom * CFrame.fromOrientation(math.rad(y), math.rad(x), 0).LookVector), pos)
end)

local mouseHeld = false
ContextActionService:BindAction(
	"CameraRotation",
	function(actionName: string, state: Enum.UserInputState, inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
			mouseHeld = state ~= Enum.UserInputState.End
			UserInputService.MouseBehavior = mouseHeld and Enum.MouseBehavior.LockCurrentPosition
				or Enum.MouseBehavior.Default
		end
		if mouseHeld and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			local a = inputObject.Delta * SENSITIVITY
			x -= a.X
			y = math.clamp(y - a.Y, -80, 80)
		end
		return Enum.ContextActionResult.Pass
	end,
	false,
	Enum.UserInputType.MouseMovement,
	Enum.UserInputType.MouseButton2
)

ContextActionService:BindAction(
	"CameraZoom",
	function(actionName: string, state: Enum.UserInputState, inputObject: InputObject)
		zoom = math.clamp(zoom-inputObject.Position.Z, 0.5, 50)
	end,
	false,
	Enum.UserInputType.MouseWheel
)

return Camera
