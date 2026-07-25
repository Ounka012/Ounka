--[[
    VIP TEAM ESP - បែងចែកក្រុមតាម Team Color
--]]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ====== រូបភាព ======
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

-- ====== អថេរ ======
local espEnabled = false
local espHighlights = {}
local espConnections = {}

-- ====== លុប GUI ចាស់ ======
if CoreGui:FindFirstChild("VIP_TEAM_ESP") then
    CoreGui:FindFirstChild("VIP_TEAM_ESP"):Destroy()
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
gui.Name = "VIP_TEAM_ESP"
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

-- Main Frame
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 420, 0, 250)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 3

-- រូបភាពផ្ទៃខាងក្រោយ
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
title.Text = "👑 VIP TEAM ESP (បែងចែកក្រុម)"
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

-- ប៊ូតុង ESP
local espBtn = Instance.new("TextButton", mainFrame)
espBtn.Size = UDim2.new(1, -40, 0, 45)
espBtn.Position = UDim2.new(0, 20, 0, 70)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
espBtn.Text = "ESP VIP: OFF"
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 16
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 10)
local espStroke = Instance.new("UIStroke", espBtn)
espStroke.Thickness = 2
espStroke.Color = Color3.fromRGB(255, 215, 0) -- មាស VIP

-- ស្លាក
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ស្ថានភាព៖ រង់ចាំ..."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13

-- ====== ESP តាម Team ======
local function getTeamColor(plr)
    if plr.Team then
        return plr.Team.TeamColor.Color
    else
        return Color3.new(1, 1, 1) -- សសម្រាប់គ្មានក្រុម
    end
end

local function createHighlight(character, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    return highlight
end

local function clearESP()
    for _, hl in ipairs(espHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espHighlights = {}
    for _, conn in ipairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
end

local function updateESPForPlayer(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end

    -- លុប Highlight ចាស់
    for i = #espHighlights, 1, -1 do
        if espHighlights[i] and espHighlights[i].Adornee == char then
            espHighlights[i]:Destroy()
            table.remove(espHighlights, i)
        end
    end

    local teamColor = getTeamColor(plr)
    local hl = createHighlight(char, teamColor)
    table.insert(espHighlights, hl)
end

local function startESP()
    clearESP()
    espEnabled = true
    espBtn.Text = "ESP VIP: ON"
    espBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Text = "ស្ថានភាព៖ ESP បែងចែកក្រុមដំណើរការ"

    for _, plr in ipairs(Players:GetPlayers()) do
        task.spawn(updateESPForPlayer, plr)
    end

    local connAdded = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if espEnabled then updateESPForPlayer(plr) end
        end)
    end)
    table.insert(espConnections, connAdded)

    local connHeart = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then updateESPForPlayer(plr) end
        end
    end)
    table.insert(espConnections, connHeart)
end

local function stopESP()
    espEnabled = false
    espBtn.Text = "ESP VIP: OFF"
    espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    clearESP()
    statusLabel.Text = "ស្ថានភាព៖ ESP បិទ"
end

-- ====== Events ======
espBtn.MouseButton1Down:Connect(function()
    if espEnabled then stopESP() else startESP() end
end)

toggleBtn.MouseButton1Down:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Down:Connect(function()
    stopESP()
    gui:Destroy()
end)

makeDraggable(mainFrame)

-- RGB
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.03) % 1
        title.TextColor3 = Color3.fromHSV(hue, 1, 1)
        mainStroke.Color = Color3.fromHSV(hue, 1, 1)
        toggleStroke.Color = Color3.fromHSV((hue + 0.3) % 1, 1, 1)
        espStroke.Color = Color3.fromHSV((hue + 0.6) % 1, 1, 1)
        task.wait(0.04)
    end
end)

-- ផ្ទុករូបភាព
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

player.CharacterAdded:Connect(function()
    if espEnabled then
        clearESP()
        startESP()
    end
end)