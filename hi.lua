local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local Settings = {
    Fly = false,
    FlySpeed = 120,
    BoostMode = false,
}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 2
        })
    end)
end

local flyConnection, bodyVelocity, bodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then return end
        local moveDir = humanoid.MoveDirection
        local speed = Settings.FlySpeed
        if Settings.BoostMode then speed = speed * 2.5 end
        bodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir * speed or Vector3.zero
        bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function createButtonUI()
    if CoreGui:FindFirstChild("FlyUI") then CoreGui.FlyUI:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FlyUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.fromOffset(60, 60)
    flyBtn.Position = UDim2.new(0, 20, 0.5, -30)
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    flyBtn.Text = "✈️\nOFF"
    flyBtn.TextColor3 = Color3.new(1, 1, 1)
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 12
    flyBtn.Active = true
    flyBtn.Draggable = true
    flyBtn.Parent = gui
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", flyBtn)
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(100, 255, 200)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.fromOffset(30, 30)
    plusBtn.Position = UDim2.new(0, 85, 0.5, -35)
    plusBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 16
    plusBtn.Parent = gui
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(1, 0)

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.fromOffset(30, 30)
    minusBtn.Position = UDim2.new(0, 85, 0.5, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18
    minusBtn.Parent = gui
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(1, 0)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.fromOffset(60, 20)
    speedLabel.Position = UDim2.new(0, 20, 0.5, 35)
    speedLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    speedLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
    speedLabel.Text = "Speed: " .. Settings.FlySpeed
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 11
    speedLabel.Parent = gui
    Instance.new("UICorner", speedLabel).CornerRadius = UDim.new(0, 6)

    flyBtn.MouseButton1Click:Connect(function()
        Settings.Fly = not Settings.Fly
        if Settings.Fly then
            startFly()
            flyBtn.Text = "✈️\nON"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
            notify("Fly", "បានបើក", 2)
        else
            stopFly()
            flyBtn.Text = "✈️\nOFF"
            flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            notify("Fly", "បានបិទ", 2)
        end
    end)

    plusBtn.MouseButton1Click:Connect(function()
        Settings.FlySpeed = math.min(Settings.FlySpeed + 20, 1000)
        speedLabel.Text = "Speed: " .. Settings.FlySpeed
    end)

    minusBtn.MouseButton1Click:Connect(function()
        Settings.FlySpeed = math.max(Settings.FlySpeed - 20, 20)
        speedLabel.Text = "Speed: " .. Settings.FlySpeed
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.Fly then
        stopFly()
        startFly()
    end
end)

createButtonUI()
notify("GhostHub", "Fly Button Ready", 2)