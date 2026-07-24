--========================================================
-- EVADE: SPIRAL FARM (STOP & WAIT, NO STICK)
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

--============== ជំនួយ GUI ==============
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

-- រក Bubble ទាំងអស់ គ្មានកំណត់ចម្ងាយ
local function getBubbles()
    local bubbles = {}
    for _, obj in Workspace:GetDescendants() do
        local name = obj.Name:lower()
        if obj:IsA("Model") and (name:find("bubble") or name:find("token")) then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(bubbles, part) end
        elseif obj:IsA("BasePart") and (name:find("bubble") or name:find("token")) then
            table.insert(bubbles, obj)
        end
    end
    return bubbles
end

-- ហោះរលូន (ដូចដើម)
local function fly(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local startPos = root.Position
    local distance = (startPos - pos).Magnitude
    if distance < 3 then return end
    local steps = math.ceil(distance / 10 + 2)
    for t = 0, 1, 1 / steps do
        root.CFrame = CFrame.new(startPos:Lerp(pos, t))
        task.wait(0.02)
    end
    root.CFrame = CFrame.new(pos)
end

--============== GUI (មានរូបភាព) ==============
local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("EvadeFarm") then
        CoreGui:FindFirstChild("EvadeFarm"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "EvadeFarm"
    gui.IgnoreGuiInset = true

    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Draggable = true
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 420, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundTransparency = 1
    title.Text = "🌀 BUBBLE SPIRAL "
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Color3.new(1,1,1)

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0,35,0,35)
    closeBtn.Position = UDim2.new(1,-45,0,10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)

    local autoLoopBtn = Instance.new("TextButton", mainFrame)
    autoLoopBtn.Size = UDim2.new(1, -40, 0, 45)
    autoLoopBtn.Position = UDim2.new(0, 20, 0, 70)
    autoLoopBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    autoLoopBtn.Text = "🔥 បើកការប្រមូល Bubble"
    autoLoopBtn.TextColor3 = Color3.new(1,1,1)
    autoLoopBtn.Font = Enum.Font.GothamBold
    autoLoopBtn.TextSize = 13
    Instance.new("UICorner", autoLoopBtn).CornerRadius = UDim.new(0, 10)

    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 30)
    hintLabel.Position = UDim2.new(0, 20, 0, 130)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព៖ ត្រៀមរួចរាល់"
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12

    -- RGB effect
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

    --============== អថេរ ==============
    local isLooping = false
    local safeHeight = 80
    local radius = 20
    local angle = 0

    --============== ហោះវង់ + ឈប់នៅ Bubble ==============
    local function toggleAutoLoop()
        isLooping = not isLooping
        if isLooping then
            autoLoopBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 30)
            autoLoopBtn.Text = "⏹️ ឈប់"

            task.spawn(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                while isLooping do
                    -- ហោះវង់
                    local rad = math.rad(angle)
                    local x = math.cos(rad) * radius
                    local z = math.sin(rad) * radius
                    local spiralTarget = Vector3.new(x, safeHeight, z)

                    hintLabel.Text = "🌀 ហោះល្បាត..."
                    hintLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                    fly(spiralTarget)

                    -- រក Bubble ទាំងអស់
                    local allBubbles = getBubbles()
                    if #allBubbles > 0 then
                        hintLabel.Text = "🎯 ប្រមូល " .. #allBubbles .. " Bubble..."
                        hintLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                        for _, b in allBubbles do
                            if not isLooping then break end
                            if b and b.Parent then
                                -- ហោះទៅជិត Bubble (3 studs ពីលើ)
                                fly(b.Position + Vector3.new(0, 3, 0))
                                -- ឈប់នៅទីនេះ រង់ចាំឲ្យ Bubble បាត់ (ប្រមូលបាន)
                                while b.Parent and isLooping do
                                    task.wait(0.2)
                                end
                            end
                        end
                        hintLabel.Text = "✅ ប្រមូលរួច"
                        hintLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end

                    angle = (angle + 25) % 360
                    radius = radius + 15
                    if radius > 150 then
                        radius = 20
                    end
                    task.wait(0.1)
                end
            end)
        else
            autoLoopBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            autoLoopBtn.Text = "🔥 បើកការប្រមូល Bubble"
            hintLabel.Text = "ស្ថានភាព៖ បានបញ្ឈប់"
            hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    autoLoopBtn.MouseButton1Down:Connect(toggleAutoLoop)
    closeBtn.MouseButton1Down:Connect(function() gui:Destroy() end)
    toggleBtn.MouseButton1Down:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    makeDraggable(mainFrame)
end

--============== ទាញយករូបភាព ==============
local function loadImageAndStart()
    local ok, response = pcall(function() return request({Url=IMAGE_URL, Method="GET"}) end)
    if ok and response and response.StatusCode == 200 then
        writefile(FILE_NAME, response.Body)
        createGUI(getcustomasset(FILE_NAME))
    else
        createGUI("")
    end
end

loadImageAndStart()