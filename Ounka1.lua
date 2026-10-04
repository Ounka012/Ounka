--========================================================
-- 🌸 OUNCOPYBARA PINK NEON GUI
-- Roblox Studio - LocalScript
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local PINK = Color3.fromRGB(255, 40, 170)
local LIGHT_PINK = Color3.fromRGB(255, 150, 220)
local PURPLE = Color3.fromRGB(150, 60, 255)

local BG = Color3.fromRGB(15, 10, 20)
local PANEL = Color3.fromRGB(25, 15, 32)
local BUTTON = Color3.fromRGB(40, 20, 48)

--========================================================
-- REMOVE OLD GUI
--========================================================

local old = PlayerGui:FindFirstChild("OuncopybaraPinkNeon")
if old then
	old:Destroy()
end

--========================================================
-- SCREEN GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "OuncopybaraPinkNeon"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--========================================================
-- MAIN FRAME
--========================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 330, 0, 390)
Main.Position = UDim2.new(0.5, -165, 0.5, -195)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PINK
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--========================================================
-- GLOW
--========================================================

local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
Glow.Size = UDim2.new(1, 55, 1, 55)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = PINK
Glow.ImageTransparency = 0.72
Glow.ZIndex = 0
Glow.Parent = Main

Main.ZIndex = 2

--========================================================
-- TOP BAR
--========================================================

local Top = Instance.new("Frame")
Top.Name = "TopBar"
Top.Size = UDim2.new(1, 0, 0, 65)
Top.BackgroundColor3 = PANEL
Top.BorderSizePixel = 0
Top.ZIndex = 3
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 18)
TopCorner.Parent = Top

-- Cover lower rounded corners of top bar
local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 18)
TopCover.Position = UDim2.new(0, 0, 1, -18)
TopCover.BackgroundColor3 = PANEL
TopCover.BorderSizePixel = 0
TopCover.ZIndex = 3
TopCover.Parent = Top

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 8)
Title.Size = UDim2.new(1, -120, 0, 28)
Title.Text = "🌸 OUNCOPYBARA"
Title.TextColor3 = LIGHT_PINK
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
Title.Parent = Top

local SubTitle = Instance.new("TextLabel")
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 19, 0, 36)
SubTitle.Size = UDim2.new(1, -120, 0, 20)
SubTitle.Text = "PINK NEON  •  STUDIO"
SubTitle.TextColor3 = Color3.fromRGB(170, 130, 180)
SubTitle.TextSize = 9
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 4
SubTitle.Parent = Top

--========================================================
-- MINIMIZE
--========================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 38, 0, 38)
Minimize.Position = UDim2.new(1, -88, 0, 13)
Minimize.BackgroundColor3 = BUTTON
Minimize.Text = "—"
Minimize.TextColor3 = LIGHT_PINK
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.ZIndex = 5
Minimize.Parent = Top

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = Minimize

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = PINK
MinStroke.Transparency = 0.35
MinStroke.Parent = Minimize

--========================================================
-- CLOSE
--========================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 38, 0, 38)
Close.Position = UDim2.new(1, -45, 0, 13)
Close.BackgroundColor3 = Color3.fromRGB(90, 20, 60)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 180, 220)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.ZIndex = 5
Close.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

--========================================================
-- CONTENT
--========================================================

local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 15, 0, 78)
Content.Size = UDim2.new(1, -30, 1, -90)
Content.ZIndex = 3
Content.Parent = Main

--========================================================
-- STATUS
--========================================================

local StatusBox = Instance.new("Frame")
StatusBox.Size = UDim2.new(1, 0, 0, 48)
StatusBox.BackgroundColor3 = Color3.fromRGB(30, 18, 38)
StatusBox.BorderSizePixel = 0
StatusBox.Parent = Content

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 12)
StatusCorner.Parent = StatusBox

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = PURPLE
StatusStroke.Transparency = 0.55
StatusStroke.Parent = StatusBox

local StatusDot = Instance.new("TextLabel")
StatusDot.BackgroundTransparency = 1
StatusDot.Position = UDim2.new(0, 12, 0, 8)
StatusDot.Size = UDim2.new(0, 25, 0, 30)
StatusDot.Text = "●"
StatusDot.TextColor3 = Color3.fromRGB(80, 255, 160)
StatusDot.TextSize = 17
StatusDot.Font = Enum.Font.GothamBold
StatusDot.Parent = StatusBox

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 40, 0, 7)
Status.Size = UDim2.new(1, -50, 0, 34)
Status.Text = "Ready • Set your Base"
Status.TextColor3 = Color3.fromRGB(225, 205, 230)
Status.TextSize = 11
Status.Font = Enum.Font.GothamMedium
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = StatusBox

--========================================================
-- BUTTON FUNCTION
--========================================================

local function CreateButton(name, text, y, accent)

	local Button = Instance.new("TextButton")
	Button.Name = name
	Button.Size = UDim2.new(1, 0, 0, 52)
	Button.Position = UDim2.new(0, 0, 0, y)
	Button.BackgroundColor3 = BUTTON
	Button.BorderSizePixel = 0
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(245, 225, 245)
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.ZIndex = 4
	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 13)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = accent
	Stroke.Thickness = 1.4
	Stroke.Transparency = 0.35
	Stroke.Parent = Button

	-- hover effect
	Button.MouseEnter:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(
					math.min(accent.R * 255 + 25, 255),
					math.min(accent.G * 255 + 15, 255),
					math.min(accent.B * 255 + 20, 255)
				)
			}
		):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = BUTTON
			}
		):Play()
	end)

	return Button
end

--========================================================
-- BUTTONS
--========================================================

local SetBase = CreateButton(
	"SetBase",
	"📍   SET BASE",
	60,
	PINK
)

local GoBase = CreateButton(
	"GoBase",
	"🚀   GO BASE",
	120,
	PURPLE
)

local Auto = CreateButton(
	"Auto",
	"⚡   AUTO : OFF",
	180,
	Color3.fromRGB(255, 80, 180)
)

local Test = CreateButton(
	"Test",
	"🧪   TEST TELEPORT",
	240,
	Color3.fromRGB(90, 100, 220)
)

--========================================================
-- BASE POSITION
--========================================================

local BaseCFrame = nil
local AutoEnabled = false

local function GetCharacter()
	local Character = Player.Character
	if not Character then
		return nil
	end

	return Character
end

local function GetRoot()
	local Character = GetCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")
end

local function SetStatus(text, color)
	Status.Text = text

	if color then
		StatusDot.TextColor3 = color
	else
		StatusDot.TextColor3 = Color3.fromRGB(80, 255, 160)
	end
end

--========================================================
-- SET BASE
--========================================================

SetBase.Activated:Connect(function()

	local Root = GetRoot()

	if not Root then
		SetStatus("Character not ready", Color3.fromRGB(255, 90, 100))
		return
	end

	BaseCFrame = Root.CFrame

	SetStatus(
		string.format(
			"Base saved  •  %.0f / %.0f / %.0f",
			Root.Position.X,
			Root.Position.Y,
			Root.Position.Z
		),
		Color3.fromRGB(80, 255, 160)
	)

	SetBase.Text = "✓   BASE SAVED"
end)

--========================================================
-- GO BASE
--========================================================

GoBase.Activated:Connect(function()

	if not BaseCFrame then
		SetStatus("Set Base first", Color3.fromRGB(255, 90, 100))
		return
	end

	local Root = GetRoot()

	if not Root then
		SetStatus("Character not ready", Color3.fromRGB(255, 90, 100))
		return
	end

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero
	Root.CFrame = BaseCFrame

	SetStatus(
		"Teleported to Base ✓",
		Color3.fromRGB(180, 120, 255)
	)
end)

--========================================================
-- AUTO TOGGLE
--========================================================

Auto.Activated:Connect(function()

	if not BaseCFrame then
		SetStatus("Set Base first", Color3.fromRGB(255, 90, 100))
		return
	end

	AutoEnabled = not AutoEnabled

	if AutoEnabled then

		Auto.Text = "⚡   AUTO : ON"

		TweenService:Create(
			Auto,
			TweenInfo.new(0.2),
			{
				BackgroundColor3 = Color3.fromRGB(100, 25, 80)
			}
		):Play()

		SetStatus(
			"Auto mode enabled",
			Color3.fromRGB(80, 255, 160)
		)

	else

		Auto.Text = "⚡   AUTO : OFF"

		TweenService:Create(
			Auto,
			TweenInfo.new(0.2),
			{
				BackgroundColor3 = BUTTON
			}
		):Play()

		SetStatus(
			"Auto mode disabled",
			Color3.fromRGB(255, 180, 210)
		)
	end
end)

--========================================================
-- TEST
--========================================================

Test.Activated:Connect(function()

	if not BaseCFrame then
		SetStatus("Set Base first", Color3.fromRGB(255, 90, 100))
		return
	end

	local Root = GetRoot()

	if not Root then
		return
	end

	local Original = Root.CFrame

	SetStatus(
		"Testing...",
		Color3.fromRGB(255, 220, 100)
	)

	Root.CFrame = BaseCFrame

	task.wait(0.6)

	if Root.Parent then
		Root.CFrame = Original
	end

	SetStatus(
		"Test complete ✓",
		Color3.fromRGB(80, 255, 160)
	)
end)

--========================================================
-- DRAG SYSTEM
--========================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then

		local Delta = Input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

--========================================================
-- FLOAT BUTTON
--========================================================

local Float = Instance.new("TextButton")
Float.Name = "FloatingButton"
Float.Size = UDim2.new(0, 58, 0, 58)
Float.Position = UDim2.new(0, 20, 0.5, -29)
Float.BackgroundColor3 = Color3.fromRGB(30, 15, 38)
Float.Text = "🌸"
Float.TextSize = 24
Float.Font = Enum.Font.GothamBold
Float.TextColor3 = LIGHT_PINK
Float.Visible = false
Float.AutoButtonColor = false
Float.ZIndex = 10
Float.Parent = Gui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = Float

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = PINK
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

--========================================================
-- MINIMIZE / SHOW
--========================================================

Minimize.Activated:Connect(function()

	Main.Visible = false
	Float.Visible = true

end)

Float.Activated:Connect(function()

	Main.Visible = true
	Float.Visible = false

end)

--========================================================
-- CLOSE
--========================================================

Close.Activated:Connect(function()

	AutoEnabled = false
	Gui:Destroy()

end)

--========================================================
-- RIGHT SHIFT TOGGLE
--========================================================

UIS.InputBegan:Connect(function(Input, GameProcessed)

	if GameProcessed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.RightShift then

		if Main.Visible then
			Main.Visible = false
			Float.Visible = true
		else
			Main.Visible = true
			Float.Visible = false
		end
	end
end)

--========================================================
-- MOBILE FLOAT DRAG
--========================================================

local FloatDragging = false
local FloatStart
local FloatPosition
local FloatMoved = false

Float.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		FloatDragging = true
		FloatMoved = false

		FloatStart = Input.Position
		FloatPosition = Float.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if not FloatDragging then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then

		local Delta = Input.Position - FloatStart

		if math.abs(Delta.X) > 5 or math.abs(Delta.Y) > 5 then
			FloatMoved = true
		end

		Float.Position = UDim2.new(
			FloatPosition.X.Scale,
			FloatPosition.X.Offset + Delta.X,
			FloatPosition.Y.Scale,
			FloatPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		FloatDragging = false
	end
end)

--========================================================
-- NEON ANIMATION
--========================================================

task.spawn(function()

	while Gui.Parent do

		TweenService:Create(
			MainStroke,
			TweenInfo.new(
				1.2,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Transparency = 0.5
			}
		):Play()

		task.wait(1.2)

		TweenService:Create(
			MainStroke,
			TweenInfo.new(
				1.2,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Transparency = 0.05
			}
		):Play()

		task.wait(1.2)
	end

end)

--========================================================
-- LOADED
--========================================================

SetStatus(
	"Ready • Pink Neon loaded ✓",
	Color3.fromRGB(80, 255, 160)
)

print("🌸 OUNCOPYBARA PINK NEON GUI LOADED")