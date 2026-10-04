--==============================================================
-- 🌸 OUNCOPYBARA PINK NEON v2
-- Advanced Roblox Studio GUI
-- AUTO REMOVED
--==============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	Name = "OuncopybaraPinkNeon",

	Colors = {
		Background = Color3.fromRGB(10, 7, 14),
		Panel = Color3.fromRGB(20, 12, 27),
		Panel2 = Color3.fromRGB(28, 15, 36),

		Pink = Color3.fromRGB(255, 45, 175),
		HotPink = Color3.fromRGB(255, 0, 140),
		SoftPink = Color3.fromRGB(255, 170, 225),

		Purple = Color3.fromRGB(150, 70, 255),
		BluePurple = Color3.fromRGB(100, 90, 255),

		White = Color3.fromRGB(245, 235, 248),
		Muted = Color3.fromRGB(165, 145, 175),

		Success = Color3.fromRGB(80, 255, 165),
		Error = Color3.fromRGB(255, 80, 100),
		Warning = Color3.fromRGB(255, 215, 90),
	},

	TweenFast = TweenInfo.new(
		0.15,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	),

	TweenNormal = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	),
}

--==============================================================
-- CLEAN OLD GUI
--==============================================================

local Old = PlayerGui:FindFirstChild(CONFIG.Name)

if Old then
	Old:Destroy()
end

--==============================================================
-- SCREEN GUI
--==============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = CONFIG.Name
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--==============================================================
-- MAIN WINDOW
--==============================================================

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.new(0, 350, 0, 410)
Main.BackgroundColor3 = CONFIG.Colors.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Colors.Pink
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--==============================================================
-- BACK GLOW
--==============================================================

local Glow = Instance.new("Frame")
Glow.Name = "NeonGlow"
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.5)
Glow.Size = UDim2.new(1, 18, 1, 18)
Glow.BackgroundColor3 = CONFIG.Colors.Pink
Glow.BackgroundTransparency = 0.93
Glow.BorderSizePixel = 0
Glow.ZIndex = 0
Glow.Parent = Main

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 24)
GlowCorner.Parent = Glow

--==============================================================
-- TOP BAR
--==============================================================

local Top = Instance.new("Frame")
Top.Name = "TopBar"
Top.Size = UDim2.new(1, 0, 0, 72)
Top.BackgroundColor3 = CONFIG.Colors.Panel
Top.BorderSizePixel = 0
Top.ZIndex = 5
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 20)
TopCorner.Parent = Top

local TopBottom = Instance.new("Frame")
TopBottom.Size = UDim2.new(1, 0, 0, 20)
TopBottom.Position = UDim2.new(0, 0, 1, -20)
TopBottom.BackgroundColor3 = CONFIG.Colors.Panel
TopBottom.BorderSizePixel = 0
TopBottom.ZIndex = 5
TopBottom.Parent = Top

--==============================================================
-- TITLE
--==============================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 10)
Title.Size = UDim2.new(1, -130, 0, 30)
Title.Text = "🌸  OUNCOPYBARA"
Title.TextColor3 = CONFIG.Colors.SoftPink
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6
Title.Parent = Top

local SubTitle = Instance.new("TextLabel")
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 21, 0, 39)
SubTitle.Size = UDim2.new(1, -130, 0, 20)
SubTitle.Text = "PINK NEON  •  ADVANCED"
SubTitle.TextColor3 = CONFIG.Colors.Muted
SubTitle.TextSize = 9
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 6
SubTitle.Parent = Top

--==============================================================
-- WINDOW BUTTON HELPER
--==============================================================

local function WindowButton(text, position, color)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(0, 38, 0, 38)
	Button.Position = position
	Button.BackgroundColor3 = color
	Button.BorderSizePixel = 0

	Button.Text = text
	Button.TextColor3 = CONFIG.Colors.White
	Button.TextSize = 20
	Button.Font = Enum.Font.GothamBold

	Button.AutoButtonColor = false
	Button.ZIndex = 7
	Button.Parent = Top

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = CONFIG.Colors.Pink
	Stroke.Transparency = 0.5
	Stroke.Parent = Button

	Button.MouseEnter:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				BackgroundColor3 = CONFIG.Colors.Pink
			}
		):Play()
	end)

	Button.MouseLeave:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				BackgroundColor3 = color
			}
		):Play()
	end)

	return Button
end

local Minimize = WindowButton(
	"—",
	UDim2.new(1, -91, 0, 17),
	Color3.fromRGB(45, 20, 50)
)

local Close = WindowButton(
	"×",
	UDim2.new(1, -46, 0, 17),
	Color3.fromRGB(75, 18, 48)
)

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 16, 0, 85)
Content.Size = UDim2.new(1, -32, 1, -100)
Content.Parent = Main

--==============================================================
-- STATUS PANEL
--==============================================================

local StatusPanel = Instance.new("Frame")
StatusPanel.Size = UDim2.new(1, 0, 0, 58)
StatusPanel.BackgroundColor3 = CONFIG.Colors.Panel2
StatusPanel.BorderSizePixel = 0
StatusPanel.Parent = Content

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 13)
StatusCorner.Parent = StatusPanel

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = CONFIG.Colors.Purple
StatusStroke.Transparency = 0.45
StatusStroke.Parent = StatusPanel

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 9, 0, 9)
StatusDot.Position = UDim2.new(0, 15, 0, 16)
StatusDot.BackgroundColor3 = CONFIG.Colors.Success
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusPanel

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusTitle = Instance.new("TextLabel")
StatusTitle.BackgroundTransparency = 1
StatusTitle.Position = UDim2.new(0, 34, 0, 7)
StatusTitle.Size = UDim2.new(1, -45, 0, 19)
StatusTitle.Text = "SYSTEM STATUS"
StatusTitle.TextColor3 = CONFIG.Colors.Muted
StatusTitle.TextSize = 8
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusPanel

local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 34, 0, 24)
StatusText.Size = UDim2.new(1, -45, 0, 23)
StatusText.Text = "Ready • Waiting for Base"
StatusText.TextColor3 = CONFIG.Colors.White
StatusText.TextSize = 11
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusPanel

--==============================================================
-- COORDINATE PANEL
--==============================================================

local CoordPanel = Instance.new("Frame")
CoordPanel.Position = UDim2.new(0, 0, 0, 68)
CoordPanel.Size = UDim2.new(1, 0, 0, 42)
CoordPanel.BackgroundColor3 = Color3.fromRGB(17, 10, 23)
CoordPanel.BorderSizePixel = 0
CoordPanel.Parent = Content

local CoordCorner = Instance.new("UICorner")
CoordCorner.CornerRadius = UDim.new(0, 11)
CoordCorner.Parent = CoordPanel

local CoordText = Instance.new("TextLabel")
CoordText.BackgroundTransparency = 1
CoordText.Position = UDim2.new(0, 12, 0, 0)
CoordText.Size = UDim2.new(1, -24, 1, 0)
CoordText.Text = "X: 0    Y: 0    Z: 0"
CoordText.TextColor3 = CONFIG.Colors.Muted
CoordText.TextSize = 9
CoordText.Font = Enum.Font.Code
CoordText.TextXAlignment = Enum.TextXAlignment.Left
CoordText.Parent = CoordPanel

--==============================================================
-- BUTTON FACTORY
--==============================================================

local function CreateButton(name, text, y, accent, icon)

	local Button = Instance.new("TextButton")

	Button.Name = name
	Button.Position = UDim2.new(0, 0, 0, y)
	Button.Size = UDim2.new(1, 0, 0, 50)

	Button.BackgroundColor3 = CONFIG.Colors.Panel2
	Button.BorderSizePixel = 0

	Button.Text = ""
	Button.AutoButtonColor = false

	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 13)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = accent
	Stroke.Thickness = 1.4
	Stroke.Transparency = 0.35
	Stroke.Parent = Button

	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.BackgroundTransparency = 1
	Icon.Position = UDim2.new(0, 15, 0, 0)
	Icon.Size = UDim2.new(0, 32, 1, 0)
	Icon.Text = icon
	Icon.TextSize = 17
	Icon.Font = Enum.Font.GothamBold
	Icon.TextColor3 = accent
	Icon.Parent = Button

	-- Text
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.new(0, 52, 0, 0)
	Label.Size = UDim2.new(1, -65, 1, 0)
	Label.Text = text
	Label.TextColor3 = CONFIG.Colors.White
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	-- Arrow
	local Arrow = Instance.new("TextLabel")
	Arrow.BackgroundTransparency = 1
	Arrow.Position = UDim2.new(1, -35, 0, 0)
	Arrow.Size = UDim2.new(0, 25, 1, 0)
	Arrow.Text = "›"
	Arrow.TextColor3 = accent
	Arrow.TextSize = 22
	Arrow.Font = Enum.Font.GothamBold
	Arrow.Parent = Button

	-- Hover
	Button.MouseEnter:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				BackgroundColor3 = Color3.fromRGB(45, 20, 55)
			}
		):Play()

		TweenService:Create(
			Stroke,
			CONFIG.TweenFast,
			{
				Transparency = 0
			}
		):Play()

		TweenService:Create(
			Arrow,
			CONFIG.TweenFast,
			{
				Position = UDim2.new(1, -30, 0, 0)
			}
		):Play()
	end)

	Button.MouseLeave:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				BackgroundColor3 = CONFIG.Colors.Panel2
			}
		):Play()

		TweenService:Create(
			Stroke,
			CONFIG.TweenFast,
			{
				Transparency = 0.35
			}
		):Play()

		TweenService:Create(
			Arrow,
			CONFIG.TweenFast,
			{
				Position = UDim2.new(1, -35, 0, 0)
			}
		):Play()
	end)

	-- Press
	Button.MouseButton1Down:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				Size = UDim2.new(1, -4, 0, 48)
			}
		):Play()
	end)

	Button.MouseButton1Up:Connect(function()

		TweenService:Create(
			Button,
			CONFIG.TweenFast,
			{
				Size = UDim2.new(1, 0, 0, 50)
			}
		):Play()
	end)

	return Button
end

--==============================================================
-- MAIN BUTTONS
--==============================================================

local SetBase = CreateButton(
	"SetBase",
	"SET BASE",
	120,
	CONFIG.Colors.Pink,
	"📍"
)

local GoBase = CreateButton(
	"GoBase",
	"GO BASE",
	178,
	CONFIG.Colors.Purple,
	"🚀"
)

local TestTP = CreateButton(
	"TestTP",
	"TEST TELEPORT",
	236,
	CONFIG.Colors.BluePurple,
	"🧪"
)

--==============================================================
-- BASE DATA
--==============================================================

local BaseCFrame = nil

--==============================================================
-- CHARACTER HELPERS
--==============================================================

local function GetRoot()

	local Character = Player.Character

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")
end

local function SetStatus(text, color)

	StatusText.Text = text
	StatusDot.BackgroundColor3 = color or CONFIG.Colors.Success

end

--==============================================================
-- UPDATE COORDINATES
--==============================================================

local CoordConnection

CoordConnection = RunService.RenderStepped:Connect(function()

	if not Gui.Parent then
		CoordConnection:Disconnect()
		return
	end

	local Root = GetRoot()

	if Root then

		local P = Root.Position

		CoordText.Text = string.format(
			"X: %.0f    Y: %.0f    Z: %.0f",
			P.X,
			P.Y,
			P.Z
		)
	end
end)

--==============================================================
-- SET BASE
--==============================================================

SetBase.Activated:Connect(function()

	local Root = GetRoot()

	if not Root then

		SetStatus(
			"Character not ready",
			CONFIG.Colors.Error
		)

		return
	end

	BaseCFrame = Root.CFrame

	SetStatus(
		"Base saved successfully ✓",
		CONFIG.Colors.Success
	)

	TweenService:Create(
		SetBase,
		CONFIG.TweenNormal,
		{
			BackgroundColor3 = Color3.fromRGB(55, 25, 60)
		}
	):Play()

	task.delay(0.35, function()

		if SetBase.Parent then

			TweenService:Create(
				SetBase,
				CONFIG.TweenNormal,
				{
					BackgroundColor3 = CONFIG.Colors.Panel2
				}
			):Play()

		end
	end)
end)

--==============================================================
-- GO BASE
--==============================================================

GoBase.Activated:Connect(function()

	if not BaseCFrame then

		SetStatus(
			"Please set Base first",
			CONFIG.Colors.Error
		)

		return
	end

	local Root = GetRoot()

	if not Root then

		SetStatus(
			"Character not ready",
			CONFIG.Colors.Error
		)

		return
	end

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero
	Root.CFrame = BaseCFrame

	SetStatus(
		"Teleported to Base ✓",
		CONFIG.Colors.Purple
	)
end)

--==============================================================
-- TEST TELEPORT
--==============================================================

TestTP.Activated:Connect(function()

	if not BaseCFrame then

		SetStatus(
			"Please set Base first",
			CONFIG.Colors.Error
		)

		return
	end

	local Root = GetRoot()

	if not Root then
		return
	end

	local Original = Root.CFrame

	SetStatus(
		"Testing teleport...",
		CONFIG.Colors.Warning
	)

	Root.CFrame = BaseCFrame

	task.wait(0.6)

	if Root and Root.Parent then
		Root.CFrame = Original
	end

	SetStatus(
		"Test completed ✓",
		CONFIG.Colors.Success
	)
end)

--==============================================================
-- DRAG SYSTEM
--==============================================================

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

--==============================================================
-- FLOATING BUTTON
--==============================================================

local Float = Instance.new("TextButton")

Float.Name = "FloatingButton"
Float.AnchorPoint = Vector2.new(0, 0.5)
Float.Position = UDim2.new(0, 18, 0.5, 0)
Float.Size = UDim2.new(0, 60, 0, 60)

Float.BackgroundColor3 = CONFIG.Colors.Panel
Float.BorderSizePixel = 0

Float.Text = "🌸"
Float.TextSize = 25
Float.TextColor3 = CONFIG.Colors.SoftPink
Float.Font = Enum.Font.GothamBold

Float.Visible = false
Float.AutoButtonColor = false
Float.ZIndex = 20
Float.Parent = Gui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = Float

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = CONFIG.Colors.Pink
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

--==============================================================
-- FLOATING BUTTON GLOW
--==============================================================

task.spawn(function()

	while Gui.Parent do

		TweenService:Create(
			FloatStroke,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Thickness = 3
			}
		):Play()

		task.wait(1)

		TweenService:Create(
			FloatStroke,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				Thickness = 2
			}
		):Play()

		task.wait(1)
	end
end)

--==============================================================
-- MINIMIZE
--==============================================================

Minimize.Activated:Connect(function()

	Main.Visible = false
	Float.Visible = true

end)

--==============================================================
-- FLOAT SHOW
--==============================================================

Float.Activated:Connect(function()

	Main.Visible = true
	Float.Visible = false

end)

--==============================================================
-- CLOSE
--==============================================================

Close.Activated:Connect(function()

	if CoordConnection then
		CoordConnection:Disconnect()
	end

	Gui:Destroy()

end)

--==============================================================
-- RIGHT SHIFT TOGGLE
--==============================================================

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

--==============================================================
-- FLOAT DRAG
--==============================================================

local FloatDragging = false
local FloatMoved = false
local FloatStart
local FloatStartPosition

Float.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		FloatDragging = true
		FloatMoved = false

		FloatStart = Input.Position
		FloatStartPosition = Float.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if not FloatDragging then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then

		local Delta = Input.Position - FloatStart

		if math.abs(Delt