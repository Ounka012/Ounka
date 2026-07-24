-- 🎵 ADVANCED BOOMBOX SYSTEM (SERVER SCRIPT)

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- =====================
-- Remote Events
-- =====================

local musicUpdateEvent = Instance.new("RemoteEvent")
musicUpdateEvent.Name = "BoomboxMusicUpdate"
musicUpdateEvent.Parent = ReplicatedStorage

-- =====================
-- បញ្ជីចម្រៀង
-- =====================

local SongLibrary = {
	{name = "ចម្រៀងលេខ 1", id = "rbxassetid://1842190355", duration = 120},
	{name = "ចម្រៀងលេខ 2", id = "rbxassetid://1845743597", duration = 180},
	{name = "ចម្រៀងលេខ 3", id = "rbxassetid://1840927967", duration = 150},
	{name = "ចម្រៀងលេខ 4", id = "rbxassetid://1837856842", duration = 200},
	{name = "ចម្រៀងលេខ 5", id = "rbxassetid://1845014938", duration = 160},
}

-- =====================
-- ការកំណត់
-- =====================

local DefaultMusicID = SongLibrary[1].id
local DefaultVolume = 0.8
local MaxDistance = 150
local MinDistance = 10

-- =====================
-- បង្កើត Sound Objects
-- =====================

local CurrentMusic = Instance.new("Sound")
CurrentMusic.Name = "BoomboxMusic"
CurrentMusic.SoundId = DefaultMusicID
CurrentMusic.Volume = DefaultVolume
CurrentMusic.Looped = false -- នឹងប្រើប្រព័ន្ធចាក់បន្ទាប់ដោយខ្លួនឯង

-- ការកំណត់សំឡេង 3D
CurrentMusic.RollOffMode = Enum.RollOffMode.InverseTapered
CurrentMusic.RollOffMaxDistance = MaxDistance
CurrentMusic.RollOffMinDistance = MinDistance
CurrentMusic.EmitterSize = 15

CurrentMusic.Parent = Handle

-- បង្កើតសំឡេងបែបផែន
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://9125405871" -- សំឡេងចុច
ClickSound.Volume = 0.5
ClickSound.Parent = Handle

local BassBoost = Instance.new("EqualizerSoundEffect")
BassBoost.LowGain = 3
BassBoost.MidGain = 0
BassBoost.HighGain = 1
BassBoost.Parent = CurrentMusic

local Reverb = Instance.new("ReverbSoundEffect")
Reverb.DecayTime = 1
Reverb.DryLevel = -3
Reverb.WetLevel = -6
Reverb.Parent = CurrentMusic

-- =====================
-- បែបផែនភ្លើង
-- =====================

local function createLightEffects()
	-- បង្កើតភ្លើង Point Light
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0
	pointLight.Range = 15
	pointLight.Color = Color3.fromRGB(0, 255, 255) -- ពណ៌ខៀវភ្លឺ
	pointLight.Parent = Handle
	
	-- បង្កើតភ្លើងសម្រាប់ចង្វាក់
	local beatLight = Instance.new("PointLight")
	beatLight.Brightness = 0
	beatLight.Range = 20
	beatLight.Color = Color3.fromRGB(255, 0, 255) -- ពណ៌ស្វាយ
	beatLight.Parent = Handle
	
	return pointLight, beatLight
end

local mainLight, beatLight = createLightEffects()

-- =====================
-- GUI សម្រាប់បង្ហាញស្ថានភាព
-- =====================

local function createStatusGUI(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BoomboxStatus"
	screenGui.ResetOnSpawn = false
	
	local statusFrame = Instance.new("Frame")
	statusFrame.Size = UDim2.new(0, 200, 0, 40)
	statusFrame.Position = UDim2.new(0.5, -100, 0, 10)
	statusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	statusFrame.BackgroundTransparency = 0.5
	statusFrame.BorderSizePixel = 0
	statusFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = statusFrame
	
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, 0, 1, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 14
	statusLabel.Text = "🎵 ត្រៀមរួចរាល់"
	statusLabel.Parent = statusFrame
	
	screenGui.Parent = playerGui
	
	return statusLabel
end

-- =====================
-- Variables
-- =====================

local IsPlaying = false
local CurrentOwner = nil
local CurrentSongIndex = 1
local CurrentVolume = DefaultVolume
local IsShuffle = false
local PlayedSongs = {}

-- =====================
-- មុខងារជំនួយ
-- =====================

local function getNextSongIndex()
	if IsShuffle then
		-- ចាក់ចៃដន្យ
		if #PlayedSongs == #SongLibrary then
			PlayedSongs = {} -- កំណត់ឡើងវិញនៅពេលចាក់អស់ទាំងអស់
		end
		
		local randomIndex
		repeat
			randomIndex = math.random(1, #SongLibrary)
		until not table.find(PlayedSongs, randomIndex)
		
		table.insert(PlayedSongs, randomIndex)
		return randomIndex
	else
		-- ចាក់តាមលំដាប់
		local nextIndex = CurrentSongIndex + 1
		if nextIndex > #SongLibrary then
			nextIndex = 1 -- ត្រឡប់ទៅចម្រៀងដំបូង
		end
		return nextIndex
	end
end

local function updateMusicInfo()
	if CurrentOwner then
		local currentSong = SongLibrary[CurrentSongIndex]
		musicUpdateEvent:FireClient(CurrentOwner, {
			songName = currentSong.name,
			songIndex = CurrentSongIndex,
			totalSongs = #SongLibrary,
			isPlaying = IsPlaying,
			volume = CurrentVolume,
			isShuffle = IsShuffle
		})
	end
end

-- =====================
-- មុខងារពន្លឺ
-- =====================

local function startLightShow()
	-- បង្កើតចលនាពន្លឺនៅពេលចាក់តន្ត្រី
	local lightTween = TweenService:Create(mainLight, 
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
		{Brightness = 5}
	)
	lightTween:Play()
	
	-- បង្កើតពន្លឺតាមចង្វាក់
	spawn(function()
		while IsPlaying do
			local beatTween = TweenService:Create(beatLight,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Brightness = 8}
			)
			beatTween:Play()
			
			task.wait(0.5) -- ចង្វាក់ពន្លឺ
			
			local fadeTween = TweenService:Create(beatLight,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Brightness = 0}
			)
			fadeTween:Play()
			
			task.wait(0.5)
		end
	end)
end

local function stopLightShow()
	mainLight.Brightness = 0
	beatLight.Brightness = 0
end

-- =====================
-- មុខងារចាក់តន្ត្រី
-- =====================

local function playCurrentSong()
	if CurrentMusic.IsLoaded then
		CurrentMusic:Play()
		startLightShow()
	else
		CurrentMusic.Loaded:Wait()
		CurrentMusic:Play()
		startLightShow()
	end
end

local function stopMusic()
	CurrentMusic:Stop()
	stopLightShow()
end

local function nextSong()
	stopMusic()
	CurrentSongIndex = getNextSongIndex()
	CurrentMusic.SoundId = SongLibrary[CurrentSongIndex].id
	updateMusicInfo()
	
	if IsPlaying then
		playCurrentSong()
	end
end

-- =====================
-- ការគ្រប់គ្រងព្រឹត្តិការណ៍
-- =====================

-- ចាប់យក Tool
Tool.Equipped:Connect(function()
	local Character = Tool.Parent
	local Player = Players:GetPlayerFromCharacter(Character)
	
	if Player then
		CurrentOwner = Player
		print("🎒 " .. Player.Name .. " បានកាន់ Boombox")
		
		-- បង្កើត GUI ស្ថានភាព
		local statusLabel = createStatusGUI(Player)
		
		-- ធ្វើបច្ចុប្បន្នភាពព័ត៌មាន
		updateMusicInfo()
	end
end)

-- ចុចបើក/បិទ
Tool.Activated:Connect(function()
	if CurrentOwner == nil then
		return
	end
	
	-- លេងសំឡេងចុច
	ClickSound:Play()
	
	if IsPlaying == false then
		-- ចាប់ផ្តើមចាក់
		IsPlaying = true
		playCurrentSong()
		
		print("🎵 ចាក់តន្ត្រី៖ " .. SongLibrary[CurrentSongIndex].name .. " ដោយ " .. CurrentOwner.Name)
		
	else
		-- បិទតន្ត្រី
		IsPlaying = false
		stopMusic()
		
		print("⛔ តន្ត្រីត្រូវបានបិទ")
	end
	
	updateMusicInfo()
end)

-- ព្រឹត្តិការណ៍ក្តារចុចសម្រាប់ការគ្រប់គ្រងបន្ថែម
Tool.Equipped:Connect(function()
	local Player = CurrentOwner
	if not Player then return end
	
	local UserInputService = game:GetService("UserInputService")
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if CurrentOwner ~= Player then return end
		
		if input.KeyCode == Enum.KeyCode.N then
			-- ចុច N សម្រាប់ចម្រៀងបន្ទាប់
			if IsPlaying then
				nextSong()
				print("⏭️ ប្តូរទៅចម្រៀងបន្ទាប់៖ " .. SongLibrary[CurrentSongIndex].name)
			end
			
		elseif input.KeyCode == Enum.KeyCode.V then
			-- ចុច V សម្រាប់បន្ថយសំឡេង
			CurrentVolume = math.max(0, CurrentVolume - 0.1)
			CurrentMusic.Volume = CurrentVolume
			print("🔉 កម្រិតសំឡេង៖ " .. math.floor(CurrentVolume * 100) .. "%")
			updateMusicInfo()
			
		elseif input.KeyCode == Enum.KeyCode.B then
			-- ចុច B សម្រាប់បង្កើនសំឡេង
			CurrentVolume = math.min(1, CurrentVolume + 0.1)
			CurrentMusic.Volume = CurrentVolume
			print("🔊 កម្រិតសំឡេង៖ " .. math.floor(CurrentVolume * 100) .. "%")
			updateMusicInfo()
			
		elseif input.KeyCode == Enum.KeyCode.S then
			-- ចុច S សម្រាប់បើក/បិទ Shuffle
			IsShuffle = not IsShuffle
			print("🔀 Shuffle " .. (IsShuffle and "បើក" or "បិទ"))
			updateMusicInfo()
		end
	end)
end)

-- ដាក់ Tool ចុះ
Tool.Unequipped:Connect(function()
	if IsPlaying then
		stopMusic()
		IsPlaying = false
	end
	
	-- លុប GUI ស្ថានភាព
	if CurrentOwner then
		local playerGui = CurrentOwner:FindFirstChild("PlayerGui")
		if playerGui then
			local statusGui = playerGui:FindFirstChild("BoomboxStatus")
			if statusGui then
				statusGui:Destroy()
			end
		end
	end
	
	CurrentOwner = nil
end)

-- Player ចាកចេញ
Players.PlayerRemoving:Connect(function(Player)
	if Player == CurrentOwner then
		stopMusic()
		IsPlaying = false
		CurrentOwner = nil
	end
end)

-- ព្រឹត្តិការណ៍ចម្រៀងបញ្ចប់
CurrentMusic.Ended:Connect(function()
	if IsPlaying then
		nextSong()
	end
end)

-- Cleanup
Tool.Destroying:Connect(function()
	stopMusic()
	CurrentMusic:Destroy()
	ClickSound:Destroy()
end)

print("🎧 Advanced Boombox System Loaded!")