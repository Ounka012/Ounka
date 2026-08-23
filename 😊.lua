-- ================================================================
-- ✨ OUNCOPYBARA - EVADE / AUTO DASH + FLING + FE KILL (Glowing Pink) ✨
-- ================================================================
local EVADE_CONFIG = {
    AUTO_DASH = false,
    DASH_SPEED = 60,
    DASH_COOLDOWN = 0.1,
    DASH_MODE = "MoveDirection",
    INSTANT_DASH = false,
    WALKSPEED = 16,
    SUPER_JUMP = false,
    INFINITE_JUMP = false,
    JUMP_POWER = 50,
    FULLBRIGHT = false,
    AUTO_REVIVE = false,
    AUTO_RESPAWN = false,
    NO_CLIP = false,
    FOV = 70,
    ESP_PLAYERS = false,
    ESP_BOTS = false,
    RAPID_FIRE = false,
    RAPID_FIRE_INTERVAL = 0.1,
    INFINITE_AMMO = false,
    NPC_AIMBOT = false,
    NPC_AIMBOT_RANGE = 50
}

if not task then
    task = {}
    task.spawn = function(func) coroutine.wrap(func)() end
    task.wait = function(...) return wait(...) end
    task.delay = function(t, func) coroutine.wrap(function() wait(t) func() end)() end
end

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local TargetGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if TargetGui:FindFirstChild("ouncopybara") then
    TargetGui:FindFirstChild("ouncopybara"):Destroy()
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(object, tweenInfo, properties)
    tw:Play()
    return tw
end

local Theme = {
    Background = Color3.fromRGB(20, 8, 16),
    Sidebar = Color3.fromRGB(28, 10, 22),
    Border = Color3.fromRGB(255, 105, 180),
    Accent = Color3.fromRGB(255, 20, 147),
    AccentHover = Color3.fromRGB(255, 105, 180),
    AccentGlow = Color3.fromRGB(255, 182, 193),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(245, 190, 220),
    Input = Color3.fromRGB(35, 12, 28),
    TitleBarLine = Color3.fromRGB(255, 105, 180)
}

local isMobile = UserInputService.TouchEnabled
local MAIN_SIZE = isMobile and UDim2.new(0, 420, 0, 340) or UDim2.new(0, 600, 0, 440)
local SIDEBAR_WIDTH = isMobile and 100 or 150

local function enableDrag(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ========== មុខងាររក NPC ==========
local function FindNearestNPC()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("Head")
    if not myRoot then return nil end

    local nearest = nil
    local minDist = EVADE_CONFIG.NPC_AIMBOT_RANGE

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
            if hum and root and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end

    return nearest
end

local NPCAimbotConnection = nil

local function UpdateNPCAimbot()
    if NPCAimbotConnection then
        NPCAimbotConnection:Disconnect()
        NPCAimbotConnection = nil
    end
    if EVADE_CONFIG.NPC_AIMBOT then
        NPCAimbotConnection = RunService.Heartbeat:Connect(function()
            local npc = FindNearestNPC()
            if npc then
                local targetRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChild("Head")
                if targetRoot then
                    local targetPos = targetRoot.Position

                    if Workspace.CurrentCamera then
                        Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, targetPos)
                    end

                    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("Head"))
                    if myRoot then
                        local lookPosition = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)
                        myRoot.CFrame = CFrame.new(myRoot.Position, lookPosition)
                    end
                end
            end
        end)
    end
end

-- ========== មុខងារ Fling / Kill ==========
local function findPlayer(name)
    name = name:gsub("%s+", ""):lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():match("^"..name) and plr ~= LocalPlayer then return plr end
    end
    return nil
end

local function SkidFling(targetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    if not Character or not Humanoid or not RootPart then return end
    local TCharacter = targetPlayer.Character
    if not TCharacter then return end
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    if THead then Workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then Workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid then Workspace.CurrentCamera.CameraSubject = THumanoid end
    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(BasePart)
        local TimeToWait = 2; local Time = tick(); local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0)); task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)); task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0)); task.wait()
                end
            else break end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TCharacter or targetPlayer.Parent ~= Players or tick() > Time + TimeToWait
    end
    workspace.FallenPartsDestroyHeight = 0 / 0
    local BV = Instance.new("BodyVelocity"); BV.Name = "EpixVel"; BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8); BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if TRootPart and THead then if (TRootPart.Position - THead.Position).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart then SFBasePart(TRootPart)
    elseif THead then SFBasePart(THead)
    elseif Handle then SFBasePart(Handle) end
    BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid
    repeat
        RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
        Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
        Humanoid:ChangeState("GettingUp")
        task.wait()
    until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
    workspace.FallenPartsDestroyHeight = getgenv().FPDH or 500
end

local function executeFling(name)
    if name == "" then return end
    local target = findPlayer(name)
    if not target then notify("Fling", "រកមិនឃើញ", 3) return end
    SkidFling(target)
end

local function flingAllPlayers()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character then SkidFling(plr) end
    end
end

local function executeFEKill(targetName)
    local target = findPlayer(targetName)
    if not target or not target.Character then notify("Kill", "រកមិនឃើញគោលដៅ", 3) return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then return end
    local savepos = root.CFrame
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    torso.Anchored = true
    local hat = char:FindFirstChildOfClass("Accessory")
    if not hat then torso.Anchored = false; return end
    local tool = Instance.new("Tool", LocalPlayer.Backpack)
    local handle = hat.Handle; handle.Parent = tool; handle.Massless = true
    tool.GripPos = Vector3.new(0, 9e99, 0); tool.Parent = char
    repeat task.wait() until char:FindFirstChildOfClass("Tool")
    tool.Grip = CFrame.new(); torso.Anchored = false
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    repeat
        task.wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
        char.HumanoidRootPart.CFrame = targetRoot.CFrame
    until target.Character == nil or target.Character:FindFirstChild("Humanoid").Health <= 0
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):UnequipTools() end
    handle.Parent = hat; handle.Massless = false; tool:Destroy()
    if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = savepos end
    notify("Kill", "បានសម្លាប់ ".. targetName, 3)
end

-- ====== GUI ROOT ======
local screenGui = Instance.new("ScreenGui", TargetGui)
screenGui.Name = "ouncopybara"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Theme.Border

-- ===== ✨ ស្រទាប់ផ្កាយ/ព្រះចន្ទ =====
local sparkleLayer = Instance.new("Frame")
sparkleLayer.Size = UDim2.new(1, 0, 1, 0)
sparkleLayer.Position = UDim2.new(0, 0, 0, 0)
sparkleLayer.BackgroundTransparency = 1
sparkleLayer.ClipsDescendants = false
sparkleLayer.ZIndex = 5
sparkleLayer.Parent = mainFrame

local moonSparkles = {}

local function createMoonDecorations()
    local symbols = {"🪐", "✦", "🪐", "✧", "★"}
    for i = 1, 50 do
        local symbol = symbols[math.random(#symbols)]
        local size = math.random(10, 20)
        local x = math.random(0, 100) / 100
        local y = math.random(0, 100) / 100

        local sparkle = Instance.new("TextLabel")
        sparkle.Size = UDim2.fromOffset(size, size)
        sparkle.Position = UDim2.new(x, 0, y, 0)
        sparkle.BackgroundTransparency = 1
        sparkle.Text = symbol
        sparkle.TextColor3 = Color3.fromHSV(0.9 + math.random() * 0.1, 0.9, 1)
        sparkle.Font = Enum.Font.GothamBold
        sparkle.TextSize = size
        sparkle.TextTransparency = 0
        sparkle.ZIndex = 10
        sparkle.Parent = sparkleLayer
        table.insert(moonSparkles, sparkle)
    end
end

createMoonDecorations()

task.spawn(function()
    while sparkleLayer and sparkleLayer.Parent do
        for _, sparkle in ipairs(moonSparkles) do
            if not sparkle or not sparkle.Parent then continue end
            local targetTransparency = math.random(0, 30) / 100
            local targetSize = math.random(8, 16)
            tween(sparkle, {TextTransparency = targetTransparency}, math.random(0.5, 1.0), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(sparkle, {Size = UDim2.fromOffset(targetSize, targetSize)}, math.random(0.5, 1.0), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(math.random(0.15, 0.4))
        end
        task.wait(0.5)
    end
end)

-- Custom Image Toggle Button
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Theme.Sidebar
toggleBtn.Active = true
toggleBtn.ClipsDescendants = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 2.5
toggleStroke.Color = Theme.Accent

-- Load Web Image (Catbox)
task.spawn(function()
    local imageUrl = "https://files.catbox.moe/ka5x56.jpg"
    local assetName = "CustomToggleImage.jpg"
    
    if writefile and getgenv then
        if not isfile(assetName) then
            local success, response = pcall(function()
                return game:HttpGet(imageUrl)
            end)
            if success and response then
                writefile(assetName, response)
            end
        end
        
        if isfile(assetName) and getcustomasset then
            toggleBtn.Image = getcustomasset(assetName)
        else
            toggleBtn.Image = imageUrl
        end
    else
        toggleBtn.Image = imageUrl
    end
end)

enableDrag(toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local divider = Instance.new("Frame", sidebar)
divider.Size = UDim2.new(0, 1, 1, -20)
divider.Position = UDim2.new(1, -1, 0, 10)
divider.BackgroundColor3 = Theme.TitleBarLine
divider.BorderSizePixel = 0

-- Avatar Box
local avatarContainer = Instance.new("Frame", sidebar)
avatarContainer.BackgroundTransparency = 1
avatarContainer.Position = UDim2.new(0, 0, 0, isMobile and 15 or 40)
avatarContainer.Size = UDim2.new(1, 0, 0, isMobile and 70 or 100)

local avatar = Instance.new("ImageLabel", avatarContainer)
avatar.BackgroundTransparency = 1
avatar.Position = isMobile and UDim2.new(0.5, -20, 0, 0) or UDim2.new(0.5, -30, 0, 0)
avatar.Size = isMobile and UDim2.new(0, 40, 0, 40) or UDim2.new(0, 60, 0, 60)
avatar.Image = "rbxassetid://0"
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", avatar)
avatarStroke.Thickness = 2
avatarStroke.Color = Theme.Accent

task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    if ok then
        avatar.Image = thumb
    end
end)

-- Sidebar Title
local sidebarTitle = Instance.new("TextLabel", sidebar)
sidebarTitle.Size = UDim2.new(1, -20, 0, 40)
sidebarTitle.Position = UDim2.new(0, 10, 0, isMobile and 75 or 115)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "ouncopybara"
sidebarTitle.Font = Enum.Font.GothamBlack
sidebarTitle.TextSize = isMobile and 12 or 15
sidebarTitle.TextColor3 = Theme.AccentGlow
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Content Container
local content = Instance.new("Frame", mainFrame)
content.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0)
content.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0)
content.BackgroundTransparency = 1

-- Header
local header = Instance.new("Frame", content)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1

enableDrag(mainFrame, header)

local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, -40, 0, 1)
headerLine.Position = UDim2.new(0, 20, 1, -1)
headerLine.BackgroundColor3 = Theme.AccentGlow
headerLine.BackgroundTransparency = 0.3

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, -5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ouncopybara"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = isMobile and 14 or 18
titleLabel.TextColor3 = Theme.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local welcomeLabel = Instance.new("TextLabel", header)
welcomeLabel.Size = UDim2.new(1, -60, 0, 18)
welcomeLabel.Position = UDim2.new(0, 20, 0, 28)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.TextSize = isMobile and 10 or 12
welcomeLabel.TextColor3 = Theme.Muted
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -30, 0, 12)
minimizeBtn.BackgroundColor3 = Theme.Accent
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Theme.Text
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Active = true
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scrollable Area
local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, 0, 1, -75)
scroll.Position = UDim2.new(0, 0, 0, 50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 1150)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y

-- Toggle Builder
local function addToggle(y, text, default, callback)
    local container = Instance.new("Frame", scroll)
    container.Size = UDim2.new(1, -20, 0, 40)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundColor3 = Theme.Input
    container.BackgroundTransparency = 0.3
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 180, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMobile and 11 or 13
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleFrame = Instance.new("Frame", container)
    toggleFrame.Size = UDim2.new(0, 48, 0, 24)
    toggleFrame.Position = UDim2.new(1, -58, 0.5, -12)
    toggleFrame.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 40, 55)
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleFrame)
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, default and 25 or 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Active = true

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        tween(toggleFrame, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 40, 55)}, 0.2)
        tween(knob, {Position = UDim2.new(0, state and 25 or 2, 0.5, -10)}, 0.2, Enum.EasingStyle.Back)
    end)
end

-- TextBox Builder
local function addTextBox(y, labelText, defaultText, callback)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 110, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = isMobile and 10 or 12
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 70, 0, 26)
    box.Position = UDim2.new(1, -110, 0, 2)
    box.BackgroundColor3 = Theme.Input
    box.TextColor3 = Theme.Text
    box.Text = defaultText
    box.Font = Enum.Font.Gotham
    box.TextSize = isMobile and 10 or 12
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    local setBtn = Instance.new("TextButton", frame)
    setBtn.Size = UDim2.new(0, 40, 0, 26)
    setBtn.Position = UDim2.new(1, -35, 0, 2)
    setBtn.BackgroundColor3 = Theme.Accent
    setBtn.Text = "Set"
    setBtn.TextColor3 = Theme.Text
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = isMobile and 10 or 12
    setBtn.Active = true
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 4)

    setBtn.MouseButton1Click:Connect(function()
        callback(box.Text)
    end)
end

-- Button Builder
local function addButton(y, text, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = isMobile and 11 or 12
    btn.Active = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(callback)
end

-- Render Options
addToggle(10, "Auto Dash", false, function(v) EVADE_CONFIG.AUTO_DASH = v end)
addTextBox(55, "Dash Speed", "60", function(v) EVADE_CONFIG.DASH_SPEED = tonumber(v) or 60 end)
addTextBox(95, "Cooldown", "0.1", function(v) EVADE_CONFIG.DASH_COOLDOWN = tonumber(v) or 0.1 end)
addToggle(135, "Instant Dash", false, function(v) EVADE_CONFIG.INSTANT_DASH = v end)

-- Dash Mode Options
local dirContainer = Instance.new("Frame", scroll)
dirContainer.Size = UDim2.new(1, -20, 0, 40)
dirContainer.Position = UDim2.new(0, 10, 0, 180)
dirContainer.BackgroundColor3 = Theme.Input
dirContainer.BackgroundTransparency = 0.3
Instance.new("UICorner", dirContainer).CornerRadius = UDim.new(0, 8)

local dirLabel = Instance.new("TextLabel", dirContainer)
dirLabel.Size = UDim2.new(0, 100, 1, 0)
dirLabel.Position = UDim2.new(0, 10, 0, 0)
dirLabel.BackgroundTransparency = 1
dirLabel.Text = "Direction:"
dirLabel.Font = Enum.Font.GothamBold
dirLabel.TextSize = isMobile and 11 or 13
dirLabel.TextColor3 = Theme.Text
dirLabel.TextXAlignment = Enum.TextXAlignment.Left

local moveBtn = Instance.new("TextButton", dirContainer)
moveBtn.Size = UDim2.new(0, 60, 0, 26)
moveBtn.Position = UDim2.new(0, 105, 0, 7)
moveBtn.BackgroundColor3 = Theme.Accent
moveBtn.Text = "Move"
moveBtn.TextColor3 = Theme.Text
moveBtn.Font = Enum.Font.GothamBold
moveBtn.TextSize = 11
moveBtn.Active = true
Instance.new("UICorner", moveBtn).CornerRadius = UDim.new(0, 4)

local cameraBtn = Instance.new("TextButton", dirContainer)
cameraBtn.Size = UDim2.new(0, 60, 0, 26)
cameraBtn.Position = UDim2.new(0, 175, 0, 7)
cameraBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 55)
cameraBtn.Text = "Camera"
cameraBtn.TextColor3 = Theme.Text
cameraBtn.Font = Enum.Font.GothamBold
cameraBtn.TextSize = 11
cameraBtn.Active = true
Instance.new("UICorner", cameraBtn).CornerRadius = UDim.new(0, 4)

moveBtn.MouseButton1Click:Connect(function()
    EVADE_CONFIG.DASH_MODE = "MoveDirection"
    moveBtn.BackgroundColor3 = Theme.Accent
    cameraBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 55)
end)

cameraBtn.MouseButton1Click:Connect(function()
    EVADE_CONFIG.DASH_MODE = "CameraDirection"
    cameraBtn.BackgroundColor3 = Theme.Accent
    moveBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 55)
end)

addTextBox(230, "Walk Speed", "16", function(v) EVADE_CONFIG.WALKSPEED = tonumber(v) or 16 end)
addToggle(265, "Super Jump", false, function(v) EVADE_CONFIG.SUPER_JUMP = v end)
addTextBox(310, "Jump Power", "50", function(v) EVADE_CONFIG.JUMP_POWER = tonumber(v) or 50 end)

addToggle(350, "Infinite Jump", false, function(v) EVADE_CONFIG.INFINITE_JUMP = v end)

addToggle(395, "Player ESP", false, function(v) EVADE_CONFIG.ESP_PLAYERS = v end)
addToggle(440, "All NPC / Bot ESP", false, function(v) EVADE_CONFIG.ESP_BOTS = v end)

addToggle(485, "FullBright", false, function(v) EVADE_CONFIG.FULLBRIGHT = v end)
addToggle(530, "No Clip", false, function(v) EVADE_CONFIG.NO_CLIP = v end)
addTextBox(575, "FOV Changer", "70", function(v) 
    EVADE_CONFIG.FOV = tonumber(v) or 70
    workspace.CurrentCamera.FieldOfView = EVADE_CONFIG.FOV
end)

addToggle(620, "Auto Revive", false, function(v) EVADE_CONFIG.AUTO_REVIVE = v end)
addToggle(665, "Auto Respawn", false, function(v) EVADE_CONFIG.AUTO_RESPAWN = v end)

-- Rapid Fire + Infinite Ammo
addToggle(710, "Rapid Fire", false, function(v) EVADE_CONFIG.RAPID_FIRE = v end)
addTextBox(755, "Fire Interval", "0.1", function(v) EVADE_CONFIG.RAPID_FIRE_INTERVAL = tonumber(v) or 0.1 end)
addToggle(800, "Infinite Ammo", false, function(v) EVADE_CONFIG.INFINITE_AMMO = v end)

-- NPC Aimbot
addToggle(845, "NPC Aimbot", false, function(v) EVADE_CONFIG.NPC_AIMBOT = v; UpdateNPCAimbot() end)
addTextBox(890, "Aimbot Range", "50", function(v) EVADE_CONFIG.NPC_AIMBOT_RANGE = tonumber(v) or 50 end)

-- Fling Player
local flingBox = Instance.new("TextBox")
flingBox.Size = UDim2.new(1, -20, 0, 30)
flingBox.Position = UDim2.new(0, 10, 0, 935)
flingBox.BackgroundColor3 = Theme.Input
flingBox.TextColor3 = Theme.Text
flingBox.PlaceholderText = "ឈ្មោះអ្នកលេង (Fling)"
flingBox.Font = Enum.Font.Gotham
flingBox.TextSize = 12
flingBox.Parent = scroll
Instance.new("UICorner", flingBox).CornerRadius = UDim.new(0, 4)

addButton(970, "Fling Player", function()
    executeFling(flingBox.Text)
end)

-- Fling All
addToggle(1010, "Fling All", false, function(v)
    if v then
        flingAllPlayers()
    end
end)

-- Kill Player (FE)
local killBox = Instance.new("TextBox")
killBox.Size = UDim2.new(1, -20, 0, 30)
killBox.Position = UDim2.new(0, 10, 0, 1055)
killBox.BackgroundColor3 = Theme.Input
killBox.TextColor3 = Theme.Text
killBox.PlaceholderText = "ឈ្មោះអ្នកលេង (Kill)"
killBox.Font = Enum.Font.Gotham
killBox.TextSize = 12
killBox.Parent = scroll
Instance.new("UICorner", killBox).CornerRadius = UDim.new(0, 4)

addButton(1090, "Kill Player", function()
    executeFEKill(killBox.Text)
end)

addButton(1130, "Unload Script", function()
    screenGui:Destroy()
end)

-- Status Bar
local statusBar = Instance.new("Frame", mainFrame)
statusBar.Size = UDim2.new(1, 0, 0, 25)
statusBar.Position = UDim2.new(0, 0, 1, -25)
statusBar.BackgroundColor3 = Theme.Sidebar

local statusText = Instance.new("TextLabel", statusBar)
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "● Ready"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 10
statusText.TextColor3 = Theme.Muted
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- 💖✨ Effect ភ្លឺផ្លេកៗ ពណ៌ផ្កាយឈូក
task.spawn(function()
    while screenGui and screenGui.Parent do
        tween(mainStroke, {Color = Color3.fromRGB(255, 192, 203)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 105, 180)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(avatarStroke, {Color = Color3.fromRGB(255, 192, 203)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
        tween(mainStroke, {Color = Color3.fromRGB(255, 20, 147)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(toggleStroke, {Color = Color3.fromRGB(255, 192, 203)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tween(avatarStroke, {Color = Color3.fromRGB(255, 20, 147)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
    end
end)

-- ===== Core Game Logic Functions =====
local lastDashTime = 0
local originalJumpPower = 50

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head"))
end

local function CreateHighlight(obj, color)
    if not obj:FindFirstChild("OuncESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "OuncESP"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.4
        hl.Adornee = obj
        hl.Parent = obj
    end
end

local function RemoveHighlight(obj)
    if obj:FindFirstChild("OuncESP") then
        obj.OuncESP:Destroy()
    end
end

local function ApplyFullBright()
    if EVADE_CONFIG.FULLBRIGHT then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
    else
        Lighting.Brightness = 0.5
        Lighting.ClockTime = 0
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(100,100,100)
    end
end

local function ApplySuperJump()
    local hum = GetHumanoid()
    if hum then
        if EVADE_CONFIG.SUPER_JUMP then
            originalJumpPower = hum.JumpPower or 50
            hum.JumpPower = EVADE_CONFIG.JUMP_POWER
        else
            hum.JumpPower = originalJumpPower
        end
    end
end

-- Dash
local function PerformDash()
    local now = os.clock()
    if now - lastDashTime < EVADE_CONFIG.DASH_COOLDOWN then return end

    local root = GetRoot()
    local hum = GetHumanoid()
    if not root or not hum then return end

    if hum.MoveDirection.Magnitude == 0 then return end

    local dir
    if EVADE_CONFIG.DASH_MODE == "CameraDirection" then
        local cam = workspace.CurrentCamera
        if cam then
            dir = cam.CFrame.LookVector
            dir = Vector3.new(dir.X, 0, dir.Z).Unit
        else
            dir = hum.MoveDirection
        end
    else
        dir = hum.MoveDirection
    end
    dir = Vector3.new(dir.X, 0, dir.Z).Unit

    if EVADE_CONFIG.INSTANT_DASH then
        root.CFrame = root.CFrame + dir * (EVADE_CONFIG.DASH_SPEED / 10)
        lastDashTime = now
    else
        local bv = root:FindFirstChild("DashBV") or Instance.new("BodyVelocity")
        bv.Name = "DashBV"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
        bv.Velocity = dir * EVADE_CONFIG.DASH_SPEED
        bv.Parent = root
        lastDashTime = now
        task.delay(0.1, function()
            if bv and bv.Parent then bv:Destroy() end
        end)
    end
end

-- Loops
RunService.Heartbeat:Connect(function()
    if EVADE_CONFIG.AUTO_DASH then
        local hum = GetHumanoid()
        if hum and hum.MoveDirection.Magnitude > 0 then
            PerformDash()
        end
    end
end)

RunService.Stepped:Connect(function()
    if EVADE_CONFIG.NO_CLIP and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    ApplySuperJump()
    ApplyFullBright()
    
    local hum = GetHumanoid()
    if hum and not EVADE_CONFIG.AUTO_DASH then
        hum.WalkSpeed = EVADE_CONFIG.WALKSPEED
    end

    -- Player ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if EVADE_CONFIG.ESP_PLAYERS then
                CreateHighlight(plr.Character, Color3.fromRGB(255, 182, 193))
            else
                RemoveHighlight(plr.Character)
            end
        end
    end

    -- Bot ESP
    if EVADE_CONFIG.ESP_BOTS then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                if obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("HumanoidRootPart") then
                    CreateHighlight(obj, Color3.fromRGB(255, 20, 147))
                end
            end
        end
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                RemoveHighlight(obj)
            end
        end
    end

    -- Infinite Ammo
    if EVADE_CONFIG.INFINITE_AMMO then
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, v in ipairs(tool:GetDescendants()) do
                    if (v:IsA("IntValue") or v:IsA("NumberValue")) and (v.Name:lower():find("ammo") or v.Name:lower():find("clip") or v.Name:lower():find("mag") or v.Name:lower():find("bullet")) then
                        if v:IsA("IntValue") then
                            v.Value = math.max(v.Value, 1)
                        else
                            v.Value = math.max(v.Value, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- Rapid Fire Loop
task.spawn(function()
    while screenGui.Parent do
        if EVADE_CONFIG.RAPID_FIRE then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        tool:Activate()
                    end)
                    pcall(function()
                        VirtualUser:ClickButton1(Vector2.new(0,0))
                    end)
                end
            end
            task.wait(EVADE_CONFIG.RAPID_FIRE_INTERVAL)
        else
            task.wait(0.1)
        end
    end
end)

-- Auto Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if EVADE_CONFIG.AUTO_RESPAWN then
            task.wait(0.5)
            pcall(function() LocalPlayer:LoadCharacter() end)
        end
    end)
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if EVADE_CONFIG.INFINITE_JUMP then
        local root = GetRoot()
        if root then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, EVADE_CONFIG.JUMP_POWER, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Status bar updater
task.spawn(function()
    local lastTime = os.clock()
    local frames = 0
    local fps = 0
    local ping = 0
    while screenGui.Parent do
        frames = frames + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            fps = frames / (now - lastTime)
            frames = 0
            lastTime = now
            if LocalPlayer then
                ping = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000)
            end
            statusText.Text = string.format("● FPS: %d | Ping: %dms | Dash: %s | NPC: %s", fps, ping, EVADE_CONFIG.AUTO_DASH and "ON" or "OFF", EVADE_CONFIG.NPC_AIMBOT and "ON" or "OFF")
        end
        task.wait(0.1)
    end
end)

-- Entrance Animation
tween(mainFrame, {Size = MAIN_SIZE}, 0.4)
print("✨ ouncopybara (Glowing Pink + Fling + FE Kill) Loaded Successfully!")