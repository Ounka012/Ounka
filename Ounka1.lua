-- =====================================================================
-- EVADE SCRIPT 2026 - MKRA ULTIMATE HUB | REBLE EDITION (VIP WITH IMAGE)
-- =====================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ==================== ⚙️ VIP CONFIGURATION & STATES ====================
local Options = {
    SpeedValue = 80,
    JumpValue = 70,
    GravityValue = 0.5,
    NextbotIcon = "rbxassetid://16766488349", -- លីងរូបភាព Nextbot របស់អ្នក
    
    SpeedToggle = false,
    JumpToggle = false,
    BhopToggle = false,
    GravityToggle = false,
    AutoFarm = false,
    NextbotAvoid = false,
    SelfRevive = false,
    EspToggle = false,
    AutoVote = false,
    NoFog = false,
    AntiAFK = false
}

-- ==================== 🎨 UI WINDOW & PINK NEON THEME ====================
local Window = Fluent:CreateWindow({
    Title = "MKRA Ultimate Hub",
    SubTitle = "REBLE VIP EDITION",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- កំណត់ពណ៌ផ្កាឈូកពន្លឺភ្លឺភ្លែត (Pink Neon Glow Theme)
Fluent.Options = {
    TextColor = Color3.fromRGB(255, 220, 235),       
    Accent = Color3.fromRGB(255, 20, 147),          
    AccentDegraded = Color3.fromRGB(255, 105, 180),  
    BackgroundColor = Color3.fromRGB(20, 10, 15),    
    Background = Color3.fromRGB(30, 15, 25),        
    HeaderColor = Color3.fromRGB(40, 18, 30)         
}
Fluent:SetTheme(Fluent.Options)

-- ==================== 🖼️ INJECT IMAGE INTO FLUENT GUI ====================
-- បង្កើតរូបភាពបញ្ចូលទៅក្នុងផ្ទាំង UI របស់ Fluent ដោយស្វ័យប្រវត្តិ
pcall(function()
    local MainFrame = game:GetService("CoreGui"):FindFirstChild("Fluent") or LocalPlayer.PlayerGui:FindFirstChild("Fluent")
    if MainFrame then
        local ContainerFrame = MainFrame:FindFirstChild("Frame", true)
        if ContainerFrame then
            local ImageLabel = Instance.new("ImageLabel")
            ImageLabel.Name = "NextbotVIPImage"
            ImageLabel.Size = UDim2.new(0, 130, 0, 75)
            ImageLabel.Position = UDim2.new(0, 15, 0, 360) -- ដាក់នៅផ្នែកខាងក្រោមនៃផ្ទាំង Navigation Tabs
            ImageLabel.Image = Options.NextbotIcon
            ImageLabel.BackgroundTransparency = 1
            ImageLabel.ZIndex = 100
            ImageLabel.Parent = ContainerFrame
            
            -- បន្ថែម UI Corner ឱ្យរលូន
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = ImageLabel
        end
    end
end)

-- បង្កើត Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Movement", Icon = "run" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "coins" }),
    Visuals = Window:AddTab({ Title = "Visuals (ESP)", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Miscellaneous", Icon = "settings" })
}

-- ==================== 🔵 MOVEMENT TAB ====================
Tabs.Main:AddParagraph({Title = "VIP Movement Control", Content = "ប្រព័ន្ធគ្រប់គ្រងល្បឿនកម្រិត VIP"})

local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "WalkSpeed", Description = "កែប្រែ WalkSpeed",
    Default = 80, Min = 16, Max = 150, Rounding = 0,
    Callback = function(Value) Options.SpeedValue = Value end
})
local SpeedToggle = Tabs.Main:AddToggle("SpeedToggle", {Title = "Enable Speed Hack", Default = false})
SpeedToggle:OnChanged(function() Options.SpeedToggle = SpeedToggle.Value end)

local JumpSlider = Tabs.Main:AddSlider("JumpSlider", {
    Title = "Jump Power", Description = "កែប្រែ JumpPower",
    Default = 70, Min = 50, Max = 150, Rounding = 0,
    Callback = function(Value) Options.JumpValue = Value end
})
local JumpToggle = Tabs.Main:AddToggle("JumpToggle", {Title = "Enable Jump Boost", Default = false})
JumpToggle:OnChanged(function() Options.JumpToggle = JumpToggle.Value end)

local BhopToggle = Tabs.Main:AddToggle("BhopToggle", {Title = "Bunny Hop", Default = false})
BhopToggle:OnChanged(function() Options.BhopToggle = BhopToggle.Value end)

local GravityToggle = Tabs.Main:AddToggle("GravityToggle", {Title = "Low Gravity Mode", Default = false})
GravityToggle:OnChanged(function() Options.GravityToggle = GravityToggle.Value end)

-- RunService Loop សម្រាប់ Movement
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if Options.SpeedToggle then hum.WalkSpeed = Options.SpeedValue else hum.WalkSpeed = 16 end
            if Options.JumpToggle then 
                hum.JumpPower = Options.JumpValue 
            elseif Options.GravityToggle then 
                hum.JumpPower = Options.JumpValue * (Options.GravityValue * 2)
            else 
                hum.JumpPower = 50 
            end
        end
    end)
end)

-- Bunny Hop Thread
task.spawn(function()
    while true do
        task.wait(0.01)
        if Options.BhopToggle then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Landed then hum.Jump = true end
            end)
        end
    end
end)

-- ==================== 🟡 AUTO FARM & AVOID TAB ====================
local FarmToggle = Tabs.Farm:AddToggle("FarmToggle", {Title = "Auto Farm Coins/Candies", Default = false})
FarmToggle:OnChanged(function() Options.AutoFarm = FarmToggle.Value end)

local AvoidToggle = Tabs.Farm:AddToggle("AvoidToggle", {Title = "Nextbot Avoidance", Default = false})
AvoidToggle:OnChanged(function() Options.NextbotAvoid = AvoidToggle.Value end)

-- Auto Farm Core Logic
task.spawn(function()
    while true do
        task.wait(0.2)
        if Options.AutoFarm then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local nearest, minDistance = nil, math.huge
                for _, v in pairs(Workspace:GetDescendants()) do
                    if (v.Name == "Coin" or v.Name == "Candy") and v:IsA("BasePart") then
                        local dist = (v.Position - root.Position).Magnitude
                        if dist < minDistance then minDistance = dist; nearest = v end
                    end
                end
                if nearest then root.CFrame = nearest.CFrame * CFrame.new(0, 3, 0) end
            end)
        end
    end
end)

-- Nextbot Avoidance Engine
task.spawn(function()
    while true do
        task.wait(0.1)
        if Options.NextbotAvoid then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Nextbot" and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                        local dist = (v.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < 35 then
                            local direction = (root.Position - v.HumanoidRootPart.Position).Unit
                            root.Velocity = Vector3.new(direction.X * 65, hum.JumpPower, direction.Z * 65)
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== 🟢 VISUALS (PINK ESP) TAB ====================
local EspToggle = Tabs.Visuals:AddToggle("EspToggle", {Title = "Enable Pink Neon ESP", Default = false})
EspToggle:OnChanged(function() Options.EspToggle = EspToggle.Value end)

local function applyPinkESP(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if not Options.EspToggle then return end
        if char:FindFirstChild("VIP_ESP") then char.VIP_ESP:Destroy() end
        
        local bgu = Instance.new("BillboardGui", char)
        bgu.Name = "VIP_ESP"
        bgu.AlwaysOnTop = true
        bgu.Size = UDim2.new(4, 0, 5.5, 0)
        bgu.Adornee = char:WaitForChild("HumanoidRootPart")
        
        local frame = Instance.new("Frame", bgu)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = 2.5
        stroke.Color = Color3.fromRGB(255, 20, 147) 
    end)
end
Players.PlayerAdded:Connect(applyPinkESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then applyPinkESP(p) end end

-- ==================== 🟣 MISCELLANEOUS TAB ====================
local ReviveToggle = Tabs.Misc:AddToggle("ReviveToggle", {Title = "Auto Self Revive", Default = false})
ReviveToggle:OnChanged(function() Options.SelfRevive = ReviveToggle.Value end)

local VoteToggle = Tabs.Misc:AddToggle("VoteToggle", {Title = "Auto Vote", Default = false})
VoteToggle:OnChanged(function() Options.AutoVote = VoteToggle.Value end)

local FogToggle = Tabs.Misc:AddToggle("FogToggle", {Title = "No Fog & Fullbright", Default = false})
FogToggle:OnChanged(function() Options.NoFog = FogToggle.Value end)

local AfkToggle = Tabs.Misc:AddToggle("AfkToggle", {Title = "Anti AFK Kick", Default = false})
AfkToggle:OnChanged(function() Options.AntiAFK = AfkToggle.Value end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        
        if Options.SelfRevive then
            pcall(function()
                for _, g in pairs(gui:GetChildren()) do
                    for _, b in pairs(g:GetDescendants()) do
                        if b:IsA("TextButton") and string.find(b.Text:lower(), "revive") then
                            if firesignal then firesignal(b.MouseButton1Click) end
                        end
                    end
                end
            end)
        end
        
        if Options.AutoVote then
            pcall(function()
                for _, g in pairs(gui:GetChildren()) do
                    for _, b in pairs(g:GetDescendants()) do
                        if b:IsA("TextButton") and (b.Text == "Vote" or b.Text == "Yes") then
                            if firesignal then firesignal(b.MouseButton1Click) end
                        end
                    end
                end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Options.NoFog then
        pcall(function()
            Lighting.Brightness = 2
            Lighting.FogEnd = 1e9
            Lighting.Ambient = Color3.new(1, 1, 1)
        end)
    end
end)

LocalPlayer.Idled:Connect(function()
    if Options.AntiAFK then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

Fluent:Notify({Title = "MKRA Ultimate Hub", Content = "REBLE VIP Loaded with Custom GUI Image!", Duration = 5})
