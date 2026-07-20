--==================================================
-- ⚡ PREMIUM SPRINT GUI v3 (Delta Optimized)
-- LocalScript -> StarterGui
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- SETTINGS
local NORMAL_SPEED = 16
local SPRINT_SPEED = 28
local Sprint = false
local SprintHold = false

-- SOUND IDS (អាចប្តូរបាន)
local SPRINT_ON_SOUND = "rbxassetid://9120387253"
local SPRINT_OFF_SOUND = "rbxassetid://9120385522"

--==================================================
-- GUI CREATION
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SprintUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 180)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 42)  -- ពណ៌ស្រអាប់
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ZIndex = 5

-- Corner (មូល)
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 20)
Corner.Parent = MainFrame

-- BORDER (ប្រើ Frame តូចជាស៊ុម ព្រោះ Delta មិនគាំទ្រ UIStroke)
local BorderFrame = Instance.new("Frame")
BorderFrame.Name = "BorderFrame"
BorderFrame.Parent = MainFrame
BorderFrame.Size = UDim2.new(1, 0, 1, 0)
BorderFrame.Position = UDim2.new(0, 0, 0, 0)
BorderFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
BorderFrame.BackgroundTransparency = 0.3
BorderFrame.BorderSizePixel = 0
BorderFrame.ZIndex = 0

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 20)
BorderCorner.Parent = BorderFrame

-- Inner Frame (ដើម្បីបិទបាំងផ្ទៃខាងក្នុងនៃ Border)
local InnerFrame = Instance.new("Frame")
InnerFrame.Name = "InnerFrame"
InnerFrame.Parent = BorderFrame
InnerFrame.Size = UDim2.new(1, -4, 1, -4)
InnerFrame.Position = UDim2.new(0, 2, 0, 2)
InnerFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
InnerFrame.BackgroundTransparency = 0
InnerFrame.BorderSizePixel = 0
InnerFrame.ZIndex = 1

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 18)
InnerCorner.Parent = InnerFrame

-- TITLE
local Title = Instance.new("TextLabel")
Title.Parent = InnerFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SPRINT SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.ZIndex = 2

-- STATUS
local Status = Instance.new("TextLabel")
Status.Parent = InnerFrame
Status.Position = UDim2.new(0, 20, 0, 55)
Status.Size = UDim2.new(1, -40, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "Speed : 16"
Status.Font = Enum.Font.Gotham
Status.TextSize = 16
Status.TextColor3 = Color3.fromRGB(200, 200, 220)
Status.ZIndex = 2

--==================================================
-- TOGGLE BUTTON
--==================================================

local Toggle = Instance.new("Frame")
Toggle.Parent = InnerFrame
Toggle.Size = UDim2.new(0, 70, 0, 34)
Toggle.Position = UDim2.new(0.5, -35, 0, 110)
Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
Toggle.BorderSizePixel = 0
Toggle.ZIndex = 2

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = Toggle

-- KNOB
local Knob = Instance.new("Frame")
Knob.Parent = Toggle
Knob.Size = UDim2.new(0, 28, 0, 28)
Knob.Position = UDim2.new(0, 3, 0.5, -14)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.ZIndex = 3

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

-- BUTTON CLICK DETECTOR (ប្រើ Frame + MouseButton1Click មិនបាន ដូច្នេះប្រើ InputBegan)
local ClickDetector = Instance.new("TextButton")
ClickDetector.Parent = Toggle
ClickDetector.Size = UDim2.new(1, 0, 1, 0)
ClickDetector.Position = UDim2.new(0, 0, 0, 0)
ClickDetector.BackgroundTransparency = 1
ClickDetector.Text = ""
ClickDetector.ZIndex = 4

--==================================================
-- SPRINT LOGIC
--==================================================

local function PlaySound(id)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	task.delay(sound.TimeLength + 0.1, function()
		sound:Destroy()
	end)
end

local function UpdateSpeed()
	if not Humanoid or not Humanoid.Parent then return end
	
	if Sprint or SprintHold then
		Humanoid.WalkSpeed = SPRINT_SPEED
		Status.Text = "Speed : " .. SPRINT_SPEED
		Status.TextColor3 = Color3.fromRGB(0, 255, 200)
	else
		Humanoid.WalkSpeed = NORMAL_SPEED
		Status.Text = "Speed : " .. NORMAL_SPEED
		Status.TextColor3 = Color3.fromRGB(200, 200, 220)
	end
end

local function ToggleSprint()
	Sprint = not Sprint
	SprintHold = false  -- បិទ Hold ពេលចុច Toggle
	
	if Sprint then
		TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Position = UDim2.new(0, 39, 0.5, -14)
		}):Play()
		Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		PlaySound(SPRINT_ON_SOUND)
	else
		TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Position = UDim2.new(0, 3, 0.5, -14)
		}):Play()
		Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
		PlaySound(SPRINT_OFF_SOUND)
	end
	UpdateSpeed()
end

-- Click on Toggle
ClickDetector.MouseButton1Click:Connect(ToggleSprint)

-- ===== SHIFT HOLD =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		if not Sprint then
			SprintHold = true
			TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				Position = UDim2.new(0, 39, 0.5, -14)
			}):Play()
			Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			PlaySound(SPRINT_ON_SOUND)
			UpdateSpeed()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		if not Sprint then
			SprintHold = false
			TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				Position = UDim2.new(0, 3, 0.5, -14)
			}):Play()
			Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
			PlaySound(SPRINT_OFF_SOUND)
			UpdateSpeed()
		end
	end
end)

--==================================================
-- RESPAWN
--==================================================

Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = Character:WaitForChild("Humanoid")
	task.wait(0.5)
	-- កំណត់ល្បឿនតាមស្ថានភាពបច្ចុប្បន្ន
	if Sprint or SprintHold then
		Humanoid.WalkSpeed = SPRINT_SPEED
	else
		Humanoid.WalkSpeed = NORMAL_SPEED
	end
	UpdateSpeed()
end)

--==================================================
-- DRAG SYSTEM
--==================================================

local Dragging = false
local DragStart
local StartPosition

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPosition = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging then
		local Delta = input.Position - DragStart
		MainFrame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function()
	Dragging = false
end)

--==================================================
-- FLOATING ANIMATION
--==================================================

task.spawn(function()
	while ScreenGui.Parent do
		local tweenUp = TweenService:Create(
			MainFrame,
			TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Position = MainFrame.Position + UDim2.new(0, 0, 0, -3)}
		)
		tweenUp:Play()
		task.wait(1.2)
		
		local tweenDown = TweenService:Create(
			MainFrame,
			TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Position = MainFrame.Position + UDim2.new(0, 0, 0, 3)}
		)
		tweenDown:Play()
		task.wait(1.2)
	end
end)

--==================================================
-- RAINBOW BORDER (ប្រើ BorderFrame ជំនួស UIStroke)
--==================================================

task.spawn(function()
	while ScreenGui.Parent do
		local h = tick() % 5 / 5
		BorderFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		task.wait(0.05)  -- ប្តូរពណ៌ឲ្យលឿន
	end
end)

--==================================================
-- INIT
--==================================================

UpdateSpeed()
print("⚡ Sprint GUI v3 Loaded (Delta Optimized)!")