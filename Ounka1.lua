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
SubTitle.Size = UDim