-- ==================================================
-- MODERN NOTIFICATION SYSTEM
-- ==================================================

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.AnchorPoint = Vector2.new(1, 0)
NotificationContainer.Position = UDim2.new(1, -18, 0, 18)
NotificationContainer.Size = UDim2.fromOffset(300, 500)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 500
NotificationContainer.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.Padding = UDim.new(0, 8)
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Parent = NotificationContainer

local NotificationColors = {
    Success = {
        Color = Color3.fromRGB(75, 220, 145),
        Icon = "✓"
    },

    Warning = {
        Color = Color3.fromRGB(245, 190, 70),
        Icon = "!"
    },

    Error = {
        Color = Color3.fromRGB(240, 80, 100),
        Icon = "×"
    },

    Info = {
        Color = Color3.fromRGB(80, 165, 255),
        Icon = "i"
    }
}

local function createNotification(
    notificationType,
    titleText,
    messageText,
    duration
)

    notificationType =
        NotificationColors[notificationType]
        and notificationType
        or "Info"

    duration = duration or 3

    local data =
        NotificationColors[notificationType]

    local card = Instance.new("Frame")
    card.Name = notificationType .. "Notification"
    card.Size = UDim2.fromOffset(290, 76)
    card.BackgroundColor3 = Theme.Surface
    card.BackgroundTransparency = 0.03
    card.BorderSizePixel = 0
    card.LayoutOrder = os.clock() * 1000
    card.ZIndex = 501
    card.Parent = NotificationContainer

    corner(card, 13)
    stroke(card, data.Color, 1.2, 0.35)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(34, 34)
    icon.Position = UDim2.fromOffset(10, 11)
    icon.BackgroundColor3 = data.Color
    icon.BackgroundTransparency = 0.78
    icon.Text = data.Icon
    icon.TextColor3 = data.Color
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 17
    icon.ZIndex = 502
    icon.Parent = card

    corner(icon, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -65, 0, 22)
    title.Position = UDim2.fromOffset(53, 8)
    title.BackgroundTransparency = 1
    title.Text = titleText or notificationType
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 502
    title.Parent = card

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -65, 0, 30)
    message.Position = UDim2.fromOffset(53, 29)
    message.BackgroundTransparency = 1
    message.Text = messageText or ""
    message.TextColor3 = Theme.SubText
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 9
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.ZIndex = 502
    message.Parent = card

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(22, 22)
    close.Position = UDim2.new(1, -27, 0, 5)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Theme.SubText
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.AutoButtonColor = false
    close.ZIndex = 503
    close.Parent = card

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = data.Color
    progress.BorderSizePixel = 0
    progress.ZIndex = 503
    progress.Parent = card

    corner(progress, 99)

    -- Initial animation
    card.Position = UDim2.new(1, 25, 0, 0)

    TweenService:Create(
        card,
        TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(0, 0, 0, 0)
        }
    ):Play()

    local closed = false

    local function remove()

        if closed then
            return
        end

        closed = true

        local tween =
            TweenService:Create(
                card,
                TweenInfo.new(
                    0.22,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In
                ),
                {
                    Position = UDim2.new(1, 25, 0, 0),
                    BackgroundTransparency = 1
                }
            )

        tween:Play()

        tween.Completed:Connect(function()
            if card then
                card:Destroy()
            end
        end)
    end

    close.MouseButton1Click:Connect(remove)

    TweenService:Create(
        progress,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear
        ),
        {
            Size = UDim2.new(0, 0, 0, 2)
        }
    ):Play()

    task.delay(duration, remove)

    return card
end

-- Compatible notify() function
local function notify(
    titleText,
    messageText,
    duration,
    notificationType
)

    createNotification(
        notificationType or "Info",
        titleText,
        messageText,
        duration or 3
    )
end

-- Easy notification helpers
local function notifySuccess(titleText, messageText, duration)
    notify(
        titleText,
        messageText,
        duration,
        "Success"
    )
end

local function notifyWarning(titleText, messageText, duration)
    notify(
        titleText,
        messageText,
        duration,
        "Warning"
    )
end

local function notifyError(titleText, messageText, duration)
    notify(
        titleText,
        messageText,
        duration,
        "Error"
    )
end

local function notifyInfo(titleText, messageText, duration)
    notify(
        titleText,
        messageText,
        duration,
        "Info"
    )
end


-- ==================================================
-- NOTIFICATION CENTER BUTTON
-- ==================================================

local notificationButton = Instance.new("TextButton")
notificationButton.Name = "NotificationButton"
notificationButton.Size = UDim2.fromOffset(34, 34)
notificationButton.Position = UDim2.new(1, -52, 0, 24)
notificationButton.BackgroundColor3 = Theme.Card
notificationButton.Text = "🔔"
notificationButton.TextColor3 = Theme.Text
notificationButton.TextSize = 15
notificationButton.Font = Enum.Font.GothamBold
notificationButton.AutoButtonColor = false
notificationButton.ZIndex = 20
notificationButton.Parent = header

corner(notificationButton, 10)
stroke(notificationButton, Theme.Stroke, 1, 0.4)

notificationButton.MouseButton1Click:Connect(function()

    notifyInfo(
        "Notification Center",
        "Notification system is active.",
        2
    )

end)


-- ==================================================
-- SEARCH SYSTEM
-- ==================================================

local searchBox = Instance.new("TextBox")
searchBox.Name = "FeatureSearch"
searchBox.Size = UDim2.new(1, -12, 0, 34)
searchBox.Position = UDim2.fromOffset(6, 6)
searchBox.BackgroundColor3 = Theme.Card
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search features..."
searchBox.PlaceholderColor3 = Theme.SubText
searchBox.Text = ""
searchBox.TextColor3 = Theme.Text
searchBox.Font = Enum.Font.GothamMedium
searchBox.TextSize = 10
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 15
searchBox.Parent = contentFrame

corner(searchBox, 10)
stroke(searchBox, Theme.Stroke, 1, 0.55)

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 12)
searchPadding.PaddingRight = UDim.new(0, 12)
searchPadding.Parent = searchBox


-- ==================================================
-- FPS / PING STATUS
-- ==================================================

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "Stats"
statsLabel.Size = UDim2.fromOffset(150, 18)
statsLabel.Position = UDim2.new(0, 12, 1, -42)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: --  •  PING: --"
statsLabel.TextColor3 = Theme.SubText
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 8
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.ZIndex = 20
statsLabel.Parent = main

task.spawn(function()

    local lastTime = tick()
    local frames = 0

    while gui.Parent do

        frames += 1

        local now = tick()

        if now - lastTime >= 1 then

            local fps = frames
            frames = 0
            lastTime = now

            local ping = "--"

            pcall(function()

                local stats =
                    game:GetService("Stats")

                local network =
                    stats.Network

                local serverStats =
                    network.ServerStatsItem

                local dataPing =
                    serverStats[
                        "Data Ping"
                    ]

                if dataPing then
                    ping =
                        math.floor(
                            dataPing:GetValue()
                        )
                end

            end)

            statsLabel.Text =
                "FPS: "
                .. tostring(fps)
                .. "  •  PING: "
                .. tostring(ping)
                .. "ms"
        end

        task.wait()
    end
end)


-- ==================================================
-- UI SETTINGS
-- ==================================================

local SettingsTab = tabContainers["Util"]

addSection(
    SettingsTab,
    "Interface"
)

addToggle(
    SettingsTab,
    "UI Sounds",
    true,
    function(v)

        Settings.UISounds = v

        notifyInfo(
            "UI Sounds",
            v and "Enabled" or "Disabled",
            2
        )

    end
)

addToggle(
    SettingsTab,
    "Animations",
    true,
    function(v)

        Settings.UIAnimations = v

        notifyInfo(
            "Animations",
            v and "Enabled" or "Disabled",
            2
        )

    end
)

addToggle(
    SettingsTab,
    "Rainbow Effects",
    true,
    function(v)

        Settings.RainbowEffects = v

        notifyInfo(
            "Rainbow",
            v and "Enabled" or "Disabled",
            2
        )

    end
)

addButton(
    SettingsTab,
    "Reset UI",
    function()

        searchBox.Text = ""

        main.Position =
            UDim2.fromScale(
                0.5,
                0.5
            )

        notifySuccess(
            "UI Reset",
            "Interface restored.",
            2
        )

    end
)


-- ==================================================
-- WELCOME NOTIFICATION
-- ==================================================

task.delay(
    0.5,
    function()

        notifySuccess(
            "MKRA HUB",
            "Modern interface loaded successfully.",
            3
        )

    end
)

task.delay(
    1.2,
    function()

        notifyInfo(
            "Interface",
            "Search and notification system ready.",
            3
        )

    end
)