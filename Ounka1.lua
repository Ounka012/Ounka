--[[
    ═══════════════════════════════════════════════════════════
      🌲⚡ AUTO TP — ច្រើន Target
      ពេលជិត Target ណាមួយ → ហោះទៅ → ត្រឡប់មក Home វិញ
    ═══════════════════════════════════════════════════════════
]]

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ═══ ការកំណត់ ═══
local Targets = {
    {Name = "Trunk",  Distance = 29},
    {Name = "Tree",   Distance = 29},   -- ⭐ Target ទី 2 (បន្ថែម)
}
local Delay        = 0.1
local AutoEnabled  = false
local HomePosition = nil

-- ═══ Helpers ═══
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ═══ 🔍 រក Target ក្នុងចម្ងាយ ═══
local function findTarget()
    local hrp = getHRP()
    if not hrp then return nil end

    local best, bestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, t in ipairs(Targets) do
                if obj.Name == t.Name then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist <= t.Distance and dist < bestDist then
                        best = obj
                        bestDist = dist
                    end
                end
            end
        end
    end

    return best
end

-- ═══ 📍 Set Home ═══
local function SetHome()
    local hrp = getHRP()
    if hrp then
        HomePosition = hrp.CFrame
        print("[TP] ✅ Home saved:", math.floor(hrp.Position.X), math.floor(hrp.Position.Y), math.floor(hrp.Position.Z))
    end
end

-- ═══ ⚡ TP ទៅ Target → ត្រឡប់មក Home ═══
local function tpAndReturn(target)
    local hrp = getHRP()
    if not hrp or not target or not target.Parent then return end

    local backCF = HomePosition or hrp.CFrame

    -- 1. ហោះទៅ Target
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    task.wait(Delay)

    -- 2. ចុចយក
    pcall(function()
        for _, prompt in ipairs(target:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end
        if firetouchinterest then
            firetouchinterest(hrp, target, 0)
            task.wait(0.03)
            firetouchinterest(hrp, target, 1)
        end
    end)

    task.wait(Delay)

    -- 3. ហោះត្រឡប់មក Home វិញ
    hrp.CFrame = backCF
end

-- ═══ ⚡ AUTO LOOP ═══
task.spawn(function()
    while task.wait(0.2) do
        if AutoEnabled then
            local target = findTarget()
            if target then
                pcall(tpAndReturn, target)
                task.wait(0.3)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎛️ COMMANDS
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
    -- 📍 កំណត់ទីតាំង Home
    SetHome = SetHome,

    -- ➕ បន្ថែម Target ថ្មី
    Add = function(name, distance)
        table.insert(Targets, {
            Name = name,
            Distance = tonumber(distance) or 29,
        })
        print("[TP] ➕ បន្ថែម Target:", name, "| ចម្ងាយ:", distance or 29)
    end,

    -- ➖ លុប Target
    Remove = function(name)
        for i, t in ipairs(Targets) do
            if t.Name == name then
                table.remove(Targets, i)
                print("[TP] ➖ លុប Target:", name)
                return
            end
        end
    end,

    -- 📋 បង្ហាញ Target ទាំងអស់
    List = function()
        print("[TP] 📋 Targets:")
        for i, t in ipairs(Targets) do
            print("   "..i..". "..t.Name.." ("..t.Distance.."m)")
        end
    end,

    -- ⚙️ កំណត់
    Delay    = function(d) Delay = tonumber(d) or 0.1 end,
    GoHome   = function()
        local hrp = getHRP()
        if hrp and HomePosition then hrp.CFrame = HomePosition end
    end,
}

-- ═══ ចាប់ផ្ដើម ═══
SetHome()
print("[TP] 🌲⚡ Ready")
print("  _G.ON()                       — បើក")
print("  _G.OFF()                      — បិទ")
print("  _G.TP.Add('ឈ្មោះ', 29)         — បន្ថែម Target")
print("  _G.TP.Remove('ឈ្មោះ')          — លុប Target")
print("  _G.TP.List()                  — បង្ហាញ Target")
print("  _G.TP.SetHome()               — កំណត់ Home")