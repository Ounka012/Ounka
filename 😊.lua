--[[
    VIP EVADE ULTIMATE | Full Features (60+ Toggles)
    រចនាឡើងសម្រាប់ Evade បច្ចុប្បន្ន
    No Memory Leak | Auto-Adapt Logic | VIP Level System | Character Morph System | Multiplayer Replication
    Fixed: attempt to index nil with 'Disconnect'
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ParentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ==================== CONFIG & VIP SYSTEM ====================
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local ACCENT = Color3.fromRGB(220, 150, 200)
local BEEP_SOUND = "rbxassetid://6034521064"

local VIP_LEVEL = 3
local VIP_COLORS = {
    [1] = Color3.fromRGB(205, 127, 50),
    [2] = Color3.fromRGB(192, 192, 192),
    [3] = Color3.fromRGB(255, 215, 0),
    [4] = Color3.fromRGB(185, 242, 255)
}
local currentVipColor = VIP_COLORS[VIP_LEVEL] or Color3.fromRGB(255, 255, 255)

local VIP_REQUIREMENTS = {
    ["Fly"] = 3,
    ["KillAll"] = 2,
    ["GodMode"] = 2,
    ["AutoFarmXP"] = 2,
    ["Trimping"] = 3,
    ["InvisibleMorph"] = 4,
    ["CopyPlayerMorph"] = 3,
    ["VisibleToOthers"] = 2,
}

local Toggles = {
    -- Core
    KillAll = false, AutoTrap = false, SilentWalk = false,
    -- Survival
    GodMode = false, AntiDown = false, AutoCola = false, AutoEscape = false,
    RemoveBarriers = false, NoWaterDmg = false,
    -- Mobility
    Speed = false, Jump = false, Gravity = false, BHop = false,
    InfiniteJump = false, Trimping = false, InfiniteSlide = false, Fly = false,
    HipHeight = false, AdjustFOV = false, AutoDash = false, AutoJumpNoKey = false,
    -- Farming
    AutoFarm = false, AFKFarm = false, AutoRevive = false, AutoVote = false,
    AutoFarmXP = false, AutoFarmCash = false, AutoInstantRevive = false, AutoCarry = false,
    AutoRespawn = false, AutoFarmCandy = false, TeleportToDowned = false,
    -- ESP & Vision
    VIPESP = false, ESPBoxes = false, ESPTracers = false, ESPHealth = false, ESPRainbow = false,
    MonstersESP = false, DownedESP = false, CollectablesESP = false, ToolESP = false,
    PlayersHighlight = false, FullBright = false, NoCameraShake = false, FPSBoost = false,
    -- Misc
    AutoInteract = false, AutoWhistle = false, AutoRandomVote = false,
    WeatherAdjust = false, RemoveDarkness = false, BuyUsables = false, NoLightFlicker = false,
    ShowGlobalChat = false, RedeemCodes = false, AllEmotes = false,
    -- HUD
    ShowRoundTimer = false, ShowGameStatus = false, ShowFPS = false,
    -- 🎭 MORPH SYSTEM
    GiantMorph = false, TinyMorph = false, InvisibleMorph = false, MuscleMorph = false,
    -- 🌐 REPLICATION SYSTEM
    VisibleToOthers = false,
}

-- ==================== UI ====================
local function buildUI(imageAsset)
    if ParentGui:FindFirstChild("VIP_Evade") then ParentGui.VIP_Evade:Destroy() end
    local gui = Instance.new("ScreenGui", ParentGui)
    gui.Name = "VIP_Evade"
    gui.IgnoreGuiInset = true

    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.Image = imageAsset or "rbxassetid://7733960981"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    local main = Instance.new("CanvasGroup", gui)
    main.Size = UDim2.new(0, 480, 0, 340)
    main.Position = UDim2.new(0.5, -240, 0.5, -170)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    main.GroupTransparency = 1
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 2

    local bg = Instance.new("ImageLabel", main)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ImageTransparency = 0.4
    bg.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 14)

    local overlay = Instance.new("Frame", main)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    overlay.BackgroundTransparency = 0.4
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 14)

    local titleLabel = Instance.new("TextLabel")
    task.spawn(function()
        local h = 0
        while gui.Parent do
            h = (h + 0.01) % 1
            local c = Color3.fromHSV(h, 0.85, 1)
            toggleStroke.Color = c
            mainStroke.Color = c
            titleLabel.TextColor3 = c
            task.wait(0.04)
        end
    end)

    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundTransparency = 1
    
    titleLabel.Size = UDim2.new(0.55, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ VIP EVADE ULTIMATE"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local vipLabel = Instance.new("TextLabel", topBar)
    vipLabel.Size = UDim2.new(0.45, -20, 1, 0)
    vipLabel.Position = UDim2.new(0.55, 0, 0, 0)
    vipLabel.BackgroundTransparency = 1
    vipLabel.Text = "👑 VIP LEVEL: " .. VIP_LEVEL
    vipLabel.Font = Enum.Font.GothamBlack
    vipLabel.TextSize = 14
    vipLabel.TextColor3 = currentVipColor
    vipLabel.TextXAlignment = Enum.TextXAlignment.Right
    vipLabel.TextStrokeTransparency = 0.7
    
    if VIP_LEVEL >= 3 then
        task.spawn(function()
            local h = 0
            while gui.Parent do
                h = (h + 0.02) % 1
                vipLabel.TextColor3 = Color3.fromHSV(h, 0.85, 1)
                task.wait(0.05)
            end
        end)
    end

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    local sideBar = Instance.new("Frame", main)
    sideBar.Size = UDim2.new(0, 120, 1, -45)
    sideBar.Position = UDim2.new(0, 0, 0, 45)
    sideBar.BackgroundTransparency = 0.8
    sideBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    local tabLayout = Instance.new("UIListLayout", sideBar)
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", sideBar).PaddingTop = UDim.new(0, 8)

    local contentArea = Instance.new("Frame", main)
    contentArea.Size = UDim2.new(1, -130, 1, -55)
    contentArea.Position = UDim2.new(0, 125, 0, 50)
    contentArea.BackgroundTransparency = 1

    local tabs = {}
    local function createTab(name, icon)
        local btn = Instance.new("TextButton", sideBar)
        btn.Size = UDim2.new(0.9, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.BackgroundTransparency = 0.3
        btn.Text = icon .. " " .. name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local content = Instance.new("ScrollingFrame", contentArea)
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 3
        content.ScrollBarImageColor3 = ACCENT
        content.Visible = false
        local layout = Instance.new("UIListLayout", content)
        layout.Padding = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                TweenService:Create(t.Button, TweenInfo.new(0.25), {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                t.Content.Visible = false
            end
            TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)}):Play()
            content.Visible = true
        end)

        table.insert(tabs, {Button = btn, Content = content})
        return content
    end

    local function addToggle(parent, label, desc, flag)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -4, 0, 70)
        frame.BackgroundColor3 = Color3.fromRGB(35, 22, 30)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", frame).Color = Color3.fromRGB(120, 80, 110)
        frame.UIStroke.Thickness = 1.5

        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, -70, 0.4, 0)
        text.Position = UDim2.new(0, 12, 0, 4)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 13
        text.TextXAlignment = Enum.TextXAlignment.Left

        local descText = Instance.new("TextLabel", frame)
        descText.Size = UDim2.new(1, -70, 0.4, 0)
        descText.Position = UDim2.new(0, 12, 0.45, 0)
        descText.BackgroundTransparency = 1
        descText.Text = desc
        descText.TextColor3 = Color3.fromRGB(200, 180, 195)
        descText.Font = Enum.Font.Gotham
        descText.TextSize = 10
        descText.TextXAlignment = Enum.TextXAlignment.Left

        local switch = Instance.new("Frame", frame)
        switch.Size = UDim2.new(0, 48, 0, 26)
        switch.Position = UDim2.new(1, -60, 0.5, -13)
        switch.BackgroundColor3 = Toggles[flag] and ACCENT or Color3.fromRGB(90, 90, 110)
        switch.BorderSizePixel = 0
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", switch)
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = Toggles[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickBtn = Instance.new("TextButton", frame)
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""

        clickBtn.MouseButton1Click:Connect(function()
            local requiredLevel = VIP_REQUIREMENTS[flag]
            if requiredLevel and VIP_LEVEL < requiredLevel then
                local originalText = text.Text
                local originalColor = text.TextColor3
                text.Text = " ត្រូវការ VIP Lv." .. requiredLevel
                text.TextColor3 = Color3.fromRGB(255, 80, 80)
                task.delay(1.2, function()
                    if text and text.Parent then
                        text.Text = originalText
                        text.TextColor3 = originalColor
                    end
                end)
                return
            end

            Toggles[flag] = not Toggles[flag]
            switch.BackgroundColor3 = Toggles[flag] and ACCENT or Color3.fromRGB(90, 90, 110)
            knob.Position = Toggles[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            pcall(function()
                local s = Instance.new("Sound")
                s.SoundId = BEEP_SOUND
                s.Volume = 0.5
                s.Parent = CoreGui
                s:Play()
                task.delay(0.3, function() s:Destroy() end)
            end)
        end)
    end

    local function addButton(parent, text, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -4, 0, 40)
        btn.BackgroundColor3 = ACCENT
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 200, 40)}):Play()
            task.wait(0.2)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT}):Play()
            if callback then callback() end
        end)
    end

    local CoreTab = createTab("Core", "🔥")
    local SurvivalTab = createTab("Survive", "🛡️")
    local MobilityTab = createTab("Move", "🏃")
    local FarmTab = createTab("Farm", "💰")
    local ESPTab = createTab("ESP", "️")
    local VisionTab = createTab("Vision", "🌞")
    local MiscTab = createTab("Misc", "🎭")
    local MorphTab = createTab("Morph", "🗿")
    local HUDTab = createTab("HUD", "📊")
    local UtilTab = createTab("Util", "⚙️")

    addToggle(CoreTab, "🔥 Kill All", "សម្លាប់ NPC ទាំងអស់ (Req: Lv.2)", "KillAll")
    addToggle(CoreTab, " Auto Trap", "ដាក់អន្ាក់", "AutoTrap")
    addToggle(CoreTab, "👻 Silent Walk", "ដើរលឿន 120", "SilentWalk")

    addToggle(SurvivalTab, "🛡️ God Mode", "ForceField + ការពារ (Req: Lv.2)", "GodMode")
    addToggle(SurvivalTab, "🛑 Anti-Down", "ការពារដួល", "AntiDown")
    addToggle(SurvivalTab, "🥤 Auto Cola", "ប្រើ Cola សវ័យ", "AutoCola")
    addToggle(SurvivalTab, "🏃 Auto Escape", "គេច Bot HP ទាប", "AutoEscape")
    addToggle(SurvivalTab, "🧱 Remove Barriers", "បំបាត់របាំង", "RemoveBarriers")
    addToggle(SurvivalTab, " No Water Dmg", "មិនខូច HP ទឹក", "NoWaterDmg")

    addToggle(MobilityTab, "💨 Speed Hack", "ល្បឿន 80", "Speed")
    addToggle(MobilityTab, "🦘 Jump Boost", "លោតខ្ពស់", "Jump")
    addToggle(MobilityTab, "🌌 Low Gravity", "ទំនាញទាប", "Gravity")
    addToggle(MobilityTab, "🔄 BHOP", "Auto Jump", "BHop")
    addToggle(MobilityTab, "♾️ Infinite Jump", "លោតគ្មានកំណត់", "InfiniteJump")
    addToggle(MobilityTab, "🚀 Trimping", "ល្ឿនផ្ទុះ (Req: Lv.3)", "Trimping")
    addToggle(MobilityTab, "🧊 Infinite Slide", "រអិលឥតឈប់", "InfiniteSlide")
    addToggle(MobilityTab, "✈️ Fly", "ហោះឆ្លងជញ្ជាំង (Req: Lv.3)", "Fly")
    addToggle(MobilityTab, "🦵 Hip Height", "កែកម្ពស់ជើង", "HipHeight")
    addToggle(MobilityTab, "🔭 Adjust FOV", "FOV 120", "AdjustFOV")
    addToggle(MobilityTab, "💨 Auto Dash", "Dash ស្វយ", "AutoDash")
    addToggle(MobilityTab, "🦘 Auto Jump No Key", "លោតដោយស្វ័យ", "AutoJumpNoKey")

    addToggle(FarmTab, "💰 Auto Farm All", "Coin, XP, Token", "AutoFarm")
    addToggle(FarmTab, "🍬 Auto Candy", "Candy លឿន", "AutoFarmCandy")
    addToggle(FarmTab, "⏳ AFK Mode", "Farm មិនដើរ", "AFKFarm")
    addToggle(FarmTab, " Auto Win XP", "ឈ្នះគ្រប់ជុំ (Req: Lv.2)", "AutoFarmXP")
    addToggle(FarmTab, "💵 Auto Cash", "Revive ភ្លាម", "AutoFarmCash")
    addToggle(FarmTab, "🔄 Instant Revive", "រស់ឡើងវិញ", "AutoInstantRevive")
    addToggle(FarmTab, "🤝 Auto Carry", "ដឹកស្វ័យ", "AutoCarry")
    addToggle(FarmTab, "💀 Auto Respawn", "Respawn", "AutoRespawn")
    addToggle(FarmTab, "📞 Teleport Downed", "ទៅអ្នកដេក", "TeleportToDowned")
    addToggle(FarmTab, "🗳️ Auto Vote", "បោះឆ្នោត", "AutoVote")
    addToggle(FarmTab, " Auto Revive", "Revive អ្កដទៃ", "AutoRevive")

    addToggle(ESPTab, "👁️ Player ESP", "ឈ្មោះ+ចម្ងាយ", "VIPESP")
    addToggle(ESPTab, " Box ESP", "ប្រអប់", "ESPBoxes")
    addToggle(ESPTab, "📏 Tracers", "បន្ទាត់", "ESPTracers")
    addToggle(ESPTab, "❤️ Health ESP", "បង្ហាញ HP", "ESPHealth")
    addToggle(ESPTab, "🌈 Rainbow", "ឥន្ទធនូ", "ESPRainbow")
    addToggle(ESPTab, "👾 Monsters ESP", "បង្ាញ NPC", "MonstersESP")
    addToggle(ESPTab, "🩹 Downed ESP", "បង្ហាញអ្នកដេក", "DownedESP")
    addToggle(ESPTab, " Collectables ESP", "បង្ហាញកាក់/XP", "CollectablesESP")
    addToggle(ESPTab, "🔧 Tool ESP", "បង្ហាញបករណ៍", "ToolESP")
    addToggle(ESPTab, "✨ Highlight", "គូសពន្ល", "PlayersHighlight")

    addToggle(VisionTab, "☀️ Full Bright", "ភលឺទាំងអស់", "FullBright")
    addToggle(VisionTab, " No Cam Shake", "កាមេរ៉ាមិនញ័រ", "NoCameraShake")
    addToggle(VisionTab, "⚡ FPS Boost", "បង្ើន FPS", "FPSBoost")

    addToggle(MiscTab, "👆 Auto Interact", "ចុច E ស្វ័យ", "AutoInteract")
    addToggle(MiscTab, "🎵 Auto Whistle", "ផ្លុំកញ្ចែ", "AutoWhistle")
    addToggle(MiscTab, "🎲 Auto Random Vote", "បោះឆ្នោតចៃដន្យ", "AutoRandomVote")
    addToggle(MiscTab, "🌤️ Weather Adjust", "កែអាកាសធាតុ", "WeatherAdjust")
    addToggle(MiscTab, "🌑 Remove Darkness", "បំបាត់ងងឹត", "RemoveDarkness")
    addToggle(MiscTab, "🛍️ Buy Usables", "ទិញរបស់", "BuyUsables")
    addToggle(MiscTab, "💡 No Light Flicker", "បំបាត់ពន្លឺភ្លឹប", "NoLightFlicker")
    addToggle(MiscTab, "💬 Show Chat", "បង្ាញឆាត", "ShowGlobalChat")
    addToggle(MiscTab, " Redeem Codes", "ចុច Redeem", "RedeemCodes")
    addToggle(MiscTab, "💃 All Emotes", "បរើ Emotes", "AllEmotes")

    -- 🎭 MORPH TAB
    addToggle(MorphTab, "🗿 Giant Morph", "ធំ x3 (អ្នកផសេងមើលឃើញ)", "GiantMorph")
    addToggle(MorphTab, "🐜 Tiny Morph", "តូច x0.4 (អ្នកផ្សេងមើលឃើញ)", "TinyMorph")
    addToggle(MorphTab, "💪 Muscle Morph", "សាច់ដុំធំ x2 (អនកផ្សេងមើលឃើញ)", "MuscleMorph")
    addToggle(MorphTab, "👻 Invisible", "លាក់ខ្លួន (Req: Lv.4)", "InvisibleMorph")
    addToggle(MorphTab, "🌐 Visible to Others", "អ្នកលេងផ្សេងមើលឃើញ Morph (Req: Lv.2)", "VisibleToOthers")
    
    local copyPlayerBtn = Instance.new("TextButton", MorphTab)
    copyPlayerBtn.Size = UDim2.new(1, -4, 0, 50)
    copyPlayerBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 220)
    copyPlayerBtn.Text = "🎭 Copy Player (Req: Lv.3)\nចម្លងរូបរាងពីអ្នកលេងផ្សេង"
    copyPlayerBtn.TextColor3 = Color3.new(1, 1, 1)
    copyPlayerBtn.Font = Enum.Font.GothamBold
    copyPlayerBtn.TextSize = 12
    Instance.new("UICorner", copyPlayerBtn).CornerRadius = UDim.new(0, 10)
    copyPlayerBtn.MouseButton1Click:Connect(function()
        if VIP_LEVEL < 3 then
            copyPlayerBtn.Text = "🔒 តរូវការ VIP Lv.3"
            task.delay(1.5, function()
                if copyPlayerBtn and copyPlayerBtn.Parent then
                    copyPlayerBtn.Text = "🎭 Copy Player (Req: Lv.3)\nចម្លងរូបរាងពីអ្នកលេងផ្សេង"
                end
            end)
            return
        end
        openPlayerList()
    end)
    
    addButton(MorphTab, "🔄 Reset Morph (កំណត់ដើមវិញ)", function()
        resetAllMorphs()
    end)

    addToggle(HUDTab, "⏱️ Round Timer", "ម៉ោង", "ShowRoundTimer")
    addToggle(HUDTab, "📢 Game Status", "ស្ថានភាព", "ShowGameStatus")
    addToggle(HUDTab, "🎮 FPS Counter", "FPS", "ShowFPS")

    addButton(UtilTab, "🔄 Rejoin", function()
        pcall(function() TeleportService:Teleport(Workspace.PlaceId, LocalPlayer) end)
    end)
    addButton(UtilTab, "❌ Disable All", function()
        for k, _ in pairs(Toggles) do Toggles[k] = false end
        resetAllMorphs()
    end)

    tabs[1].Button.BackgroundTransparency = 0
    tabs[1].Button.TextColor3 = Color3.new(1, 1, 1)
    tabs[1].Content.Visible = true

    local function makeDraggable(bar, frame)
        local drag, startPos, objPos
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = true; startPos = input.Position; objPos = frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - startPos
                frame.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + d.X, objPos.Y.Scale, objPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
    end
    makeDraggable(topBar, main)

    local isOpen = false
    local function toggleWindow()
        isOpen = not isOpen
        main.Visible = true
        if isOpen then
            TweenService:Create(main, TweenInfo.new(0.35), {GroupTransparency = 0}):Play()
            TweenService:Create(toggleBtn, TweenInfo.new(0.35), {Rotation = 180}):Play()
        else
            local anim = TweenService:Create(main, TweenInfo.new(0.35), {GroupTransparency = 1})
            anim:Play()
            TweenService:Create(toggleBtn, TweenInfo.new(0.35), {Rotation = 0}):Play()
            anim.Completed:Wait()
            main.Visible = false
        end
    end

    local toggleDrag, toggleMoved, toggleStart, toggleObj
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDrag = true; toggleMoved = false; toggleStart = input.Position; toggleObj = toggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if toggleDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if (input.Position - toggleStart).Magnitude > 5 then toggleMoved = true end
            toggleBtn.Position = UDim2.new(toggleObj.X.Scale, toggleObj.X.Offset + (input.Position - toggleStart).X, toggleObj.Y.Scale, toggleObj.Y.Offset + (input.Position - toggleStart).Y)
        end
    end)
    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if toggleDrag and not toggleMoved then toggleWindow() end
            toggleDrag = false
        end
    end)
    closeBtn.MouseButton1Click:Connect(function() if isOpen then toggleWindow() end end)

    local playerListGui = Instance.new("ScreenGui", gui)
    playerListGui.Name = "PlayerList_Morph"
    playerListGui.IgnoreGuiInset = true
    playerListGui.DisplayOrder = 10
    playerListGui.Enabled = false
    
    local plFrame = Instance.new("Frame", playerListGui)
    plFrame.Size = UDim2.new(0, 300, 0, 400)
    plFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    plFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", plFrame).CornerRadius = UDim.new(0, 12)
    local plStroke = Instance.new("UIStroke", plFrame)
    plStroke.Color = ACCENT
    plStroke.Thickness = 2
    
    local plTitle = Instance.new("TextLabel", plFrame)
    plTitle.Size = UDim2.new(1, 0, 0, 40)
    plTitle.BackgroundTransparency = 1
    plTitle.Text = "🎭 ជ្រើសរើសអ្នកលេងដើម្បីចម្លងរូបរាង"
    plTitle.TextColor3 = ACCENT
    plTitle.Font = Enum.Font.GothamBold
    plTitle.TextSize = 14
    
    local plClose = Instance.new("TextButton", plFrame)
    plClose.Size = UDim2.new(0, 30, 0, 30)
    plClose.Position = UDim2.new(1, -35, 0, 5)
    plClose.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    plClose.Text = "✕"
    plClose.TextColor3 = Color3.new(1, 1, 1)
    plClose.Font = Enum.Font.GothamBold
    plClose.TextSize = 13
    Instance.new("UICorner", plClose).CornerRadius = UDim.new(0, 8)
    plClose.MouseButton1Click:Connect(function()
        playerListGui.Enabled = false
    end)
    
    local plScroll = Instance.new("ScrollingFrame", plFrame)
    plScroll.Size = UDim2.new(1, -20, 1, -50)
    plScroll.Position = UDim2.new(0, 10, 0, 45)
    plScroll.BackgroundTransparency = 1
    plScroll.ScrollBarThickness = 3
    plScroll.ScrollBarImageColor3 = ACCENT
    local plLayout = Instance.new("UIListLayout", plScroll)
    plLayout.Padding = UDim.new(0, 4)
    
    function openPlayerList()
        for _, c in ipairs(plScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton", plScroll)
                btn.Size = UDim2.new(1, -4, 0, 35)
                btn.BackgroundColor3 = Color3.fromRGB(50, 40, 60)
                btn.Text = "👤 " .. plr.Name
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 13
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                btn.MouseButton1Click:Connect(function()
                    copyPlayerAppearance(plr)
                    playerListGui.Enabled = false
                end)
            end
        end
        playerListGui.Enabled = true
    end

    local hud = Instance.new("TextLabel", gui)
    hud.Size = UDim2.new(0, 300, 0, 150)
    hud.Position = UDim2.new(0.02, 0, 0.1, 0)
    hud.BackgroundTransparency = 1
    hud.TextColor3 = Color3.new(1, 1, 1)
    hud.Font = Enum.Font.GothamBold
    hud.TextSize = 14
    hud.Text = ""
    task.spawn(function()
        while gui.Parent do
            task.wait(0.5)
            local t = "👑 VIP Level: " .. VIP_LEVEL .. "\n"
            
            if Toggles.ShowFPS then
                t = t .. "FPS: " .. math.floor(1 / RunService.Heartbeat:Wait()) .. "\n"
            end
            if Toggles.ShowRoundTimer then
                pcall(function()
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    if pg then
                        for _, x in pg:GetDescendants() do
                            if x:IsA("TextLabel") and (x.Text:match("Round") or x.Text:match("Timer") or x.Text:match("Ends")) then
                                t = t .. x.Text .. "\n"
                            end
                        end
                    end
                end)
            end
            if Toggles.ShowGameStatus then
                pcall(function()
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    if pg then
                        for _, x in pg:GetDescendants() do
                            if x:IsA("TextLabel") and (x.Text:match("Next round") or x.Text:match("Voting") or x.Text:match("Playing")) then
                                t = t .. x.Text .. "\n"
                            end
                        end
                    end
                end)
            end
            hud.Text = t
        end
    end)

    return gui
end

-- ==================== MORPH SYSTEM WITH REPLICATION (FIXED) ====================
local morphState = {
    scale = 1,
    invisible = false,
    muscle = false,
    copiedDesc = nil,
    charConn = nil,
    replicated = false,
}

local function setNetworkOwnership(char)
    pcall(function()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root:SetNetworkOwner(LocalPlayer)
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part:SetNetworkOwner(LocalPlayer) end)
            end
        end
    end)
end

local function applyScaleToChar(char, scale, replicate)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if replicate and Toggles.VisibleToOthers then
            local desc = hum:FindFirstChildOfClass("HumanoidDescription")
            if desc then
                desc.BodyHeightScale = scale
                desc.BodyWidthScale = scale
                desc.BodyDepthScale = scale
                desc.HeadScale = scale
                pcall(function() hum:ApplyDescription(desc) end)
            end
        end
        
        local scales = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, name in ipairs(scales) do
            local s = hum:FindFirstChild(name)
            if s then s.Value = scale end
        end
    end)
end

local function applyMuscleToChar(char, enable, replicate)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if replicate and Toggles.VisibleToOthers then
            local desc = hum:FindFirstChildOfClass("HumanoidDescription")
            if desc then
                local muscleScale = enable and 1.4 or 1.0
                desc.BodyWidthScale = muscleScale
                desc.BodyDepthScale = muscleScale
                pcall(function() hum:ApplyDescription(desc) end)
            end
        end
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("BasePart") then
                if part.Name:match("Torso") or part.Name:match("UpperArm") or part.Name:match("UpperLeg") then
                    if enable then
                        part:Scale(Vector3.new(1.4, 1.1, 1.4))
                    else
                        part:Scale(Vector3.new(1/1.4, 1/1.1, 1/1.4))
                    end
                end
            end
        end
    end)
end

local function applyInvisibleToChar(char, enable, replicate)
    pcall(function()
        local transparency = enable and 1 or 0
        
        if replicate and Toggles.VisibleToOthers then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = transparency
                end
            end
        else
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = transparency
                end
            end
        end
        
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = head:FindFirstChildOfClass("BillboardGui")
            if billboard then billboard.Enabled = not enable end
        end
    end)
end

function resetAllMorphs()
    Toggles.GiantMorph = false
    Toggles.TinyMorph = false
    Toggles.InvisibleMorph = false
    Toggles.MuscleMorph = false
    Toggles.VisibleToOthers = false
    morphState.scale = 1
    morphState.invisible = false
    morphState.muscle = false
    morphState.copiedDesc = nil
    morphState.replicated = false
    
    local char = LocalPlayer.Character
    if char then
        pcall(applyScaleToChar, char, 1, false)
        pcall(applyInvisibleToChar, char, false, false)
        pcall(applyMuscleToChar, char, false, false)
    end
    print("🔄 Morph ទាំងអស់បានកំណត់ដើមវិញ!")
end

function copyPlayerAppearance(targetPlayer)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        local targetChar = targetPlayer.Character
        if not targetChar then
            warn("️ អ្នកលេងនេះមិនមានតួអង្គទេ!")
            return
        end
        
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if not targetHum then return end
        
        local success, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
        end)
        
        if success and desc then
            morphState.copiedDesc = desc
            if Toggles.VisibleToOthers then
                pcall(function() hum:ApplyDescription(desc) end)
            else
                pcall(function() hum:ApplyDescription(desc, true) end)
            end
            print("✅ បានចម្លងរូបរាងពី: " .. targetPlayer.Name)
        else
            warn("⚠️ មិនអាចចម្លងរូបរាងបានទេ!")
        end
    end)
end

local function applyAllMorphs()
    local char = LocalPlayer.Character
    if not char then return end
    
    pcall(setNetworkOwnership, char)
    
    local scale = 1
    if Toggles.GiantMorph then scale = 3 end
    if Toggles.TinyMorph then scale = 0.4 end
    morphState.scale = scale
    pcall(applyScaleToChar, char, scale, true)
    
    morphState.invisible = Toggles.InvisibleMorph
    pcall(applyInvisibleToChar, char, Toggles.InvisibleMorph, true)
    
    morphState.muscle = Toggles.MuscleMorph
    pcall(applyMuscleToChar, char, Toggles.MuscleMorph, true)
    
    if morphState.copiedDesc then
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Toggles.VisibleToOthers then
                    hum:ApplyDescription(morphState.copiedDesc)
                else
                    hum:ApplyDescription(morphState.copiedDesc, true)
                end
            end
        end)
    end
    
    morphState.replicated = Toggles.VisibleToOthers
end

-- ✅ FIXED: runMorphSystem with full nil protection
local function runMorphSystem()
    pcall(applyAllMorphs)
    
    local conn = nil
    local charConn = nil
    
    conn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local anyActive = Toggles.GiantMorph or Toggles.TinyMorph or Toggles.InvisibleMorph or Toggles.MuscleMorph or morphState.copiedDesc
        
        if not anyActive and morphState.scale == 1 and not morphState.invisible and not morphState.muscle then
            if conn then
                pcall(function() conn:Disconnect() end)
                conn = nil
            end
            return
        end
        
        if not morphState.replicated and Toggles.VisibleToOthers then
            pcall(setNetworkOwnership, char)
            morphState.replicated = true
        end
        
        local targetScale = 1
        if Toggles.GiantMorph then targetScale = 3 end
        if Toggles.TinyMorph then targetScale = 0.4 end
        if targetScale ~= morphState.scale then
            morphState.scale = targetScale
            pcall(applyScaleToChar, char, targetScale, true)
        end
        
        if Toggles.InvisibleMorph ~= morphState.invisible then
            morphState.invisible = Toggles.InvisibleMorph
            pcall(applyInvisibleToChar, char, Toggles.InvisibleMorph, true)
        end
        
        if Toggles.MuscleMorph ~= morphState.muscle then
            morphState.muscle = Toggles.MuscleMorph
            pcall(applyMuscleToChar, char, Toggles.MuscleMorph, true)
        end
        
        if not Toggles.VisibleToOthers and morphState.replicated then
            pcall(applyAllMorphs)
            morphState.replicated = false
        end
    end)
    
    if morphState.charConn then
        pcall(function() morphState.charConn:Disconnect() end)
        morphState.charConn = nil
    end
    
    charConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("Humanoid")
        task.wait(0.5)
        pcall(applyAllMorphs)
    end)
    morphState.charConn = charConn
    
    return function()
        if conn then
            pcall(function() conn:Disconnect() end)
            conn = nil
        end
        if morphState.charConn then
            pcall(function() morphState.charConn:Disconnect() end)
            morphState.charConn = nil
        end
    end
end

-- ==================== LOGIC SYSTEMS ====================
local function getNPCs()
    local npcs = {}
    local myChar = LocalPlayer.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                table.insert(npcs, {Model = obj, Humanoid = hum, RootPart = root})
            end
        end
    end
    return npcs
end

local function getCollectables()
    local items = {}
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local n = part.Name:lower()
            if n:find("coin") or n:find("candy") or n:find("token") or n:find("gem") or n:find("xp") or n:find("gift") or n:find("box") then
                table.insert(items, part)
            elseif part:FindFirstChildOfClass("Sparkles") or part:FindFirstChildOfClass("Highlight") then
                table.insert(items, part)
            end
        end
    end
    return items
end

local function runKillAll()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not (Toggles.KillAll or Toggles.AutoFarmXP) then conn:Disconnect(); return end
        for _, npc in ipairs(getNPCs()) do
            pcall(function() npc.Model:Destroy() end)
        end
    end)
    return conn
end

local function runGodMode()
    local charData = {}
    local function onChar(char)
        local hum = char:WaitForChild("Humanoid")
        local ff = Instance.new("ForceField", char)
        local conn = hum.HealthChanged:Connect(function()
            if hum.Health < 100 then
                pcall(function() hum.Health = 100 end)
            end
        end)
        charData[char] = {ff, conn}
        hum.Died:Connect(function()
            if charData[char] then
                pcall(function() charData[char][1]:Destroy() end)
                pcall(function() charData[char][2]:Disconnect() end)
                charData[char] = nil
            end
        end)
    end
    local charAdd = LocalPlayer.CharacterAdded:Connect(onChar)
    if LocalPlayer.Character and Toggles.GodMode then
        onChar(LocalPlayer.Character)
    end
    return function()
        charAdd:Disconnect()
        for _, data in pairs(charData) do
            pcall(function() data[1]:Destroy() end)
            pcall(function() data[2]:Disconnect() end)
        end
        charData = {}
    end
end

local function runSpeed()
    local conn = RunService.Heartbeat:Connect(function()
        if not Toggles.Speed then conn:Disconnect(); return end
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 80 end
            end
        end)
    end)
    return conn
end

local function runFly()
    local flyRender, bv, bg
    local conn = RunService.Heartbeat:Connect(function()
        if not Toggles.Fly then
            if flyRender then flyRender:Disconnect() end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.PlatformStand = false end
                end
            end)
            conn:Disconnect()
            return
        end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end
            if not root:FindFirstChild("FlyBV") then
                bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                hum.PlatformStand = true
                flyRender = RunService.RenderStepped:Connect(function()
                    local dir = hum.MoveDirection
                    bv.Velocity = dir.Magnitude > 0 and dir * 80 or Vector3.zero
                    bg.CFrame = Camera.CFrame
                end)
            end
        end)
    end)
    return conn
end

local function runInfJump()
    local conn = UserInputService.JumpRequest:Connect(function()
        if Toggles.InfiniteJump then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        end
    end)
    return conn
end

local function runAutoFarm()
    local conn = RunService.Heartbeat:Connect(function()
        if not (Toggles.AutoFarm or Toggles.AFKFarm or Toggles.AutoFarmCandy) then
            conn:Disconnect(); return
        end
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local nearest, minDist = nil, 100
            for _, item in ipairs(getCollectables()) do
                local d = (item.Position - root.Position).Magnitude
                if d < minDist then minDist = d; nearest = item end
            end
            if nearest and minDist > 5 then
                root.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
            end
        end)
    end)
    return conn
end

local function runTeleportDowned()
    local conn = RunService.Heartbeat:Connect(function()
        if not Toggles.TeleportToDowned then conn:Disconnect(); return end
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local target = plr.Character
                    if target then
                        local hum = target:FindFirstChildOfClass("Humanoid")
                        local tr = target:FindFirstChild("HumanoidRootPart")
                        if hum and tr and hum.Health <= 0 then
                            root.CFrame = tr.CFrame * CFrame.new(0, 3, 0)
                            break
                        end
                    end
                end
            end
        end)
    end)
    return conn
end

local function runAutoReviveCarry()
    local conn = RunService.Heartbeat:Connect(function()
        if not (Toggles.AutoFarmCash or Toggles.AutoInstantRev
