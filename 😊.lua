--[[
╔══════════════════════════════════════════════════════════╗
║         NPC KILLER ULTIMATE - COMPLETE                 ║
║            Version: 5.0.0 - Full UI                    ║
╚══════════════════════════════════════════════════════════╝
]]

-- ═══════════════════ SERVICES ═══════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ═══════════════════ CORE SETUP ═══════════════════
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ParentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════ CONFIGURATION ═══════════════════
local CONFIG = {
    -- NPC KILLER
    NPC_Killer = false,
    NPC_Range = 50,
    NPC_Damage = 30,
    NPC_Mode = "ALL",
    
    -- ESP
    ESP_Range = 200,
    ESP_ShowName = true,
    ESP_ShowHealth = true,
    ESP_ShowDistance = true,
    ESP_HideDead = true,
    ESP_Highlight = true,
    
    -- Movement
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 120,
    Noclip = false,
    WalkSpeedDirect = 16,
    JumpPower = 50,
    
    -- Combat
    GodMode = false,
    KillAura = false,
    KillAuraRange = 30,
    KillAuraDamage = 30,
    AutoClick = false,
    ForceField = false,
}

-- ═══════════════════ STATE ═══════════════════
local State = {
    ESPObjects = {},
    IsRunning = true,
}

-- ═══════════════════ UTILITY FUNCTIONS ═══════════════════

local function getRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") 
        or model:FindFirstChild("UpperTorso") 
        or model:FindFirstChild("Torso") 
        or model:FindFirstChild("Head")
end

local function isPlayerCharacter(model)
    if not model then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return true end
    end
    return false
end

local function isValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    if isPlayerCharacter(model) then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = getRootPart(model)
    
    if not hum or not root then return false end
    if hum.Health <= 0 then return false end
    
    return true
end

local function getDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function getAllNPCs()
    local npcs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isValidNPC(obj) then
            table.insert(npcs, obj)
        end
    end
    return npcs
end

-- ═══════════════════ NPC KILLER METHODS ═══════════════════

local function killNPC(npc, damage)
    if not npc or not npc.Parent then return false end
    
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    -- Method 1: TakeDamage
    pcall(function()
        hum:TakeDamage(damage)
    end)
    if hum.Health <= 0 then return true end
    
    -- Method 2: Set Health
    pcall(function()
        hum.Health = math.max(0, hum.Health - damage)
    end)
    if hum.Health <= 0 then return true