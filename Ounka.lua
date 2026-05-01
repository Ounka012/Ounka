--[[
    99 Night VIP Pro - Ultimate Magnet Edition (Updated)
    បន្ថែមមុខងារ៖ ទាញអ្នកលេង (Player Magnet)
--]]

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- State
local FeatureStates = {
    Noclip = false,
    Fly = false,
    EnemyESP = false,
    MagnetCoal = false,
    MagnetFuel = false,
    MagnetHealing = false,
    MagnetMetal = false,
    MagnetPlayers = false,   -- បន្ថែមថ្មី
    GoldChestESP = false,
    DayLight = false,
    SpeedX3 = false,
}

-- Config
local FlySpeed = 50
local MagnetRange = 500
local MagnetStrength = 120
local CurrentWalkSpeed = 16
local CurrentJumpPower = 50

-- Connections
local FlyConnection, NoclipConnection, MagnetConnection
local FlyAttachment, LinearVel, AlignOrient

-- Cache
local EnemyESP_Objects = {}
local ChestESP_Objects = {}
local MagnetTargets = {}
local MagnetTargetSet = {}

-- Keywords
local CoalNames = {"coal", "charcoal", "carbon", "ore_coal", "coalore", "coal_ore", "rock_coal"}
local FuelNames = {"fuel", "gas", "canister", "jerry", "petrol", "gasoline", "fuelcan", "gascan"}
local HealingNames = {"medkit", "bandage", "health", "firstaid", "first aid", "potion", "stim", "heal", "aidkit", "healthpack", "medicine"}
local MetalNames = {"iron", "metal", "steel", "copper", "bronze", "scrap", "ore_iron", "ironore", "iron_ore", "metalpiece", "ingot"}

-- Helpers
local function containsKeyword(name, keywords)
    name = string.lower(name)
    for _, kw in ipairs(keywords) do
        if string.find(name, kw) then return true end
    end
    return false
end

local function getModelTargetPart(model)
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Handle") or model:FindFirstChildWhichIsA("BasePart")
end

-- ==================== Enemy ESP ====================
local function ClearEnemyESP()
    for _, obj in pairs(EnemyESP_Objects) do if obj and obj.Parent then obj:Destroy() end end
    EnemyESP_Objects = {}
end

local function ApplyEnemyESP()
    ClearEnemyESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local isPlayer = false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character == obj then isPlayer = true break end
            end
            if not isPlayer then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255,0,0)
                highlight.OutlineColor = Color3.fromRGB(255,0,0)
                highlight.FillTransparency = 0.5
                highlight.Parent = obj
                table.insert(EnemyESP_Objects, highlight)

                local primary = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if primary then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0,100,0,30)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = primary
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1,0,1,0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.fromRGB(255,0,0)
                    text.TextStrokeTransparency = 0
                    text.TextScaled = true
                    text.Text = "☠ " .. obj.Name
                    text.Parent = billboard
                    table.insert(EnemyESP_Objects, billboard)
                end
            end
        end
    end
end

-- ==================== Gold Chest ESP ====================
local function ClearChestESP()
    for _, obj in pairs(ChestESP_Objects) do if obj and obj.Parent then obj:Destroy() end end
    ChestESP_Objects = {}
end

local function ApplyGoldChestESP()
    ClearChestESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure") or obj.Name:lower():find("box") or obj.Name:lower():find("crate")) then
            if not obj:FindFirstChild("Humanoid") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255,215,0)
                highlight.OutlineColor = Color3.fromRGB(255,255,255)
                highlight.FillTransparency = 0.4
                highlight.Parent = obj
                table.insert(ChestESP_Objects, highlight)

                local primary = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                if primary then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0,120,0,30)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = primary
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1,0,1,0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.fromRGB(255,215,0)
                    text.TextStrokeTransparency = 0
                    text.TextScaled = true
                    text.Text = "✨ ហិបមាស ✨"
                    text.Parent = billboard
                    table.insert(ChestESP_Objects, billboard)
                end
            end
        end
    end
end

-- ==================== Day Light ====================
local function EnableDayLight()
    Lighting.ClockTime = 14
    Lighting.Brightness = 5
    Lighting.Ambient = Color3.fromRGB(200,200,220)
    Lighting.OutdoorAmbient = Color3.fromRGB(180,180,200)
    Lighting.FogEnd = 100000
end

local function DisableDayLight()
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(0,0,0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
end

-- ==================== Speed & Jump ====================
local function ApplySpeedAndJump(character)
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = FeatureStates.SpeedX3 and (CurrentWalkSpeed * 3) or CurrentWalkSpeed
        hum.JumpPower = CurrentJumpPower
    end
end

local function UpdateSpeedAndJump()
    if LocalPlayer.Character then ApplySpeedAndJump(LocalPlayer.Character) end
end

-- ==================== Fly ====================
local function StopFly()
    FeatureStates.Fly = false
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if LinearVel then LinearVel:Destroy() LinearVel = nil end
    if AlignOrient then AlignOrient:Destroy() AlignOrient = nil end
    if FlyAttachment then FlyAttachment:Destroy() FlyAttachment = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
end

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true
    hrp.AssemblyLinearVelocity = Vector3.zero

    FlyAttachment = Instance.new("Attachment"); FlyAttachment.Parent = hrp
    LinearVel = Instance.new("LinearVelocity")
    LinearVel.Attachment0 = FlyAttachment
    LinearVel.MaxForce = math.huge
    LinearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    LinearVel.Parent = hrp
    AlignOrient = Instance.new("AlignOrientation")
    AlignOrient.Attachment0 = FlyAttachment
    AlignOrient.MaxTorque = math.huge
    AlignOrient.MaxAngularVelocity = math.huge
    AlignOrient.Responsiveness = 200
    AlignOrient.Parent = hrp

    FeatureStates.Fly = true

    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FeatureStates.Fly or not LinearVel then return end
        local camera = Workspace.CurrentCamera
        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hum2 = char2:FindFirstChildOfClass("Humanoid")
        if not hum2 then return end

        local moveDir = Vector3.zero
        if hum2.MoveDirection.Magnitude > 0 then
            moveDir = hum2.MoveDirection * FlySpeed
        end
        LinearVel.VectorVelocity = moveDir
        AlignOrient.CFrame = CFrame.new(Vector3.zero, camera.CFrame.LookVector)
    end)
end

-- ==================== Noclip ====================
local function StartNoclip()
    if NoclipConnection then return end
    NoclipConnection = RunService.Stepped:Connect(function()
        if not FeatureStates.Noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
end

local function StopNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ==================== Magnet System (Updated with Player Magnet) ====================
local function isValidTarget(obj)
    if not obj then return false end
    local name = obj.Name
    if FeatureStates.MagnetCoal and containsKeyword(name, CoalNames) then return true end
    if FeatureStates.MagnetFuel and containsKeyword(name, FuelNames) then return true end
    if FeatureStates.MagnetHealing and containsKeyword(name, HealingNames) then return true end
    if FeatureStates.MagnetMetal and containsKeyword(name, MetalNames) then return true end
    return false
end

-- ពិនិត្យថាជាតួអង្គអ្នកលេងផ្សេង
local function isPlayerCharacter(obj)
    if not FeatureStates.MagnetPlayers then return false end
    if not obj:IsA("Model") then return false end
    if not obj:FindFirstChildOfClass("Humanoid") then return false end
    return obj ~= LocalPlayer.Character
end

local function tryAddTarget(obj)
    local isAnyMagnetOn = FeatureStates.MagnetCoal or FeatureStates.MagnetFuel or FeatureStates.MagnetHealing or FeatureStates.MagnetMetal or FeatureStates.MagnetPlayers
    if not isAnyMagnetOn then return end

    -- ប្រសិនបើជាអ្នកលេង
    if isPlayerCharacter(obj) then
        local root = obj:FindFirstChild("HumanoidRootPart")
        if root then
            if not MagnetTargetSet[root] then
                MagnetTargetSet[root] = true
                table.insert(MagnetTargets, root)
            end
        end
        return
    end

    -- ធនធានធម្មតា
    if not isValidTarget(obj) then return end

    local part = nil
    if obj:IsA("BasePart") then part = obj
    elseif obj:IsA("Model") then part = getModelTargetPart(obj)
    elseif obj:IsA("Tool") then part = obj:FindFirstChild("Handle")
    end
    if not part then return end
    if MagnetTargetSet[part] then return end

    MagnetTargetSet[part] = true
    table.insert(MagnetTargets, part)
end

local function scanForTargets()
    table.clear(MagnetTargets)
    table.clear(MagnetTargetSet)
    -- បន្ថែមតួអង្គអ្នកលេងដែលមានស្រាប់
    if FeatureStates.MagnetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                tryAddTarget(plr.Character)
            end
        end
    end
    -- ធនធាន
    for _, obj in ipairs(Workspace:GetDescendants()) do
        tryAddTarget(obj)
    end
end

local function onDescendantAdded(descendant)
    tryAddTarget(descendant)
end

-- នៅពេលអ្នកលេងថ្មីចូល
local function onPlayerAdded(plr)
    if not FeatureStates.MagnetPlayers then return end
    plr.CharacterAdded:Connect(function(char)
        if FeatureStates.MagnetPlayers then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                if not MagnetTargetSet[root] then
                    MagnetTargetSet[root] = true
                    table.insert(MagnetTargets, root)
                end
            end
        end
    end)
    if plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root and not MagnetTargetSet[root] then
            MagnetTargetSet[root] = true
            table.insert(MagnetTargets, root)
        end
    end
end

-- ភ្ជាប់ event សម្រាប់អ្នកលេងថ្មី
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then onPlayerAdded(plr) end
end
Players.PlayerAdded:Connect(onPlayerAdded)

local function magnetUpdate()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local playerPos = root.Position

    for i = #MagnetTargets, 1, -1 do
        local part = MagnetTargets[i]
        if not part or not part.Parent then
            MagnetTargetSet[part] = nil
            table.remove(MagnetTargets, i)
            continue
        end

        local delta = playerPos - part.Position
        local distance = delta.Magnitude
        if distance > 0.5 and distance < MagnetRange then
            local direction = delta.Unit
            if part.Anchored then
                part.CFrame = part.CFrame + direction * (MagnetStrength * 0.05)
            else
                part.AssemblyLinearVelocity = direction * MagnetStrength
            end
        end
    end
end

local function StartMagnet()
    if MagnetConnection then return end
    scanForTargets()
    MagnetConnection = RunService.Heartbeat:Connect(magnetUpdate)
    Workspace.DescendantAdded:Connect(onDescendantAdded)
end

local function StopMagnet()
    if MagnetConnection then MagnetConnection:Disconnect() MagnetConnection = nil end
    table.clear(MagnetTargets)
    table.clear(MagnetTargetSet)
end

local function RefreshMagnet()
    StopMagnet()
    if FeatureStates.MagnetCoal or FeatureStates.MagnetFuel or FeatureStates.MagnetHealing or FeatureStates.MagnetMetal or FeatureStates.MagnetPlayers then
        StartMagnet()
    end
end

-- ==================== Character Restore ====================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    ApplySpeedAndJump(newChar)
    if FeatureStates.EnemyESP then ApplyEnemyESP() end
    if FeatureStates.GoldChestESP then ApplyGoldChestESP() end
    if FeatureStates.Noclip then StopNoclip(); StartNoclip() end
    if FeatureStates.Fly then StopFly(); StartFly() end
    if FeatureStates.MagnetCoal or FeatureStates.MagnetFuel or FeatureStates.MagnetHealing or FeatureStates.MagnetMetal or FeatureStates.MagnetPlayers then
        StopMagnet()
        StartMagnet()
    end
end)

-- ==================== GUI ====================
local Window = Rayfield:CreateWindow({
    Name = "99 Night VIP Pro",
    LoadingTitle = "Ultimate + Player Magnet",
    LoadingSubtitle = "ដោយ mkra & Ounka",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Enemy ESP Tab
local ESPTab = Window:CreateTab("សត្រូវ ESP", "eye")
ESPTab:CreateToggle({ Name = "☠ ESP សត្រូវ (ក្រហម)", CurrentValue = false, Callback = function(v) FeatureStates.EnemyESP = v; if v then ApplyEnemyESP() else ClearEnemyESP() end end })

-- Noclip Tab
local NoclipTab = Window:CreateTab("ដើរកាត់", "door-open")
NoclipTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) FeatureStates.Noclip = v; if v then StartNoclip() else StopNoclip() end end })

-- Fly Tab
local FlyTab = Window:CreateTab("ហោះ", "navigation")
FlyTab:CreateSlider({ Name = "ល្បឿនហោះ", Range = {10,200}, Increment = 5, CurrentValue = FlySpeed, Callback = function(v) FlySpeed = v end })
FlyTab:CreateToggle({ Name = "ហោះ", CurrentValue = false, Callback = function(v) if v then StartFly() else StopFly() end end })
FlyTab:CreateButton({ Name = "⬆ ឡើងលើ", Callback = function() if LinearVel and FeatureStates.Fly then LinearVel.VectorVelocity = Vector3.new(0, FlySpeed, 0) task.wait(0.5) if LinearVel then LinearVel.VectorVelocity = Vector3.zero end end end })
FlyTab:CreateButton({ Name = "⬇ ចុះក្រោម", Callback = function() if LinearVel and FeatureStates.Fly then LinearVel.VectorVelocity = Vector3.new(0, -FlySpeed, 0) task.wait(0.5) if LinearVel then LinearVel.VectorVelocity = Vector3.zero end end end })

-- VIP Magnet Tab
local VIPTab = Window:CreateTab("VIP មេដែក", "star")
VIPTab:CreateSection("ជ្រើសរើសធនធាន និងអ្នកលេង")
VIPTab:CreateToggle({ Name = "🧲 ទាញធ្យូង", CurrentValue = false, Callback = function(v) FeatureStates.MagnetCoal = v; RefreshMagnet() end })
VIPTab:CreateToggle({ Name = "⛽ ទាញសាំង", CurrentValue = false, Callback = function(v) FeatureStates.MagnetFuel = v; RefreshMagnet() end })
VIPTab:CreateToggle({ Name = "💊 ទាញព្យាបាល", CurrentValue = false, Callback = function(v) FeatureStates.MagnetHealing = v; RefreshMagnet() end })
VIPTab:CreateToggle({ Name = "🔩 ទាញដែក/លោហៈ", CurrentValue = false, Callback = function(v) FeatureStates.MagnetMetal = v; RefreshMagnet() end })
VIPTab:CreateToggle({ Name = "👥 ទាញអ្នកលេង", CurrentValue = false, Callback = function(v) FeatureStates.MagnetPlayers = v; RefreshMagnet() end })

VIPTab:CreateSection("ការកំណត់មេដែក")
VIPTab:CreateSlider({ Name = "ចម្ងាយទាញ", Range = {50, 1000000}, Increment = 1000, CurrentValue = MagnetRange, Callback = function(v) MagnetRange = v end })
VIPTab:CreateSlider({ Name = "កម្លាំងទាញ", Range = {50, 500}, Increment = 10, CurrentValue = MagnetStrength, Callback = function(v) MagnetStrength = v end })

VIPTab:CreateSection("មុខងារផ្សេងទៀត")
VIPTab:CreateToggle({ Name = "✨ ពន្លឺមាសលើហិប", CurrentValue = false, Callback = function(v) FeatureStates.GoldChestESP = v; if v then ApplyGoldChestESP() else ClearChestESP() end end })
VIPTab:CreateToggle({ Name = "☀️ ពន្លឺថ្ងៃពេលយប់", CurrentValue = false, Callback = function(v) FeatureStates.DayLight = v; if v then EnableDayLight() else DisableDayLight() end end })

-- Speed Tab
local SpeedTab = Window:CreateTab("VIP រត់លឿន", "zap")
SpeedTab:CreateSection("ល្បឿន និងលោត")
SpeedTab:CreateSlider({ Name = "ល្បឿនដើរ", Range = {16,300}, Increment = 1, CurrentValue = CurrentWalkSpeed, Callback = function(v) CurrentWalkSpeed = v; UpdateSpeedAndJump() end })
SpeedTab:CreateSlider({ Name = "កម្លាំងលោត", Range = {50,500}, Increment = 5, CurrentValue = CurrentJumpPower, Callback = function(v) CurrentJumpPower = v; UpdateSpeedAndJump() end })
SpeedTab:CreateToggle({ Name = "បង្កើនល្បឿន x3", CurrentValue = false, Callback = function(v) FeatureStates.SpeedX3 = v; UpdateSpeedAndJump() end })
SpeedTab:CreateButton({ Name = "កំណត់ឡើងវិញ", Callback = function() CurrentWalkSpeed = 16; CurrentJumpPower = 50; UpdateSpeedAndJump() end })

Rayfield:Notify({ Title = "99 Night VIP Pro", Content = "អាប់ដេតរួចរាល់! ឥឡូវមានមេដែកទាញអ្នកលេងផងដែរ", Duration = 6, Image = "check" })
