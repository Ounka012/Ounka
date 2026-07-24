-- 🎵 Boombox Client v2 (មានការបញ្ជាក់ និងចាប់កំហុស)
local success, err = pcall(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    -- បញ្ជីចម្រៀង
    local SongLibrary = {
        { name = "ចម្រៀងដំបូង", id = "rbxassetid://1842190355" },
        { name = "ចម្រៀងទីពីរ", id = "rbxassetid://1845743597" },
        { name = "ចម្រៀងទីបី", id = "rbxassetid://1840927967" },
        { name = "ចម្រៀងទីបួន", id = "rbxassetid://1837856842" },
        { name = "ចម្រៀងទីប្រាំ", id = "rbxassetid://1845014938" },
    }

    local currentSongIndex = 1
    local isPlaying = false
    local currentVolume = 0.8
    local isShuffle = false
    local playedSongs = {}

    -- Sound
    local Music = Instance.new("Sound")
    Music.Volume = currentVolume
    Music.Looped = false
    Music.Parent = PlayerGui
    Music.SoundId = SongLibrary[currentSongIndex].id

    local ClickSound = Instance.new("Sound")
    ClickSound.SoundId = "rbxassetid://9125405871"
    ClickSound.Volume = 0.4
    ClickSound.Parent = PlayerGui

    -- GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoomboxSystem"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🎧 BOOMBOX"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Song info
    local SongInfoFrame = Instance.new("Frame")
    SongInfoFrame.Size = UDim2.new(1, -20, 0, 60)
    SongInfoFrame.Position = UDim2.new(0, 10, 0, 50)
    SongInfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SongInfoFrame.BorderSizePixel = 0
    SongInfoFrame.Parent = MainFrame
    Instance.new("UICorner", SongInfoFrame).CornerRadius = UDim.new(0, 8)

    local SongNameLabel = Instance.new("TextLabel")
    SongNameLabel.Size = UDim2.new(1, -10, 0, 30)
    SongNameLabel.Position = UDim2.new(0, 5, 0, 5)
    SongNameLabel.BackgroundTransparency = 1
    SongNameLabel.Text = "ចម្រៀង: " .. SongLibrary[currentSongIndex].name
    SongNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SongNameLabel.Font = Enum.Font.Gotham
    SongNameLabel.TextSize = 14
    SongNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    SongNameLabel.Parent = SongInfoFrame

    local SongStatusLabel = Instance.new("TextLabel")
    SongStatusLabel.Size = UDim2.new(1, -10, 0, 20)
    SongStatusLabel.Position = UDim2.new(0, 5, 0, 35)
    SongStatusLabel.BackgroundTransparency = 1
    SongStatusLabel.Text = "ស្ថានភាព: ឈប់"
    SongStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SongStatusLabel.Font = Enum.Font.Gotham
    SongStatusLabel.TextSize = 12
    SongStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    SongStatusLabel.Parent = SongInfoFrame

    -- Volume
    local VolumeFrame = Instance.new("Frame")
    VolumeFrame.Size = UDim2.new(1, -20, 0, 40)
    VolumeFrame.Position = UDim2.new(0, 10, 0, 120)
    VolumeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    VolumeFrame.BorderSizePixel = 0
    VolumeFrame.Parent = MainFrame
    Instance.new("UICorner", VolumeFrame).CornerRadius = UDim.new(0, 8)

    local VolumeLabel = Instance.new("TextLabel")
    VolumeLabel.Size = UDim2.new(0, 80, 1, 0)
    VolumeLabel.Position = UDim2.new(0, 5, 0, 0)
    VolumeLabel.BackgroundTransparency = 1
    VolumeLabel.Text = "🔊 កម្រិត"
    VolumeLabel.TextColor3 = Color3.fromRGB(255,255,255)
    VolumeLabel.Font = Enum.Font.Gotham
    VolumeLabel.TextSize = 12
    VolumeLabel.TextXAlignment = Enum.TextXAlignment.Left
    VolumeLabel.Parent = VolumeFrame

    local VolumeSlider = Instance.new("TextButton")
    VolumeSlider.Size = UDim2.new(1, -100, 0, 20)
    VolumeSlider.Position = UDim2.new(0, 85, 0, 10)
    VolumeSlider.BackgroundColor3 = Color3.fromRGB(60,60,60)
    VolumeSlider.Text = ""
    VolumeSlider.BorderSizePixel = 0
    VolumeSlider.Parent = VolumeFrame
    Instance.new("UICorner", VolumeSlider).CornerRadius = UDim.new(0, 4)

    local VolumeFill = Instance.new("Frame")
    VolumeFill.Size = UDim2.new(currentVolume, 0, 1, 0)
    VolumeFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    VolumeFill.BorderSizePixel = 0
    VolumeFill.Parent = VolumeSlider
    Instance.new("UICorner", VolumeFill).CornerRadius = UDim.new(0, 4)

    -- Buttons
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -20, 0, 50)
    ButtonFrame.Position = UDim2.new(0, 10, 0, 175)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = MainFrame

    local function createButton(text, posX, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.Position = UDim2.new(0, posX, 0, 5)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Parent = ButtonFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            ClickSound:Play()
            callback()
        end)
        return btn
    end

    local PlayPauseBtn = createButton("▶", 0, Color3.fromRGB(0, 150, 0), function()
        if not isPlaying then
            Music.TimePosition = 0
            Music:Play()
            isPlaying = true
            PlayPauseBtn.Text = "⏸"
            SongStatusLabel.Text = "ស្ថានភាព: កំពុងចាក់"
        else
            Music:Pause()
            isPlaying = false
            PlayPauseBtn.Text = "▶"
            SongStatusLabel.Text = "ស្ថានភាព: ផ្អាក"
        end
    end)

    createButton("⏹", 50, Color3.fromRGB(150, 0, 0), function()
        Music:Stop()
        isPlaying = false
        PlayPauseBtn.Text = "▶"
        SongStatusLabel.Text = "ស្ថានភាព: ឈប់"
    end)

    createButton("⏮", 100, Color3.fromRGB(100, 100, 100), function()
        Music:Stop()
        currentSongIndex = currentSongIndex - 1
        if currentSongIndex < 1 then currentSongIndex = #SongLibrary end
        Music.SoundId = SongLibrary[currentSongIndex].id
        SongNameLabel.Text = "ចម្រៀង: " .. SongLibrary[currentSongIndex].name
        if isPlaying then Music:Play(); PlayPauseBtn.Text = "⏸" end
    end)

    createButton("⏭", 150, Color3.fromRGB(100, 100, 100), function()
        Music:Stop()
        currentSongIndex = currentSongIndex + 1
        if currentSongIndex > #SongLibrary then currentSongIndex = 1 end
        Music.SoundId = SongLibrary[currentSongIndex].id
        SongNameLabel.Text = "ចម្រៀង: " .. SongLibrary[currentSongIndex].name
        if isPlaying then Music:Play(); PlayPauseBtn.Text = "⏸" end
    end)

    local ShuffleBtn = Instance.new("TextButton")
    ShuffleBtn.Size = UDim2.new(0, 40, 0, 40)
    ShuffleBtn.Position = UDim2.new(0, 210, 0, 5)
    ShuffleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ShuffleBtn.Text = "🔀"
    ShuffleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ShuffleBtn.Font = Enum.Font.GothamBold
    ShuffleBtn.TextSize = 18
    ShuffleBtn.Parent = ButtonFrame
    Instance.new("UICorner", ShuffleBtn).CornerRadius = UDim.new(0, 8)
    ShuffleBtn.MouseButton1Click:Connect(function()
        ClickSound:Play()
        isShuffle = not isShuffle
        ShuffleBtn.BackgroundColor3 = isShuffle and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 80)
    end)

    -- Playlist
    local PlaylistFrame = Instance.new("ScrollingFrame")
    PlaylistFrame.Size = UDim2.new(1, -20, 0, 120)
    PlaylistFrame.Position = UDim2.new(0, 10, 0, 235)
    PlaylistFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    PlaylistFrame.BorderSizePixel = 0
    PlaylistFrame.ScrollBarThickness = 5
    PlaylistFrame.CanvasSize = UDim2.new(0,0,0,0)
    PlaylistFrame.Parent = MainFrame
    Instance.new("UICorner", PlaylistFrame).CornerRadius = UDim.new(0, 8)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0,5)
    UIListLayout.Parent = PlaylistFrame

    local function updatePlaylist()
        for _, child in ipairs(PlaylistFrame:GetChildren()) do
            if child ~= UIListLayout then child:Destroy() end
        end
        for idx, song in ipairs(SongLibrary) do
            local songBtn = Instance.new("TextButton")
            songBtn.Size = UDim2.new(1, -10, 0, 30)
            songBtn.BackgroundColor3 = (idx == currentSongIndex) and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(45,45,45)
            songBtn.Text = "🎵 " .. song.name
            songBtn.TextColor3 = Color3.fromRGB(255,255,255)
            songBtn.Font = Enum.Font.Gotham
            songBtn.TextSize = 13
            songBtn.TextXAlignment = Enum.TextXAlignment.Left
            songBtn.Parent = PlaylistFrame
            Instance.new("UICorner", songBtn).CornerRadius = UDim.new(0, 4)
            songBtn.MouseButton1Click:Connect(function()
                ClickSound:Play()
                Music:Stop()
                currentSongIndex = idx
                Music.SoundId = song.id
                SongNameLabel.Text = "ចម្រៀង: " .. song.name
                if isPlaying then Music:Play(); PlayPauseBtn.Text = "⏸"
                else PlayPauseBtn.Text = "▶"; SongStatusLabel.Text = "ស្ថានភាព: ឈប់" end
                updatePlaylist()
            end)
        end
        PlaylistFrame.CanvasSize = UDim2.new(0,0,0, UIListLayout.AbsoluteContentSize.Y + 10)
    end

    -- Volume slider interaction
    VolumeSlider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                connection:Disconnect()
                return
            end
            local mousePos = UserInputService:GetMouseLocation()
            local sliderAbsPos = VolumeSlider.AbsolutePosition
            local sliderSize = VolumeSlider.AbsoluteSize
            local relativeX = math.clamp(mousePos.X - sliderAbsPos.X, 0, sliderSize.X)
            local newVolume = relativeX / sliderSize.X
            currentVolume = math.round(newVolume * 100) / 100
            Music.Volume = currentVolume
            VolumeFill.Size = UDim2.new(newVolume, 0, 1, 0)
        end)
    end)

    -- Song ended -> next
    Music.Ended:Connect(function()
        if not isPlaying then return end
        if isShuffle then
            if #playedSongs == #SongLibrary then playedSongs = {} end
            local nextIdx
            repeat nextIdx = math.random(1, #SongLibrary) until not table.find(playedSongs, nextIdx)
            table.insert(playedSongs, nextIdx)
            currentSongIndex = nextIdx
        else
            currentSongIndex = currentSongIndex + 1
            if currentSongIndex > #SongLibrary then currentSongIndex = 1 end
        end
        Music.SoundId = SongLibrary[currentSongIndex].id
        SongNameLabel.Text = "ចម្រៀង: " .. SongLibrary[currentSongIndex].name
        updatePlaylist()
        Music:Play()
    end)

    updatePlaylist()

    -- Toggle with RightControl
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("✅ Boombox GUI Loaded Successfully! ចុច RightControl ដើម្បីបង្ហាញ/លាក់")
end)

if not success then
    warn("❌ កំហុសក្នុងការដំណើរការ Boombox: " .. tostring(err))
    -- បង្កើត GUI តូចដើម្បីបង្ហាញកំហុស
    local Player = game.Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "ErrorDisplay"
    errorGui.Parent = PlayerGui
    local errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.new(0,300,0,50)
    errorFrame.Position = UDim2.new(0.5,-150,0.5,-25)
    errorFrame.BackgroundColor3 = Color3.fromRGB(255,0,0)
    errorFrame.BorderSizePixel = 0
    errorFrame.Parent = errorGui
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1,0,1,0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = "Error: " .. tostring(err)
    errorLabel.TextColor3 = Color3.fromRGB(255,255,255)
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextSize = 12
    errorLabel.Parent = errorFrame
end