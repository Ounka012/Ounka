--========================================================
-- EVADE: GUI + PLAYER ESP VIP + TEAM SEPARATION
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"

--============== ESP Settings ==============
local ESP_SETTINGS = {
    Enabled = false,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracers = true,
    ShowTeam = true,
    ShowTeamName = true,
    TeamCheck = true,
    ShowTeammates = false,
    MaxDistance = 2000,
    TextSize = 13,
    TextFont = Enum.Font.GothamBold,
    TracerColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(0, 255, 255),
    TeamColors = {
        ["Survivor"] = Color3.fromRGB(0, 200, 255),
        ["Monster"] = Color3.fromRGB(255, 50, 50),
        ["Default"] = Color3.fromRGB(255, 220, 100),
        ["Neutral"] = Color3.fromRGB(150, 255, 100),
    }
}

local ESP_Objects = {}
local TeamCount = {Survivor = 0, Monster = 0, Neutral = 0}

--============== Utility Functions ==============
local function tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

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

--============== Team Detection ==============
local function getTeamName(player)
    if player.Team then
        local name = player.Team.Name
        if name:lower():find("survivor") or name:lower():find("human") or name:lower():find("player") then
            return "Survivor"
        elseif name:lower():find("monster") or name:lower():find("killer") or name:lower():find("enemy") or name:lower():find("bot") then
            return "Monster"
        else
            return "Neutral"
        end
    end
    return "Neutral"
end

local function getTeamColor(player)
    local teamName = getTeamName(player)
    return ESP_SETTINGS.TeamColors[teamName] or ESP_SETTINGS.TeamColors["Default"]
end

local function isTeammate(player)
    if not ESP_SETTINGS.TeamCheck then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

local function getHealth(player)
    local char = player.Character
    if not char then return 0, 100 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health, hum.MaxHealth
    end
    return 0, 100
end

--============== ESP System ==============
local function createESP(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then return end

    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 220, 0, 85)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_SETTINGS.MaxDistance
    billboard.Parent = espFolder

    local teamBadge = Instance.new("Frame", billboard)
    teamBadge.Size = UDim2.new(0, 80, 0, 16)
    teamBadge.Position = UDim2.new(0.5, -40, 0, -18)
    teamBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    teamBadge.BackgroundTransparency = 0.1
    teamBadge.BorderSizePixel = 0
    Instance.new("UICorner", teamBadge).CornerRadius = UDim.new(0, 8)

    local teamBadgeText = Instance.new("TextLabel", teamBadge)
    teamBadgeText.Size = UDim2.new(1, 0, 1, 0)
    teamBadgeText.BackgroundTransparency = 1
    teamBadgeText.Text = "TEAM"
    teamBadgeText.Font = Enum.Font.GothamBold
    teamBadgeText.TextSize = 9
    teamBadgeText.TextColor3 = Color3.new(0, 0, 0)

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.Font = ESP_SETTINGS.TextFont
    nameLabel.TextSize = ESP_SETTINGS.TextSize
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 18)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0m]"
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.3

    local healthBg = Instance.new("Frame", billboard)
    healthBg.Size = UDim2.new(0, 70, 0, 5)
    healthBg.Position = UDim2.new(0.5, -35, 0, 34)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    Instance.new("UICorner", healthBg).CornerRadius = UDim.new(1, 0)

    local healthFill = Instance.new("Frame", healthBg)
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    healthFill.BorderSizePixel = 0
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(1, 0)

    local healthText = Instance.new("TextLabel", billboard)
    healthText.Size = UDim2.new(1, 0, 0, 12)
    healthText.Position = UDim2.new(0, 0, 0, 42)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100 HP"
    healthText.Font = Enum.Font.Gotham
    healthText.TextSize = 10
    healthText.TextColor3 = Color3.fromRGB(0, 255, 100)
    healthText.TextStrokeTransparency = 0.3

    local tracer = Instance.new("Frame")
    tracer.Size = UDim2.new(0, 1, 0, 1)
    tracer.Position = UDim2.new(0.5, 0, 0.5, 0)
    tracer.BackgroundColor3 = ESP_SETTINGS.TracerColor
    tracer.BackgroundTransparency = 0.3
    tracer.BorderSizePixel = 0
    tracer.Parent = espFolder

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 80)
    box.Position = UDim2.new(0.5, -25, 0.5, -40)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = espFolder

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Thickness = 1.5
    boxStroke.Color = Color3.fromRGB(255, 50, 50)
    boxStroke.Transparency = 0.6

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = espFolder

    espFolder.Parent = CoreGui
    ESP_Objects[player] = {
        folder = espFolder,
        billboard = billboard,
        teamBadge = teamBadge,
        teamBadgeText = teamBadgeText,
        nameLabel = nameLabel,
        distLabel = distLabel,
        healthFill = healthFill,
        healthText = healthText,
        tracer = tracer,
        box = box,
        boxStroke = boxStroke,
        highlight = highlight,
        player = player
    }
end

local function removeESP(player)
    if ESP_Objects[player] then
        pcall(function() ESP_Objects[player].folder:Destroy() end)
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    if not ESP_SETTINGS.Enabled then
        for player, _ in pairs(ESP_Objects) do
            removeESP(player)
        end
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    local screenSize = camera.ViewportSize
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    TeamCount = {Survivor = 0, Monster = 0, Neutral = 0}

    for player, data in pairs(ESP_Objects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not char or not root or not hum or hum.Health <= 0 then
            data.folder.Enabled = false
        else
            local isTeam = isTeammate(player)
            local teamName = getTeamName(player)
            local teamColor = getTeamColor(player)

            if isTeam and not ESP_SETTINGS.ShowTeammates then
                data.folder.Enabled = false
            else
                if TeamCount[teamName] then
                    TeamCount[teamName] = TeamCount[teamName] + 1
                end

                local dist = localRoot and (root.Position - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then
                    data.folder.Enabled = false
                else
                    data.folder.Enabled = true

                    if ESP_SETTINGS.ShowTeam then
                        data.teamBadge.Visible = true
                        data.teamBadgeText.Text = teamName:upper()
                        data.teamBadge.BackgroundColor3 = teamColor
                        data.teamBadgeText.TextColor3 = Color3.new(0, 0, 0)
                    else
                        data.teamBadge.Visible = false
                    end

                    data.nameLabel.Text = player.Name
                    if ESP_SETTINGS.ShowName then
                        data.nameLabel.Visible = true
                        if ESP_SETTINGS.ShowTeam then
                            data.nameLabel.TextColor3 = teamColor
                        else
                            data.nameLabel.TextColor3 = Color3.new(1, 1, 1)
                        end
                    else
                        data.nameLabel.Visible = false
                    end

                    if ESP_SETTINGS.ShowDistance then
                        data.distLabel.Visible = true
                        data.distLabel.Text = string.format("[%.0fm]", dist)
                    else
                        data.distLabel.Visible = false
                    end

                    if ESP_SETTINGS.ShowHealth then
                        local health, maxHealth = getHealth(player)
                        local healthPercent = math.clamp(health / maxHealth, 0, 1)
                        data.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                        data.healthText.Text = string.format("%.0f HP", health)
                        data.healthFill.Parent.Visible = true
                        data.healthText.Visible = true

                        if healthPercent > 0.6 then
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                            data.healthText.TextColor3 = Color3.fromRGB(0, 255, 100)
                        elseif healthPercent > 0.3 then
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                            data.healthText.TextColor3 = Color3.fromRGB(255, 200, 0)
                        else
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                            data.healthText.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                    else
                        data.healthFill.Parent.Visible = false
                        data.healthText.Visible = false
                    end

                    data.highlight.Adornee = char
                    data.highlight.FillColor = teamColor
                    data.highlight.OutlineColor = teamColor
                    data.boxStroke.Color = teamColor

                    if ESP_SETTINGS.ShowTracers then
                        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            data.tracer.Visible = true
                            data.tracer.BackgroundColor3 = teamColor
                            local startX = screenSize.X / 2
                            local startY = screenSize.Y
                            local endX = screenPos.X
                            local endY = screenPos.Y
                            local dx = endX - startX
                            local dy = endY - startY
                            local length = math.sqrt(dx * dx + dy * dy)
                            local angle = math.atan2(dy, dx)
                            data.tracer.Size = UDim2.new(0, length, 0, 1.5)
                            data.tracer.Position = UDim2.new(0, startX, 0, startY)
                            data.tracer.Rotation = math.deg(angle)
                            data.tracer.BackgroundTransparency = 0.3
                        else
                            data.tracer.Visible = false
                        end
                    else
                        data.tracer.Visible = false
                    end
                end
            end
        end
    end
end

-- Auto create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

RunService.RenderStepped:Connect(updateESP)

--============== GUI ==============
local function createGUI()
    if CoreGui:FindFirstChild("EvadeFarm") then
        CoreGui:FindFirstChild("EvadeFarm"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "EvadeFarm"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBtn.Text = "👁️"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    -- Main Frame
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 440, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- Title
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "🌀 EVADE VIP + TEAM ESP"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.new(1, 1, 1)

    -- Close Button
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

    -- ESP Toggle Card
    local espCard = Instance.new("Frame", mainFrame)
    espCard.Size = UDim2.new(1, -40, 0, 55)
    espCard.Position = UDim2.new(0, 20, 0, 55)
    espCard.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    espCard.BackgroundTransparency = 0.2
    Instance.new("UICorner", espCard).CornerRadius = UDim.new(0, 12)

    local espIcon = Instance.new("TextLabel", espCard)
    espIcon.Size = UDim2.new(0, 40, 0, 40)
    espIcon.Position = UDim2.new(0, 10, 0.5, -20)
    espIcon.BackgroundTransparency = 1
    espIcon.Text = "👁️"
    espIcon.Font = Enum.Font.GothamBold
    espIcon.TextSize = 24

    local espTitle = Instance.new("TextLabel", espCard)
    espTitle.Size = UDim2.new(0, 150, 0, 20)
    espTitle.Position = UDim2.new(0, 55, 0, 8)
    espTitle.BackgroundTransparency = 1
    espTitle.Text = "PLAYER ESP"
    espTitle.Font = Enum.Font.GothamBold
    espTitle.TextSize = 14
    espTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
    espTitle.TextXAlignment = Enum.TextXAlignment.Left

    local espDesc = Instance.new("TextLabel", espCard)
    espDesc.Size = UDim2.new(0, 220, 0, 16)
    espDesc.Position = UDim2.new(0, 55, 0, 30)
    espDesc.BackgroundTransparency = 1
    espDesc.Text = "Name | Team | Distance | Health"
    espDesc.Font = Enum.Font.Gotham
    espDesc.TextSize = 10
    espDesc.TextColor3 = Color3.fromRGB(150, 150, 180)
    espDesc.TextXAlignment = Enum.TextXAlignment.Left

    -- Toggle Switch
    local espToggle = Instance.new("Frame", espCard)
    espToggle.Size = UDim2.new(0, 52, 0, 28)
    espToggle.Position = UDim2.new(1, -67, 0.5, -14)
    espToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Instance.new("UICorner", espToggle).CornerRadius = UDim.new(1, 0)

    local espKnob = Instance.new("Frame", espToggle)
    espKnob.Size = UDim2.new(0, 24, 0, 24)
    espKnob.Position = UDim2.new(0, 2, 0.5, -12)
    espKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", espKnob).CornerRadius = UDim.new(1, 0)

    local espBtn = Instance.new("TextButton", espCard)
    espBtn.Size = UDim2.new(1, 0, 1, 0)
    espBtn.BackgroundTransparency = 1
    espBtn.Text = ""

    -- Team Info Panel
    local teamPanel = Instance.new("Frame", mainFrame)
    teamPanel.Size = UDim2.new(1, -40, 0, 40)
    teamPanel.Position = UDim2.new(0, 20, 0, 118)
    teamPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
    teamPanel.BackgroundTransparency = 0.15
    Instance.new("UICorner", teamPanel).CornerRadius = UDim.new(0, 10)

    local survLabel = Instance.new("TextLabel", teamPanel)
    survLabel.Size = UDim2.new(0.33, 0, 1, 0)
    survLabel.Position = UDim2.new(0, 0, 0, 0)
    survLabel.BackgroundTransparency = 1
    survLabel.Text = "🔵 Survivor: 0"
    survLabel.Font = Enum.Font.GothamBold
    survLabel.TextSize = 11
    survLabel.TextColor3 = Color3.fromRGB(0, 200, 255)

    local monLabel = Instance.new("TextLabel", teamPanel)
    monLabel.Size = UDim2.new(0.33, 0, 1, 0)
    monLabel.Position = UDim2.new(0.33, 0, 0, 0)
    monLabel.BackgroundTransparency = 1
    monLabel.Text = "🔴 Monster: 0"
    monLabel.Font = Enum.Font.GothamBold
    monLabel.TextSize = 11
    monLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

    local neutLabel = Instance.new("TextLabel", teamPanel)
    neutLabel.Size = UDim2.new(0.33, 0, 1, 0)
    neutLabel.Position = UDim2.new(0.66, 0, 0, 0)
    neutLabel.BackgroundTransparency = 1
    neutLabel.Text = "🟢 Neutral: 0"
    neutLabel.Font = Enum.Font.GothamBold
    neutLabel.TextSize = 11
    neutLabel.TextColor3 = Color3.fromRGB(150, 255, 100)

    -- Options Grid
    local optionsFrame = Instance.new("Frame", mainFrame)
    optionsFrame.Size = UDim2.new(1, -40, 0, 100)
    optionsFrame.Position = UDim2.new(0, 20, 0, 166)
    optionsFrame.BackgroundTransparency = 1

    local function createOption(parent, x, y, icon, text, settingKey)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0.48, 0, 0, 45)
        btn.Position = UDim2.new(x, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.BackgroundTransparency = 0.2
        btn.Text = ""
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local btnIcon = Instance.new("TextLabel", btn)
        btnIcon.Size = UDim2.new(0, 30, 0, 30)
        btnIcon.Position = UDim2.new(0, 8, 0.5, -15)
        btnIcon.BackgroundTransparency = 1
        btnIcon.Text = icon
        btnIcon.Font = Enum.Font.GothamBold
        btnIcon.TextSize = 18

        local btnText = Instance.new("TextLabel", btn)
        btnText.Size = UDim2.new(1, -45, 1, 0)
        btnText.Position = UDim2.new(0, 40, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = text
        btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 11
        btnText.TextColor3 = Color3.fromRGB(180, 180, 200)
        btnText.TextXAlignment = Enum.TextXAlignment.Left

        local check = Instance.new("Frame", btn)
        check.Size = UDim2.new(0, 18, 0, 18)
        check.Position = UDim2.new(1, -26, 0.5, -9)
        check.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        check.BorderSizePixel = 0
        Instance.new("UICorner", check).CornerRadius = UDim.new(0, 5)

        local checkMark = Instance.new("TextLabel", check)
        checkMark.Size = UDim2.new(1, 0, 1, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "✓"
        checkMark.Font = Enum.Font.GothamBold
        checkMark.TextSize = 12
        checkMark.TextColor3 = Color3.fromRGB(0, 255, 120)
        checkMark.Visible = ESP_SETTINGS[settingKey] or false

        if ESP_SETTINGS[settingKey] then
            check.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        btn.MouseButton1Down:Connect(function()
            ESP_SETTINGS[settingKey] = not ESP_SETTINGS[settingKey]
            if ESP_SETTINGS[settingKey] then
                tween(check, {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}, 0.2)
                checkMark.Visible = true
                btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tween(check, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}, 0.2)
                checkMark.Visible = false
                btnText.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end)

        return btn
    end

    createOption(optionsFrame, 0, 0, "🏷️", "Show Names", "ShowName")
    createOption(optionsFrame, 0.52, 0, "📏", "Show Distance", "ShowDistance")
    createOption(optionsFrame, 0, 52, "❤️", "Show Health", "ShowHealth")
    createOption(optionsFrame, 0.52, 52, "📍", "Show Tracers", "ShowTracers")

    -- Team Options Row
    local teamOptions = Instance.new("Frame", mainFrame)
    teamOptions.Size = UDim2.new(1, -40, 0, 45)
    teamOptions.Position = UDim2.new(0, 20, 0, 272)
    teamOptions.BackgroundTransparency = 1

    local function createTeamToggle(parent, x, icon, text, settingKey, color)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0.48, 0, 1, 0)
        btn.Position = UDim2.new(x, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.BackgroundTransparency = 0.2
        btn.Text = ""
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local btnIcon = Instance.new("TextLabel", btn)
        btnIcon.Size = UDim2.new(0, 30, 0, 30)
        btnIcon.Position = UDim2.new(0, 8, 0.5, -15)
        btnIcon.BackgroundTransparency = 1
        btnIcon.Text = icon
        btnIcon.Font = Enum.Font.GothamBold
        btnIcon.TextSize = 18

        local btnText = Instance.new("TextLabel", btn)
        btnText.Size = UDim2.new(1, -45, 1, 0)
        btnText.Position = UDim2.new(0, 40, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = text
        btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 11
        btnText.TextColor3 = Color3.fromRGB(180, 180, 200)
        btnText.TextXAlignment = Enum.TextXAlignment.Left

        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0, 8, 0, 8)
        indicator.Position = UDim2.new(1, -18, 0.5, -4)
        indicator.BackgroundColor3 = color
        indicator.BorderSizePixel = 0
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        if ESP_SETTINGS[settingKey] then
            indicator.BackgroundTransparency = 0
            btnText.TextColor3 = color
        else
            indicator.BackgroundTransparency = 0.7
        end

        btn.MouseButton1Down:Connect(function()
            ESP_SETTINGS[settingKey] = not ESP_SETTINGS[settingKey]
            if ESP_SETTINGS[settingKey] then
                tween(indicator, {BackgroundTransparency = 0}, 0.2)
                btnText.TextColor3 = color
            else
                tween(indicator, {BackgroundTransparency = 0.7}, 0.2)
                btnText.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end)

        return btn
    end

    createTeamToggle(teamOptions, 0, "🛡️", "Team Check", "TeamCheck", Color3.fromRGB(0, 255, 150))
    createTeamToggle(teamOptions, 0.52, "👥", "Show Teammates", "ShowTeammates", Color3.fromRGB(255, 200, 0))

    -- Distance Slider
    local distFrame = Instance.new("Frame", mainFrame)
    distFrame.Size = UDim2.new(1, -40, 0, 50)
    distFrame.Position = UDim2.new(0, 20, 0, 325)
    distFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    distFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", distFrame).CornerRadius = UDim.new(0, 12)

    local distLabel = Instance.new("TextLabel", distFrame)
    distLabel.Size = UDim2.new(0, 200, 0, 18)
    distLabel.Position = UDim2.new(0, 12, 0, 6)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "Max Distance: " .. ESP_SETTINGS.MaxDistance .. "m"
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 12
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
    distLabel.TextXAlignment = Enum.TextXAlignment.Left

    local distBarBg = Instance.new("Frame", distFrame)
    distBarBg.Size = UDim2.new(1, -24, 0, 6)
    distBarBg.Position = UDim2.new(0, 12, 0, 30)
    distBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    distBarBg.BorderSizePixel = 0
    Instance.new("UICorner", distBarBg).CornerRadius = UDim.new(1, 0)

    local distBarFill = Instance.new("Frame", distBarBg)
    distBarFill.Size = UDim2.new(ESP_SETTINGS.MaxDistance / 3000, 0, 1, 0)
    distBarFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    distBarFill.BorderSizePixel = 0
    Instance.new("UICorner", distBarFill).CornerRadius = UDim.new(1, 0)

    local distKnob = Instance.new("TextButton", distBarBg)
    distKnob.Size = UDim2.new(0, 16, 0, 16)
    distKnob.Position = UDim2.new(ESP_SETTINGS.MaxDistance / 3000, -8, 0.5, -8)
    distKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    distKnob.Text = ""
    Instance.new("UICorner", distKnob).CornerRadius = UDim.new(1, 0)

    local distDragging = false
    distKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            distDragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if distDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp(input.Position.X - distBarBg.AbsolutePosition.X, 0, distBarBg.AbsoluteSize.X)
            local value = math.floor((relX / distBarBg.AbsoluteSize.X) * 3000)
            ESP_SETTINGS.MaxDistance = value
            distBarFill.Size = UDim2.new(value / 3000, 0, 1, 0)
            distKnob.Position = UDim2.new(value / 3000, -8, 0.5, -8)
            distLabel.Text = "Max Distance: " .. value .. "m"
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            distDragging = false
        end
    end)

    -- Status Label
    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 380)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "● ESP: OFF | Players: 0"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Update status & team counts
    task.spawn(function()
        while gui.Parent do
            local count = 0
            for _ in pairs(ESP_Objects) do count = count + 1 end

            survLabel.Text = "🔵 Survivor: " .. (TeamCount.Survivor or 0)
            monLabel.Text = "🔴 Monster: " .. (TeamCount.Monster or 0)
            neutLabel.Text = "🟢 Neutral: " .. (TeamCount.Neutral or 0)

            if ESP_SETTINGS.Enabled then
                statusLabel.Text = "● ESP: ON | Players: " .. count
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            else
                statusLabel.Text = "● ESP: OFF | Players: " .. count
                statusLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
            end
            task.wait(0.5)
        end
    end)

    -- Toggle Animation
    local function animateToggle(state)
        if state then
            tween(espToggle, {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}, 0.25)
            tween(espKnob, {Position = UDim2.new(0, 26, 0.5, -12)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(espCard, {BackgroundColor3 = Color3.fromRGB(15, 40, 25)}, 0.3)
            tween(espIcon, {TextColor3 = Color3.fromRGB(0, 255, 120)}, 0.3)
        else
            tween(espToggle, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}, 0.25)
            tween(espKnob, {Position = UDim2.new(0, 2, 0.5, -12)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(espCard, {BackgroundColor3 = Color3.fromRGB(25, 25, 45)}, 0.3)
            tween(espIcon, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
        end
    end

    espBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
        animateToggle(ESP_SETTINGS.Enabled)
    end)

    -- Hover Effects
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 40, 40)}, 0.15)
    end)

    -- Button Functions
    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    closeBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = false
        for player, _ in pairs(ESP_Objects) do
            removeESP(player)
        end
        gui:Destroy()
    end)

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

    makeDraggable(mainFrame)
    makeDraggable(toggleBtn)
end

createGUI()

print("🌀 Evade VIP + Team ESP Loaded!")