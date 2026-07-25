-- Evade Ultimate Full ESP (Visible Highlight Fix) for Delta
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

local ESP_SETTINGS = {
    Enabled = true,
    ShowPlayers = true, ShowPlayerName = true, ShowPlayerHealth = true,
    ShowPlayerDistance = true, ShowPlayerBox = true, ShowPlayerTracer = true,
    ShowPlayerHighlight = true, ShowPlayerTeam = true,
    ShowMonsters = true, ShowMonsterName = true, ShowMonsterDistance = true,
    ShowMonsterTracer = true, ShowMonsterHighlight = true,
    ShowItems = true, ShowItemName = true, ShowItemDistance = true,
    MaxDistance = 3000, TextSize = 14, BoxThickness = 2, TracerThickness = 1.5,
    PlayerColor = Color3.fromRGB(0, 255, 120),
    MonsterColor = Color3.fromRGB(255, 50, 50),
    ItemColor = Color3.fromRGB(255, 220, 0),
    TeammateColor = Color3.fromRGB(0, 200, 255),
    TeamCheck = true,
    ShowTeammates = true,
}

local ESP_Objects, Monster_Objects, Item_Objects = {}, {}, {}

-- Helper functions (same as before)
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

local function isTeammate(player)
    if not ESP_SETTINGS.TeamCheck then return false end
    if player.Team and LocalPlayer.Team then return player.Team == LocalPlayer.Team end
    return false
end

local function getHealth(char)
    if not char then return 0, 100 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return 0, 100
end

local function isMonster(obj)
    local name = obj.Name:lower()
    return name:find("monster") or name:find("bot") or name:find("nextbot")
        or name:find("slenderman") or name:find("killer") or name:find("enemy")
        or name:find("angry") or name:find("chase")
end

local function isItem(obj)
    local name = obj.Name:lower()
    return name:find("revive") or name:find("cash") or name:find("money")
        or name:find("coin") or name:find("board") or name:find("medkit")
        or name:find("item") or name:find("collect") or name:find("pickup")
end

-- Create ESP object with VISIBLE highlight
local function createESP(target, espType)
    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. espType .. "_" .. target.Name

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_SETTINGS.MaxDistance
    billboard.Parent = folder

    local badge = Instance.new("Frame", billboard)
    badge.Size = UDim2.new(0, 80, 0, 18)
    badge.Position = UDim2.new(0.5, -40, 0, -20)
    badge.BackgroundTransparency = 0.2
    badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel", badge)
    badgeText.Size = UDim2.new(1,0,1,0)
    badgeText.BackgroundTransparency = 1
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 9
    badgeText.TextColor3 = Color3.new(0,0,0)

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1,0,0,20)
    nameLabel.Position = UDim2.new(0,0,0,2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = ESP_SETTINGS.TextSize
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0.2

    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Size = UDim2.new(1,0,0,16)
    distLabel.Position = UDim2.new(0,0,0,22)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 12
    distLabel.TextColor3 = Color3.fromRGB(200,200,200)

    local hpBg = Instance.new("Frame", billboard)
    hpBg.Size = UDim2.new(0,80,0,6)
    hpBg.Position = UDim2.new(0.5,-40,0,42)
    hpBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    hpBg.BorderSizePixel = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1,0)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0,255,100)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1,0)

    local hpText = Instance.new("TextLabel", billboard)
    hpText.Size = UDim2.new(1,0,0,14)
    hpText.Position = UDim2.new(0,0,0,50)
    hpText.BackgroundTransparency = 1
    hpText.Font = Enum.Font.GothamBold
    hpText.TextSize = 10
    hpText.TextColor3 = Color3.fromRGB(0,255,100)

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = folder

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Thickness = ESP_SETTINGS.BoxThickness

    local corners = {}
    for i=1,4 do
        local line = Instance.new("Frame", box)
        line.BackgroundColor3 = Color3.new(1,1,1)
        line.BorderSizePixel = 0
        corners[i] = line
    end

    local tracer = Instance.new("Frame")
    tracer.BackgroundTransparency = 0.3
    tracer.BorderSizePixel = 0
    tracer.Parent = folder

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0,40,0,40)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▲"
    arrow.Font = Enum.Font.GothamBlack
    arrow.TextSize = 30
    arrow.TextStrokeTransparency = 0.2
    arrow.Visible = false
    arrow.Parent = folder

    -- ========== HIGHLIGHT (NOW VERY VISIBLE) ==========
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5   -- ពណ៌ភ្លឺច្បាស់ (ពីមុន 0.85 ថ្លាពេក)
    highlight.OutlineTransparency = 0  -- គែមពណ៌ភ្លឺ
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillColor = Color3.new(1,1,1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = folder

    folder.Parent = CoreGui

    return {
        folder=folder, billboard=billboard, badge=badge, badgeText=badgeText,
        nameLabel=nameLabel, distLabel=distLabel, hpFill=hpFill, hpText=hpText,
        box=box, boxStroke=boxStroke, corners=corners, tracer=tracer, arrow=arrow,
        highlight=highlight, target=target, type=espType
    }
end

local function removeESP(tbl, target)
    if tbl[target] then pcall(function() tbl[target].folder:Destroy() end); tbl[target]=nil end
end

-- Update all ESP
local function updateAllESP()
    if not ESP_SETTINGS.Enabled then
        for _,d in pairs(ESP_Objects) do d.folder.Enabled = false end
        for _,d in pairs(Monster_Objects) do d.folder.Enabled = false end
        for _,d in pairs(Item_Objects) do d.folder.Enabled = false end
        return
    end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local screenSize = camera.ViewportSize
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

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

                    if ESP_SETTINGS.ShowPlayerTeam then
                        data.badge.Visible = true
                        data.badge.BackgroundColor3 = color
                        data.badgeText.Text = isTeam and "TEAM" or "PLAYER"
                    else data.badge.Visible = false end

                    if ESP_SETTINGS.ShowPlayerName then
                        data.nameLabel.Visible = true
                        data.nameLabel.Text = player.Name
                        data.nameLabel.TextColor3 = color
                    else data.nameLabel.Visible = false end

                    if ESP_SETTINGS.ShowPlayerDistance then
                        data.distLabel.Visible = true
                        data.distLabel.Text = string.format("[%.0f m]", dist)
                    else data.distLabel.Visible = false end

                    if ESP_SETTINGS.ShowPlayerHealth then
                        local hp,maxHp = getHealth(char)
                        local pct = math.clamp(hp/maxHp,0,1)
                        data.hpFill.Size = UDim2.new(pct,0,1,0)
                        data.hpText.Text = string.format("%.0f/%.0f HP", hp, maxHp)
                        data.hpFill.Parent.Visible = true
                        data.hpText.Visible = true
                        if pct > 0.6 then
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(0,255,100)
                            data.hpText.TextColor3 = Color3.fromRGB(0,255,100)
                        elseif pct > 0.3 then
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(255,200,0)
                            data.hpText.TextColor3 = Color3.fromRGB(255,200,0)
                        else
                            data.hpFill.BackgroundColor3 = Color3.fromRGB(255,50,50)
                            data.hpText.TextColor3 = Color3.fromRGB(255,50,50)
                        end
                    else
                        data.hpFill.Parent.Visible = false
                        data.hpText.Visible = false
                    end

                    -- HIGHLIGHT (always try to set)
                    pcall(function()
                        if ESP_SETTINGS.ShowPlayerHighlight then
                            data.highlight.Adornee = char
                            data.highlight.FillColor = color
                            data.highlight.OutlineColor = color
                            data.highlight.Visible = true
                            data.highlight.Enabled = true
                        else
                            data.highlight.Visible = false
                        end
                    end)

                    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        data.arrow.Visible = false
                        if ESP_SETTINGS.ShowPlayerBox then
                            local head = char:FindFirstChild("Head")
                            local headY = head and camera:WorldToViewportPoint(head.Position).Y or screenPos.Y-50
                            local boxH = math.abs(screenPos.Y - headY)*1.2
                            local boxW = boxH*0.5
                            data.box.Size = UDim2.new(0,boxW,0,boxH)
                            data.box.Position = UDim2.new(0, screenPos.X-boxW/2, 0, headY-boxH*0.1)
                            data.box.Visible = true
                            data.boxStroke.Color = color
                            local s=8
                            data.corners[1].Size=UDim2.new(0,s,0,2); data.corners[1].Position=UDim2.new(0,0,0,0); data.corners[1].BackgroundColor3=color
                            data.corners[2].Size=UDim2.new(0,2,0,s); data.corners[2].Position=UDim2.new(0,0,0,0); data.corners[2].BackgroundColor3=color
                            data.corners[3].Size=UDim2.new(0,s,0,2); data.corners[3].Position=UDim2.new(1,-s,0,0); data.corners[3].BackgroundColor3=color
                            data.corners[4].Size=UDim2.new(0,2,0,s); data.corners[4].Position=UDim2.new(1,-2,0,0); data.corners[4].BackgroundColor3=color
                        else data.box.Visible = false end
                        if ESP_SETTINGS.ShowPlayerTracer then
                            data.tracer.Visible = true
                            data.tracer.BackgroundColor3 = color
                            local sx,sy = screenSize.X/2, screenSize.Y-50
                            local dx,dy = screenPos.X-sx, screenPos.Y+(data.box.Visible and data.box.AbsoluteSize.Y/2 or 20)-sy
                            local len = math.sqrt(dx*dx+dy*dy)
                            local ang = math.atan2(dy,dx)
                            data.tracer.Size = UDim2.new(0,len,0,ESP_SETTINGS.TracerThickness)
                            data.tracer.Position = UDim2.new(0,sx,0,sy)
                            data.tracer.Rotation = math.deg(ang)
                        else data.tracer.Visible = false end
                    else
                        data.box.Visible=false; data.tracer.Visible=false; data.arrow.Visible=true
                        data.arrow.Position = UDim2.new(0, math.clamp(screenPos.X,50,screenSize.X-50), 0, math.clamp(screenPos.Y,50,screenSize.Y-50))
                        data.arrow.TextColor3 = color
                        data.arrow.Rotation = math.deg(math.atan2(screenPos.Y-screenSize.Y/2, screenPos.X-screenSize.X/2))-90
                    end
                end
            end
        end
    end

    -- Update Monsters (same logic, visible highlight)
    for obj, data in pairs(Monster_Objects) do
        if not ESP_SETTINGS.ShowMonsters or not obj or not obj.Parent then
            data.folder.Enabled = false
        else
            local pos = (obj:IsA("BasePart") and obj.Position) or (obj:IsA("Model") and pcall(function() return obj:GetPivot().Position end) and obj:GetPivot().Position) or (obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position)
            if not pos then data.folder.Enabled = false
            else
                local dist = localRoot and (pos - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then data.folder.Enabled = false
                else
                    data.folder.Enabled = true
                    pcall(function() data.billboard.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj end)
                    local color = ESP_SETTINGS.MonsterColor
                    data.badge.Visible = true; data.badge.BackgroundColor3 = color; data.badgeText.Text = "NPC"
                    if ESP_SETTINGS.ShowMonsterName then
                        data.nameLabel.Visible = true; data.nameLabel.Text = obj.Name; data.nameLabel.TextColor3 = color
                    else data.nameLabel.Visible = false end
                    if ESP_SETTINGS.ShowMonsterDistance then
                        data.distLabel.Visible = true; data.distLabel.Text = string.format("[%.0f m]", dist)
                    else data.distLabel.Visible = false end
                    data.hpFill.Parent.Visible = false; data.hpText.Visible = false
                    -- NPC HIGHLIGHT (visible)
                    if ESP_SETTINGS.ShowMonsterHighlight then
                        pcall(function()
                            data.highlight.Adornee = obj
                            data.highlight.FillColor = color
                            data.highlight.OutlineColor = color
                            data.highlight.Visible = true
                            data.highlight.Enabled = true
                        end)
                    else data.highlight.Visible = false end
                    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
                    if onScreen then
                        data.arrow.Visible = false; data.box.Visible = false
                        if ESP_SETTINGS.ShowMonsterTracer then
                            data.tracer.Visible = true
                            local sx,sy = screenSize.X/2, screenSize.Y-50
                            local dx,dy = screenPos.X-sx, screenPos.Y-sy
                            local len = math.sqrt(dx*dx+dy*dy)
                            data.tracer.Size = UDim2.new(0,len,0,ESP_SETTINGS.TracerThickness+1)
                            data.tracer.Position = UDim2.new(0,sx,0,sy)
                            data.tracer.Rotation = math.deg(math.atan2(dy,dx))
                            data.tracer.BackgroundColor3 = color
                        else data.tracer.Visible = false end
                    else
                        data.tracer.Visible = false; data.box.Visible = false; data.arrow.Visible = true
                        data.arrow.Position = UDim2.new(0, math.clamp(screenPos.X,50,screenSize.X-50), 0, math.clamp(screenPos.Y,50,screenSize.Y-50))
                        data.arrow.TextColor3 = color
                        data.arrow.Rotation = math.deg(math.atan2(screenPos.Y-screenSize.Y/2, screenPos.X-screenSize.X/2))-90
                    end
                end
            end
        end
    end

    -- Update Items (same)
    for obj, data in pairs(Item_Objects) do
        if not ESP_SETTINGS.ShowItems or not obj or not obj.Parent then
            data.folder.Enabled = false
        else
            local pos = (obj:IsA("BasePart") and obj.Position) or (obj:IsA("Model") and obj:GetPivot().Position)
            if not pos then data.folder.Enabled = false
            else
                local dist = localRoot and (pos - localRoot.Position).Magnitude or 0
                if dist > ESP_SETTINGS.MaxDistance then data.folder.Enabled = false
                else
                    data.folder.Enabled = true
                    pcall(function() data.billboard.Adornee = obj end)
                    local color = ESP_SETTINGS.ItemColor
                    data.badge.Visible = true; data.badge.BackgroundColor3 = color; data.badgeText.Text = "ITEM"
                    data.nameLabel.Visible = ESP_SETTINGS.ShowItemName; data.nameLabel.Text = obj.Name; data.nameLabel.TextColor3 = color
                    data.distLabel.Visible = ESP_SETTINGS.ShowItemDistance; data.distLabel.Text = string.format("[%.0f m]", dist)
                    data.hpFill.Parent.Visible = false; data.hpText.Visible = false
                    data.highlight.Visible = false; data.box.Visible = false; data.tracer.Visible = false; data.arrow.Visible = false
                end
            end
        end
    end
end

-- Scan world for NPCs and Items
local function scanWorld()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if isMonster(obj) and not Monster_Objects[obj] then
                Monster_Objects[obj] = createESP(obj, "NPC")
            end
            if isItem(obj) and not Item_Objects[obj] then
                Item_Objects[obj] = createESP(obj, "Item")
            end
        end
    end
    for obj,_ in pairs(Monster_Objects) do if not obj or not obj.Parent then removeESP(Monster_Objects, obj) end end
    for obj,_ in pairs(Item_Objects) do if not obj or not obj.Parent then removeESP(Item_Objects, obj) end end
end

-- Player connections
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then ESP_Objects[player] = createESP(player, "Player") end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then ESP_Objects[p] = createESP(p, "Player") end end)
Players.PlayerRemoving:Connect(function(p) removeESP(ESP_Objects, p) end)

RunService.RenderStepped:Connect(function()
    scanWorld()
    updateAllESP()
end)

--============== GUI WITH IMAGE (same as before) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("EvadeUltimateESP") then
        CoreGui:FindFirstChild("EvadeUltimateESP"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "EvadeUltimateESP"
    gui.IgnoreGuiInset = true

    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0,60,0,60)
    toggleBtn.Position = UDim2.new(0,25,0.5,-30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,35)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,460,0,480)
    main.Position = UDim2.new(0.5,-230,0.5,-240)
    main.BackgroundColor3 = Color3.fromRGB(10,10,20)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,20)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 2
    mainStroke.Color = Color3.fromRGB(100,100,255)
    mainStroke.Transparency = 0.3

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundTransparency = 1
    title.Text = "👁️ EVADE ULTIMATE ESP"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.new(1,1,1)

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0,32,0,32)
    closeBtn.Position = UDim2.new(1,-42,0,14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(230,60,60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

    -- Master Toggle
    local masterCard = Instance.new("Frame", main)
    masterCard.Size = UDim2.new(1,-40,0,55)
    masterCard.Position = UDim2.new(0,20,0,60)
    masterCard.BackgroundColor3 = Color3.fromRGB(20,20,40)
    masterCard.BackgroundTransparency = 0.2
    Instance.new("UICorner", masterCard).CornerRadius = UDim.new(0,14)

    local masterIcon = Instance.new("TextLabel", masterCard)
    masterIcon.Size = UDim2.new(0,40,0,40)
    masterIcon.Position = UDim2.new(0,12,0.5,-20)
    masterIcon.BackgroundTransparency = 1
    masterIcon.Text = "👁️"
    masterIcon.Font = Enum.Font.GothamBold
    masterIcon.TextSize = 26

    local masterTitle = Instance.new("TextLabel", masterCard)
    masterTitle.Size = UDim2.new(0,200,0,22)
    masterTitle.Position = UDim2.new(0,55,0,6)
    masterTitle.BackgroundTransparency = 1
    masterTitle.Text = "MASTER ESP"
    masterTitle.Font = Enum.Font.GothamBlack
    masterTitle.TextSize = 15
    masterTitle.TextColor3 = Color3.fromRGB(220,220,255)
    masterTitle.TextXAlignment = Enum.TextXAlignment.Left

    local masterToggle = Instance.new("Frame", masterCard)
    masterToggle.Size = UDim2.new(0,56,0,30)
    masterToggle.Position = UDim2.new(1,-72,0.5,-15)
    masterToggle.BackgroundColor3 = Color3.fromRGB(0,200,100)
    Instance.new("UICorner", masterToggle).CornerRadius = UDim.new(1,0)

    local masterKnob = Instance.new("Frame", masterToggle)
    masterKnob.Size = UDim2.new(0,26,0,26)
    masterKnob.Position = UDim2.new(0,28,0.5,-13)
    masterKnob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", masterKnob).CornerRadius = UDim.new(1,0)

    local masterBtn = Instance.new("TextButton", masterCard)
    masterBtn.Size = UDim2.new(1,0,1,0)
    masterBtn.BackgroundTransparency = 1
    masterBtn.Text = ""

    local function animateMaster(state)
        if state then
            tween(masterToggle, {BackgroundColor3 = Color3.fromRGB(0,200,100)}, 0.25)
            tween(masterKnob, {Position = UDim2.new(0,28,0.5,-13)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            tween(masterToggle, {BackgroundColor3 = Color3.fromRGB(200,50,50)}, 0.25)
            tween(masterKnob, {Position = UDim2.new(0,2,0.5,-13)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end

    masterBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = not ESP_SETTINGS.Enabled
        animateMaster(ESP_SETTINGS.Enabled)
    end)

    -- Categories
    local function createCategory(y, icon, titleText, color, settingsPrefix)
        local card = Instance.new("Frame", main)
        card.Size = UDim2.new(1,-40,0,110)
        card.Position = UDim2.new(0,20,0,y)
        card.BackgroundColor3 = Color3.fromRGB(20,20,40)
        card.BackgroundTransparency = 0.2
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)

        local iconLbl = Instance.new("TextLabel", card)
        iconLbl.Size = UDim2.new(0,35,0,35)
        iconLbl.Position = UDim2.new(0,12,0,8)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text = icon
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 24

        local titleLbl = Instance.new("TextLabel", card)
        titleLbl.Size = UDim2.new(0,200,0,20)
        titleLbl.Position = UDim2.new(0,50,0,6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = titleText
        titleLbl.Font = Enum.Font.GothamBlack
        titleLbl.TextSize = 13
        titleLbl.TextColor3 = color
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local toggles = {
            {text="Name", key=settingsPrefix.."Name", x=0, y=45},
            {text="Distance", key=settingsPrefix.."Distance", x=0.33, y=45},
            {text="Tracer", key=settingsPrefix.."Tracer", x=0.66, y=45},
        }
        if settingsPrefix=="ShowPlayer" then
            table.insert(toggles, {text="Box", key="ShowPlayerBox", x=0, y=78})
            table.insert(toggles, {text="Highlight", key="ShowPlayerHighlight", x=0.33, y=78})
            table.insert(toggles, {text="Team", key="ShowPlayerTeam", x=0.66, y=78})
        elseif settingsPrefix=="ShowMonster" then
            table.insert(toggles, {text="Highlight", key="ShowMonsterHighlight", x=0, y=78})
        end

        for _,t in ipairs(toggles) do
            local btn = Instance.new("TextButton", card)
            btn.Size = UDim2.new(0.3,-4,0,26)
            btn.Position = UDim2.new(t.x,2,0,t.y)
            btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
            btn.Text = ""
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.Text = t.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 9
            lbl.TextColor3 = Color3.fromRGB(180,180,200)

            local dot = Instance.new("Frame", btn)
            dot.Size = UDim2.new(0,6,0,6)
            dot.Position = UDim2.new(1,-10,0.5,-3)
            dot.BackgroundColor3 = color
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

            if ESP_SETTINGS[t.key] then
                dot.BackgroundTransparency = 0
                lbl.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = Color3.fromRGB(color.R*80, color.G*80, color.B*80)
            else
                dot.BackgroundTransparency = 0.7
            end

            btn.MouseButton1Down:Connect(function()
                ESP_SETTINGS[t.key] = not ESP_SETTINGS[t.key]
                if ESP_SETTINGS[t.key] then
                    tween(dot, {BackgroundTransparency=0}, 0.2)
                    lbl.TextColor3 = Color3.new(1,1,1)
                    tween(btn, {BackgroundColor3=Color3.fromRGB(color.R*80, color.G*80, color.B*80)}, 0.2)
                else
                    tween(dot, {BackgroundTransparency=0.7}, 0.2)
                    lbl.TextColor3 = Color3.fromRGB(180,180,200)
                    tween(btn, {BackgroundColor3=Color3.fromRGB(35,35,55)}, 0.2)
                end
            end)
        end
    end

    createCategory(125, "👤", "PLAYERS", ESP_SETTINGS.PlayerColor, "ShowPlayer")
    createCategory(245, "🤖", "MONSTERS", ESP_SETTINGS.MonsterColor, "ShowMonster")
    createCategory(365, "📦", "ITEMS", ESP_SETTINGS.ItemColor, "ShowItem")

    -- Distance Slider
    local distFrame = Instance.new("Frame", main)
    distFrame.Size = UDim2.new(1,-40,0,45)
    distFrame.Position = UDim2.new(0,20,1,-85)
    distFrame.BackgroundColor3 = Color3.fromRGB(20,20,40)
    distFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", distFrame).CornerRadius = UDim.new(0,12)

    local distLbl = Instance.new("TextLabel", distFrame)
    distLbl.Size = UDim2.new(0,200,0,16)
    distLbl.Position = UDim2.new(0,12,0,4)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "📏 Max Distance: "..ESP_SETTINGS.MaxDistance.."m"
    distLbl.Font = Enum.Font.GothamBold
    distLbl.TextSize = 11
    distLbl.TextColor3 = Color3.fromRGB(200,200,230)

    local distBarBg = Instance.new("Frame", distFrame)
    distBarBg.Size = UDim2.new(1,-24,0,5)
    distBarBg.Position = UDim2.new(0,12,0,26)
    distBarBg.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner", distBarBg).CornerRadius = UDim.new(1,0)

    local distBarFill = Instance.new("Frame", distBarBg)
    distBarFill.Size = UDim2.new(ESP_SETTINGS.MaxDistance/5000,0,1,0)
    distBarFill.BackgroundColor3 = Color3.fromRGB(100,150,255)
    Instance.new("UICorner", distBarFill).CornerRadius = UDim.new(1,0)

    local distKnob = Instance.new("TextButton", distBarBg)
    distKnob.Size = UDim2.new(0,14,0,14)
    distKnob.Position = UDim2.new(ESP_SETTINGS.MaxDistance/5000,-7,0.5,-7)
    distKnob.BackgroundColor3 = Color3.new(1,1,1)
    distKnob.Text = ""
    Instance.new("UICorner", distKnob).CornerRadius = UDim.new(1,0)

    local distDragging = false
    distKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then distDragging=true end end)
    UserInputService.InputChanged:Connect(function(i)
        if distDragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local relX = math.clamp(i.Position.X-distBarBg.AbsolutePosition.X,0,distBarBg.AbsoluteSize.X)
            local val = math.floor((relX/distBarBg.AbsoluteSize.X)*5000)
            ESP_SETTINGS.MaxDistance = val
            distBarFill.Size = UDim2.new(val/5000,0,1,0)
            distKnob.Position = UDim2.new(val/5000,-7,0.5,-7)
            distLbl.Text = "📏 Max Distance: "..val.."m"
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then distDragging=false end end)

    -- Status
    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1,-40,0,18)
    status.Position = UDim2.new(0,20,1,-32)
    status.BackgroundTransparency = 1
    status.Text = "● ESP ACTIVE"
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(0,255,120)

    task.spawn(function()
        while gui.Parent do
            local p,m,i = 0,0,0
            for _ in pairs(ESP_Objects) do p=p+1 end
            for _ in pairs(Monster_Objects) do m=m+1 end
            for _ in pairs(Item_Objects) do i=i+1 end
            if ESP_SETTINGS.Enabled then
                status.Text = string.format("● ACTIVE | Players:%d NPC:%d Items:%d", p,m,i)
                status.TextColor3 = Color3.fromRGB(0,255,120)
            else
                status.Text = "● ESP DISABLED"
                status.TextColor3 = Color3.fromRGB(120,120,150)
            end
            task.wait(0.5)
        end
    end)

    closeBtn.MouseButton1Down:Connect(function()
        ESP_SETTINGS.Enabled = false
        for p,_ in pairs(ESP_Objects) do removeESP(ESP_Objects, p) end
        for m,_ in pairs(Monster_Objects) do removeESP(Monster_Objects, m) end
        for i,_ in pairs(Item_Objects) do removeESP(Item_Objects, i) end
        gui:Destroy()
    end)
    toggleBtn.MouseButton1Down:Connect(function() main.Visible = not main.Visible end)

    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue+0.015)%1
            title.TextColor3 = Color3.fromHSV(hue,0.9,1)
            mainStroke.Color = Color3.fromHSV(hue,0.6,0.9)
            toggleStroke.Color = Color3.fromHSV((hue+0.3)%1,0.8,1)
            task.wait(0.05)
        end
    end)

    makeDraggable(main)
    makeDraggable(toggleBtn)
end

-- Load Image
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

print("👁️ EVADE ULTIMATE ESP LOADED! (Highlight now very visible)")