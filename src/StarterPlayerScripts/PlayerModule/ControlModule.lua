local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local held = { -- What actions are currently being held down
	forward = false,
	backward = false,
	left = false,
	right = false,
	jump = false,
}
local character, humanoid: Humanoid, rootPart: Part

-- Module
local Controls = {}

do -- Walking
	local DEADZONE = 0.1 -- The controler deadzone
	local MOVEMENTS = { -- What buttons match each direction
		[Enum.KeyCode.W] = "forward",
		[Enum.KeyCode.A] = "left",
		[Enum.KeyCode.S] = "backward",
		[Enum.KeyCode.D] = "right",
	}

	local direction = Vector3.zero -- The direction the player is currently moving in

	function Controls.Walk(actionName: string, state: Enum.UserInputState, inputObject: InputObject)
		if inputObject.KeyCode == Enum.KeyCode.Thumbstick1 then -- Sets the direction based on the thumbstick
			local d = inputObject.Position
			direction = Vector3.new(math.abs(d.X) > DEADZONE and d.X or 0, 0, math.abs(d.Y) > DEADZONE and -d.Y)
		else -- Sets the diretion based on held keys
			held[MOVEMENTS[inputObject.KeyCode]] = state == Enum.UserInputState.Begin
			direction = Vector3.new(
				(held.left and -1 or 0) + (held.right and 1 or 0),
				0,
				(held.forward and -1 or 0) + (held.backward and 1 or 0)
			)
		end
		return Enum.ContextActionResult.Pass
	end

	RunService.PreRender:Connect(function() -- Updates the humanoid with the new direction every frame
		if humanoid then
			humanoid:Move(direction, true)
		end
	end)
end

local stateChanged
do -- Jumping
	function Controls.Jump(actionName: string, state: Enum.UserInputState, inputObject: InputObject) -- Makes the character jump
		held.jump = state == Enum.UserInputState.Begin
		humanoid.Jump = held.jump
		return Enum.ContextActionResult.Pass
	end

	function stateChanged(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType) -- Gets called when the player state changes.
		if held.jump and oldState == Enum.HumanoidStateType.Landed and newState == Enum.HumanoidStateType.Running then
			humanoid.Jump = true -- Jump if the player lands on the ground while holding a jump button
		end
	end
end

-- Events
local function handleCharacter(char)
	character = char
	rootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")

	humanoid.StateChanged:Connect(stateChanged)
end
handleCharacter(Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait())
Players.LocalPlayer.CharacterAdded:Connect(handleCharacter)

-- Action bindings
ContextActionService:BindActionAtPriority(
	"CharacterWalk",
	Controls.Walk,
	false,
	4000,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Thumbstick1
)
ContextActionService:BindActionAtPriority(
	"CharacterJump",
	Controls.Jump,
	false,
	4000,
	Enum.KeyCode.Space,
	Enum.KeyCode.ButtonA
)

return Controls
