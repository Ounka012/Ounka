--========================================================
-- 💎 VIP PRO FULL UI TEMPLATE | RGB Glow & Custom BG
-- រួមបញ្ចូលមុខងារ "វាយមួយងាប់" (OHK)
--========================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
-- ប្រើ CoreGui បើមាន ឬប្រើ PlayerGui តាមស្តង់ដារ
local ParentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ⚙️ CONFIGURATION
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"
local FILE_NAME = "vip_bg.jpg"
local DEFAULT_ACCENT = Color3.fromRGB(0, 180, 255)

local TWEEN_FAST = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- 🛠️ HELPER: HTTP REQUEST WRAPPER (ដើម្បីឱ្យដំណើរការគ្រប់ executor)
local function fetchImageContent(url)
    local success, response
    if syn and syn.request then
        success, response = pcall(function() return syn.request({Url = url, Method = "GET"}) end)
    elseif request then
        success, response = pcall(function() return request({Url = url, Method = "GET"}) end)
    elseif http_request then
        success, response = pcall(function() return http_request({Url = url, Method = "GET"}) end)
    else
        success, response = pcall(function() return HttpService:GetAsync(url) end)
    end
    return success, response
end

-- 🛠️ HELPER: DRAGGABLE MAIN WINDOW
local function makeDraggable(topBar, mainFrame)
    local dragging, startPos, objPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            objPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            mainFrame.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 🛠️ HELPER: DRAGGABLE TOGGLE BUTTON (Smart Click/Drag)
local function makeToggleDraggable(button, onClickCallback)
    local dragging = false
    local startPos, objPos
    local hasMoved = false

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            startPos = input.Position
            objPos = button.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            button.Position = UDim2.new(objPos.X.Scale, objPos.X.Offset + delta.X, objPos.Y.Scale, objPos.Y.Offset + delta.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not hasMoved then
                onClickCallback()
            end
            dragging = false
        end
    end)
end

-- 🏗️ BUILD VIP INTERFACE
local function buildVIPFullUI(imageAsset)
    if ParentGui:FindFirstChild("VIP_Full_UI") then
        ParentGui.VIP_Full_UI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VIP_Full_UI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = ParentGui

    -- 🔘 FLOATING TOGGLE BUTTON (ជាមួយរូបភាព និង RGB Glow)
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "OpenToggle"
    toggleBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.Image = imageAsset or "rbxassetid://7733960981"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.Parent = screenGui

    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Thickness = 3

    -- 🪟 MAIN CONTAINER (MAIN WINDOW)
    local mainFrame = Instance.new("CanvasGroup")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 480, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainFrame.GroupTransparency = 1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Thickness = 2

    -- 🖼️ BACKGROUND IMAGE (ជាមួយ Overlay)
    local bgImage = Instance.new("ImageLabel", mainFrame)
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = imageAsset or ""
    bgImage.ImageTransparency = 0.4
    bgImage.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 14)

    local overlay = Instance.new("Frame", mainFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    overlay.BackgroundTransparency = 0.4
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 14)

    -- 🌈 ANIMATION RGB GLOW (ធ្វើឱ្យរ៉េបពណ៌លើ Border និង Title)
    local titleLabel = Instance.new("TextLabel")
    task.spawn(function()
        local h = 0
        while screenGui.Parent do
            h = (h + 0.01) % 1
            local rgbColor = Color3.fromHSV(h, 0.85, 1)
            toggleStroke.Color = rgbColor
            mainStroke.Color = rgbColor
            titleLabel.TextColor3 = rgbColor
            task.wait(0.04)
        end
    end)

    -- 🔝 TOP HEADER BAR
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundTransparency = 1
    topBar.Parent = mainFrame

    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ VIP PRO CONTROL PANEL"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- 📑 TAB NAVIGATION SIDEBAR
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, 120, 1, -45)
    sideBar.Position = UDim2.new(0, 0, 0, 45)
    sideBar.BackgroundTransparency = 0.8
    sideBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sideBar.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout", sideBar)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPadding = Instance.new("UIPadding", sideBar)
    tabPadding.PaddingTop = UDim.new(0, 10)

    -- 📦 CONTENT AREA
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -130, 1, -55)
    contentArea.Position = UDim2.new(0, 125, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- 🔄 TAB CONTROLLER SYSTEM
    local tabs = {}
    local function createTab(tabName, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.9, 0, 0, 36)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabBtn.BackgroundTransparency = 0.3
        tabBtn.Text = icon .. " " .. tabName
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 12
        tabBtn.Parent = sideBar
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = DEFAULT_ACCENT
        tabContent.Visible = false
        tabContent.Parent = contentArea

        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.Padding = UDim.new(0, 8)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                TweenService:Create(t.Button, TWEEN_FAST, {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                t.Content.Visible = false
            end
            TweenService:Create(tabBtn, TWEEN_FAST, {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)}):Play()
            tabContent.Visible = true
        end)

        local tabObj = {Button = tabBtn, Content = tabContent}
        table.insert(tabs, tabObj)
        return tabContent
    end

    -- 📄 CREATE TABS
    local homeTab = createTab("Home", "🏠")
    local settingsTab = createTab("Settings", "⚙️")

    -- 🧩 BUTTON COMPONENT
    local function addActionButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 42)
        btn.BackgroundColor3 = DEFAULT_ACCENT
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(40, 200, 40)}):Play()
            task.wait(0.2)
            TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = DEFAULT_ACCENT}):Play()
            if callback then callback() end
        end)
    end

    -- 🌟 ADD COMPONENTS (រួមបញ្ចូលប៊ូតុង OHK)
    addActionButton(homeTab, "🚀 បើកមុខងារពិសេស 1", function()
        print("Feature 1 Clicked!")
    end)

    addActionButton(homeTab, "🔥 បើកមុខងារពិសេស 2", function()
        print("Feature 2 Clicked!")
    end)

    -- 👉 ប៊ូតុង "វាយមួយងាប់" (OHK) ដែលអ្នកបានសុំ
    addActionButton(homeTab, "💀 វាយមួយងាប់ (OHK)", function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return -- ការពារកំហុសប្រសិនបើតួអង្គអ្នកលេងរលាយ
        end
        
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        
        -- ករណីទី 1: ចុចទៅលើតួអង្គផ្ទាល់
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            target.Parent.Humanoid.Health = 0
        else
            -- ករណីទី 2: ស្វែងរកអ្នកលេងដែលនៅជិតខ្លួនបំផុត
            local closestPlayer = nil
            local closestDist = math.huge
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
            -- សម្លាប់អ្នកដែលនៅជិតបំផុត
            if closestPlayer and closestPlayer.Character then
                closestPlayer.Character:FindFirstChild("Humanoid").Health = 0
            end
        end
    end)

    addActionButton(settingsTab, "🔄 Reset UI Position", function()
        mainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
    end)

    -- 🎬 ANIMATION OPEN / CLOSE
    local isOpen = false
    local function toggleWindow()
        isOpen = not isOpen
        mainFrame.Visible = true
        if isOpen then
            TweenService:Create(mainFrame, TWEEN_SMOOTH, {GroupTransparency = 0}):Play()
            TweenService:Create(toggleBtn, TWEEN_SMOOTH, {Rotation = 180}):Play()
        else
            local anim = TweenService:Create(mainFrame, TWEEN_SMOOTH, {GroupTransparency = 1})
            anim:Play()
            TweenService:Create(toggleBtn, TWEEN_SMOOTH, {Rotation = 0}):Play()
            anim.Completed:Wait()
            mainFrame.Visible = false
        end
    end

    -- Default Active First Tab
    tabs[1].Button.BackgroundTransparency = 0
    tabs[1].Button.TextColor3 = Color3.new(1, 1, 1)
    tabs[1].Content.Visible = true

    -- Bind Events
    makeToggleDraggable(toggleBtn, toggleWindow)
    makeDraggable(topBar, mainFrame)
    closeBtn.MouseButton1Click:Connect(toggleWindow)
end

-- 📥 ASSET LOADER (ទាញយករូបភាព Background ជាមួយការការពារកំហុស)
task.spawn(function()
    local asset = ""
    local ok, response = fetchImageContent(IMAGE_URL)
    
    if ok and response then
        local content
        -- ពិនិត្យមើលថាតើ response ជា table (សម្រាប់ syn.request) ឬ string (សម្រាប់ HttpService)
        if type(response) == "table" and response.Body then
            content = response.Body
        elseif type(response) == "string" then
            content = response
        end
        
        if content then
            local writeSuccess, writeErr = pcall(function()
                writefile(FILE_NAME, content)
            end)
            if writeSuccess then
                local assetSuccess, assetPath = pcall(function()
                    return getcustomasset(FILE_NAME)
                end)
                if assetSuccess then
                    asset = assetPath
                end
            end
        end
    end
    
    buildVIPFullUI(asset)
end)