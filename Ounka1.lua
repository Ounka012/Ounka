--========================================================
-- Standard UI Template with Custom Background
--========================================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "bg.jpg"

-- Helper: Draggable UI
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

local function createGUI(imageAsset)
    if CoreGui:FindFirstChild("CustomBgGUI") then CoreGui:FindFirstChild("CustomBgGUI"):Destroy() end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "CustomBgGUI"
    gui.IgnoreGuiInset = true

    -- Toggle Button (ជាមួយរូបភាព)
    local toggleBtn = Instance.new("ImageButton", gui)
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBtn.Image = imageAsset or ""
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 50)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    -- Main Frame
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 420, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -110)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 3

    -- Background Image
    local bg = Instance.new("ImageLabel", mainFrame)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = imageAsset or ""
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ImageTransparency = 0.3
    bg.ZIndex = -1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 15)

    -- Title
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "⚡ CONTROL PANEL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
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

    -- Action Button
    local actionBtn = Instance.new("TextButton", mainFrame)
    actionBtn.Size = UDim2.new(1, -40, 0, 45)
    actionBtn.Position = UDim2.new(0, 20, 0, 70)
    actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    actionBtn.Text = "ចុចទីនេះ"
    actionBtn.TextColor3 = Color3.new(1, 1, 1)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 13
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 10)

    -- Status Label
    local hintLabel = Instance.new("TextLabel", mainFrame)
    hintLabel.Size = UDim2.new(1, -40, 0, 30)
    hintLabel.Position = UDim2.new(0, 20, 0, 130)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "ស្ថានភាព៖ រង់ចាំ..."
    hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 12

    -- RGB Effect
    task.spawn(function()
        local hue = 0
        while gui.Parent do
            hue = (hue + 0.03) % 1
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            mainStroke.Color = Color3.fromHSV(hue, 1, 1)
            toggleStroke.Color = Color3.fromHSV((hue + 0.3) % 1, 1, 1)
            task.wait(0.04)
        end
    end)

    toggleBtn.MouseButton1Down:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
    closeBtn.MouseButton1Down:Connect(function() gui:Destroy() end)

    local isActive = false
    actionBtn.MouseButton1Down:Connect(function()
        isActive = not isActive
        if isActive then
            actionBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 30)
            actionBtn.Text = "⏹️ ឈប់"
            hintLabel.Text = "ស្ថានភាព៖ បានបើក"
        else
            actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            actionBtn.Text = "ចុចទីនេះ"
            hintLabel.Text = "ស្ថានភាព៖ បានបិទ"
        end
    end)

    makeDraggable(mainFrame)
end

-- Download and set image asset
local ok, response = pcall(function() return request({Url = IMAGE_URL, Method = "GET"}) end)
if ok and response and response.StatusCode == 200 then
    writefile(FILE_NAME, response.Body)
    createGUI(getcustomasset(FILE_NAME))
else
    createGUI("")
end
