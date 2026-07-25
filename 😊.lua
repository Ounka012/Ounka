--========================================================
-- EVADE-STYLE GUI + KILL AURA (Original Remote Config)
-- Image: https://files.catbox.moe/ka5x56.jpg
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

--============== ជំនួយ GUI ==============
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

--============== មុខងារប្រយុទ្ធ (MKRA HUB ដើម) ==============
local Settings = {
    KillAura = false,
    KillAuraRange = 30,
    KillAuraDamage = 30,
    KillAuraNPC = false,
    KillAuraRemote = "",        -- ឈ្មោះ Remote ជាក់លាក់ (ទទេ = ស្វែងរកស្វ័យប្រវត្តិ)
    KillAuraRemoteArgs = "target,damage",
    KillMobs = false,
}
local Connections = {
    KillAura = nil,
    KillMobs = nil,
}

local function GetCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Humanoid")) and char or nil
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function GetKARemote()
    local remoteName = Settings.KillAuraRemote
    if remoteName ~= "" then
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                return v
            end
        end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                return v
            end
        end
    else
        local searchNames = {"Attack", "Damage", "Hit", "Kill", "DealDamage", "Fire"}
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                for _, n in ipairs(searchNames) do
                    if v.Name:lower():find(n:lower()) then return v end
                end
            end
        end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                for _, n in ipairs(searchNames) do
                    if v.Name:lower():find(n:lower()) then return v end
                end
            end
        end
    end
    return nil
end

local function GetKATargets()
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(targets, {Humanoid = hum, RootPart = root, IsPlayer = true})
            end
        end
    end
    if Settings.KillAuraNPC then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local root = m:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(targets, {Humanoid = hum, RootPart = root, IsPlayer = false})
                end
            end
        end
    end
    return targets
end

local function BuildArgs(target)
    local args = {}
    local argStr = Settings.KillAuraRemoteArgs:gsub("%s+", "")
    for a in argStr:gmatch("[^,]+") do
        a = a:match("^%s*(.-)%s*$")
        if a == "target" then table.insert(args, target.RootPart)
        elseif a == "damage" then table.insert(args, Settings.KillAuraDamage)
        elseif a == "humanoid" then table.insert(args, target.Humanoid)
        elseif a == "model" then table.insert(args, target.RootPart.Parent)
        else table.insert(args, a) end
    end
    if #args == 0 then args = {target.RootPart, Settings.KillAuraDamage} end
    return args
end

local function ToggleKillAura()
    if Connections.KillAura then
        pcall(function() Connections.KillAura:Disconnect() end)
        Connections.KillAura = nil
    end
    if not Settings.KillAura then return end

    local remote = Settings.KillAuraNPC and GetKARemote() or nil
    Connections.KillAura = RunService.Heartbeat:Connect(function()
        local char = GetCharacter()
        if not char then return end
        local myRoot = GetRootPart()
        if not myRoot then return end

        local targets = GetKATargets()
        for _, t in ipairs(targets) do
            if (myRoot.Position - t.RootPart.Position).Magnitude <= Settings.KillAuraRange then
                if t.IsPlayer then
                    pcall(function() t.Humanoid:TakeDamage(Settings.KillAuraDamage) end)
                else
                    if remote then
                        local args = BuildArgs(t)
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(args))
                            else
                                remote:InvokeServer(unpack(args))
                            end
                        end)
                    else
                        pcall(function()
                            t.Humanoid.Health = math.max(0, t.Humanoid.Health - Settings.KillAuraDamage)
                        end)
                    end
                end
            end
        end
    end)
end

local function ToggleKillMobs()
    if Connections.KillMobs then
        pcall(function() Connections.KillMobs:Disconnect() end)
        Connections.KillMobs = nil
    end
    if not Settings.KillMobs then return end

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

--============== GUI ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("KillGUI") then
        CoreGui:FindFirstChild("KillGUI"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "KillGUI"
    gui.IgnoreGuiInset = true

    -- Toggle Button
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
    mainFrame.Size = UDim2.new(0, 420, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
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
    bg.ImageTransparency = 0
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

    -- Close
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    local y = 70

    -- Helper: Toggle
    local function addToggle(yPos, text, default, callback)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(1, -40, 0, 45)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        btn.BackgroundColor3 = default and Color3.fromRGB(0,180,0) or Color3.fromRGB(0,180,255)
        btn.Text = text .. ": " .. (default and "ON" or "OFF")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

        local state = default
        btn.MouseButton1Down:Connect(function()
            state = not state
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(0,180,0) or Color3.fromRGB(0,180,255)
            callback(state)
        end)
        return btn
    end

    -- Helper: TextBox
    local function addTextBox(yPos, label, default, callback)
        local frame = Instance.new("Frame", mainFrame)
        frame.Size = UDim2.new(1, -40, 0, 40)
        frame.Position = UDim2.new(0, 20, 0, yPos)
        frame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0, 120, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextBox", frame)
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
        return frame
    end

    -- Kill Aura
    addToggle(y, "Kill Aura", Settings.KillAura, function(v)
        Settings.KillAura = v
        ToggleKillAura()
    end)
    y = y + 55

    addTextBox(y, "KA Range", tostring(Settings.KillAuraRange), function(v)
        Settings.KillAuraRange = tonumber(v) or 30
    end)
    y = y + 50

    addTextBox(y, "KA Damage", tostring(Settings.KillAuraDamage), function(v)
        Settings.KillAuraDamage = tonumber(v) or 30
    end)
    y = y + 50

    addToggle(y, "KA NPCs", Settings.KillAuraNPC, function(v)
        Settings.KillAuraNPC = v
        remoteFrame.Visible = v
        argsFrame.Visible = v
        if Settings.KillAura then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)
    y = y + 55

    local remoteFrame = addTextBox(y, "Remote Name", Settings.KillAuraRemote, function(v)
        Settings.KillAuraRemote = v
        if Settings.KillAura and Settings.KillAuraNPC then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)
    y = y + 50

    local argsFrame = addTextBox(y, "Remote Args", Settings.KillAuraRemoteArgs, function(v)
        Settings.KillAuraRemoteArgs = v
        if Settings.KillAura and Settings.KillAuraNPC then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)
    y = y + 50

    -- លាក់ Remote ដំបូង
    remoteFrame.Visible = Settings.KillAuraNPC
    argsFrame.Visible = Settings.KillAuraNPC

    -- Kill Mobs
    addToggle(y, "Kill Mobs", Settings.KillMobs, function(v)
        Settings.KillMobs = v
        ToggleKillMobs()
    end)
    y = y + 55

    -- Status
    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 30)
    hintLabel.Position = UDim2.new(0, 20, 1, -35)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព៖ ត្រៀម"
    hintLabel.TextColor3 = Color3.new(1,1,1)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12

    -- RGB Effect
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
        ToggleKillAura()
        ToggleKillMobs()
        gui:Destroy()
    end)

    makeDraggable(mainFrame)
end

--============== ទាញយករូប ==============
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    local asset = ""
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        asset = getcustomasset(FILE_NAME)
    end
    createGUI(asset)
end

loadImageAndStart()

-- ពេលរស់ឡើងវិញ
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.KillAura then
        ToggleKillAura()
        ToggleKillAura()
    end
    if Settings.KillMobs then
        ToggleKillMobs()
        ToggleKillMobs()
    end
end)