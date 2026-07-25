--[[
    KILL AURA & KILL MOBS - Original GUI with Image
    Features: Kill Aura (Players), Kill Aura NPCs (toggle), Kill Mobs
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ====== រូបភាព ======
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

-- ====== អថេរ ======
local Settings = {
    KillAura = false,
    KillAuraRange = 30,
    KillAuraDamage = 30,
    KillAuraNPC = false,
    KillMobs = false,
}
local Connections = {
    KillAura = nil,
    KillMobs = nil,
}

-- ====== លុប GUI ចាស់ ======
if CoreGui:FindFirstChild("KillAura_GUI") then
    CoreGui:FindFirstChild("KillAura_GUI"):Destroy()
end

-- ====== មុខងារជំនួយ ======
local function makeDraggable(guiObject)
    local dragging, startPos, objPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startPos = input.Position; objPos = guiObject.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            guiObject.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function GetCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Humanoid")) and char or nil
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

-- ====== មុខងារ Kill Aura ======
local function getKATargets()
    local targets = {}
    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(targets, { Humanoid = hum, RootPart = root })
            end
        end
    end
    -- NPCs (if enabled)
    if Settings.KillAuraNPC then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(targets, { Humanoid = hum, RootPart = root })
                end
            end
        end
    end
    return targets
end

local function toggleKillAura()
    if Connections.KillAura then
        pcall(function() Connections.KillAura:Disconnect() end)
        Connections.KillAura = nil
    end

    if Settings.KillAura then
        Connections.KillAura = RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end
            local myRoot = GetRootPart()
            if not myRoot then return end

            local targets = getKATargets()
            for _, t in pairs(targets) do
                if (myRoot.Position - t.RootPart.Position).Magnitude <= Settings.KillAuraRange then
                    pcall(function()
                        t.Humanoid:TakeDamage(Settings.KillAuraDamage)
                    end)
                end
            end
        end)
    end
end

-- ====== មុខងារ Kill Mobs ======
local function toggleKillMobs()
    if Connections.KillMobs then
        pcall(function() Connections.KillMobs:Disconnect() end)
        Connections.KillMobs = nil
    end

    if Settings.KillMobs then
        Connections.KillMobs = RunService.Heartbeat:Connect(function()
            local char = GetCharacter()
            if not char then return end
            local root = GetRootPart()
            if not root then return end

            local folder = Workspace:FindFirstChild("Mobs")
            if not folder then return end

            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChildOfClass("Humanoid")
                if mobRoot and mobHum and mobHum.Health > 0 then
                    if (root.Position - mobRoot.Position).Magnitude < 25 then
                        pcall(function()
                            if ReplicatedStorage:FindFirstChild("Events") and
                               ReplicatedStorage.Events:FindFirstChild("Attack") then
                                ReplicatedStorage.Events.Attack:FireServer(mobHum)
                            end
                        end)
                    end
                end
            end
        end)
    end
end

-- ====== GUI ដើម (មានរូបភាព) ======
local function createGUI(imageAsset)
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "KillAura_GUI"
    gui.IgnoreGuiInset = true

    -- Toggle Button (រាងមូល)
    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Draggable = true
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    -- Main Frame
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 420, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- Background Image
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- Title
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ KILL AURA & MOBS"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)

    -- Close Button
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    -- Helper function to add toggle
    local function addToggle(yOffset, text, default, callback)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(1, -40, 0, 45)
        btn.Position = UDim2.new(0, 20, 0, yOffset)
        btn.BackgroundColor3 = default and Color3.fromRGB(0,140,0) or Color3.fromRGB(50,50,70)
        btn.Text = text .. ": " .. (default and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

        local state = default
        btn.MouseButton1Down:Connect(function()
            state = not state
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(0,140,0) or Color3.fromRGB(50,50,70)
            callback(state)
        end)
        return btn
    end

    -- Helper function to add TextBox
    local function addTextBox(yOffset, label, default, callback)
        local boxFrame = Instance.new("Frame", mainFrame)
        boxFrame.Size = UDim2.new(1, -40, 0, 40)
        boxFrame.Position = UDim2.new(0, 20, 0, yOffset)
        boxFrame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", boxFrame)
        lbl.Size = UDim2.new(0, 120, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextBox", boxFrame)
        box.Size = UDim2.new(1, -130, 1, 0)
        box.Position = UDim2.new(0, 130, 0, 0)
        box.BackgroundColor3 = Color3.fromRGB(50,50,70)
        box.TextColor3 = Color3.new(1,1,1)
        box.Text = default
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        box.FocusLost:Connect(function()
            callback(box.Text)
        end)
    end

    -- Add UI elements
    addToggle(70, "Kill Aura", Settings.KillAura, function(v)
        Settings.KillAura = v
        toggleKillAura()
    end)

    addTextBox(125, "KA Range", tostring(Settings.KillAuraRange), function(v)
        Settings.KillAuraRange = tonumber(v) or 30
    end)

    addTextBox(175, "KA Damage", tostring(Settings.KillAuraDamage), function(v)
        Settings.KillAuraDamage = tonumber(v) or 30
    end)

    addToggle(225, "KA NPCs", Settings.KillAuraNPC, function(v)
        Settings.KillAuraNPC = v
        if Settings.KillAura then
            toggleKillAura() -- restart to refresh target list
            toggleKillAura()
        end
    end)

    addToggle(275, "Kill Mobs", Settings.KillMobs, function(v)
        Settings.KillMobs = v
        toggleKillMobs()
    end)

    -- Status label
    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "ស្ថានភាព៖ រង់ចាំ..."
    statusLabel.TextColor3 = Color3.new(1,1,1)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12

    -- RGB effect
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            mainStroke.Color = Color3.fromHSV(hue, 1, 1)
            toggleStroke.Color = Color3.fromHSV((hue+0.3)%1, 1, 1)
            task.wait(0.04)
        end
    end)

    -- Events
    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    closeBtn.MouseButton1Down:Connect(function()
        Settings.KillAura = false
        Settings.KillMobs = false
        toggleKillAura()
        toggleKillMobs()
        gui:Destroy()
    end)

    makeDraggable(mainFrame)
end

-- ====== ទាញយករូបភាព ======
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        createGUI("")
    end
end

loadImageAndStart()

-- ====== Respawn Handling ======
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.KillAura then
        toggleKillAura()
        toggleKillAura()
    end
    if Settings.KillMobs then
        toggleKillMobs()
        toggleKillMobs()
    end
end)