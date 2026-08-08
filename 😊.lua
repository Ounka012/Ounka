-- ==================================================
-- MKRA HUB - UI ONLY
-- Modern UI + Tabs + Mobile + Notifications
-- Success / Warning / Error / Info
-- ==================================================

-- ==================================================
-- SERVICES
-- ==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_IMAGE = "rbxassetid://0"

-- ==================================================
-- SETTINGS
-- ==================================================

local Settings = {
    Fly = false,
    FlySpeed = 120,

    BoostMode = false,
    Noclip = false,

    SpeedBoostMultiplier = 1,
    InfiniteJumpOrig = false,

    NPC_ESP = false,
    NPC_ESP_Name = true,
    NPC_ESP_Health = true,
    NPC_ESP_Distance = true,
    NPC_ESP_HideDead = true,
    NPC_ESP_Range = 200,

    VIPFreezeHold = false,
    VIPFreezeKill = false,

    FullBright = false,
    FOV = 70
}

-- ==================================================
-- SAFE HELPERS
-- ==================================================

local safeNotify = function()
end

local function placeholder(name)
    safeNotify(
        "Unavailable",
        name .. " is not implemented in this UI-only build.",
        3,
        "Warning"
    )
end

local function playBeep()
    -- Optional UI sound hook
end

local function startFly()
    placeholder("Fly")
end

local function stopFly()
end

local function toggleNoclip()
    placeholder("Noclip")
end

local function updateESP()
    placeholder("Player ESP")
end

local function toggleGodMode()
    placeholder("God Mode")
end

local function toggleInstantRespawn()
    placeholder("Instant Respawn")
end

local function toggleAutoF()
    placeholder("Auto F")
end

local function toggleVIPFreezeHold()
    placeholder("VIP Freeze Hold")
end

local function toggleVIPFreezeKill()
    placeholder("VIP Freeze Kill")
end

local function updateWalkSpeed()

    local character = LocalPlayer.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed =
            math.max(
                16,
                16 * Settings.SpeedBoostMultiplier
            )
    end
end

-- ==================================================
-- CREATE UI
-- ==================================================

local function createUI(imageAsset)

    imageAsset = imageAsset or ""

    if CoreGui:FindFirstChild("MKRA_Hub") then
        CoreGui.MKRA_Hub:Destroy()
    end

    local gui = Instance.new("ScreenGui")

    gui.Name = "MKRA_Hub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    -- ==================================================
    -- THEME
    -- ==================================================

    local Theme = {

        Background = Color3.fromRGB(
            12, 12, 18
        ),

        Surface = Color3.fromRGB(
            20, 20, 29
        ),

        Surface2 = Color3.fromRGB(
            27, 27, 38
        ),

        Card = Color3.fromRGB(
            30, 30, 42
        ),

        Text = Color3.fromRGB(
            245, 245, 250
        ),

        SubText = Color3.fromRGB(
            150, 150, 165
        ),

        Accent = Color3.fromRGB(
            220, 150, 200
        ),

        Success = Color3.fromRGB(
            75, 220, 145
        ),

        Warning = Color3.fromRGB(
            255, 190, 70
        ),

        Error = Color3.fromRGB(
            240, 80, 100
        ),

        Info = Color3.fromRGB(
            90, 170, 255
        ),

        Stroke = Color3.fromRGB(
            65, 65, 82
        )
    }

    -- ==================================================
    -- HELPERS
    -- ==================================================

    local function corner(obj, radius)

        local c = Instance.new("UICorner")

        c.CornerRadius =
            UDim.new(
                0,
                radius or 8
            )

        c.Parent = obj

        return c
    end

    local function stroke(
        obj,
        color,
        thickness,
        transparency
    )

        local s = Instance.new("UIStroke")

        s.Color =
            color or Theme.Stroke

        s.Thickness =
            thickness or 1

        s.Transparency =
            transparency or 0

        s.ApplyStrokeMode =
            Enum.ApplyStrokeMode.Border

        s.Parent = obj

        return s
    end

    -- ==================================================
    -- NOTIFICATION SYSTEM
    -- ==================================================

    local NotificationHolder

    local NotificationColors = {
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error,
        Info = Theme.Info
    }

    local NotificationIcons = {
        Success = "✓",
        Warning = "!",
        Error = "×",
        Info = "i"
    }

    local function createNotificationHolder()

        if NotificationHolder
            and NotificationHolder.Parent then

            return NotificationHolder
        end

        NotificationHolder =
            Instance.new("Frame")

        NotificationHolder.Name =
            "NotificationHolder"

        NotificationHolder.AnchorPoint =
            Vector2.new(1, 0)

        NotificationHolder.Position =
            UDim2.new(
                1,
                -16,
                0,
                16
            )

        NotificationHolder.Size =
            UDim2.new(
                0,
                340,
                1,
                -32
            )

        NotificationHolder.BackgroundTransparency =
            1

        NotificationHolder.ZIndex = 1000
        NotificationHolder.Parent = gui

        local layout =
            Instance.new("UIListLayout")

        layout.Padding =
            UDim.new(0, 8)

        layout.HorizontalAlignment =
            Enum.HorizontalAlignment.Right

        layout.VerticalAlignment =
            Enum.VerticalAlignment.Top

        layout.SortOrder =
            Enum.SortOrder.LayoutOrder

        layout.Parent =
            NotificationHolder

        return NotificationHolder
    end

    local function notify(
        titleText,
        messageText,
        duration,
        notificationType
    )

        notificationType =
            notificationType or "Info"

        duration =
            tonumber(duration) or 3

        if not NotificationColors[
            notificationType
        ] then

            notificationType = "Info"
        end

        local color =
            NotificationColors[
                notificationType
            ]

        local iconText =
            NotificationIcons[
                notificationType
            ]

        local holder =
            createNotificationHolder()

        local card =
            Instance.new("CanvasGroup")

        card.Name =
            "Notification"

        card.Size =
            UDim2.new(
                1,
                0,
                0,
                78
            )

        card.BackgroundColor3 =
            Theme.Surface

        card.BackgroundTransparency =
            0.03

        card.BorderSizePixel = 0

        card.GroupTransparency = 1

        card.ClipsDescendants = true

        card.LayoutOrder =
            -math.floor(
                os.clock() * 1000
            )

        card.ZIndex = 1001
        card.Parent = holder

        corner(card, 14)

        stroke(
            card,
            color,
            1,
            0.35
        )

        -- Accent bar

        local accent =
            Instance.new("Frame")

        accent.Size =
            UDim2.new(
                0,
                4,
                1,
                0
            )

        accent.BackgroundColor3 =
            color

        accent.BorderSizePixel = 0

        accent.ZIndex = 1002
        accent.Parent = card

        corner(accent, 8)

        -- Icon

        local iconBox =
            Instance.new("Frame")

        iconBox.Size =
            UDim2.fromOffset(
                38,
                38
            )

        iconBox.Position =
            UDim2.fromOffset(
                12,
                13
            )

        iconBox.BackgroundColor3 =
            color

        iconBox.BackgroundTransparency =
            0.82

        iconBox.BorderSizePixel = 0

        iconBox.ZIndex = 1003
        iconBox.Parent = card

        corner(iconBox, 12)

        stroke(
            iconBox,
            color,
            1,
            0.5
        )

        local icon =
            Instance.new("TextLabel")

        icon.Size =
            UDim2.fromScale(
                1,
                1
            )

        icon.BackgroundTransparency = 1

        icon.Text =
            iconText

        icon.TextColor3 =
            color

        icon.Font =
            Enum.Font.GothamBold

        icon.TextSize = 18

        icon.ZIndex = 1004
        icon.Parent = iconBox

        -- Title

        local title =
            Instance.new("TextLabel")

        title.Size =
            UDim2.new(
                1,
                -105,
                0,
                22
            )

        title.Position =
            UDim2.fromOffset(
                60,
                9
            )

        title.BackgroundTransparency = 1

        title.Text =
            tostring(titleText)

        title.TextColor3 =
            Theme.Text

        title.Font =
            Enum.Font.GothamBold

        title.TextSize = 11

        title.TextXAlignment =
            Enum.TextXAlignment.Left

        title.ZIndex = 1004
        title.Parent = card

        -- Message

        local message =
            Instance.new("TextLabel")

        message.Size =
            UDim2.new(
                1,
                -105,
                0,
                28
            )

        message.Position =
            UDim2.fromOffset(
                60,
                31
            )

        message.BackgroundTransparency = 1

        message.Text =
            tostring(messageText)

        message.TextColor3 =
            Theme.SubText

        message.Font =
            Enum.Font.GothamMedium

        message.TextSize = 9

        message.TextWrapped = true

        message.TextXAlignment =
            Enum.TextXAlignment.Left

        message.TextYAlignment =
            Enum.TextYAlignment.Top

        message.ZIndex = 1004
        message.Parent = card

        -- Close button

        local close =
            Instance.new("TextButton")

        close.Size =
            UDim2.fromOffset(
                25,
                25
            )

        close.Position =
            UDim2.new(
                1,
                -31,
                0,
                7
            )

        close.BackgroundTransparency = 1

        close.Text = "×"

        close.TextColor3 =
            Theme.SubText

        close.Font =
            Enum.Font.GothamBold

        close.TextSize = 17

        close.AutoButtonColor = false

        close.ZIndex = 1005
        close.Parent = card

        close.MouseEnter:Connect(
            function()

                close.TextColor3 =
                    color
            end
        )

        close.MouseLeave:Connect(
            function()

                close.TextColor3 =
                    Theme.SubText
            end
        )

        -- Progress background

        local progressBG =
            Instance.new("Frame")

        progressBG.Size =
            UDim2.new(
                1,
                -20,
                0,
                3
            )

        progressBG.Position =
            UDim2.new(
                0,
                10,
                1,
                -7
            )

        progressBG.BackgroundColor3 =
            Theme.Surface2

        progressBG.BorderSizePixel = 0

        progressBG.ZIndex = 1006
        progressBG.Parent = card

        corner(progressBG, 99)

        local progress =
            Instance.new("Frame")

        progress.Size =
            UDim2.fromScale(
                1,
                1
            )

        progress.BackgroundColor3 =
            color

        progress.BorderSizePixel = 0

        progress.ZIndex = 1007
        progress.Parent = progressBG

        corner(progress, 99)

        local removed = false

        local function remove()

            if removed then
                return
            end

            removed = true

            local tween =
                TweenService:Create(
                    card,
                    TweenInfo.new(
                        0.22,
                        Enum.EasingStyle.Quint,
                        Enum.EasingDirection.In
                    ),
                    {
                        GroupTransparency = 1
                    }
                )

            tween:Play()

            tween.Completed:Connect(
                function()

                    if card
                        and card.Parent then

                        card:Destroy()
                    end
                end
            )
        end

        close.MouseButton1Click:Connect(
            remove
        )

        TweenService:Create(
            card,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                GroupTransparency = 0
            }
        ):Play()

        TweenService:Create(
            progress,
            TweenInfo.new(
                duration,
                Enum.EasingStyle.Linear
            ),
            {
                Size =
                    UDim2.new(
                        0,
                        0,
                        1,
                        0
                    )
            }
        ):Play()

        task.delay(
            duration,
            function()

                if card
                    and card.Parent then

                    remove()
                end
            end
        )

        return card
    end

    safeNotify = notify

    -- ==================================================
    -- FLOATING BUTTON
    -- ==================================================

    local toggleBtn =
        Instance.new("ImageButton")

    toggleBtn.Name =
        "ToggleButton"

    toggleBtn.Size =
        UDim2.fromOffset(
            52,
            52
        )

    toggleBtn.Position =
        UDim2.new(
            0,
            18,
            0.5,
            -26
        )

    toggleBtn.BackgroundColor3 =
        Theme.Surface

    toggleBtn.Image =
        imageAsset ~= ""
        and imageAsset
        or DEFAULT_IMAGE

    toggleBtn.ScaleType =
        Enum.ScaleType.Crop

    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = gui

    corner(toggleBtn, 16)

    local toggleStroke =
        stroke(
            toggleBtn,
            Theme.Accent,
            2
        )

    -- ==================================================
    -- MAIN WINDOW
    -- ==================================================

    local main =
        Instance.new("CanvasGroup")

    main.Name = "Main"

    main.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    main.Size =
        UDim2.fromOffset(
            440,
            520
        )

    main.Position =
        UDim2.fromScale(
            0.5,
            0.5
        )

    main.BackgroundColor3 =
        Theme.Background

    main.BorderSizePixel = 0

    main.GroupTransparency = 1

    main.Visible = false
    main.Active = true
    main.ClipsDescendants = true

    main.Parent = gui

    corner(main, 18)

    local mainStroke =
        stroke(
            main,
            Theme.Stroke,
            1,
            0.15
        )

    -- ==================================================
    -- BACKGROUND
    -- ==================================================

    local bg =
        Instance.new("Frame")

    bg.Size =
        UDim2.fromScale(
            1,
            1
        )

    bg.BackgroundColor3 =
        Theme.Background

    bg.BorderSizePixel = 0
    bg.ZIndex = 0
    bg.Parent = main

    corner(bg, 18)

    local bgGradient =
        Instance.new("UIGradient")

    bgGradient.Rotation = 135

    bgGradient.Color =
        ColorSequence.new({

            ColorSequenceKeypoint.new(
                0,
                Color3.fromRGB(
                    40,
                    25,
                    45
                )
            ),

            ColorSequenceKeypoint.new(
                0.45,
                Color3.fromRGB(
                    12,
                    12,
                    18
                )
            ),

            ColorSequenceKeypoint.new(
                1,
                Color3.fromRGB(
                    18,
                    20,
                    35
                )
            )
        })

    bgGradient.Parent = bg

    -- ==================================================
    -- HEADER
    -- ==================================================

    local header =
        Instance.new("Frame")

    header.Size =
        UDim2.new(
            1,
            -24,
            0,
            62
        )

    header.Position =
        UDim2.fromOffset(
            12,
            10
        )

    header.BackgroundColor3 =
        Theme.Surface

    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = main

    corner(header, 14)

    stroke(
        header,
        Theme.Stroke,
        1,
        0.45
    )

    local headerIcon =
        Instance.new("ImageLabel")

    headerIcon.Size =
        UDim2.fromOffset(
            42,
            42
        )

    headerIcon.Position =
        UDim2.fromOffset(
            10,
            10
        )

    headerIcon.BackgroundColor3 =
        Theme.Card

    headerIcon.Image =
        imageAsset ~= ""
        and imageAsset
        or DEFAULT_IMAGE

    headerIcon.ScaleType =
        Enum.ScaleType.Crop

    headerIcon.ZIndex = 11
    headerIcon.Parent = header

    corner(headerIcon, 12)

    local iconStroke =
        stroke(
            headerIcon,
            Theme.Accent,
            1.5
        )

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(
            1,
            -115,
            0,
            25
        )

    title.Position =
        UDim2.fromOffset(
            62,
            7
        )

    title.BackgroundTransparency = 1

    title.Text =
        "MKRA HUB"

    title.TextColor3 =
        Theme.Text

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 18

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex = 11
    title.Parent = header

    local subtitle =
        Instance.new("TextLabel")

    subtitle.Size =
        UDim2.new(
            1,
            -115,
            0,
            20
        )

    subtitle.Position =
        UDim2.fromOffset(
            63,
            32
        )

    subtitle.BackgroundTransparency = 1

    subtitle.Text =
        "UI ONLY  •  v4.2  •  MOBILE READY"

    subtitle.TextColor3 =
        Theme.SubText

    subtitle.Font =
        Enum.Font.GothamMedium

    subtitle.TextSize = 9

    subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    subtitle.ZIndex = 11
    subtitle.Parent = header

    local minimizeBtn =
        Instance.new("TextButton")

    minimizeBtn.Size =
        UDim2.fromOffset(
            34,
            34
        )

    minimizeBtn.Position =
        UDim2.new(
            1,
            -44,
            0,
            14
        )

    minimizeBtn.BackgroundColor3 =
        Theme.Card

    minimizeBtn.Text = "—"

    minimizeBtn.TextColor3 =
        Theme.Text

    minimizeBtn.Font =
        Enum.Font.GothamBold

    minimizeBtn.TextSize = 16

    minimizeBtn.AutoButtonColor = false

    minimizeBtn.ZIndex = 12
    minimizeBtn.Parent = header

    corner(minimizeBtn, 10)

    stroke(
        minimizeBtn,
        Theme.Stroke,
        1
    )

    -- ==================================================
    -- STATUS
    -- ==================================================

    local status =
        Instance.new("Frame")

    status.Size =
        UDim2.new(
            1,
            -24,
            0,
            28
        )

    status.Position =
        UDim2.fromOffset(
            12,
            78
        )

    status.BackgroundColor3 =
        Theme.Surface

    status.BorderSizePixel = 0
    status.ZIndex = 10
    status.Parent = main

    corner(status, 9)

    local statusDot =
        Instance.new("Frame")

    statusDot.Size =
        UDim2.fromOffset(
            7,
            7
        )

    statusDot.Position =
        UDim2.fromOffset(
            11,
            10
        )

    statusDot.BackgroundColor3 =
        Theme.Success

    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 11
    statusDot.Parent = status

    corner(statusDot, 99)

    local statusText =
        Instance.new("TextLabel")

    statusText.Size =
        UDim2.new(
            1,
            -30,
            1,
            0
        )

    statusText.Position =
        UDim2.fromOffset(
            26,
            0
        )

    statusText.BackgroundTransparency = 1

    statusText.Text =
        "SYSTEM READY  •  UI ONLY"

    statusText.TextColor3 =
        Theme.SubText

    statusText.Font =
        Enum.Font.GothamMedium

    statusText.TextSize = 9

    statusText.TextXAlignment =
        Enum.TextXAlignment.Left

    statusText.ZIndex = 11
    statusText.Parent = status

    -- ==================================================
    -- BODY
    -- ==================================================

    local body =
        Instance.new("Frame")

    body.Size =
        UDim2.new(
            1,
            -24,
            1,
            -120
        )

    body.Position =
        UDim2.fromOffset(
            12,
            112
        )

    body.BackgroundTransparency = 1
    body.Parent = main

    -- ==================================================
    -- SIDEBAR
    -- ==================================================

    local sidebar =
        Instance.new("Frame")

    sidebar.Size =
        UDim2.fromOffset(
            96,
            1
        )

    sidebar.BackgroundColor3 =
        Theme.Surface

    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 10
    sidebar.Parent = body

    corner(sidebar, 14)

    stroke(
        sidebar,
        Theme.Stroke,
        1,
        0.5
    )

    local sideLayout =
        Instance.new("UIListLayout")

    sideLayout.Padding =
        UDim.new(
            0,
            5
        )

    sideLayout.HorizontalAlignment =
        Enum.HorizontalAlignment.Center

    sideLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    sideLayout.Parent =
        sidebar

    local sidePad =
        Instance.new("UIPadding")

    sidePad.PaddingTop =
        UDim.new(
            0,
            8
        )

    sidePad.PaddingLeft =
        UDim.new(
            0,
            7
        )

    sidePad.PaddingRight =
        UDim.new(
            0,
            7
        )

    sidePad.Parent =
        sidebar

    -- ==================================================
    -- CONTENT
    -- ==================================================

    local contentFrame =
        Instance.new("Frame")

    contentFrame.Size =
        UDim2.new(
            1,
            -106,
            1,
            0
        )

    contentFrame.Position =
        UDim2.fromOffset(
            106,
            0
        )

    contentFrame.BackgroundColor3 =
        Theme.Surface

    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = body

    corner(contentFrame, 14)

    stroke(
        contentFrame,
        Theme.Stroke,
        1,
        0.5
    )

    -- ==================================================
    -- TABS
    -- ==================================================

    local tabs = {
        {"Move", "MOVE"},
        {"Combat", "FIGHT"},
        {"Farm", "FARM"},
        {"VIP", "VIP"},
        {"Visual", "VIEW"},
        {"Util", "UTIL"},
        {"ESP", "ESP"},
        {"Ctrl", "CTRL"}
    }

    local tabContainers = {}
    local tabButtons = {}

    for index, info in ipairs(tabs) do

        local tabName = info[1]
        local tabText = info[2]

        local btn =
            Instance.new("TextButton")

        btn.Name =
            tabName .. "Tab"

        btn.Size =
            UDim2.new(
                1,
                0,
                0,
                34
            )

        btn.BackgroundColor3 =
            Theme.Card

        btn.BackgroundTransparency =
            0.65

        btn.Text =
            tabText

        btn.TextColor3 =
            Theme.SubText

        btn.Font =
            Enum.Font.GothamBold

        btn.TextSize = 9

        btn.AutoButtonColor = false

        btn.LayoutOrder = index
        btn.ZIndex = 11
        btn.Parent = sidebar

        corner(btn, 9)

        local indicator =
            Instance.new("Frame")

        indicator.Size =
            UDim2.fromOffset(
                3,
                18
            )

        indicator.Position =
            UDim2.new(
                0,
                0,
                0.5,
                -9
            )

        indicator.BackgroundColor3 =
            Theme.Accent

        indicator.BackgroundTransparency = 1

        indicator.BorderSizePixel = 0

        indicator.ZIndex = 12
        indicator.Parent = btn

        corner(indicator, 5)

        tabButtons[tabName] = {
            Button = btn,
            Indicator = indicator
        }

        local container =
            Instance.new("ScrollingFrame")

        container.Name =
            tabName .. "Container"

        container.Size =
            UDim2.new(
                1,
                -12,
                1,
                -12
            )

        container.Position =
            UDim2.fromOffset(
                6,
                6
            )

        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ScrollBarThickness = 2

        container.ScrollBarImageColor3 =
            Theme.Accent

        container.AutomaticCanvasSize =
            Enum.AutomaticSize.Y

        container.Visible = false
        container.Parent = contentFrame

        local list =
            Instance.new("UIListLayout")

        list.Padding =
            UDim.new(
                0,
                7
            )

        list.SortOrder =
            Enum.SortOrder.LayoutOrder

        list.Parent = container

        local p =
            Instance.new("UIPadding")

        p.PaddingLeft =
            UDim.new(
                0,
                6
            )

        p.PaddingRight =
            UDim.new(
                0,
                6
            )

        p.PaddingTop =
            UDim.new(
                0,
                6
            )

        p.PaddingBottom =
            UDim.new(
                0,
                6
            )

        p.Parent = container

        tabContainers[tabName] =
            container

        btn.MouseButton1Click:Connect(
            function()

                for name, c in pairs(
                    tabContainers
                ) do

                    c.Visible = false

                    local b =
                        tabButtons[name]

                    b.Button.BackgroundTransparency =
                        0.65

                    b.Button.TextColor3 =
                        Theme.SubText

                    b.Indicator.BackgroundTransparency =
                        1
                end

                container.Visible = true

                btn.BackgroundColor3 =
                    Theme.Accent

                btn.BackgroundTransparency =
                    0.82

                btn.TextColor3 =
                    Theme.Text

                indicator.BackgroundTransparency =
                    0

                playBeep()
            end
        )
    end

    -- ==================================================
    -- UI HELPERS
    -- ==================================================

    local function addSection(
        container,
        text
    )

        local section =
            Instance.new("TextLabel")

        section.Size =
            UDim2.new(
                1,
                0,
                0,
                24
            )

        section.BackgroundTransparency = 1

        section.Text =
            "  " ..
            string.upper(text)

        section.TextColor3 =
            Theme.Accent

        section.Font =
            Enum.Font.GothamBold

        section.TextSize = 10

        section.TextXAlignment =
            Enum.TextXAlignment.Left

        section.Parent = container

        return section
    end

    local function addToggle(
        container,
        text,
        default,
        callback
    )

        local card =
            Instance.new("TextButton")

        card.Size =
            UDim2.new(
                1,
                0,
                0,
                44
            )

        card.BackgroundColor3 =
            Theme.Card

        card.BorderSizePixel = 0

        card.Text = ""

        card.AutoButtonColor = false
        card.Parent = container

        corner(card, 11)

        stroke(
            card,
            Theme.Stroke,
            1,
            0.65
        )

        local label =
            Instance.new("TextLabel")

        label.Size =
            UDim2.new(
                1,
                -70,
                1,
                0
            )

        label.Position =
            UDim2.fromOffset(
                13,
                0
            )

        label.BackgroundTransparency = 1

        label.Text =
            text

        label.TextColor3 =
            Theme.Text

        label.Font =
            Enum.Font.GothamMedium

        label.TextSize = 10

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.Parent = card

        local switch =
            Instance.new("Frame")

        switch.Size =
            UDim2.fromOffset(
                38,
                20
            )

        switch.Position =
            UDim2.new(
                1,
                -51,
                0.5,
                -10
            )

        switch.BackgroundColor3 =
            default
            and Theme.Accent
            or Theme.Surface2

        switch.BorderSizePixel = 0
        switch.Parent = card

        corner(switch, 99)

        local knob =
            Instance.new("Frame")

        knob.Size =
            UDim2.fromOffset(
                16,
                16
            )

        knob.Position =
            default
            and UDim2.new(
                1,
                -18,
                0.5,
                -8
            )
            or UDim2.fromOffset(
                2,
                2
            )

        knob.BackgroundColor3 =
            Color3.new(
                1,
                1,
                1
            )

        knob.BorderSizePixel = 0
        knob.Parent = switch

        corner(knob, 99)

        local state = default

        local function refresh()

            TweenService:Create(
                switch,
                TweenInfo.new(0.18),
                {
                    BackgroundColor3 =
                        state
                        and Theme.Accent
                        or Theme.Surface2
                }
            ):Play()

            TweenService:Create(
                knob,
                TweenInfo.new(
                    0.18,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Position =
                        state
                        and UDim2.new(
                            1,
                            -18,
                            0.5,
                            -8
                        )
                        or UDim2.fromOffset(
                            2,
                            2
                        )
                }
            ):Play()
        end

        card.MouseButton1Click:Connect(
            function()

                state = not state

                refresh()

                playBeep()

                pcall(
                    callback,
                    state
                )
            end
        )

        return card
    end

    local function addButton(
        container,
        text,
        callback
    )

        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.new(
                1,
                0,
                0,
                42
            )

        button.BackgroundColor3 =
            Theme.Card

        button.BorderSizePixel = 0

        button.Text =
            text

        button.TextColor3 =
            Theme.Text

        button.Font =
            Enum.Font.GothamBold

        button.TextSize = 10

        button.AutoButtonColor = false
        button.Parent = container

        corner(button, 11)

        stroke(
            button,
            Theme.Stroke,
            1,
            0.6
        )

        button.MouseEnter:Connect(
            function()

                TweenService:Create(
                    button,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            Theme.Surface2
                    }
                ):Play()
            end
        )

        button.MouseLeave:Connect(
            function()

                TweenService:Create(
                    button,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            Theme.Card
                    }
                ):Play()
            end
        )

        button.MouseButton1Click:Connect(
            function()

                playBeep()

                pcall(callback)
            end
        )

        return button
    end

    local function addTextBox(
        container,
        labelText,
        default,
        callback
    )

        local card =
            Instance.new("Frame")

        card.Size =
            UDim2.new(
                1,
                0,
                0,
                48
            )

        card.BackgroundColor3 =
            Theme.Card

        card.BorderSizePixel = 0
        card.Parent = container

        corner(card, 11)

        stroke(
            card,
            Theme.Stroke,
            1,
            0.65
        )

        local label =
            Instance.new("TextLabel")

        label.Size =
            UDim2.new(
                0.42,
                0,
                1,
                0
            )

        label.Position =
            UDim2.fromOffset(
                13,
                0
            )

        label.BackgroundTransparency = 1

        label.Text =
            labelText

        label.TextColor3 =
            Theme.Text

        label.Font =
            Enum.Font.GothamMedium

        label.TextSize = 10

        label.TextXAlignment =
            Enum.TextXAlignment.Left

        label.Parent = card

        local box =
            Instance.new("TextBox")

        box.Size =
            UDim2.new(
                0.48,
                0,
                0,
                30
            )

        box.Position =
            UDim2.new(
                0.48,
                0,
                0.5,
                -15
            )

        box.BackgroundColor3 =
            Theme.Surface2

        box.BorderSizePixel = 0

        box.Text =
            tostring(default or "")

        box.TextColor3 =
            Theme.Text

        box.PlaceholderColor3 =
            Theme.SubText

        box.Font =
            Enum.Font.GothamMedium

        box.TextSize = 10

        box.ClearTextOnFocus = false

        box.TextXAlignment =
            Enum.TextXAlignment.Center

        box.Parent = card

        corner(box, 8)

        stroke(
            box,
            Theme.Stroke,
            1,
            0.4
        )

        box.FocusLost:Connect(
            function()

                pcall(
                    callback,
                    box.Text
                )
            end
        )

        return box
    end

    -- ==================================================
    -- MOVE
    -- ==================================================

    addSection(
        tabContainers.Move,
        "Movement UI"
    )

    addToggle(
        tabContainers.Move,
        "Fly",
        false,
        function(v)

            Settings.Fly = v

            if v then
                startFly()
            else
                stopFly()
            end
        end
    )

    addTextBox(
        tabContainers.Move,
        "Fly Speed",
        "120",
        function(v)

            Settings.FlySpeed =
                tonumber(v) or 120
        end
    )

    addToggle(
        tabContainers.Move,
        "Boost Mode",
        false,
        function(v)

            Settings.BoostMode = v

            notify(
                "Boost Mode",
                v and "Enabled." or "Disabled.",
                2,
                v and "Success" or "Info"
            )
        end
    )

    addToggle(
        tabContainers.Move,
        "Noclip",
        false,
        function(v)

            Settings.Noclip = v

            toggleNoclip()
        end
    )

    addTextBox(
        tabContainers.Move,
        "Speed Mult",
        "1",
        function(v)

            Settings.SpeedBoostMultiplier =
                tonumber(v) or 1

            updateWalkSpeed()
        end
    )

    addToggle(
        tabContainers.Move,
        "Infinite Jump",
        false,
        function(v)

            Settings.InfiniteJumpOrig = v

            notify(
                "Infinite Jump",
                v and "Enabled" or "Disabled",
                2,
                v and "Success" or "Info"
            )
        end
    )

    -- ==================================================
    -- COMBAT
    -- ==================================================

    addSection(
        tabContainers.Combat,
        "Combat UI"
    )

    addButton(
        tabContainers.Combat,
        "Combat Settings",
        function()

            notify(
                "Combat",
                "Combat settings UI is ready.",
                3,
                "Info"
            )
        end
    )

    addToggle(
        tabContainers.Combat,
        "Combat Preview",
        false,
        function(v)

            notify(
                "Combat Preview",
                v and "Enabled." or "Disabled.",
                2,
                v and "Success" or "Info"
            )
        end
    )

    addTextBox(
        tabContainers.Combat,
        "Range",
        "30",
        function(v)

            local value =
                tonumber(v)

            if not value then

                notify(
                    "Invalid Value",
                    "Range must be a number.",
                    3,
                    "Error"
                )

                return
            end

            notify(
                "Range",
                "UI value updated to " .. value,
                2,
                "Success"
            )
        end
    )

    -- ==================================================
    -- FARM
    -- ==================================================

    addSection(
        tabContainers.Farm,
        "Farming UI"
    )

    addToggle(
        tabContainers.Farm,
        "Auto Chop",
        false,
        function(v)

            notify(
                "Auto Chop",
                v and "Enabled." or "Disabled.",
                2,
                v and "Success" or "Info"
            )
        end
    )

    addTextBox(
        tabContainers.Farm,
        "Walk Speed",
        "16",
        function(v)

            local value =
                tonumber(v)

            if not value then

                notify(
                    "Invalid Speed",
                    "Please enter a number.",
                    3,
                    "Error"
                )

                return
            end

            Settings.SpeedBoostMultiplier =
                math.max(
                    1,
                    value / 16
                )

            updateWalkSpeed()

            notify(
                "Walk Speed",
                "UI value updated.",
                2,
                "Success"
            )
        end
    )

    -- ==================================================
    -- VIP
    -- ==================================================

    addSection(
        tabContainers.VIP,
        "VIP UI"
    )

    addButton(
        tabContainers.VIP,
        "VIP Status",
        function()

            notify(
                "VIP",
                "VIP interface is active.",
                3,
                "Success"
            )
        end
    )

    addButton(
        tabContainers.VIP,
        "Heal Preview",
        function()

            notify(
                "Heal",
                "Heal button pressed. Gameplay implementation is disabled in UI-only mode.",
                3,
                "Info"
            )
        end
    )

    addButton(
        tabContainers.VIP,
        "VIP Speed Preview",
        function()

            notify(
                "VIP Speed",
                "VIP speed UI action triggered.",
                3,
                "Info"
            )
        end
    )

    addButton(
        tabContainers.VIP,
        "Reset Speed",
        function()

            Settings.SpeedBoostMultiplier = 1

            updateWalkSpeed()

            notify(
                "Speed",
                "Speed reset.",
                2,
                "Info"
            )
        end
    )

    addToggle(
        tabContainers.VIP,
        "Player ESP",
        false,
        function(v)

            Settings.ESP = v

            updateESP()
        end
    )

    addToggle(
        tabContainers.VIP,
        "God Mode",
        false,
        function(v)

            Settings.GodMode = v

            toggleGodMode()
        end
    )

    addToggle(
        tabContainers.VIP,
        "Instant Respawn",
        false,
        function(v)

            Settings.InstantRespawn = v

            toggleInstantRespawn()
        end
    )

    -- ==================================================
    -- VISUAL
    -- ==================================================

    addSection(
        tabContainers.Visual,
        "Visual"
    )

    addTextBox(
        tabContainers.Visual,
        "Field Of View",
        "70",
        function(v)

            local value =
                math.clamp(
                    tonumber(v) or 70,
                    40,
                    120
                )

            Settings.FOV =
                value

            if Workspace.CurrentCamera then

                Workspace.CurrentCamera.FieldOfView =
                    value
            end

            notify(
                "FOV",
                "Field of view updated.",
                2,
                "Success"
            )
        end
    )

    addToggle(
        tabContainers.Visual,
        "Full Bright",
        false,
        function(v)

            Settings.FullBright = v

            if v then

                Lighting.Brightness = 2
                Lighting.ClockTime = 12
                Lighting.FogEnd = 100000

                notify(
                    "Full Bright",
                    "Enabled.",
                    2,
                    "Success"
                )

            else

                Lighting.Brightness = 0.5
                Lighting.ClockTime = 0
                Lighting.FogEnd = 1000

                notify(
                    "Full Bright",
                    "Disabled.",
                    2,
                    "Info"
                )
            end
        end
    )

    -- ==================================================
    -- ESP
    -- ==================================================

    addSection(
        tabContainers.ESP,
        "NPC ESP UI"
    )

    addToggle(
        tabContainers.ESP,
        "NPC ESP",
        false,
        function(v)

            Settings.NPC_ESP = v

            notify(
                "NPC ESP",
                v and "Enabled." or "Disabled.",
                2,
                v and "Success" or "Info"
            )
        end
    )

    addToggle(
        tabContainers.ESP,
        "Show Name",
        true,
        function(v)

            Settings.NPC_ESP_Name = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Show Health",
        true,
        function(v)

            Settings.NPC_ESP_Health = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Show Distance",
        true,
        function(v)

            Settings.NPC_ESP_Distance = v
        end
    )

    addToggle(
        tabContainers.ESP,
        "Hide Dead",
        true,
        function(v)

            Settings.NPC_ESP_HideDead = v
        end
    )

    addTextBox(
        tabContainers.ESP,
        "ESP Range",
        "200",
        function(v)

            Settings.NPC_ESP_Range =
                tonumber(v) or 200
        end
    )

    -- ==================================================
    -- CONTROL
    -- ==================================================

    addSection(
        tabContainers.Ctrl,
        "Control UI"
    )

    addToggle(
        tabContainers.Ctrl,
        "VIP Freeze Hold",
        false,
        function(v)

            Settings.VIPFreezeHold = v

            toggleVIPFreezeHold()
        end
    )

    addToggle(
        tabContainers.Ctrl,
        "VIP Freeze Kill",
        false,
        function(v)

            Settings.VIPFreezeKill = v

            toggleVIPFreezeKill()
        end
    )

    -- ==================================================
    -- UTIL
    -- ==================================================

    addSection(
        tabContainers.Util,
        "Utilities"
    )

    addButton(
        tabContainers.Util,
        "System Information",
        function()

            notify(
                "System",
                "MKRA Hub UI is running normally.",
                3,
                "Info"
            )
        end
    )

    addButton(
        tabContainers.Util,
        "Test Success Notification",
        function()

            notify(
                "Success",
                "Everything is working correctly.",
                3,
                "Success"
            )
        end
    )

    addButton(
        tabContainers.Util,
        "Test Warning Notification",
        function()

            notify(
                "Warning",
                "This is a warning message.",
                4,
                "Warning"
            )
        end
    )

    addButton(
        tabContainers.Util,
        "Test Error Notification",
        function()

            notify(
                "Error",
                "This is an error message.",
                4,
                "Error"
            )
        end
    )

    addButton(
        tabContainers.Util,
        "Test Info Notification",
        function()

            notify(
                "Information",
                "This is an information message.",
                3,
                "Info"
            )
        end
    )

    addButton(
        tabContainers.Util,
        "Test All Notifications",
        function()

            notify(
                "Success",
                "Success notification.",
                3,
                "Success"
            )

            task.wait(0.15)

            notify(
                "Warning",
                "Warning notification.",
                3,
                "Warning"
            )

            task.wait(0.15)

            notify(
                "Error",
                "Error notification.",
                3,
                "Error"
            )

            task.wait(0.15)

            notify(
                "Information",
                "Info notification.",
                3,
                "Info"
            )
        end
    )

    -- ==================================================
    -- FOOTER
    -- ==================================================

    local footer =
        Instance.new("TextLabel")

    footer.Size =
        UDim2.new(
            1,
            -24,
            0,
            18
        )

    footer.Position =
        UDim2.new(
            0,
            12,
            1,
            -22
        )

    footer.BackgroundTransparency = 1

    footer.Text =
        "MKRA HUB  •  UI ONLY  •  MOBILE OPTIMIZED"

    footer.TextColor3 =
        Theme.SubText

    footer.Font =
        Enum.Font.GothamMedium

    footer.TextSize = 8

    footer.TextXAlignment =
        Enum.TextXAlignment.Center

    footer.ZIndex = 20
    footer.Parent = main

    -- ==================================================
    -- DEFAULT TAB
    -- ==================================================

    tabContainers.Move.Visible = true

    tabButtons.Move.Button.BackgroundColor3 =
        Theme.Accent

    tabButtons.Move.Button.BackgroundTransparency =
        0.82

    tabButtons.Move.Button.TextColor3 =
        Theme.Text

    tabButtons.Move.Indicator.BackgroundTransparency =
        0

    -- ==================================================
    -- OPEN / CLOSE
    -- ==================================================

    local function openUI()

        main.Visible = true

        main.GroupTransparency = 1

        TweenService:Create(
            main,
            TweenInfo.new(
                0.28,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                GroupTransparency = 0
            }
        ):Play()

        TweenService:Create(
            toggleBtn,
            TweenInfo.new(0.25),
            {
                Rotation = 180
            }
        ):Play()
    end

    local function closeUI()

        local tween =
            TweenService:Create(
                main,
                TweenInfo.new(
                    0.22,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In
                ),
                {
                    GroupTransparency = 1
                }
            )

        tween:Play()

        TweenService:Create(
            toggleBtn,
            TweenInfo.new(0.22),
            {
                Rotation = 0
            }
        ):Play()

        tween.Completed:Wait()

        main.Visible = false
    end

    -- ==================================================
    -- MINIMIZE
    -- ==================================================

    local restoreButton

    local function minimizeUI()

        main.Visible = false

        if restoreButton then
            return
        end

        restoreButton =
            Instance.new("TextButton")

        restoreButton.Name =
            "RestoreButton"

        restoreButton.Size =
            UDim2.fromOffset(
                48,
                48
            )

        restoreButton.Position =
            UDim2.fromScale(
                0.5,
                0.5
            )

        restoreButton.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        restoreButton.BackgroundColor3 =
            Theme.Surface

        restoreButton.Text =
            "MK"

        restoreButton.TextColor3 =
            Theme.Text

        restoreButton.Font =
            Enum.Font.GothamBold

        restoreButton.TextSize = 12

        restoreButton.AutoButtonColor = false

        restoreButton.ZIndex = 100
        restoreButton.Parent = gui

        corner(
            restoreButton,
            14
        )

        local rs =
            stroke(
                restoreButton,
                Theme.Accent,
                2
            )

        restoreButton.MouseButton1Click:Connect(
            function()

                restoreButton:Destroy()

                restoreButton = nil

                openUI()
            end
        )

        task.spawn(
            function()

                while restoreButton
                    and restoreButton.Parent do

                    rs.Color =
                        Color3.fromHSV(
                            (
                                os.clock()
                                * 0.35
                            ) % 1,
                            0.8,
                            1
                        )

                    task.wait(0.04)
                end
            end
        )
    end

    minimizeBtn.MouseButton1Click:Connect(
        minimizeUI
    )

    -- ==================================================
    -- DRAG
    -- ==================================================

    local function makeDraggable(
        handle,
        frame
    )

        local dragging = false
        local dragStart
        local startPos

        handle.InputBegan:Connect(
            function(input)

                if input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or input.UserInputType ==
                    Enum.UserInputType.Touch then

                    dragging = true

                    dragStart =
                        input.Position

                    startPos =
                        frame.Position
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)

                if not dragging then
                    return
                end

                if input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                    or input.UserInputType ==
                    Enum.UserInputType.Touch then

                    local delta =
                        input.Position
                        - dragStart

                    frame.Position =
                        UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset
                                + delta.X,

                            startPos.Y.Scale,
                            startPos.Y.Offset
                                + delta.Y
                        )
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)

                if input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or input.UserInputType ==
                    Enum.UserInputType.Touch then

                    dragging = false
                end
            end
        )
    end

    makeDraggable(
        header,
        main
    )

    -- ==================================================
    -- FLOAT BUTTON DRAG
    -- ==================================================

    local toggleDragging = false
    local toggleMoved = false
    local toggleStart
    local toggleStartPosition

    toggleBtn.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                toggleDragging = true
                toggleMoved = false

                toggleStart =
                    input.Position

                toggleStartPosition =
                    toggleBtn.Position
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if not toggleDragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                local delta =
                    input.Position
                    - toggleStart

                if delta.Magnitude > 5 then
                    toggleMoved = true
                end

                toggleBtn.Position =
                    UDim2.new(
                        toggleStartPosition.X.Scale,
                        toggleStartPosition.X.Offset
                            + delta.X,

                        toggleStartPosition.Y.Scale,
                        toggleStartPosition.Y.Offset
                            + delta.Y
                    )
            end
        end
    )

    toggleBtn.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                if not toggleMoved then

                    if main.Visible then
                        closeUI()
                    else
                        openUI()
                    end
                end

                toggleDragging = false
            end
        end
    )

    -- ==================================================
    -- MOBILE RESPONSIVE
    -- ==================================================

    local camera =
        Workspace.CurrentCamera

    local function updateScale()

        camera =
            Workspace.CurrentCamera

        if not camera then
            return
        end

        local viewport =
            camera.ViewportSize

        if viewport.X < 600 then

            main.Size =
                UDim2.new(
                    0.92,
                    0,
                    0,
                    math.min(
                        520,
                        viewport.Y - 40
                    )
                )

            main.Position =
                UDim2.fromScale(
                    0.5,
                    0.5
                )

            sidebar.Size =
                UDim2.fromOffset(
                    82,
                    1
                )

            contentFrame.Position =
                UDim2.fromOffset(
                    92,
                    0
                )

            contentFrame.Size =
                UDim2.new(
                    1,
                    -92,
                    1,
                    0
                )

            if NotificationHolder then

                NotificationHolder.Size =
                    UDim2.new(
                        0,
                        math.min(
                            320,
                            viewport.X - 25
                        ),
                        1,
                        -32
                    )
            end

        else

            main.Size =
                UDim2.fromOffset(
                    440,
                    520
                )

            sidebar.Size =
                UDim2.fromOffset(
                    96,
                    1
                )

            contentFrame.Position =
                UDim2.fromOffset(
                    106,
                    0
                )

            contentFrame.Size =
                UDim2.new(
                    1,
                    -106,
                    1,
                    0
                )
        end
    end

    if camera then

        camera:GetPropertyChangedSignal(
            "ViewportSize"
        ):Connect(
            updateScale
        )
    end

    updateScale()

    -- ==================================================
    -- RAINBOW ANIMATION
    -- ==================================================

    task.spawn(
        function()

            while gui.Parent do

                local hue =
                    (
                        os.clock()
                        * 0.18
                    ) % 1

                local rainbowColor =
                    Color3.fromHSV(
                        hue,
                        0.8,
                        1
                    )

                mainStroke.Color =
                    rainbowColor

                toggleStroke.Color =
                    rainbowColor

                iconStroke.Color =
                    rainbowColor

                title.TextColor3 =
                    rainbowColor

                task.wait(0.04)
            end
        end
    )

    -- ==================================================
    -- INITIAL
    -- ==================================================

    main.Visible = false

    main.GroupTransparency = 1

    task.delay(
        0.5,
        function()

            notify(
                "MKRA Hub",
                "Modern UI loaded successfully!",
                3,
                "Success"
            )
        end
    )
end

-- ==================================================
-- START
-- ==================================================

createUI("")