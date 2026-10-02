--[[
    ═══════════════════════════════════════════════════════════
      ⚡ TELEPORT SYSTEM — Instant To Egg + Return Home
      តេឡេផតទៅពងភ្លាម → ចុចយក → តេឡេផតមកវិញភ្លាម
    ═══════════════════════════════════════════════════════════
]]

local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Runtime = {
    IsReturning = false,
    HomePosition = nil,  -- CFrame កំណត់ទីតាំង
    TeleportDelay = 0.05,
    AutoCollectEgg = false,
    AutoReturnOnHold = false,
}

local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ═══════════════ 📍 កំណត់ទីតាំងកំណត់ ═══════════════
local function saveHome()
    local hrp = getHRP()
    if hrp then
        Runtime.HomePosition = hrp.CFrame
        print("[Teleport] បានកំណត់ទីតាំងកំណត់!")
        return true
    end
    return false
end

-- ═══════════════ 🏠 តេឡេផតទៅកន្លែងកំណត់ ═══════════════
local function goHome()
    local hrp = getHRP()
    if hrp and Runtime.HomePosition then
        hrp.CFrame = Runtime.HomePosition
        return true
    end
    return false
end

-- ═══════════════ 🥚 ស្វែងរកពង ═══════════════
local function findEgg()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("steal") or n:find("ពង") then
                return obj
            end
        elseif obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local t = (obj.ActionText .. " " .. obj.ObjectText):lower()
                if t:find("egg") or t:find("steal") then
                    return parent
                end
            end
        end
    end
    return nil
end

-- ═══════════════ ⚡ ចុចយកពង ═══════════════
local function collectEgg(eggPart)
    local hrp = getHRP()
    if not hrp or not eggPart or not eggPart.Parent then return false end

    local originalCF = Runtime.HomePosition or hrp.CFrame

    -- 1. ⚡ តេឡេផតទៅពងភ្លាម
    hrp.CFrame = CFrame.new(eggPart.Position + Vector3.new(0, 3, 0))
    task.wait(Runtime.TeleportDelay)

    -- 2. ចុចយកពង
    pcall(function()
        for _, prompt in ipairs(eggPart:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
            end
        end
        if firetouchinterest then
            firetouchinterest(hrp, eggPart, 0)
            task.wait(0.03)
            firetouchinterest(hrp, eggPart, 1)
        end
        for _, cd in ipairs(eggPart:GetDescendants()) do
            if cd:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(cd)
            end
        end
    end)

    task.wait(Runtime.TeleportDelay)

    -- 3. ⚡ តេឡេផតមកវិញភ្លាម
    hrp.CFrame = originalCF
    return true
end

-- ═══════════════ ⚡ AUTO COLLECT LOOP ═══════════════
task.spawn(function()
    while task.wait(0.15) do
        if Runtime.AutoCollectEgg and not Runtime.IsReturning then
            local egg = findEgg()
            if egg then
                collectEgg(egg)
            else
                task.wait(0.5)
            end
        end
    end
end)

-- ═══════════════ ⚡ AUTO RETURN ពេលកាន់ពង ═══════════════
local function isHoldingEgg()
    local char = getChar()
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local n = child.Name:lower()
            if n:find("egg") or n:find("steal") then return true end
        end
    end
    if char:GetAttribute("HoldingEgg") or char:GetAttribute("HasEgg") then
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if Runtime.AutoReturnOnHold and Runtime.HomePosition and not Runtime.IsReturning then
            if isHoldingEgg() then
                Runtime.IsReturning = true
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = Runtime.HomePosition
                end
                task.wait(0.5)
                Runtime.IsReturning = false
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎛️ ពូតុង / COMMANDS (ហៅតាម Console ឬ UI របស់អ្នក)
-- ═══════════════════════════════════════════════════════════

-- Expose Functions សម្រាប់ហៅពី UI ឬ Console
_G.MKRA_Teleport = {
    SetHome = function()
        return saveHome()
    end,
    GoHome = function()
        return goHome()
    end,
    ToggleAutoCollect = function(state)
        Runtime.AutoCollectEgg = state or not Runtime.AutoCollectEgg
        print("[Teleport] Auto Collect: "..(Runtime.AutoCollectEgg and "ON" or "OFF"))
        return Runtime.AutoCollectEgg
    end,
    ToggleAutoReturn = function(state)
        Runtime.AutoReturnOnHold = state or not Runtime.AutoReturnOnHold
        print("[Teleport] Auto Return: "..(Runtime.AutoReturnOnHold and "ON" or "OFF"))
        return Runtime.AutoReturnOnHold
    end,
    SetDelay = function(d)
        Runtime.TeleportDelay = tonumber(d) or 0.05
        print("[Teleport] Delay: "..Runtime.TeleportDelay)
    end,
    CollectOnce = function()
        local egg = findEgg()
        if egg then
            collectEgg(egg)
            print("[Teleport] យកពងជោគជ័យ")
        else
            print("[Teleport] រកមិនឃើញពង")
        end
    end,
}

print("[MKRA] ⚡ Teleport System Ready")
print("   _G.MKRA_Teleport.SetHome()")
print("   _G.MKRA_Teleport.GoHome()")
print("   _G.MKRA_Teleport.ToggleAutoCollect(true)")
print("   _G.MKRA_Teleport.ToggleAutoReturn(true)")
print("   _G.MKRA_Teleport.CollectOnce()")