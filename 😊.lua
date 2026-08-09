-- ==================================================
-- MKRA HUB - COMPLETE WITH NPC KILLER
-- All Systems Fixed + NPC Killer Added
-- ==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local DEFAULT_IMAGE = "rbxassetid://0"
local IMAGE_URL = "https://files.catbox.moe/ka5x56.jpg"

-- ==================================================
-- SETTINGS (Added NPC Killer)
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
    
    -- NPC KILLER SETTINGS
    NPC_Killer = false,
    NPC_Kill_Range = 50,
    NPC_Kill_Damage = 30,
    NPC_Kill_Interval = 0.15,
    NPC_Kill_Mode = "ALL", -- ALL, NEAREST, LOWEST_HP
    NPC_Kill_UseRemotes = true,
    NPC_Kill_UseRaycast = true,
    
    VIPFreezeHold = false,
    VIPFreezeKill = false,
    FullBright = false,
    FOV = 70,
    GodMode = false,
    InstantRespawn = false,
    AutoF = false,
    PlayerESP = false,
    AutoChop = false,
    CombatRange = 30,
    CombatPreview = false
}

-- ==================================================
-- STATE MANAGEMENT
-- ==================================================

local State = {
    FlyConnection = nil,
    NoclipConnection = nil,
    ESPObjects = {},
    PlayerESPObjects = {},
    GodModeConnection = nil,
    AutoFConnection = nil,
    FreezeConnection = nil,
    AutoChopConnection = nil,
    CombatConnection = nil,
    NPCKillConnection = nil,
    IsRunning = true
}

-- ==================================================
-- UTILITY FUNCTIONS
-- ==================================================

local function getRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function isValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return false end
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(model)
    return hum ~= nil and root ~= nil
end

local function isValidPlayer(model)
    if not model or not model:IsA("Model") then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model and player ~= LocalPlayer then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = getRootPart(model)
            return hum ~= nil and root ~= nil and hum.Health > 0
        end
    end
    return false
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

-- ==================================================
-- NPC KILLER SYSTEM (5 METHODS)
-- ==================================================

-- Method 1: Direct Damage
local function killMethod_Direct(npc, damage)
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local success = pcall(function()
        hum:TakeDamage(damage)
    end)
    
    return success and hum.Health <= 0
end

-- Method 2: Health Manipulation
local function killMethod_Health(npc, damage)
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local success = pcall(function()
        hum.Health = math.max(0, hum.Health - damage)
    end)
    
    return success and hum.Health <= 0
end

-- Method 3: Remote Event Firing
local function killMethod_Remote(npc)
    local remotes = {}
    
    local function scanForRemotes(obj)
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("attack") or name:find("hit") or 
               name:find("damage") or name:find("kill") then
                table.insert(remotes, obj)
            end
        elseif obj:IsA("Folder") then
            for _, child in ipairs(obj:GetChildren()) do
                scanForRemotes(child)
            end
        end
    end
    
    pcall(function()
        if game:GetService("ReplicatedStorage") then 
            scanForRemotes(game:GetService("ReplicatedStorage")) 
        end
        if Workspace then scanForRemotes(Workspace) end
    end)
    
    for _, remote in ipairs(remotes) do
        local success = pcall(function()
            remote:FireServer(npc)
        end)
        if success then return true end
    end
    
    return false
end

-- Method 4: Raycast Hit Simulation
local function killMethod_Raycast(npc)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    local npcRoot = getRootPart(npc)
    if not npcRoot then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local origin = char:GetPivot().Position
    local direction = (npcRoot.Position - origin).Unit * 50
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result and result.Instance and result.Instance:IsDescendantOf(npc) then
        local hitRemote = nil
        
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("RemoteEvent") and child.Name:lower():find("hit") then
                hitRemote = child
                break
            end
        end
        
        if hitRemote then
            pcall(function()
                hitRemote:FireServer(result.Instance, result.Position)
            end)
            return true
        end
    end
    
    return false
end

-- Method 5: Model Destruction (Last Resort)
local function killMethod_Destroy(npc)
    local success = pcall(function()
        npc:Destroy()
    end)
    return success
end

-- Master Kill Function
local function killNPC(npc, damage)
    if not npc or not npc.Parent then return false end
    
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local methods = {
        function() return killMethod_Direct(npc, damage) end,
        function() return killMethod_Health(npc, damage) end,
    }
    
    if Settings.NPC_Kill_UseRemotes then
        table.insert(methods, function() return killMethod_Remote(npc) end)
    end
    
    if Settings.NPC_Kill_UseRaycast then
        table.insert(methods, function() return killMethod_Raycast(npc) end)
    end
    
    for _, method in ipairs(methods) do
        local success = method()
        if success then return true end
    end
    
    return false
end

-- ==================================================
-- FLY SYSTEM
-- ==================================================

local function startFly()
    if State.FlyConnection then
        State.FlyConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = getRootPart(character)
    
    if not humanoid or not rootPart then return end
    
    for _, obj in ipairs(rootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyForce") then
            obj:Destroy()
        end
    end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 1e4
    bodyGyro.Parent = rootPart
    
    local bodyForce = Instance.new("BodyForce")
    bodyForce.Force = Vector3.new(0, workspace.Gravity * rootPart.AssemblyMass, 0)
    bodyForce.Parent = rootPart
    
    State.FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly or not character or not character.Parent then
            pcall(function()
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
                bodyForce:Destroy()
            end)
            return
        end
        
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        local speed = Settings.FlySpeed
        if Settings.BoostMode then speed = speed * 2 end
        
        bodyVelocity.Velocity = moveDirection * speed
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFly()
    if State.FlyConnection then
        State.FlyConnection:Disconnect()
        State.FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = getRootPart(character)
    if not rootPart then return end
    
    pcall(function()
        for _, obj in ipairs(rootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyForce") then
                obj:Destroy()
            end
        end
    end)
end

-- ==================================================
-- NOCLIP SYSTEM
-- ==================================================

local function toggleNoclip()
    if State.NoclipConnection then
        State.NoclipConnection:Disconnect()
        State.NoclipConnection = nil
    end
    
    if not Settings.Noclip then return end
    
    State.NoclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Noclip then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end)
end

-- ==================================================
-- WALK SPEED UPDATE
-- ==================================================

local function updateWalkSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = math.max(16, 16 * Settings.SpeedBoostMultiplier)
    end
end

-- ==================================================
-- ESP SYSTEMS
-- ==================================================

local function createPlayerESP(player)
    if State.PlayerESPObjects[player] then return end
    
    local character = player.Character
    if not character or not isValidPlayer(character) then return end
    
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(character)
    if not hum or not root then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Enabled = Settings.PlayerESP
    highlight.Parent = character
    
    State.PlayerESPObjects[player] = {
        Highlight = highlight,
        Humanoid = hum,
        Root = root
    }
end

local function removePlayerESP(player)
    local data = State.PlayerESPObjects[player]
    if not data then return end
    pcall(function() data.Highlight:Destroy() end)
    State.PlayerESPObjects[player] = nil
end

local function updateESP()
    for player, data in pairs(State.PlayerESPObjects) do
        if data.Highlight then
            data.Highlight.Enabled = Settings.PlayerESP
        end
    end
end

local function scanPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createPlayerESP(player)
        end
    end
end

local function createNPCESP(npc)
    if State.ESPObjects[npc] then return end
    if not isValidNPC(npc) then return end
    
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(npc)
    if not hum or not root then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPC_ESP"
    highlight.Adornee = npc
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(220, 150, 200)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.15
    highlight.Enabled = false
    highlight.Parent = npc
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(180, 48)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = CoreGui
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    
    local healthBG = Instance.new("Frame", billboard)
    healthBG.Size = UDim2.new(1, 0, 0, 6)
    healthBG.Position = UDim2.fromOffset(0, 20)
    healthBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    healthBG.BorderSizePixel = 0
    Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0, 4)
    
    local healthFill = Instance.new("Frame", healthBG)
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = Color3.fromRGB(35, 225, 110)
    healthFill.BorderSizePixel = 0
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0, 4)
    
    local infoLabel = Instance.new("TextLabel", billboard)
    infoLabel.Size = UDim2.new(1, 0, 0, 18)
    infoLabel.Position = UDim2.fromOffset(0, 27)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(165, 170, 195)
    infoLabel.TextSize = 8
    infoLabel.Font = Enum.Font.GothamMedium
    infoLabel.TextStrokeTransparency = 0.5
    
    State.ESPObjects[npc] = {
        Highlight = highlight,
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthBG = healthBG,
        HealthFill = healthFill,
        InfoLabel = infoLabel,
        Humanoid = hum,
        Root = root,
    }
end

local function removeNPCESP(npc)
    local data = State.ESPObjects[npc]
    if not data then return end
    pcall(function() 
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end)
    State.ESPObjects[npc] = nil
end

local function scanNPCs()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isValidNPC(obj) then
            createNPCESP(obj)
        end
    end
end

-- ==================================================
-- NPC KILLER LOOP
-- ==================================================

task.spawn(function()
    while State.IsRunning and task.wait(Settings.NPC_Kill_Interval) do
        if not Settings.NPC_Killer then continue end
        
        local char = LocalPlayer.Character
        local playerRoot = char and getRootPart(char)
        if not playerRoot then continue end
        
        local nearestNPC = nil
        local nearestDist = math.huge
        local lowestHP_NPC = nil
        local lowestHP = math.huge
        
        for npc, data in pairs(State.ESPObjects) do
            if npc.Parent and data.Root and data.Humanoid then
                local dist = (playerRoot.Position - data.Root.Position).Magnitude
                local hp = data.Humanoid.Health
                
                if dist < nearestDist and dist <= Settings.NPC_Kill_Range then
                    nearestDist = dist
                    nearestNPC = npc
                end
                
                if hp < lowestHP and dist <= Settings.NPC_Kill_Range then
                    lowestHP = hp
                    lowestHP_NPC = npc
                end
            end
        end
        
        for npc, data in pairs(State.ESPObjects) do
            if not npc.Parent or not data.Root or not data.Humanoid then continue end
            
            local hum = data.Humanoid
            local root = data.Root
            local alive = hum.Health > 0
            local dist = (playerRoot.Position - root.Position).Magnitude
            
            if alive and dist <= Settings.NPC_Kill_Range then
                local shouldKill = false
                
                if Settings.NPC_Kill_Mode == "ALL" then
                    shouldKill = true
                elseif Settings.NPC_Kill_Mode == "NEAREST" then
                    shouldKill = (npc == nearestNPC)
                elseif Settings.NPC_Kill_Mode == "LOWEST_HP" then
                    shouldKill = (npc == lowestHP_NPC)
                end
                
                if shouldKill then
                    killNPC(npc, Settings.NPC_Kill_Damage)
                end
            end
        end
    end
end)

-- ESP Update Loop
task.spawn(function()
    while State.IsRunning and task.wait(0.1) do
        local char = LocalPlayer.Character
        local playerRoot = char and getRootPart(char)
        
        for npc, data in pairs(State.ESPObjects) do
            if not npc.Parent then
                removeNPCESP(npc)
            else
                local hum = data.Humanoid
                local root = data.Root
                if not hum or not root then
                    removeNPCESP(npc)
                else
                    local alive = hum.Health > 0
                    local dist = playerRoot and (playerRoot.Position - root.Position).Magnitude or math.huge
                    
                    local visible = Settings.NPC_ESP
                    if dist > Settings.NPC_ESP_Range then visible = false end
                    if Settings.NPC_ESP_HideDead and not alive then visible = false end
                    
                    data.Highlight.Enabled = visible
                    data.Billboard.Enabled = visible
                    
                    if visible then
                        if Settings.NPC_ESP_Name then
                            data.NameLabel.Text = npc.Name
                            data.NameLabel.Visible = true
                        else
                            data.NameLabel.Visible = false
                        end
                        
                        if Settings.NPC_ESP_Health then
                            local maxHP = math.max(hum.MaxHealth, 1)
                            local percent = math.clamp(hum.Health / maxHP, 0, 1)
                            data.HealthBG.Visible = true
                            data.HealthFill.Size = UDim2.new(percent, 0, 1, 0)
                            
                            if percent > 0.6 then
                                data.HealthFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
                            elseif percent > 0.3 then
                                data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                            else
                                data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                            end
                        else
                            data.HealthBG.Visible = false
                        end
                        
                        if Settings.NPC_ESP_Distance and playerRoot then
                            data.InfoLabel.Visible = true
                            data.InfoLabel.Text = math.floor(dist) .. " studs"
                        else
                            data.InfoLabel.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

-- ==================================================
-- GOD MODE
-- ==================================================

local function toggleGodMode()
    if State.GodModeConnection then
        State.GodModeConnection:Disconnect()
        State.GodModeConnection = nil
    end
    
    if not Settings.GodMode then return end
    
    State.GodModeConnection = RunService.RenderStepped:Connect(function()
        if not Settings.GodMode then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

-- ==================================================
-- INSTANT RESPAWN
-- ==================================================

local function toggleInstantRespawn()
    if not Settings.InstantRespawn then return end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if not Settings.InstantRespawn then return end
        
        character:WaitForChild("Humanoid")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.Died:Connect(function()
                task.wait(0.1)
                LocalPlayer:LoadCharacter()
            end)
        end
    end)
end

-- ==================================================
-- AUTO F (FIXED - No VirtualInputManager)
-- ==================================================

local function toggleAutoF()
    if State.AutoFConnection then
        State.AutoFConnection:Disconnect()
        State.AutoFConnection = nil
    end
    
    if not Settings.AutoF then return end
    
    -- Use fireproximityprompt instead
    State.AutoFConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoF then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local dist = (obj.Parent.Position - char:GetPivot().Position).Magnitude
                if dist <= 10 then
                    pcall(function()
                        fireproximityprompt(obj)
                    end)
                end
            end
        end
    end)
end

-- ==================================================
-- AUTO CHOP
-- ==================================================

local function toggleAutoChop()
    if State.AutoChopConnection then
        State.AutoChopConnection:Disconnect()
        State.AutoChopConnection = nil
    end
    
    if not Settings.AutoChop then return end
    
    State.AutoChopConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoChop then return end
        
        local char = LocalPlayer.Character
        local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("tree") or obj.Name:lower():find("wood")) then
                local root = getRootPart(obj) or obj:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (playerRoot.Position - root.Position).Magnitude
                    if dist < 10 then
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- ==================================================
-- VIP FREEZE SYSTEMS
-- ==================================================

local function toggleVIPFreezeHold()
    if State.FreezeConnection then
        State.FreezeConnection:Disconnect()
        State.FreezeConnection = nil
    end
    
    if not Settings.VIPFreezeHold and not Settings.VIPFreezeKill then return end
    
    State.FreezeConnection = RunService.RenderStepped:Connect(function()
        if not Settings.VIPFreezeHold and not Settings.VIPFreezeKill then return end
        
        local char = LocalPlayer.Character
        local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        
        for npc, data in pairs(State.ESPObjects) do
            if npc.Parent and data.Root and data.Humanoid then
                local dist = (playerRoot.Position - data.Root.Position).Magnitude
                
                if dist <= 50 then
                    local root = data.Root
                    if root:IsA("BasePart") then
                        pcall(function()
                            root.Velocity = Vector3.new(0, 0, 0)
                            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end)
                    end
                    
                    if Settings.VIPFreezeKill and data.Humanoid.Health > 0 then
                        pcall(function()
                            data.Humanoid:TakeDamage(100)
                        end)
                    end
                end
            end
        end
    end)
end

local function toggleVIPFreezeKill()
    toggleVIPFreezeHold()
end

-- ==================================================
-- COMBAT PREVIEW
-- ==================================================

local function toggleCombatPreview()
    if State.CombatConnection then
        State.CombatConnection:Disconnect()
        State.CombatConnection = nil
    end
    
    if not Settings.CombatPreview then return end
    
    State.CombatConnection = RunService.RenderStepped:Connect(function()
        if not Settings.CombatPreview then return end
        
        local char = LocalPlayer.Character
        local playerRoot = char and getRootPart(char)
        if not playerRoot then return end
        
        for npc, data in pairs(State.ESPObjects) do
            if npc.Parent and data.Root and data.Humanoid then
                local dist = (playerRoot.Position - data.Root.Position).Magnitude
                
                if dist <= Settings.CombatRange then
                    data.Highlight.FillColor = Color3.fromRGB(255, 50, 50)
                else
                    data.Highlight.FillColor = Color3.fromRGB(220, 150, 200)
                end
            end
        end
    end)
end

-- ==================================================
-- INFINITE JUMP
-- ==================================================

UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJumpOrig then return end
    
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

-- ==================================================
-- LOAD IMAGE
-- ==================================================

local function loadImage()
    local asset = ""
    pcall(function()
        if request and writefile and getcustomasset then
            local response = request({ Url = IMAGE_URL, Method = "GET" })
            if response and response.StatusCode == 200 then
                writefile("mkra_bg.jpg", response.Body)
                asset = getcustomasset("mkra_bg.jpg")
            end
        end
    end)
    return asset
end

-- ==================================================
-- UI CREATION (FULL CODE WITH NPC KILLER TAB)
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

    local Theme = {
        Background = Color3.fromRGB(12, 12, 18),
        Surface = Color3.fromRGB(20, 20, 29),
        Surface2 = Color3.fromRGB(27, 27, 38),
        Card = Color3.fromRGB(30, 30, 42),
        Text = Color3.fromRGB(245, 245, 250),
        SubText = Color3.fromRGB(150, 150, 165),
        Accent = Color3.fromRGB(220, 150, 200),
        Success = Color3.fromRGB(75, 220, 145),
        Warning = Color3.fromRGB(255, 190, 70),
        Error = Color3.fromRGB(240, 80, 100),
        Info = Color3.fromRGB(90, 170, 255),
        Stroke = Color3.fromRGB(65, 65, 82)
    }

    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
        return c
    end

    local function stroke(obj, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or Theme.Stroke
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = obj
        return s
    end

    -- Notification System
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
        if NotificationHolder and NotificationHolder.Parent then
            return NotificationHolder
        end

        NotificationHolder = Instance.new("Frame")
        NotificationHolder.Name = "NotificationHolder"
        NotificationHolder.AnchorPoint = Vector2.new(1, 0)
        NotificationHolder.Position = UDim2.new(1, -16, 0, 16)
        NotificationHolder.Size = UDim2.new(0, 340, 1, -32)
        NotificationHolder.BackgroundTransparency = 1
        NotificationHolder.ZIndex = 1000
        NotificationHolder.Parent = gui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = NotificationHolder

        return NotificationHolder
    end

    local function notify(titleText, messageText, duration, notificationType)
        notificationType = notificationType or "Info"
        duration = tonumber(duration) or 3

        if not NotificationColors[notificationType] then
            notificationType = "Info"
        end

        local color = NotificationColors[notificationType]
        local iconText = NotificationIcons[notificationType]
        local holder = createNotificationHolder()

        local card = Instance.new("CanvasGroup")
        card.Name = "Notification"
        card.Size = UDim2.new(1, 0, 0, 78)
        card.BackgroundColor3 = Theme.Surface
        card.BackgroundTransparency = 0.03
        card.BorderSizePixel = 0
        card.GroupTransparency = 1
        card.ClipsDescendants = true
        card.LayoutOrder = -math.floor(os.clock() * 1000)
        card.ZIndex = 1001
        card.Parent = holder

        corner(card, 14)
        stroke(card, color, 1, 0.35)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.BackgroundColor3 = color
        accent.BorderSizePixel = 0
        accent.ZIndex = 1002
        accent.Parent = card
        corner(accent, 8)

        local iconBox = Instance.new("Frame")
        iconBox.Size = UDim2.fromOffset(38, 38)
        iconBox.Position = UDim2.fromOffset(12, 13)
        iconBox.BackgroundColor3 = color
        iconBox.BackgroundTransparency = 0.82
        iconBox.BorderSizePixel = 0
        iconBox.ZIndex = 1003
        iconBox.Parent = card
        corner(iconBox, 12)
        stroke(iconBox, color, 1, 0.5)

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromScale(1, 1)
        icon.BackgroundTransparency = 1
        icon.Text = iconText
        icon.TextColor3 = color
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 18
        icon.ZIndex = 1004
        icon.Parent = iconBox

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -105, 0, 22)
        title.Position = UDim2.fromOffset(60, 9)
        title.BackgroundTransparency = 1
        title.Text = tostring(titleText)
        title.TextColor3 = Theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 1004
        title.Parent = card

        local message = Instance.new("TextLabel")
        message.Size = UDim2.new(1, -105, 0, 28)
        message.Position = UDim2.fromOffset(60, 31)
        message.BackgroundTransparency = 1
        message.Text = tostring(messageText)
        message.TextColor3 = Theme.SubText
        message.Font = Enum.Font.GothamMedium
        message.TextSize = 9
        message.TextWrapped = true
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.ZIndex = 1004
        message.Parent = card

        local close = Instance.new("TextButton")
        close.Size = UDim2.fromOffset(25, 25)
        close.Position = UDim2.new(1, -31, 0, 7)
        close.BackgroundTransparency = 1
        close.Text = "×"
        close.TextColor3 = Theme.SubText
        close.Font = Enum.Font.GothamBold
        close.TextSize = 17
        close.AutoButtonColor = false
        close.ZIndex = 1005
        close.Parent = card

        close.MouseEnter:Connect(function()
            close.TextColor3 = color
        end)

        close.MouseLeave:Connect(function()
            close.TextColor3 = Theme.SubText
        end)

        local progressBG = Instance.new("Frame")
        progressBG.Size = UDim2.new(1, -20, 0, 3)
        progressBG.Position = UDim2.new(0, 10, 1, -7)
        progressBG.BackgroundColor3 = Theme.Surface2
        progressBG.BorderSizePixel = 0
        progressBG.ZIndex = 1006
        progressBG.Parent = card
        corner(progressBG, 99)

        local progress = Instance.new("Frame")
        progress.Size = UDim2.fromScale(1, 1)
        progress.BackgroundColor3 = color
        progress.BorderSizePixel = 0
        progress.ZIndex = 1007
        progress.Parent = progressBG
        corner(progress, 99)

        local removed = false

        local function remove()
            if removed then return end
            removed = true

            local tween = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                GroupTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                if card and card.Parent then
                    card:Destroy()
                end
            end)
        end

        close.MouseButton1Click:Connect(remove)

        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            GroupTransparency = 0
        }):Play()

        TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()

        task.delay(duration, function()
            if card and card.Parent then
                remove()
            end
        end)

        return card
    end

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.fromOffset(52, 52)
    toggleBtn.Position = UDim2.new(0, 18, 0.5, -26)
    toggleBtn.BackgroundColor3 = Theme.Surface
    toggleBtn.Image = imageAsset ~= "" and imageAsset or DEFAULT_IMAGE
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = gui
    corner(toggleBtn, 16)
    local toggleStroke = stroke(toggleBtn, Theme.Accent, 2)

    local main = Instance.new("CanvasGroup")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.fromOffset(440, 520)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.GroupTransparency = 1
    main.Visible = false
    main.Active = true
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 18)
    local mainStroke = stroke(main, Theme.Stroke, 1, 0.15)

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Theme.Background
    bg.BorderSizePixel = 0
    bg.ZIndex = 0
    bg.Parent = main
    corner(bg, 18)

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Rotation = 135
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 25, 45)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(12, 12, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 35))
    })
    bgGradient.Parent = bg

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -24, 0, 62)
    header.Position = UDim2.fromOffset(12, 10)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = main
    corner(header, 14)
    stroke(header, Theme.Stroke, 1, 0.45)

    local headerIcon = Instance.new("ImageLabel")
    headerIcon.Size = UDim2.fromOffset(42, 42)
    headerIcon.Position = UDim2.fromOffset(10, 10)
    headerIcon.BackgroundColor3 = Theme.Card
    headerIcon.Image = imageAsset ~= "" and imageAsset or DEFAULT_IMAGE
    headerIcon.ScaleType = Enum.ScaleType.Crop
    headerIcon.ZIndex = 11
    headerIcon.Parent = header
    corner(headerIcon, 12)
    local iconStroke = stroke(headerIcon, Theme.Accent, 1.5)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -115, 0, 25)
    title.Position = UDim2.fromOffset(62, 7)
    title.BackgroundTransparency = 1
    title.Text = "MKRA HUB"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -115, 0, 20)
    subtitle.Position = UDim2.fromOffset(63, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "VIP  •  v4.2  •  WITH NPC KILLER"
    subtitle.TextColor3 = Theme.SubText
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 11
    subtitle.Parent = header

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.fromOffset(34, 34)
    minimizeBtn.Position = UDim2.new(1, -44, 0, 14)
    minimizeBtn.BackgroundColor3 = Theme.Card
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Theme.Text
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 12
    minimizeBtn.Parent = header
    corner(minimizeBtn, 10)
    stroke(minimizeBtn, Theme.Stroke, 1)

    local status = Instance.new("Frame")
    status.Size = UDim2.new(1, -24, 0, 28)
    status.Position = UDim2.fromOffset(12, 78)
    status.BackgroundColor3 = Theme.Surface
    status.BorderSizePixel = 0
    status.ZIndex = 10
    status.Parent = main
    corner(status, 9)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(7, 7)
    statusDot.Position = UDim2.fromOffset(11, 10)
    statusDot.BackgroundColor3 = Theme.Success
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 11
    statusDot.Parent = status
    corner(statusDot, 99)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -30, 1, 0)
    statusText.Position = UDim2.fromOffset(26, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "SYSTEM READY"
    statusText.TextColor3 = Theme.SubText
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextSize = 9
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.ZIndex = 11
    statusText.Parent = status

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -24, 1, -120)
    body.Position = UDim2.fromOffset(12, 112)
    body.BackgroundTransparency = 1
    body.Parent = main

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.fromOffset(96, 1)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 10
    sidebar.Parent = body
    corner(sidebar, 14)
    stroke(sidebar, Theme.Stroke, 1, 0.5)

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 5)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Parent = sidebar

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop = UDim.new(0, 8)
    sidePad.PaddingLeft = UDim.new(0, 7)
    sidePad.PaddingRight = UDim.new(0, 7)
    sidePad.Parent = sidebar

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -106, 1, 0)
    contentFrame.Position = UDim2.fromOffset(106, 0)
    contentFrame.BackgroundColor3 = Theme.Surface
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = body
    corner(contentFrame, 14)
    stroke(contentFrame, Theme.Stroke, 1, 0.5)

    local tabs = {
        {"Move", "MOVE"},
        {"Combat", "FIGHT"},
        {"Farm", "FARM"},
        {"VIP", "VIP"},
        {"Visual", "VIEW"},
        {"Util", "UTIL"},
        {"ESP", "ESP"},
        {"NPC", "NPC"},
        {"Ctrl", "CTRL"}
    }

    local tabContainers = {}
    local tabButtons = {}

    for index, info in ipairs(tabs) do
        local tabName = info[1]
        local tabText = info[2]

        local btn = Instance.new("TextButton")
        btn.Name = tabName .. "Tab"
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Theme.Card
        btn.BackgroundTransparency = 0.65
        btn.Text = tabText
        btn.TextColor3 = Theme.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.AutoButtonColor = false
        btn.LayoutOrder = index
        btn.ZIndex = 11
        btn.Parent = sidebar
        corner(btn, 9)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.fromOffset(3, 18)
        indicator.Position = UDim2.new(0, 0, 0.5, -9)
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 12
        indicator.Parent = btn
        corner(indicator, 5)

        tabButtons[tabName] = {
            Button = btn,
            Indicator = indicator
        }

        local container = Instance.new("ScrollingFrame")
        container.Name = tabName .. "Container"
        container.Size = UDim2.new(1, -12, 1, -12)
        container.Position = UDim2.fromOffset(6, 6)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ScrollBarThickness = 2
        container.ScrollBarImageColor3 = Theme.Accent
        container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        container.Visible = false
        container.Parent = contentFrame

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 7)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = container

        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 6)
        p.PaddingRight = UDim.new(0, 6)
        p.PaddingTop = UDim.new(0, 6)
        p.PaddingBottom = UDim.new(0, 6)
        p.Parent = container

        tabContainers[tabName] = container

        btn.MouseButton1Click:Connect(function()
            for name, c in pairs(tabContainers) do
                c.Visible = false
                local b = tabButtons[name]
                b.Button.BackgroundTransparency = 0.65
                b.Button.TextColor3 = Theme.SubText
                b.Indicator.BackgroundTransparency = 1
            end

            container.Visible = true
            btn.BackgroundColor3 = Theme.Accent
            btn.BackgroundTransparency = 0.82
            btn.TextColor3 = Theme.Text
            indicator.BackgroundTransparency = 0
        end)
    end

    local function addSection(container, text)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, 0, 0, 24)
        section.BackgroundTransparency = 1
        section.Text = "  " .. string.upper(text)
        section.TextColor3 = Theme.Accent
        section.Font = Enum.Font.GothamBold
        section.TextSize = 10
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Parent = container
        return section
    end

    local function addToggle(container, text, default, callback)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(1, 0, 0, 44)
        card.BackgroundColor3 = Theme.Card
        card.BorderSizePixel = 0
        card.Text = ""
        card.AutoButtonColor = false
        card.Parent = container
        corner(card, 11)
        stroke(card, Theme.Stroke, 1, 0.65)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.fromOffset(13, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card

        local switch = Instance.new("Frame")
        switch.Size = UDim2.fromOffset(38, 20)
        switch.Position = UDim2.new(1, -51, 0.5, -10)
        switch.BackgroundColor3 = default and Theme.Accent or Theme.Surface2
        switch.BorderSizePixel = 0
        switch.Parent = card
        corner(switch, 99)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        corner(knob, 99)

        local state = default

        local function refresh()
            TweenService:Create(switch, TweenInfo.new(0.18), {
                BackgroundColor3 = state and Theme.Accent or Theme.Surface2
            }):Play()

            TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
            }):Play()
        end

        card.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            pcall(callback, state)
        end)

        return card
    end

    local function addButton(container, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 42)
        button.BackgroundColor3 = Theme.Card
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Theme.Text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 10
        button.AutoButtonColor = false
        button.Parent = container
        corner(button, 11)
        stroke(button, Theme.Stroke, 1, 0.6)

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.Surface2
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.Card
            }):Play()
        end)

        button.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        return button
    end

    local function addTextBox(container, labelText, default, callback)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 48)
        card.BackgroundColor3 = Theme.Card
        card.BorderSizePixel = 0
        card.Parent = container
        corner(card, 11)
        stroke(card, Theme.Stroke, 1, 0.65)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.42, 0, 1, 0)
        label.Position = UDim2.fromOffset(13, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.48, 0, 0, 30)
        box.Position = UDim2.new(0.48, 0, 0.5, -15)
        box.BackgroundColor3 = Theme.Surface2
        box.BorderSizePixel = 0
        box.Text = tostring(default or "")
        box.TextColor3 = Theme.Text
        box.PlaceholderColor3 = Theme.SubText
        box.Font = Enum.Font.GothamMedium
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Center
        box.Parent = card
        corner(box, 8)
        stroke(box, Theme.Stroke, 1, 0.4)

        box.FocusLost:Connect(function()
            pcall(callback, box.Text)
        end)

        return box
    end

    -- Move Tab
    addSection(tabContainers.Move, "Movement")

    addToggle(tabContainers.Move, "Fly", false, function(v)
        Settings.Fly = v
        if v then startFly() else stopFly() end
    end)

    addTextBox(tabContainers.Move, "Fly Speed", "120", function(v)
        Settings.FlySpeed = tonumber(v) or 120
    end)

    addToggle(tabContainers.Move, "Boost Mode", false, function(v)
        Settings.BoostMode = v
    end)

    addToggle(tabContainers.Move, "Noclip", false, function(v)
        Settings.Noclip = v
        toggleNoclip()
    end)

    addTextBox(tabContainers.Move, "Speed Mult", "1", function(v)
        Settings.SpeedBoostMultiplier = tonumber(v) or 1
        updateWalkSpeed()
    end)

    addToggle(tabContainers.Move, "Infinite Jump", false, function(v)
        Settings.InfiniteJumpOrig = v
        notify("Infinite Jump", v and "Enabled" or "Disabled", 2, v and "Success" or "Info")
    end)

    -- Combat Tab
    addSection(tabContainers.Combat, "Combat")

    addToggle(tabContainers.Combat, "Combat Preview", false, function(v)
        Settings.CombatPreview = v
        toggleCombatPreview()
        notify("Combat Preview", v and "Enabled" or "Disabled", 2, v and "Success" or "Info")
    end)

    addTextBox(tabContainers.Combat, "Range", "30", function(v)
        local value = tonumber(v)
        if not value then
            notify("Invalid Value", "Range must be a number.", 3, "Error")
            return
        end
        Settings.CombatRange = value
        notify("Range", "Value updated to " .. value, 2, "Success")
    end)

    -- Farm Tab
    addSection(tabContainers.Farm, "Farming")

    addToggle(tabContainers.Farm, "Auto Chop", false, function(v)
        Settings.AutoChop = v
        toggleAutoChop()
        notify("Auto Chop", v and "Enabled" or "Disabled", 2, v and "Success" or "Info")
    end)

    -- VIP Tab
    addSection(tabContainers.VIP, "VIP Tools")

    addButton(tabContainers.VIP, "Heal", function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
            notify("Heal", "Health restored.", 2, "Success")
        else
            notify("Heal", "Character not ready.", 3, "Warning")
        end
    end)

    addToggle(tabContainers.VIP, "Player ESP", false, function(v)
        Settings.PlayerESP = v
        updateESP()
    end)

    addToggle(tabContainers.VIP, "God Mode", false, function(v)
        Settings.GodMode = v
        toggleGodMode()
    end)

    addToggle(tabContainers.VIP, "Instant Respawn", false, function(v)
        Settings.InstantRespawn = v
        toggleInstantRespawn()
    end)

    -- Visual Tab
    addSection(tabContainers.Visual, "Visual")

    addTextBox(tabContainers.Visual, "Field Of View", "70", function(v)
        local value = math.clamp(tonumber(v) or 70, 70, 120)
        Settings.FOV = value
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = value
        end
        notify("FOV", "Field of view updated.", 2, "Success")
    end)

    addToggle(tabContainers.Visual, "Full Bright", false, function(v)
        Settings.FullBright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            notify("Full Bright", "Enabled.", 2, "Success")
        else
            Lighting.Brightness = 0.5
            Lighting.ClockTime = 0
            Lighting.FogEnd = 1000
            notify("Full Bright", "Disabled.", 2, "Info")
        end
    end)

    -- ESP Tab
    addSection(tabContainers.ESP, "NPC ESP")

    addToggle(tabContainers.ESP, "NPC ESP", false, function(v)
        Settings.NPC_ESP = v
        notify("NPC ESP", v and "Enabled." or "Disabled.", 2, v and "Success" or "Info")
    end)

    addToggle(tabContainers.ESP, "Show Name", true, function(v)
        Settings.NPC_ESP_Name = v
    end)

    addToggle(tabContainers.ESP, "Show Health", true, function(v)
        Settings.NPC_ESP_Health = v
    end)

    addToggle(tabContainers.ESP, "Show Distance", true, function(v)
        Settings.NPC_ESP_Distance = v
    end)

    addToggle(tabContainers.ESP, "Hide Dead", true, function(v)
        Settings.NPC_ESP_HideDead = v
    end)

    addTextBox(tabContainers.ESP, "ESP Range", "200", function(v)
        Settings.NPC_ESP_Range = tonumber(v) or 200
    end)

    -- NPC KILLER TAB (NEW!)
    addSection(tabContainers.NPC, "NPC Killer")

    addToggle(tabContainers.NPC, "🎯 NPC Killer", false, function(v)
        Settings.NPC_Killer = v
        notify("NPC Killer", v and "Enabled - Multi-Method" or "Disabled", 2, v and "Success" or "Info")
    end)

    addToggle(tabContainers.NPC, "📡 Use Remotes", true, function(v)
        Settings.NPC_Kill_UseRemotes = v
    end)

    addToggle(tabContainers.NPC, "🔫 Use Raycast", true, function(v)
        Settings.NPC_Kill_UseRaycast = v
    end)

    addTextBox(tabContainers.NPC, "Kill Range", "50", function(v)
        Settings.NPC_Kill_Range = tonumber(v) or 50
    end)

    addTextBox(tabContainers.NPC, "Damage", "30", function(v)
        Settings.NPC_Kill_Damage = tonumber(v) or 30
    end)

    addButton(tabContainers.NPC, "Mode: " .. Settings.NPC_Kill_Mode, function()
        if Settings.NPC_Kill_Mode == "ALL" then
            Settings.NPC_Kill_Mode = "NEAREST"
        elseif Settings.NPC_Kill_Mode == "NEAREST" then
            Settings.NPC_Kill_Mode = "LOWEST_HP"
        else
            Settings.NPC_Kill_Mode = "ALL"
        end
        notify("NPC Mode", "Changed to: " .. Settings.NPC_Kill_Mode, 2, "Success")
    end)

    -- Util Tab
    addSection(tabContainers.Util, "Utilities")

    addToggle(tabContainers.Util, "Auto F (Interact)", false, function(v)
        Settings.AutoF = v
        toggleAutoF()
        notify("Auto F", v and "Enabled - Uses fireproximityprompt" or "Disabled", 2, v and "Success" or "Info")
    end)

    -- Ctrl Tab
    addSection(tabContainers.Ctrl, "VIP Control")

    addToggle(tabContainers.Ctrl, "VIP Freeze Hold", false, function(v)
        Settings.VIPFreezeHold = v
        toggleVIPFreezeHold()
    end)

    addToggle(tabContainers.Ctrl, "VIP Freeze Kill", false, function(v)
        Settings.VIPFreezeKill = v
        toggleVIPFreezeKill()
    end)

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -24, 0, 18)
    footer.Position = UDim2.new(0, 12, 1, -22)
    footer.BackgroundTransparency = 1
    footer.Text = "MKRA HUB  •  VIP  •  WITH NPC KILLER"
    footer.TextColor3 = Theme.SubText
    footer.Font = Enum.Font.GothamMedium
    footer.TextSize = 8
    footer.TextXAlignment = Enum.TextXAlignment.Center
    footer.ZIndex = 20
    footer.Parent = main

    tabContainers.Move.Visible = true
    tabButtons.Move.Button.BackgroundColor3 = Theme.Accent
    tabButtons.Move.Button.BackgroundTransparency = 0.82
    tabButtons.Move.Button.TextColor3 = Theme.Text
    tabButtons.Move.Indicator.BackgroundTransparency = 0

    local function openUI()
        main.Visible = true
        main.GroupTransparency = 1
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            GroupTransparency = 0
        }):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), {
            Rotation = 180
        }):Play()
    end

    local function closeUI()
        local tween = TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            GroupTransparency = 1
        })
        tween:Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.22), {
            Rotation = 0
        }):Play()
        tween.Completed:Wait()
        main.Visible = false
    end

    local restoreButton

    local function minimizeUI()
        main.Visible = false
        if restoreButton then return end

        restoreButton = Instance.new("TextButton")
        restoreButton.Name = "RestoreButton"
        restoreButton.Size = UDim2.fromOffset(48, 48)
        restoreButton.Position = UDim2.fromScale(0.5, 0.5)
        restoreButton.AnchorPoint = Vector2.new(0.5, 0.5)
        restoreButton.BackgroundColor3 = Theme.Surface
        restoreButton.Text = "MK"
        restoreButton.TextColor3 = Theme.Text
        restoreButton.Font = Enum.Font.GothamBold
        restoreButton.TextSize = 12
        restoreButton.AutoButtonColor = false
        restoreButton.ZIndex = 100
        restoreButton.Parent = gui
        corner(restoreButton, 14)
        local rs = stroke(restoreButton, Theme.Accent, 2)

        restoreButton.MouseButton1Click:Connect(function()
            restoreButton:Destroy()
            restoreButton = nil
            openUI()
        end)
    end

    minimizeBtn.MouseButton1Click:Connect(minimizeUI)

    local function makeDraggable(handle, frame)
        local dragging = false
        local dragStart
        local startPos

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    makeDraggable(header, main)

    local toggleDragging = false
    local toggleMoved = false
    local toggleStart
    local toggleStartPosition

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragging = true
            toggleMoved = false
            toggleStart = input.Position
            toggleStartPosition = toggleBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not toggleDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - toggleStart
            if delta.Magnitude > 5 then toggleMoved = true end
            toggleBtn.Position = UDim2.new(toggleStartPosition.X.Scale, toggleStartPosition.X.Offset + delta.X, toggleStartPosition.Y.Scale, toggleStartPosition.Y.Offset + delta.Y)
        end
    end)

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not toggleMoved then
                if main.Visible then closeUI() else openUI() end
            end
            toggleDragging = false
        end
    end)

    task.spawn(function()
        while gui.Parent do
            local hue = (os.clock() * 0.18) % 1
            local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
            mainStroke.Color = rainbowColor
            toggleStroke.Color = rainbowColor
            iconStroke.Color = rainbowColor
            title.TextColor3 = rainbowColor
            task.wait(0.04)
        end
    end)

    main.Visible = false
    main.GroupTransparency = 1

    scanNPCs()
    scanPlayers()
    
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.wait(0.1)
            if isValidNPC(obj) then
                createNPCESP(obj)
            end
        end
    end)
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if Settings.PlayerESP then
                createPlayerESP(player)
            end
        end)
    end)

    task.delay(0.5, function()
        notify("MKRA Hub", "Loaded with NPC Killer!", 3, "Success")
    end)
    
    print("✅ MKRA HUB v4.2 - WITH NPC KILLER!")
end

task.spawn(function()
    local image = loadImage()
    createUI(image)
end)

game:BindToClose(function()
    State.IsRunning = false
    if State.FlyConnection then State.FlyConnection:Disconnect() end
    if State.NoclipConnection then State.NoclipConnection:Disconnect() end
    if State.GodModeConnection then State.GodModeConnection:Disconnect() end
    if State.AutoFConnection then State.AutoFConnection:Disconnect() end
    if State.FreezeConnection then State.FreezeConnection:Disconnect() end
    if State.AutoChopConnection then State.AutoChopConnection:Disconnect() end
    if State.CombatConnection then State.CombatConnection:Disconnect() end
    if State.NPCKillConnection then State.NPCKillConnection:Disconnect() end
end)