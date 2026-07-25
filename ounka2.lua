--[[
    VIP TEAM ESP + NPC ESP - គូសអ្នកលេងតាមក្រុម និង NPC
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ====== រូបភាព ======
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

-- ====== អថេរ ESP ======
local espPlayersEnabled = false
local espNPCEnabled = false
local espPlayerHighlights = {}
local espNPCHighlights = {}
local espConnections = {}

-- ====== លុប GUI ចាស់ ======
if CoreGui:FindFirstChild("VIP_ESP_GUI") then
    CoreGui:FindFirstChild("VIP_ESP_GUI"):Destroy()
end

-- ====== មុខងារអូស ======
local function makeDraggable(guiObject)
    local dragging, startPos, objPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            objPos = guiObject.Position
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

-- ====== GUI ======
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "VIP_ESP_GUI"
gui.IgnoreGuiInset = true

-- Toggle Button
local toggleBtn = Instance.new("ImageButton", gui)
toggleBtn.Size = UDim2.new(0, 55, 0, 55)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Image = ""
toggleBtn.ScaleType = Enum.ScaleType.Crop
toggleBtn.Draggable = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 3

-- Main Frame (ខ្ពស់ជាងដើមបន្តិចដើម្បីទទួលប៊ូតុងបន្ថែម)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 420, 0, 300)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 3

-- ផ្ទៃខាងក្រោយ
local bg = Instance.new("ImageLabel", mainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = ""
bg.ScaleType = Enum.ScaleType.Stretch
bg.ImageTransparency = 0.3
bg.ZIndex = -1
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

-- ចំណងជើង
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "👑 VIP ESP (ក្រុម + NPC)"
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextColor3 = Color3.new(1, 1, 1)

-- បិទ
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

-- ប៊ូតុង ESP អ្នកលេង
local espPlayersBtn = Instance.new("TextButton", mainFrame)
espPlayersBtn.Size = UDim2.new(1, -40, 0, 45)
espPlayersBtn.Position = UDim2.new(0, 20, 0, 70)
espPlayersBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
espPlayersBtn.Text = "ESP Players: OFF"
espPlayersBtn.TextColor3 = Color3.new(1, 1, 1)
espPlayersBtn.Font = Enum.Font.GothamBold
espPlayersBtn.TextSize = 16
Instance.new("UICorner", espPlayersBtn).CornerRadius = UDim.new(0, 10)
local espPlayersStroke = Instance.new("UIStroke", espPlayersBtn)
espPlayersStroke.Thickness = 2
espPlayersStroke.Color = Color3.fromRGB(255, 215, 0)

-- ប៊ូតុង ESP NPC
local espNPCBtn = Instance.new("TextButton", mainFrame)
espNPCBtn.Size = UDim2.new(1, -40, 0, 45)
espNPCBtn.Position = UDim2.new(0, 20, 0, 125)
espNPCBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
espNPCBtn.Text = "ESP NPCs: OFF"
espNPCBtn.TextColor3 = Color3.new(1, 1, 1)
espNPCBtn.Font = Enum.Font.GothamBold
espNPCBtn.TextSize = 16
Instance.new("UICorner", espNPCBtn).CornerRadius = UDim.new(0, 10)
local espNPCStroke = Instance.new("UIStroke", espNPCBtn)
espNPCStroke.Thickness = 2
espNPCStroke.Color = Color3.fromRGB(50, 255, 50)

-- ស្លាកស្ថានភាព
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 185)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ស្ថានភាព៖ រង់ចាំ..."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13

-- ====== មុខងារ ESP អ្នកលេង (ក្រុម) ======
local function getTeamColor(plr)
    if plr.Team then
        return plr.Team.TeamColor.Color
    else
        return Color3.new(1, 1, 1) -- ស
    end
end

local function createPlayerHighlight(character, color)
    local hl = Instance.new("Highlight")
    hl.Adornee = character
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = character
    return hl
end

local function clearESPPlayers()
    for _, hl in ipairs(espPlayerHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espPlayerHighlights = {}
end

local function updatePlayerESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end

    -- លុប highlight ចាស់
    for i = #espPlayerHighlights, 1, -1 do
        if espPlayerHighlights[i] and espPlayerHighlights[i].Adornee == char then
            espPlayerHighlights[i]:Destroy()
            table.remove(espPlayerHighlights, i)
        end
    end

    local color = getTeamColor(plr)
    local hl = createPlayerHighlight(char, color)
    table.insert(espPlayerHighlights, hl)
end

local function startESPPlayers()
    clearESPPlayers()
    espPlayersEnabled = true
    espPlayersBtn.Text = "ESP Players: ON"
    espPlayersBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    for _, plr in ipairs(Players:GetPlayers()) do
        task.spawn(updatePlayerESP, plr)
    end
end

local function stopESPPlayers()
    espPlayersEnabled = false
    espPlayersBtn.Text = "ESP Players: OFF"
    espPlayersBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    clearESPPlayers()
end

-- ====== មុខងារ ESP NPC ======
local NPC_HIGHLIGHT_COLOR = Color3.new(0, 1, 0) -- បៃតង

local function createNPCHighlight(model)
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillColor = NPC_HIGHLIGHT_COLOR
    hl.FillTransparency = 0.5
    hl.OutlineColor = NPC_HIGHLIGHT_COLOR
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
    return hl
end

local function clearESPNPC()
    for _, hl in ipairs(espNPCHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espNPCHighlights = {}
end

local function refreshESPNPC()
    -- លុបទាំងអស់មុនធ្វើថ្មី
    clearESPNPC()
    if not espNPCEnabled then return end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant ~= player.Character then
            -- ត្រូវមាន Humanoid និង HumanoidRootPart ដើម្បីជា NPC
            local humanoid = descendant:FindFirstChildOfClass("Humanoid")
            local rootPart = descendant:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart then
                -- មិនមែនជាអ្នកលេង (ពិនិត្យថាមិនមាន Player ជាមេ)
                local isPlayerCharacter = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character == descendant then
                        isPlayerCharacter = true
                        break
                    end
                end
                if not isPlayerCharacter then
                    local hl = createNPCHighlight(descendant)
                    table.insert(espNPCHighlights, hl)
                end
            end
        end
    end
end

local function startESPNPC()
    espNPCEnabled = true
    espNPCBtn.Text = "ESP NPCs: ON"
    espNPCBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    refreshESPNPC()
end

local function stopESPNPC()
    espNPCEnabled = false
    espNPCBtn.Text = "ESP NPCs: OFF"
    espNPCBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    clearESPNPC()
end

-- ====== ភ្ជាប់ការធ្វើបច្ចុប្បន្នភាព ======
local function cleanupConnections()
    for _, conn in ipairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
end

local function startAllESP()
    cleanupConnections()

    -- ធ្វើបច្ចុប្បន្នភាពអ្នកលេង
    local connPlayerAdded = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if espPlayersEnabled then updatePlayerESP(plr) end
        end)
    end)
    table.insert(espConnections, connPlayerAdded)

    -- Heartbeat សម្រាប់អ្នកលេង (ធ្វើបច្ចុប្បន្នភាពគ្រប់ស៊ុម)
    local connHeartPlayers = RunService.Heartbeat:Connect(function()
        if espPlayersEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then updatePlayerESP(plr) end
            end
        end
        if espNPCEnabled then
            refreshESPNPC()
        end
    end)
    table.insert(espConnections, connHeartPlayers)

    -- ផ្ទុកដំបូង
    if espPlayersEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            task.spawn(updatePlayerESP, plr)
        end
    end
    if espNPCEnabled then
        refreshESPNPC()
    end
end

-- ====== ព្រឹត្តិការណ៍ប៊ូតុង ======
espPlayersBtn.MouseButton1Down:Connect(function()
    if espPlayersEnabled then
        stopESPPlayers()
    else
        startESPPlayers()
    end
    startAllESP() -- ចាប់ផ្ដើមការតាមដានឡើងវិញ
    statusLabel.Text = "ESP Players: " .. (espPlayersEnabled and "ON" or "OFF") .. " | ESP NPCs: " .. (espNPCEnabled and "ON" or "OFF")
end)

espNPCBtn.MouseButton1Down:Connect(function()
    if espNPCEnabled then
        stopESPNPC()
    else
        startESPNPC()
    end
    startAllESP()
    statusLabel.Text = "ESP Players: " .. (espPlayersEnabled and "ON" or "OFF") .. " | ESP NPCs: " .. (espNPCEnabled and "ON" or "OFF")
end)

toggleBtn.MouseButton1Down:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Down:Connect(function()
    stopESPPlayers()
    stopESPNPC()
    cleanupConnections()
    gui:Destroy()
end)

makeDraggable(mainFrame)

-- ====== RGB ======
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.03) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = Color3.fromHSV(hue, 1, 1)
        toggleStroke.Color = Color3.fromHSV((hue + 0.3) % 1, 1, 1)
        espPlayersStroke.Color = Color3.fromHSV((hue + 0.6) % 1, 1, 1)
        espNPCStroke.Color = Color3.fromHSV((hue + 0.9) % 1, 1, 1)
        task.wait(0.04)
    end
end)

-- ====== រូបភាព ======
local function setupImage(asset)
    if asset and asset ~= "" then
        toggleBtn.Image = asset
        bg.Image = asset
    end
end

local ok, response = pcall(function() return request({Url = IMAGE_URL, Method = "GET"}) end)
if ok and response and response.StatusCode == 200 then
    writefile(FILE_NAME, response.Body)
    setupImage(getcustomasset(FILE_NAME))
else
    setupImage("")
end

-- ====== សម្អាតពេលស្លាប់ ======
player.CharacterAdded:Connect(function()
    if espPlayersEnabled then
        clearESPPlayers()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then task.spawn(updatePlayerESP, plr) end
        end
    end
    if espNPCEnabled then
        refreshESPNPC()
    end
end)

-- ចាប់ផ្ដើមដំបូង បើមុខងារណាមួយត្រូវបានបើក (នៅទីនេះមិនទាន់បើក ទុកឲ្យអ្នកប្រើចុច)