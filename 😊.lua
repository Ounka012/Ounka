--========================================================
-- EVADE-STYLE GUI + FULL KILL AURA (Original Remote Logic)
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

--============== មុខងារប្រយុទ្ធ (ដូច MKRA HUB ដើម) ==============
local Settings = {
    KillAura = false,
    KillAuraRange = 30,
    KillAuraDamage = 30,
    KillAuraNPC = false,
    KillAuraRemote = "",        -- ទុកទទេបើចង់ស្វែងរកដោយស្វ័យប្រវត្តិ
    KillAuraRemoteArgs = "target,damage",  -- គំរូ arguments
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

-- ស្វែងរក Remote តាមឈ្មោះដែលបានកំណត់ (ឬស្វ័យប្រវត្តិ)
local function GetKARemote()
    local remoteName = Settings.KillAuraRemote
    if remoteName ~= "" then
        -- ស្វែងរកតាមឈ្មោះពិតប្រាកដ
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
        -- ស្វ័យប្រវត្តិស្វែងរក Remote ដែលមានពាក្យគន្លឹះ
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

-- បង្កើត arguments តាមគំរូ (ដូចដើម)
local function BuildArgs(target)
    local args = {}
    local argStr = Settings.KillAuraRemoteArgs:gsub("%s+", "")
    for a in argStr:gmatch("[^,]+") do
        a = a:match("^%s*(.-)%s*$")
        if a == "target" then
            table.insert(args, target.RootPart)
        elseif a == "damage" then
            table.insert(args, Settings.KillAuraDamage)
        elseif a == "humanoid" then
            table.insert(args, target.Humanoid)
        elseif a == "model" then
            table.insert(args, target.RootPart.Parent)
        else
            table.insert(args, a) -- តម្លៃផ្សេងៗ
        end
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
                    -- ប្រើ Remote បើមាន បើមិនអញ្ចឹងកាត់ Health ផ្ទាល់
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

--============== GUI (រូបភាពភ្លឺ + ប្រអប់ Remote) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("KillGUI") then
        CoreGui:FindFirstChild("KillGUI"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "KillGUI"
    gui.IgnoreGuiInset = true

    -- ប៊ូតុងមូល (មានរូប)
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
    mainFrame.Size = UDim2.new(0, 420, 0, 400) -- ខ្ពស់ជាងមុនសម្រាប់ Remote
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- រូបភាពផ្ទៃខាងក្រោយ (ភ្លឺច្បាស់)
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- ចំណងជើង
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ KILL AURA & MOBS"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)

    -- ប៊ូតុងបិទ
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    -- មុខងារជំនួយបង្កើតប៊ូតុង
    local function addToggleBtn(yPos, text, default, callback)
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
        return frame, box
    end

    -- ដាក់មុខងារជាជួរ
    addToggleBtn(70, "Kill Aura", Settings.KillAura, function(v)
        Settings.KillAura = v
        ToggleKillAura()
    end)

    addTextBox(125, "KA Range", tostring(Settings.KillAuraRange), function(v)
        Settings.KillAuraRange = tonumber(v) or 30
    end)

    addTextBox(175, "KA Damage", tostring(Settings.KillAuraDamage), function(v)
        Settings.KillAuraDamage = tonumber(v) or 30
    end)

    addToggleBtn(225, "KA NPCs", Settings.KillAuraNPC, function(v)
        Settings.KillAuraNPC = v
        if Settings.KillAura then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)

    -- ប្រអប់ Remote (បង្ហាញពេល KA NPCs បើក)
    local remoteFrame, remoteBox = addTextBox(280, "Remote Name", Settings.KillAuraRemote, function(v)
        Settings.KillAuraRemote = v
        if Settings.KillAura and Settings.KillAuraNPC then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)
    local argsFrame, argsBox = addTextBox(330, "Remote Args", Settings.KillAuraRemoteArgs, function(v)
        Settings.KillAuraRemoteArgs = v
        if Settings.KillAura and Settings.KillAuraNPC then
            ToggleKillAura()
            ToggleKillAura()
        end
    end)
    -- លាក់វាបើ KA NPCs មិនបើក
    local function updateRemoteVisibility()
        remoteFrame.Visible = Settings.KillAuraNPC
        argsFrame.Visible = Settings.KillAuraNPC
    end
    updateRemoteVisibility()
    -- ពេលចុចប៊ូតុង KA NPCs យើងធ្វើបច្ចុប្បន្នភាពភាពមើលឃើញ
    -- យើងនឹងធ្វើឡើងវិញនៅក្នុង addToggleBtn ដែលជាផ្នែកដដែល
    -- ដូច្នេះយើងត្រូវកែ callback របស់ KA NPCs toggle
    -- សូមធ្វើការដាក់អនុគមន៍ឡើងវិញ
    -- (ខាងក្រោមយើងនឹងជំនួសមុខងារ addToggleBtn ដែលបានបង្កើតមុនសម្រាប់ KA NPCs)
    -- ប៉ុន្តែដើម្បីភាពងាយស្រួល យើងនឹងរក្សាទុកប៊ូតុង ហើយកែ callback វិញ
    -- នៅទីនេះយើងបានបង្កើត addToggleBtn រួចហើយ ដូច្នេះយើងនឹងស្វែងរកប៊ូតុង KA NPCs ដោយផ្ទាល់
    -- ដោយសារយើងមិនទាន់បានរក្សាទុក reference យើងនឹងធ្វើការកែសម្រួលមុខងារ addToggleBtn ដើម្បីប្រគល់ btn មកវិញ

    -- យើងនឹងបង្កើតមុខងារ addToggleBtn ថ្មីដែលប្រគល់ btn មកវិញ ប៉ុន្តែឥឡូវនេះយើងនឹងស្វែងរកពី mainFrame វិញ
    local kaNpcBtn = mainFrame:FindFirstChild("KA_NPCs_Btn") -- យើងនឹងដាក់ឈ្មោះ
    -- ដូច្នេះខ្ញុំនឹងសរសេរសាជាថ្មីទាំងស្រុងដោយប្រើវិធីល្អជាង

    -- សូមអភ័យទោសចំពោះភាពស្មុគស្មាញ ខ្ញុំនឹងសរសេរស្គ្រីបដែលរៀបចំបានស្អាតជាងមុននៅខាងក្រោម
end

-- ខ្ញុំនឹងបង្កើត GUI ឡើងវិញដោយប្រើរចនាសម្ព័ន្ធល្អជាង ដើម្បីគ្រប់គ្រងការបង្ហាញ Remote
-- សូមអធ្យាស្រ័យ ខ្ញុំសូមដាក់កូដពេញនៅចម្លើយចុងក្រោយ