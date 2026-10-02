-- =========================================================================
-- [ 🌳 TREE ESP - មើលឈ្មោះដើមឈើ + ចម្ងាយ ]
-- =========================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- លុប GUI ចាស់
for _, gui in pairs(CoreGui:GetChildren()) do
    if string.find(gui.Name, "TreeESP") then gui:Destroy() end
end

-- =========================================================================
-- [ CONFIG ]
-- =========================================================================
local Config = {
    IsEnabled = true,           -- បើក/បិទ ESP
    ShowDistance = true,        -- បង្ហាញចម្ងាយ
    ShowName = true,            -- បង្ហាញឈ្មោះ
    MaxDistance = 500,          -- ចម្ងាយអតិបរមាដែលបង្ហាញ (studs)
    TextColor = Color3.fromRGB(0, 255, 100),   -- ពណ៌អក្សរ (បៃតង)
    OutlineColor = Color3.fromRGB(0, 0, 0),    -- ពណ៌ស៊ុមអក្សរ
    TextSize = 14,
    UseBoxHighlight = true,     -- បង្ហាញ Highlight ជុំវិញដើមឈើ
    HighlightColor = Color3.fromRGB(0, 255, 100),
}

-- ពាក្យគន្លឹះសម្រាប់រកដើមឈើ (បន្ថែមបាន)
local TreeKeywords = {
    "tree", "wood", "oak", "pine", "palm", "birch", "maple",
    "trunk", "log", "bamboo", "cactus", "bush", "plant",
}

-- =========================================================================
-- [ HELPER ]
-- =========================================================================
local activeESP = {}  -- រក្សាទុក ESP ដែលកំពុងដំណើរការ

local function isTree(obj)
    if not obj or not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local name = string.lower(obj.Name)
    for _, kw in ipairs(TreeKeywords) do
        if string.find(name, kw) then return true end
    end
    return false
end

local function createESPLabel(adornee)
    if not adornee then return nil end
    
    -- បង្កើត BillBoardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TreeESP_Label"
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Adornee = adornee
    billboard.Parent = CoreGui

    -- Label សម្រាប់ឈ្មោះ + ចម្ងាយ
    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = ""
    textLabel.TextColor3 = Config.TextColor
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Config.OutlineColor
    textLabel.TextScaled = false
    textLabel.TextSize = Config.TextSize
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true

    -- Highlight ជុំវិញដើមឈើ
    local highlight = nil
    if Config.UseBoxHighlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "TreeESP_Highlight"
        highlight.Adornee = adornee
        highlight.FillColor = Config.HighlightColor
        highlight.OutlineColor = Config.HighlightColor
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = CoreGui
    end

    return {
        billboard = billboard,
        textLabel = textLabel,
        highlight = highlight,
        adornee = adornee,
    }
end

local function destroyESP(esp)
    if not esp then return end
    if esp.billboard then esp.billboard:Destroy() end
    if esp.highlight then esp.highlight:Destroy() end
end

-- =========================================================================
-- [ SCAN & UPDATE LOOP ]
-- =========================================================================
local function scanTrees()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myPos = hrp.Position
    
    -- ស្កេនរកដើមឈើទាំងអស់
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if isTree(obj) then
                -- បើមិនទាន់មាន ESP ទេ បង្កើតថ្មី
                if not activeESP[obj] then
                    local adornee = obj
                    if obj:IsA("Model") then
                        adornee = obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
                    end
                    
                    if adornee then
                        local esp = createESPLabel(adornee)
                        if esp then
                            activeESP[obj] = esp
                        end
                    end
                end
            end
        end
    end
end

-- Loop Update រាល់ Frame
local updateConnection = RunService.RenderStepped:Connect(function()
    if not Config.IsEnabled then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myPos = hrp.Position
    
    -- Update ឈ្មោះ និងចម្ងាយ
    for obj, esp in pairs(activeESP) do
        -- បើ Object ត្រូវ Destroy ឬអត់មាន Parent
        if not obj or not obj.Parent or not esp.adornee or not esp.adornee.Parent then
            destroyESP(esp)
            activeESP[obj] = nil
            continue
        end
        
        local espPos = esp.adornee.Position
        local distance = (myPos - espPos).Magnitude
        
        -- បើឆ្ងាយពេក បិទ ESP
        if distance > Config.MaxDistance then
            esp.billboard.Enabled = false
            if esp.highlight then esp.highlight.Enabled = false end
        else
            esp.billboard.Enabled = true
            if esp.highlight then esp.highlight.Enabled = true end
            
            -- បង្កើតអក្សរ
            local text = ""
            if Config.ShowName then
                text = obj.Name
            end
            if Config.ShowDistance then
                if text ~= "" then text = text .. " " end
                text = text .. "[" .. math.floor(distance) .. "m]"
            end
            esp.textLabel.Text = text
        end
    end
end)

-- =========================================================================
-- [ AUTO SCAN LOOP - ស្កេនរាល់ 2 វិនាទី ]
-- =========================================================================
task.spawn(function()
    while task.wait(2) do
        if Config.IsEnabled then
            pcall(scanTrees)
        end
    end
end)

-- ស្កេនភ្លាមម្តង
task.wait(1)
pcall(scanTrees)

-- =========================================================================
-- [ GUI ]
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TreeESP_GUI"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Title
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🌳 TREE ESP"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 100)
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.Activated:Connect(function()
    Config.IsEnabled = false
    if updateConnection then updateConnection:Disconnect() end
    for _, esp in pairs(activeESP) do destroyESP(esp) end
    ScreenGui:Destroy()
end)

-- Button Toggle ESP
local btnToggle = Instance.new("TextButton", MainFrame)
btnToggle.Size = UDim2.new(1, -30, 0, 40)
btnToggle.Position = UDim2.new(0, 15, 0, 55)
btnToggle.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
btnToggle.Text = "🌳 ESP: ON ✅"
btnToggle.TextColor3 = Color3.new(1, 1, 1)
btnToggle.Font = Enum.Font.GothamBold
btnToggle.TextSize = 13
Instance.new("UICorner", btnToggle).CornerRadius = UDim.new(0, 8)

-- Button Rescan
local btnRescan = Instance.new("TextButton", MainFrame)
btnRescan.Size = UDim2.new(1, -30, 0, 40)
btnRescan.Position = UDim2.new(0, 15, 0, 105)
btnRescan.BackgroundColor3 = Color3.fromRGB(45, 100, 180)
btnRescan.Text = "🔄 ស្កេនដើមឈើឡើងវិញ"
btnRescan.TextColor3 = Color3.new(1, 1, 1)
btnRescan.Font = Enum.Font.GothamBold
btnRescan.TextSize = 13
Instance.new("UICorner", btnRescan).CornerRadius = UDim.new(0, 8)

-- Status
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -30, 0, 25)
StatusLabel.Position = UDim2.new(0, 15, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "កំពុងស្កេន..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11

-- Logic Buttons
btnToggle.Activated:Connect(function()
    Config.IsEnabled = not Config.IsEnabled
    if Config.IsEnabled then
        btnToggle.Text = "🌳 ESP: ON ✅"
        btnToggle.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        -- បង្ហាញ ESP ទាំងអស់ឡើងវិញ
        for _, esp in pairs(activeESP) do
            esp.billboard.Enabled = true
            if esp.highlight then esp.highlight.Enabled = true end
        end
    else
        btnToggle.Text = "🌳 ESP: OFF ❌"
        btnToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        -- បិទ ESP ទាំងអស់
        for _, esp in pairs(activeESP) do
            esp.billboard.Enabled = false
            if esp.highlight then esp.highlight.Enabled = false end
        end
    end
end)

btnRescan.Activated:Connect(function()
    -- លុប ESP ចាស់ចេញ
    for _, esp in pairs(activeESP) do destroyESP(esp) end
    activeESP = {}
    -- ស្កេនថ្មី
    pcall(scanTrees)
    StatusLabel.Text = "✅ ស្កេនរួចរាល់! រកឃើញ " .. tostring(#activeESP) .. " ដើម"
end)

-- Update status រាល់ 1 វិនាទី
task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        local count = 0
        for _ in pairs(activeESP) do count = count + 1 end
        StatusLabel.Text = "🌳 រកឃើញ: " .. count .. " ដើមឈើ"
    end
end)

StatusLabel.Text = "✅ រួចរាល់! ESP កំពុងដំណើរការ"