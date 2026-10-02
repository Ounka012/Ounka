--[[
    ═══════════════════════════════════════════════════════════
      🌲 AUTO TP TRUNK — ON / OFF (គ្មាន GUI)
    ═══════════════════════════════════════════════════════════
]]

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ═══ ការកំណត់ ═══
local TargetName   = "Trunk"
local MaxDistance  = 29
local Delay        = 0.1
local AutoEnabled  = false       -- ⚡ ចាប់ផ្ដើម OFF
local HomePosition = nil

-- ═══ Helpers ═══
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ═══ 🔍 រក Trunk ក្នុងចម្ងាយ ═══
local function findTrunk()
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, closestDist = nil, MaxDistance
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == TargetName then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= MaxDistance and dist < closestDist then
                closest = obj
                closestDist = dist
            end
        end
    end
    return closest
end

-- ═══ 📍 Set Home ═══
local function SetHome()
    local hrp = getHRP()
    if hrp then
        HomePosition = hrp.CFrame
        print("[TP] ✅ Home saved")
    end
end

-- ═══ ⚡ TP ទៅ Trunk ═══
local function tpToTrunk(trunk)
    local hrp = getHRP()
    if not hrp or not trunk or not trunk.Parent then return end

    local backCF = HomePosition or hrp.CFrame

    hrp.CFrame = CFrame.new(trunk.Position + Vector3.new(0, 3, 0))
    task.wait(Delay)

    pcall(function()
        for _, prompt in ipairs(trunk:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
        if firetouchinterest then
            firetouchinterest(hrp, trunk, 0)
            task.wait(0.03)
            firetouchinterest(hrp, trunk, 1)
        end
    end)

    task.wait(Delay)
    hrp.CFrame = backCF
end

-- ═══ ⚡ AUTO LOOP ═══
task.spawn(function()
    while task.wait(0.2) do
        if AutoEnabled then
            local trunk = findTrunk()
            if trunk then
                pcall(tpToTrunk, trunk)
                task.wait(0.3)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎛️ ON / OFF
-- ═══════════════════════════════════════════════════════════
_G.ON = function()
    AutoEnabled = true
    print("[TP] ⚡ ON")
end

_G.OFF = function()
    AutoEnabled = false
    print("[TP] 🔴 OFF")
end

_G.TP = {
    SetHome = SetHome,
    Distance = function(d) MaxDistance = tonumber(d) or 29 end,
    Delay = function(d) Delay = tonumber(d) or 0.1 end,
}

-- ═══ ចាប់ផ្ដើម ═══
SetHome()  -- កំណត់ទីតាំងកំណត់ភ្លាម
print("[TP] 🌲 Ready")
print("  _G.ON()      — បើក")
print("  _G.OFF()     — បិទ")