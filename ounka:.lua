--==================================================
-- ✨ PREMIUM SPRINT GUI SYSTEM (Roblox Studio)
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- Settings
local NORMAL_SPEED = 16
local SPRINT_SPEED = 28

local SprintEnabled = false


--==================================================
-- CREATE GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumSprintGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")


-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,350,0,180)
MainFrame.Position = UDim2.new(0.5,-175,0.5,-90)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,20,35)
MainFrame.BackgroundTransparency = .15
MainFrame.BorderSizePixel = 0


local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,20)
Corner.Parent = MainFrame


local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,170,255)


-- Gradient
local Gradient = Instance.new("UIGradient")
Gradient.Parent = MainFrame
Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(0,170,255)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(100,0,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(0,255,255))
}


-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "⚡ PREMIUM SPRINT"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.new(1,1,1)


-- Speed Text
local SpeedText = Instance.new("TextLabel")
SpeedText.Parent = MainFrame
SpeedText.Position = UDim2.new(0,20,0,55)
SpeedText.Size = UDim2.new(1,-40,0,30)
SpeedText.BackgroundTransparency = 1
SpeedText.Text = "Speed : 16"
SpeedText.Font = Enum.Font.Gotham
SpeedText.TextSize = 16
SpeedText.TextColor3 = Color3.fromRGB(200,200,220)



--==================================================
-- TOGGLE
--==================================================

local Toggle = Instance.new("Frame")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0,70,0,34)
Toggle.Position = UDim2.new(0.5,-35,0,105)
Toggle.BackgroundColor3 = Color3.fromRGB(70,70,90)


local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1,0)
ToggleCorner.Parent = Toggle


local Knob = Instance.new("Frame")
Knob.Parent = Toggle
Knob.Size = UDim2.new(0,28,0,28)
Knob.Position = UDim2.new(0,3,.5,-14)
Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)


local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1,0)
KnobCorner.Parent = Knob



--==================================================
-- SPRINT FUNCTION
--==================================================

local function UpdateSprint()

	local Character = Player.Character

	if not Character then return end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then

		if SprintEnabled then
			Humanoid.WalkSpeed = SPRINT_SPEED
			SpeedText.Text = "Speed : "..SPRINT_SPEED

		else
			Humanoid.WalkSpeed = NORMAL_SPEED
			SpeedText.Text = "Speed : "..NORMAL_SPEED
		end

	end
end



-- Toggle Click
Toggle.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		SprintEnabled = not SprintEnabled


		if SprintEnabled then

			TweenService:Create(
				Knob,
				TweenInfo.new(.25,Enum.EasingStyle.Back),
				{
					Position = UDim2.new(0,39,.5,-14)
				}
			):Play()


			TweenService:Create(
				Toggle,
				TweenInfo.new(.25),
				{
					BackgroundColor3 =
					Color3.fromRGB(0,170,255)
				}
			):Play()


		else

			TweenService:Create(
				Knob,
				TweenInfo.new(.25,Enum.EasingStyle.Back),
				{
					Position = UDim2.new(0,3,.5,-14)
				}
			):Play()


			TweenService:Create(
				Toggle,
				TweenInfo.new(.25),
				{
					BackgroundColor3 =
					Color3.fromRGB(70,70,90)
				}
			):Play()

		end


		UpdateSprint()

	end

end)



-- Respawn Fix
Player.CharacterAdded:Connect(function()
	task.wait(1)
	UpdateSprint()
end)



--==================================================
-- DRAG MOBILE + PC
--==================================================

local dragging = false
local dragStart
local startPos


MainFrame.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

	end

end)


UserInputService.InputChanged:Connect(function(input)

	if dragging then

		local delta = input.Position - dragStart

		MainFrame.Position =
			UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

	end

end)


UserInputService.InputEnded:Connect(function()

	dragging = false

end)



-- Rainbow Border

task.spawn(function()

	local h = 0

	while ScreenGui.Parent do

		h = (h + .005) % 1

		Stroke.Color =
			Color3.fromHSV(h,1,1)

		task.wait()

	end

end)


print("⚡ Premium Sprint GUI Loaded")