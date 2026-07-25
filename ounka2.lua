--========================================================
-- EVADE: ULTIMATE FULL ESP - SEE EVERYTHING (Fixed v2)
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

--============== ESP Settings ==============
local ESP_SETTINGS = {
    Enabled = true,
    -- Players
    ShowPlayers = true,
    ShowPlayerName = true,
    ShowPlayerHealth = true,
    ShowPlayerDistance = true,
    ShowPlayerBox = true,
    ShowPlayerTracer = true,
    ShowPlayerHighlight = true,
    ShowPlayerTeam = true,
    -- Monsters/Bots (NPC)
    ShowMonsters = true,
    ShowMonsterName = true,
    ShowMonsterDistance = true,
    ShowMonsterTracer = true,
    ShowMonsterHighlight = true,
    -- Items
    ShowItems = true,
    ShowItemName = true,
    ShowItemDistance = true,
    -- Visual
    MaxDistance = 3000,
    TextSize = 14,
    BoxThickness = 2,
    TracerThickness = 1.5,
    -- Colors
    PlayerColor = Color3.fromRGB(0, 255, 120),   -- បៃតង
    MonsterColor = Color3.fromRGB(255, 50, 50),  -- ក្រហម
    ItemColor = Color3.fromRGB(255, 220, 0),     -- លឿង
    TeammateColor = Color3.fromRGB(0, 200, 255), -- ខៀវ
    TeamCheck = true,
    ShowTeammates = true,  -- បង្ហាញមិត្តរួមក្រុម
}

local ESP_Objects = {}
local Monster_Objects = {}
local Item_Objects = {}

--============== Utility ==============
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

--============== Detection ==============
local function isTeammate(player)
    if not ESP_SETTINGS.TeamCheck then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

local function getHealth(char)
    if not char then return 0, 100 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return 0, 100
end

-- ស្វែងរក NPC សត្រូវ (រួមទាំង nextbot, slenderman, angry ជាដើម)
local function isMonster(obj)
    local name = obj.Name:lower()
    local parent = obj.Parent and obj.Parent.Name:lower() or ""
    -- ពិនិត្យទាំងឈ្មោះរបស់វា និងឈ្មោះរបស់ parent
    return name:find("monster") or name:find("bot") or name:find("killer") 
        or name:find("nextbot") or name:find("npc") or name:find("enemy")
        or name:find("slenderman") or name:find("angry") or name:find("chase")
        or parent:find("monster") or parent:find("enemy") or parent:find("bot")
end

local function isItem(obj)
    local name = obj.Name:lower()
    return name:find("revive") or name:find("cash") or name:find("money") 
        or name:find("coin") or name:find("board") or name:find("medkit")
        or name:find("item") or name:find("collect") or name:find("pickup")
end

--============== ESP Objects ==============
local function createDrawingESP(target, espType)
    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. target.Name .. "_" .. espType

    -- BillboardGui (គ្មានផ្ទៃខ្មៅ)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_SETTINGS.MaxDistance
    billboard.Parent = folder

    -- Badge
    local badge = Instance.new("Frame", billboard)
    badge.Size = UDim2.new(0, 80, 0, 18)
    badge.Position = UDim2.new(0.5, -40, 0, -20)
    badge.BackgroundTransparency = 0.2
    badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel", badge)
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 9
    badgeText.TextColor3 = Color3.new(0, 0, 0)

    -- Name
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = ESP_SETTINGS.TextSize
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

    -- Distance
    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 22)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 12
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.3

    -- Health bar (សម្រាប់តែ player)
    local hpBg = Instance.new("Frame", billboard)
    hpBg.Size = UDim2.new(0, 80, 0, 8)
    hpBg.Position = UDim2.new(0.5, -40, 0, 42)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

    local hpText = Instance.new("TextLabel", billboard)
    hpText.Size = UDim2.new(1, 0, 0, 14)
    hpText.Position = UDim2.new(0, 0, 0, 54)
    hpText.BackgroundTransparency = 1
    hpText.Font = Enum.Font.GothamBold
    hpText.TextSize = 10
    hpText.TextColor3 = Color3.fromRGB(0, 255, 100)
    hpText.TextStrokeTransparency = 0.3

    -- Box (2D)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = folder

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Thickness = ESP_SETTINGS.BoxThickness
    boxStroke.Transparency = 0.4

    local corners = {}
    for i = 1, 4 do
        local line = Instance.new("Frame", box)
        line.BackgroundColor3 = Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        corners[i] = line
    end

    -- Tracer
    local tracer = Instance.new("Frame")
    tracer.BackgroundTransparency = 0.3
    tracer.BorderSizePixel = 0
    tracer.Parent = folder

    -- Arrow (off-screen)
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 40, 0, 40)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▲"
    arrow.Font = Enum.Font.GothamBlack
    arrow.TextSize = 30
    arrow.TextStrokeTransparency = 0.2
    arrow.Parent = folder
    arrow.Visible = false

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = folder

    folder.Parent = CoreGui

    return {
        folder = folder,
        billboard = billboard,
        badge = badge,
        badgeText = badgeText,
        nameLabel = nameLabel,
        distLabel = distLabel,
        hpFill = hpFill,
        hpText = hpText,
        box = box,
        boxStroke = boxStroke,
        corners = corners,
        tracer = tracer,
        arrow = arrow,
        highlight = highlight,
        target = target,
        type = espType
    }
end

local function removeESP(dataTable, target)
    if dataTable[target] then
        pcall(function() dataTable[target].folder:Destroy() end)
        dataTable[target] = nil
    end
end

--============== Update ESP ==============
local function updateAllESP()
    if not ESP_SETTINGS.Enabled then
        for _, data in pairs(ESP_Objects) do removeESP(ESP_Objects, data.target) end
        for _, data in pairs(Monster_Objects) do removeESP(Monster_Objects, data.target) end
        for _, data in pairs(Item_Objects) do removeESP(Item_Objects, data.target) end
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end
    local screenSize = camera.ViewportSize
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    -- Update Players
    for player, data in pairs(ESP_Objects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not ESP_SETTINGS.ShowPlayers or not char or not root or not hum or hum.Health <= 0 then
            data.folder.Enabled = false
        else
            local isTeam = isTeammate(player)
            if isTeam and not ESP_SETTINGS.ShowTeammates then
                data.folder.Enabled = false
            else
                local dist = localRoot and (root.Position - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then
                    data.folder.Enabled = false
                else
                    data.folder.Enabled = true
                    data.billboard.Adornee = root

                    local color = isTeam and ESP_SETTINGS.TeammateColor or ESP_SETTINGS.PlayerColor

                    -- Badge
                    if ESP_SETTINGS.ShowPlayerTeam then
                        data.badge.Visible = true
                        data.badge.BackgroundColor3 = color
                        data.badgeText.Text = isTeam and "TEAM" or "PLAYER"
                    else
                        data.badge.Visible = false
                    end

                    -- Name
                    if ESP_SETTINGS.ShowPlayerName then
                        data.nameLabel.Visible = true
                        data.nameLabel.Text = player.Name
                        data.nameLabel.TextColor3 = color
                    else
                        data.nameLabel.Visible = false
                    end

                    -- Distance
                    if ESP_SETTINGS.ShowPlayerDistance then
                        data.distLabel.Visible = true
                        data.distLabel.Text = string.format("[%.0f m]", dist)
                    else
                        data.distLabel.Visible = false
                    end

                    -- Health
                    if ESP_SETTINGS.ShowPlayerHealth then
                        local hp, maxHp = getHealth(char)
                        local pct = math.clamp(hp / maxHp, 0, 1)
                        data.hpFill.Size = UDim2.new(pct, 0, 1, 0)
                        data.hpText.Text = string.format("%.0f / %.0f HP", hp, maxHp)

                        if pct > 0.6 then
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                            data.hpText.TextColor3 = Color3.fromRGB(0, 255, 100)
                        elseif pct > 0.3 then
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                            data.hpText.TextColor3 = Color3.fromRGB(255, 200, 0)
                        else
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                            data.hpText.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                        data.hpFill.Parent.Visible = true
                        data.hpText.Visible = true
                    else
                        data.hpFill.Parent.Visible = false
                        data.hpText.Visible = false
                    end

                    -- Highlight
                    if ESP_SETTINGS.ShowPlayerHighlight then
                        pcall(function()
                            data.highlight.Adornee = char
                            data.highlight.FillColor = color
                            data.highlight.OutlineColor = color
                        end)
                        data.highlight.Visible = true
                    else
                        data.highlight.Visible = false
                    end

                    -- Box & Tracer
                    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        data.arrow.Visible = false

                        if ESP_SETTINGS.ShowPlayerBox then
                            local head = char:FindFirstChild("Head")
                            local headY = head and camera:WorldToViewportPoint(head.Position).Y or screenPos.Y - 50
                            local footY = screenPos.Y
                            local boxHeight = math.abs(footY - headY) * 1.2
                            local boxWidth = boxHeight * 0.5

                            data.box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                            data.box.Position = UDim2.new(0, screenPos.X - boxWidth/2, 0, headY - boxHeight*0.1)
                            data.box.Visible = true
                            data.boxStroke.Color = color

                            local cornerSize = 8
                            data.corners[1].Size = UDim2.new(0, cornerSize, 0, 2)
                            data.corners[1].Position = UDim2.new(0, 0, 0, 0)
                            data.corners[1].BackgroundColor3 = color
                            data.corners[2].Size = UDim2.new(0, 2, 0, cornerSize)
                            data.corners[2].Position = UDim2.new(0, 0, 0, 0)
                            data.corners[2].BackgroundColor3 = color
                            data.corners[3].Size = UDim2.new(0, cornerSize, 0, 2)
                            data.corners[3].Position = UDim2.new(1, -cornerSize, 0, 0)
                            data.corners[3].BackgroundColor3 = color
                            data.corners[4].Size = UDim2.new(0, 2, 0, cornerSize)
                            data.corners[4].Position = UDim2.new(1, -2, 0, 0)
                            data.corners[4].BackgroundColor3 = color
                        else
                            data.box.Visible = false
                        end

                        if ESP_SETTINGS.ShowPlayerTracer then
                            data.tracer.Visible = true
                            data.tracer.BackgroundColor3 = color
                            local startX = screenSize.X / 2
                            local startY = screenSize.Y - 50
                            local endX = screenPos.X
                            local endY = screenPos.Y + (data.box.Visible and data.box.AbsoluteSize.Y/2 or 20)
                            local dx = endX - startX
                            local dy = endY - startY
                            local length = math.sqrt(dx*dx + dy*dy)
                            local angle = math.atan2(dy, dx)
                            data.tracer.Size = UDim2.new(0, length, 0, ESP_SETTINGS.TracerThickness)
                            data.tracer.Position = UDim2.new(0, startX, 0, startY)
                            data.tracer.Rotation = math.deg(angle)
                        else
                            data.tracer.Visible = false
                        end
                    else
                        data.box.Visible = false
                        data.tracer.Visible = false
                        data.arrow.Visible = true
                        data.arrow.Position = UDim2.new(0, math.clamp(screenPos.X, 50, screenSize.X-50), 0, math.clamp(screenPos.Y, 50, screenSize.Y-50))
                        data.arrow.TextColor3 = color
                        local angle = math.atan2(screenPos.Y - screenSize.Y/2, screenPos.X - screenSize.X/2)
                        data.arrow.Rotation = math.deg(angle) - 90
                    end
                end
            end
        end
    end

    -- Update Monsters
    for monster, data in pairs(Monster_Objects) do
        if not ESP_SETTINGS.ShowMonsters or not monster or not monster.Parent then
            data.folder.Enabled = false
        else
            local pos = (monster:IsA("Model") and monster:GetPivot().Position) or (monster:IsA("BasePart") and monster.Position)
            if not pos then data.folder.Enabled = false
            else
                local dist = localRoot and (pos - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then
                    data.folder.Enabled = false
                else
                    data.folder.Enabled = true
                    data.billboard.Adornee = monster

                    local color = ESP_SETTINGS.MonsterColor

                    data.badge.Visible = true
                    data.badge.BackgroundColor3 = color
                    data.badgeText.Text = "⚠️ MONSTER"

                    if ESP_SETTINGS.ShowMonsterName then
                        data.nameLabel.Visible = true
                        data.nameLabel.Text = monster.Name
                        data.nameLabel.TextColor3 = color
                    else
                        data.nameLabel.Visible = false
                    end

                    if ESP_SETTINGS.ShowMonsterDistance then
                        data.distLabel.Visible = true
                        data.distLabel.Text = string.format("[%.0f m]", dist)
                    else
                        data.distLabel.Visible = false
                    end

                    data.hpFill.Parent.Visible = false
                    data.hpText.Visible = false

                    if ESP_SETTINGS.ShowMonsterHighlight then
                        pcall(function()
                            data.highlight.Adornee = monster
                            data.highlight.FillColor = color
                            data.highlight.OutlineColor = color
                        end)
                        data.highlight.Visible = true
                    else
                        data.highlight.Visible = false
                    end

                    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
                    if onScreen then
                        data.arrow.Visible = false
                        if ESP_SETTINGS.ShowMonsterTracer then
                            data.tracer.Visible = true
                            data.tracer.BackgroundColor3 = color
                            local startX = screenSize.X / 2
                            local startY = screenSize.Y - 50
                            local dx = screenPos.X - startX
                            local dy = screenPos.Y - startY
                            local length = math.sqrt(dx*dx + dy*dy)
                            local angle = math.atan2(dy, dx)
                            data.tracer.Size = UDim2.new(0, length, 0, ESP_SETTINGS.TracerThickness + 1)
                            data.tracer.Position = UDim2.new(0, startX, 0, startY)
                            data.tracer.Rotation = math.deg(angle)
                        else
                            data.tracer.Visible = false
                        end
                        data.box.Visible = false
                    else
                        data.box.Visible = false
                        data.tracer.Visible = false
                        data.arrow.Visible = true
                        data.arrow.Position = UDim2.new(0, math.clamp(screenPos.X, 50, screenSize.X-50), 0, math.clamp(screenPos.Y, 50, screenSize.Y-50))
                        data.arrow.TextColor3 = color
                        local angle = math.atan2(screenPos.Y - screenSize.Y/2, screenPos.X - screenSize.X/2)
                        data.arrow.Rotation = math.deg(angle) - 90
                    end
                end
            end
        end
    end

    -- Update Items
    for item, data in pairs(Item_Objects) do
        if not ESP_SETTINGS.ShowItems or not item or not item.Parent then
            data.folder.Enabled = false
        else
            local pos = (item:IsA("Model") and item:GetPivot().Position) or (item:IsA("BasePart") and item.Position)
            if not pos then data.folder.Enabled = false
            else
                local dist = localRoot and (pos - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then
                    data.folder.Enabled = false
                else
                    data.folder.Enabled = true
                    data.billboard.Adornee = item
                    local color = ESP_SETTINGS.ItemColor

                    data.badge.Visible = true
                    data.badge.BackgroundColor3 = color
                    data.badgeText.Text = "📦 ITEM"

                    if ESP_SETTINGS.ShowItemName then
                        data.nameLabel.Visible = true
                        data.nameLabel.Text = item.Name
                        data.nameLabel.TextColor3 = color
                    else
                        data.nameLabel.Visible = false
                    end

                    if ESP_SETTINGS.ShowItemDistance then
                        data.distLabel.Visible = true
                        data.distLabel.Text = string.format("[%.0f m]", dist)
                    else
                        data.distLabel.Visible = false
                    end

                    data.hpFill.Parent.Visible = false
                    data.hpText.Visible = false
                    data.highlight.Visible = false
                    data.box.Visible = false
                    data.tracer.Visible = false
                    data.arrow.Visible = false
                end
            end
        end
    end
end

--============== Scan & Player Management ==============
local function scanWorkspace()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if isMonster(obj) and not Monster_Objects[obj] then
                Monster_Objects[obj] = createDrawingESP(obj, "monster")
            end
            if isItem(obj) and not Item_Objects[obj] then
                Item_Objects[obj] = createDrawingESP(obj, "item")
            end
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and not ESP_Objects[player] then
        ESP_Objects[player] = createDrawingESP(player, "player")
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESP_Objects[player] = createDrawingESP(player, "player")
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removeESP(ESP_Objects, player)
end)

RunService.RenderStepped:Connect(function()
    scanWorkspace()
    updateAllESP()
end)

task.spawn(function()
    while true do
        task.wait(2)
        for obj, _ in pairs(Monster_Objects) do
            if not obj or not obj.Parent then removeESP(Monster_Objects, obj) end
        end
        for obj, _ in pairs(Item_Objects) do
            if not obj or not obj.Parent then removeESP(Item_Objects, obj) end
        end
    end
end)

--============== GUI ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("EvadeUltimateESP") then
        CoreGui:FindFirstChild("EvadeUltimateESP"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "EvadeUltimateESP"
    gui.IgnoreGuiInset = true

    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 60, 0, 60)
    toggleBtn.Position = UDim2.new(0, 25, 0.5, -30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 460, 0, 480)
    main.Position = UDim2.new(0.5, -230, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(100, 100, 255)
    mainStroke.Transparency = 0.3

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "👁️ EVADE ULTIMATE ESP"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.new(1, 1, 1)

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0, 14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- Master Toggle
    local masterCard = Instance.new("Frame", main)
    masterCard.Size = UDim2.new(1, -40, 0, 55)
    masterCard.Position = UDim2.new(0, 20, 0, 60)
    masterCard.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    masterCard.BackgroundTransparency = 0.2
    Instance.new("UICorner", masterCard).CornerRadius = UDim.new(0, 14)

    local masterIcon = Instance.new("TextLabel", masterCard)
    masterIcon.Size = UDim2.new(0, 40, 0, 40)
    masterIcon.Position = UDim2.new(0, 12, 0.5, -20)
    masterIcon.BackgroundTransparency = 1
    masterIcon.Text = "👁️"
    masterIcon.Font = Enum.Font.GothamBold
    masterIcon.TextSize = 26

    local masterTitle = Instance.new("TextLabel", masterCard)
    masterTitle.Size = UDim2.new(0, 200, 0, 22)
    masterTitle.Position = UDim2.new(0, 55, 0, 6)
    masterTitle.BackgroundTransparency = 1
    masterTitle.Text = "MASTER ESP"
    masterTitle.Font = Enum.Font.GothamBlack
    masterTitle.TextSize = 15
    masterTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
    masterTitle.TextXAlignment = Enum.TextXAlignment.Left

    local masterToggle = Instance.new("Frame", masterCard)
    masterToggle.Size = UDim2.new(0, 56, 0, 30)
    masterToggle.Position = UDim2.new(1, -72, 0.5, -15)
    masterToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    Instance.new("UICorner", masterToggle).CornerRadius = UDim.new(1, 0)

    local masterKnob = Instance.new("Frame", masterToggle)
    masterKnob.Size = UDim2.new(0, 26, 0, 26)
    masterKnob.Position = UDim2.new(0, 28, 0.5, -13)
    masterKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", masterKnob).CornerRadius = UDim.new(1, 0)

    local masterBtn = Instance.new("TextButton", masterCard)
    masterBtn.Size = UDim2.new(1, 0, 1, 0)
    masterBtn.BackgroundTransparency = 1
    masterBtn.Text = ""

    local function animateMaster(state)
        if state then
            tween(masterToggle, {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}, 0.25)
            tween(masterKnob, {Position = UDim2.new(0, 28, 0.5, -13)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(masterCard, {BackgroundColor3 = Color3.fromRGB(15, 40, 25)}, 0.3)
        else
            tween(masterToggle, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.25)
            tween(masterKnob, {Position = UDim2.new(0, 2, 0.5, -13)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(masterCard, {BackgroundColor3 = Color3.fromRGB(40, 15, 15)}, 0.3)
        end
    end
    masterBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
        animateMaster(ESP_SETTINGS.Enabled)
    end)

    -- Team Check & Show Teammates
    local teamFrame = Instance.new("Frame", main)
    teamFrame.Size = UDim2.new(1, -40, 0, 30)
    teamFrame.Position = UDim2.new(0, 20, 0, 125)
    teamFrame.BackgroundTransparency = 1

    local function createTeamToggle(x, text, setting)
        local btn = Instance.new("TextButton", teamFrame)
        btn.Size = UDim2.new(0.45, 0, 1, 0)
        btn.Position = UDim2.new(x, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = ESP_SETTINGS[setting] and Color3.fromRGB(0,255,150) or Color3.fromRGB(180,180,200)
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Down:Connect(function()
            ESP_SETTINGS[setting] = not ESP_SETTINGS[setting]
            btn.TextColor3 = ESP_SETTINGS[setting] and Color3.fromRGB(0,255,150) or Color3.fromRGB(180,180,200)
        end)
    end
    createTeamToggle(0, "Team Check", "TeamCheck")
    createTeamToggle(0.52, "Show Teammates", "ShowTeammates")

    -- Status
    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, -40, 0, 18)
    status.Position = UDim2.new(0, 20, 1, -32)
    status.BackgroundTransparency = 1
    status.Text = "● ESP ACTIVE"
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(0, 255, 120)
    status.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while gui.Parent do
            local pCount, mCount, iCount = 0,0,0
            for _ in pairs(ESP_Objects) do pCount = pCount + 1 end
            for _ in pairs(Monster_Objects) do mCount = mCount + 1 end
            for _ in pairs(Item_Objects) do iCount = iCount + 1 end
            if ESP_SETTINGS.Enabled then
                status.Text = string.format("● ACTIVE | Players: %d | Monsters: %d | Items: %d", pCount, mCount, iCount)
                status.TextColor3 = Color3.fromRGB(0, 255, 120)
            else
                status.Text = "● ESP DISABLED"
                status.TextColor3 = Color3.fromRGB(120, 120, 150)
            end
            task.wait(0.5)
        end
    end)

    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(230, 60, 60)}, 0.15) end)
    toggleBtn.MouseButton1Down:Connect(function() main.Visible = not main.Visible end)
    closeBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = false
        for p, _ in pairs(ESP_Objects) do removeESP(ESP_Objects, p) end
        for m, _ in pairs(Monster_Objects) do removeESP(Monster_Objects, m) end
        for i, _ in pairs(Item_Objects) do removeESP(Item_Objects, i) end
        gui:Destroy()
    end)

    -- Rainbow effect
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.015) % 1
            title.TextColor3 = Color3.fromHSV(hue, 0.9, 1)
            mainStroke.Color = Color3.fromHSV(hue, 0.6, 0.9)
            toggleStroke.Color = Color3.fromHSV((hue + 0.3) % 1, 0.8, 1)
            task.wait(0.05)
        end
    end)

    makeDraggable(main)
    makeDraggable(toggleBtn)
end

--============== Load Image (រក្សាដូចដើម) ==============
local function loadImageAndStart()
    local requestFunc = syn and syn.request or http_request or request
    if requestFunc and writefile and getcustomasset then
        local ok, response = pcall(function() return requestFunc({Url = IMAGE_URL, Method = "GET"}) end)
        if ok and response and response.StatusCode == 200 then
            writefile(FILE_NAME, response.Body)
            createGUI(getcustomasset(FILE_NAME))
        else
            createGUI("")
        end
    else
        createGUI("")
    end
end

loadImageAndStart()

print("👁️ EVADE ULTIMATE ESP LOADED - Fixed & Optimized!")