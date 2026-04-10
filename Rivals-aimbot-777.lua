--[[
Rivals Script by 777zent
Key: 777 (Hidden)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Load Libraries
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local aimbotEnabled = false
local aimAtPart = "HumanoidRootPart"
local wallCheckEnabled = false
local teamCheckEnabled = false
local IJ = false
local currentSpeed = 16

-- ESP Default Settings
ESP.Enabled = true
ESP.ShowBox = false
ESP.ShowName = true
ESP.ShowHealth = true
ESP.ShowTracer = true
ESP.ShowDistance = false
ESP.ShowSkeletons = false

-- Key System Window
local Window = Rayfield:CreateWindow({
    Name = "Rivals [777zent]",
    LoadingTitle = "777zent Hub",
    LoadingSubtitle = "Loading Script...",
    Theme = "Ocean",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "777zentHub",
        FileName = "Rivals_Config"
    },
    KeySystem = true,
    KeySettings = {
        Title = "777zent Key System",
        Subtitle = "Verification Required",
        Note = "Private Script",
        FileName = "777zent_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"777"}
    }
})

Rayfield:Notify({
    Title = "777zent Hub",
    Content = "Successfully Loaded!",
    Duration = 4,
    Image = 4483362458,
})

-- ==================== FUNCTIONS ====================

local function getClosestTarget()
    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local nearestTarget = nil
    local shortestDistance = math.huge

    local function checkTarget(target)
        if not target or not target:FindFirstChild("Humanoid") or not target:FindFirstChild(aimAtPart) then return end
        if target.Humanoid.Health <= 0 then return end

        local targetRoot = target[aimAtPart]
        local distance = (targetRoot.Position - rootPart.Position).Magnitude

        if distance < shortestDistance then
            if wallCheckEnabled then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local result = workspace:Raycast(camera.CFrame.Position, (targetRoot.Position - camera.CFrame.Position).Unit * 2000, rayParams)
                if result and result.Instance:IsDescendantOf(target) then
                    shortestDistance = distance
                    nearestTarget = target
                end
            else
                shortestDistance = distance
                nearestTarget = target
            end
        end
    end

    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not teamCheckEnabled or player.Team ~= localPlayer.Team) then
            checkTarget(player.Character)
        end
    end

    return nearestTarget
end

-- ==================== TABS ====================

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP | Wallhack", "rewind")
local MiscTab = Window:CreateTab("Misc", 4483362458)
local InfoTab = Window:CreateTab("Credits", 4483362458)

-- Aimbot Tab
AimbotTab:CreateSection("Aimbot")

AimbotTab:CreateButton({
    Name = "Silent Aim (Bolts)",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ThunderScriptSolutions/Misc/refs/heads/main/RivalsSilentAim'))()
    end,
})

AimbotTab:CreateToggle({
    Name = "Camera Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value - 1, function()
                if not aimbotEnabled then return end
                local target = getClosestTarget()
                if target and target:FindFirstChild(aimAtPart) then
                    workspace.CurrentCamera.CFrame = CFrame.lookAt(
                        workspace.CurrentCamera.CFrame.Position,
                        target[aimAtPart].Position
                    )
                end
            end)
        else
            RunService:UnbindFromRenderStep("Aimbot")
        end
    end,
})

AimbotTab:CreateButton({
    Name = "Switch Aim Part (Head / Torso)",
    Callback = function()
        aimAtPart = (aimAtPart == "HumanoidRootPart") and "Head" or "HumanoidRootPart"
        Rayfield:Notify({Title = "Aim Part", Content = "Now aiming at: " .. aimAtPart, Duration = 3})
    end,
})

AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "WallCheck",
    Callback = function(Value) wallCheckEnabled = Value end,
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(Value) teamCheckEnabled = Value end,
})

-- ESP Tab
ESPTab:CreateSection("ESP Settings")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = true,
    Callback = function(Value) ESP.Enabled = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = false,
    Callback = function(Value) ESP.ShowBox = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Callback = function(Value) ESP.ShowName = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Tracers",
    CurrentValue = true,
    Callback = function(Value) ESP.ShowTracer = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Callback = function(Value) ESP.ShowDistance = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Skeletons",
    CurrentValue = false,
    Callback = function(Value) ESP.ShowSkeletons = Value end,
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value) ESP.TeamCheck = Value end,
})

-- Misc Tab
MiscTab:CreateSection("Movement")

MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        IJ = Value
    end,
})

MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        currentSpeed = Value
        local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end,
})

-- Auto apply walkspeed
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = currentSpeed
end)

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if IJ then
        local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Credits Tab
InfoTab:CreateLabel("Made by 777zent", nil, Color3.fromRGB(255, 215, 0))
InfoTab:CreateLabel("UI: Rayfield", nil, Color3.fromRGB(255, 255, 255))

Rayfield:Notify({
    Title = "Loaded Successfully",
    Content = "Key: 777 | Enjoy!",
    Duration = 5,
})
