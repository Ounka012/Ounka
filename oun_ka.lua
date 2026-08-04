--// NPC ESP GUI
--// GUI + Background Image + NPC ESP + Infinite Jump

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"

local CONFIG = {
    ESP = true,
    ShowName = true,
    ShowHealth = true,
    ShowDistance = true,
    HideDead = true,
    ESPRange = 250,

    InfiniteJump = false,

    Accent = Color3.fromRGB(220,150,200)
}

local ESP = {}

--==================================================
-- GUI
--==================================================

local old = PlayerGui:FindFirstChild("NPC_ESP_GUI")
if old then
    old:Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "NPC_ESP_GUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = PlayerGui

--==================================================
-- TOGGLE BUTTON
--==================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(55,55)
Toggle.Position = UDim2.new(0,20,0.5,-27)
Toggle.BackgroundColor3 = Color3.fromRGB(25,25,30)
Toggle.Text = "☠"
Toggle.TextSize = 25
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Parent = GUI

Instance.new("UICorner",Toggle).CornerRadius = UDim.new(1,0)

local ToggleStroke = Instance.new("UIStroke",Toggle)
ToggleStroke.Thickness = 2
ToggleStroke.Color = CONFIG.Accent

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(360,430)
Main.Position = UDim2.new(0.5,-180,0.5,-215)
Main.BackgroundColor3 = Color3.fromRGB(18,18,23)
Main.Visible = false
Main.Parent = GUI

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Thickness = 2
Stroke.Color = CONFIG.Accent

--==================================================
-- BACKGROUND IMAGE
--==================================================

local BG = Instance.new("ImageLabel")
BG.Size = UDim2.fromScale(1,1)
BG.BackgroundTransparency = 1
BG.Image = IMAGE_URL
BG.ImageTransparency = 0.72
BG.ScaleType = Enum.ScaleType.Crop
BG.Parent = Main

Instance.new("UICorner",BG).CornerRadius = UDim.new(0,12)

--==================================================
-- OVERLAY
--==================================================

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.fromScale(1,1)
Overlay.BackgroundColor3 = Color3.fromRGB(10,10,15)
Overlay.BackgroundTransparency = 0.2
Overlay.BorderSizePixel = 0
Overlay.Parent = Main

Instance.new("UICorner",Overlay).CornerRadius = UDim.new(0,12)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-60,0,45)
Title.Position = UDim2.fromOffset(15,5)
Title.BackgroundTransparency = 1
Title.Text = "☠ NPC ESP HUB"
Title.TextColor3 = CONFIG.Accent
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35,35)
Close.Position = UDim2.new(1,-45,0,8)
Close.BackgroundColor3 = Color3.fromRGB(220,60,70)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Main

Instance.new("UICorner",Close).CornerRadius = UDim.new(0,8)

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1,-20,1,-65)
Content.Position = UDim2.fromOffset(10,55)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.Parent = Main

local Layout = Instance.new("UIListLayout",Content)
Layout.Padding = UDim.new(0,7)

--==================================================
-- TOGGLE FUNCTION
--==================================================

local function AddToggle(text,key)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-5,0,45)
    Button.BackgroundColor3 =
        CONFIG[key] and CONFIG.Accent or Color3.fromRGB(45,45,52)

    Button.Text = text .. " : " .. (CONFIG[key] and "ON" or "OFF")
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Content

    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,8)

    Button.MouseButton1Click:Connect(function()

        CONFIG[key] = not CONFIG[key]

        Button.Text =
            text .. " : " .. (CONFIG[key] and "ON" or "OFF")

        TweenService:Create(
            Button,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 =
                    CONFIG[key]
                    and CONFIG.Accent
                    or Color3.fromRGB(45,45,52)
            }
        ):Play()

    end)

end

--==================================================
-- RANGE BOX
--==================================================

local RangeBox = Instance.new("TextBox")
RangeBox.Size = UDim2.new(1,-5,0,42)
RangeBox.BackgroundColor3 = Color3.fromRGB(40,40,48)
RangeBox.TextColor3 = Color3.new(1,1,1)
RangeBox.PlaceholderText = "ESP Range"
RangeBox.Text = tostring(CONFIG.ESPRange)
RangeBox.Font = Enum.Font.Gotham
RangeBox.TextSize = 12
RangeBox.ClearTextOnFocus = false
RangeBox.Parent = Content

Instance.new("UICorner",RangeBox).CornerRadius = UDim.new(0,8)

RangeBox.FocusLost:Connect(function()

    local n = tonumber(RangeBox.Text)

    if n then
        CONFIG.ESPRange = math.clamp(n,10,2000)
        RangeBox.Text = tostring(CONFIG.ESPRange)
    else
        RangeBox.Text = tostring(CONFIG.ESPRange)
    end

end)

--==================================================
-- BUTTONS
--==================================================

AddToggle("👁 NPC ESP","ESP")
AddToggle("🏷 Show Name","ShowName")
AddToggle("❤️ Show Health","ShowHealth")
AddToggle("📍 Show Distance","ShowDistance")
AddToggle("💀 Hide Dead","HideDead")
AddToggle("♾ Infinite Jump","InfiniteJump")

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false

    end

end)

--==================================================
-- OPEN / CLOSE
--==================================================

Toggle.MouseButton1Click:Connect(function()

    Main.Visible = not Main.Visible

end)

Close.MouseButton1Click:Connect(function()

    Main.Visible = false

end)

--==================================================
-- NPC CHECK
--==================================================

local function IsPlayerCharacter(model)

    for _,player in ipairs(Players:GetPlayers()) do

        if player.Character == model then
            return true
        end

    end

    return false

end

local function GetRoot(model)

    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")

end

local function IsNPC(model)

    if not model:IsA("Model") then
        return false
    end

    if IsPlayerCharacter(model) then
        return false
    end

    local Hum = model:FindFirstChildOfClass("Humanoid")
    local Root = GetRoot(model)

    return Hum ~= nil and Root ~= nil

end

--==================================================
-- CREATE ESP
--==================================================

local function CreateESP(NPC)

    if ESP[NPC] then
        return
    end

    if not IsNPC(NPC) then
        return
    end

    local Hum = NPC:FindFirstChildOfClass("Humanoid")
    local Root = GetRoot(NPC)

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "NPC_ESP"
    Billboard.Adornee = Root
    Billboard.Size = UDim2.fromOffset(180,55)
    Billboard.StudsOffset = Vector3.new(0,3,0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false
    Billboard.Parent = GUI

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1,0,0,20)
    Name.BackgroundTransparency = 1
    Name.TextColor3 = Color3.new(1,1,1)
    Name.TextStrokeTransparency = 0
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 12
    Name.Parent = Billboard

    local Health = Instance.new("TextLabel")
    Health.Size = UDim2.new(1,0,0,18)
    Health.Position = UDim2.fromOffset(0,20)
    Health.BackgroundTransparency = 1
    Health.TextColor3 = Color3.fromRGB(100,255,120)
    Health.TextStrokeTransparency = 0
    Health.Font = Enum.Font.Gotham
    Health.TextSize = 10
    Health.Parent = Billboard

    local Distance = Instance.new("TextLabel")
    Distance.Size = UDim2.new(1,0,0,17)
    Distance.Position = UDim2.fromOffset(0,38)
    Distance.BackgroundTransparency = 1
    Distance.TextColor3 = Color3.fromRGB(210,210,220)
    Distance.TextStrokeTransparency = 0
    Distance.Font = Enum.Font.Gotham
    Distance.TextSize = 9
    Distance.Parent = Billboard

    ESP[NPC] = {
        Billboard = Billboard,
        Name = Name,
        Health = Health,
        Distance = Distance,
        Humanoid = Hum,
        Root = Root
    }

end

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(NPC)

    local Data = ESP[NPC]

    if not Data then
        return
    end

    if Data.Billboard then
        Data.Billboard:Destroy()
    end

    ESP[NPC] = nil

end

--==================================================
-- SCAN NPC
--==================================================

local function Scan()

    for _,obj in ipairs(Workspace:GetDescendants()) do

        if obj:IsA("Model") and IsNPC(obj) then
            CreateESP(obj)
        end

    end

end

Scan()

Workspace.DescendantAdded:Connect(function(obj)

    task.wait(0.1)

    if obj:IsA("Model") and IsNPC(obj) then
        CreateESP(obj)
    end

end)

--==================================================
-- ESP UPDATE
--==================================================

RunService.RenderStepped:Connect(function()

    local Character = LP.Character
    local MyRoot = Character and GetRoot(Character)

    if not MyRoot then
        return
    end

    for NPC,Data in pairs(ESP) do

        if not NPC.Parent then

            RemoveESP(NPC)

        else

            local Hum = Data.Humanoid
            local Root = Data.Root

            if not Hum or not Root then

                RemoveESP(NPC)

            else

                local Distance =
                    (MyRoot.Position - Root.Position).Magnitude

                local Alive = Hum.Health > 0

                local Show =
                    CONFIG.ESP
                    and Distance <= CONFIG.ESPRange

                if CONFIG.HideDead and not Alive then
                    Show = false
                end

                Data.Billboard.Enabled = Show

                if Show then

                    Data.Name.Visible = CONFIG.ShowName
                    Data.Health.Visible = CONFIG.ShowHealth
                    Data.Distance.Visible = CONFIG.ShowDistance

                    Data.Name.Text = NPC.Name

                    Data.Health.Text =
                        string.format(
                            "HP: %.0f / %.0f",
                            Hum.Health,
                            Hum.MaxHealth
                        )

                    Data.Distance.Text =
                        string.format(
                            "%.0f studs",
                            Distance
                        )

                end

            end

        end

    end

end)

--==================================================
-- INFINITE JUMP
--==================================================

UIS.JumpRequest:Connect(function()

    if not CONFIG.InfiniteJump then
        return
    end

    local Character = LP.Character

    if not Character then
        return
    end

    local Hum = Character:FindFirstChildOfClass("Humanoid")

    if Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

end)

--==================================================
-- DONE
--==================================================

print("NPC ESP GUI Loaded")