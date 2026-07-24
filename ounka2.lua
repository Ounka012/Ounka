-- សាកល្បងបង្កើត GUI ធម្មតា
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "TestGUI"
screen.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0.5,-100,0.5,-50)
frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
frame.BorderSizePixel = 0
frame.Parent = screen

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,1,0)
label.BackgroundTransparency = 1
label.Text = "GUI ដំណើរការ!"
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.Parent = frame

print("Test GUI created. You should see a red box.")