-- Pet Simulator 99 | Full Auto Script
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Remote caching
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

local function getRemote(name)
    return Remotes and Remotes:FindFirstChild(name)
end

-- State flags
local State = {
    AutoFarm = true,
    AutoHatch = true,
    AutoCollectCoins = true,
    AutoRankUp = true,
    AutoOpenChests = true,
    AutoEquipBest = true,
    AutoSell = false, -- toggle manually
    AutoQuests = true,
    TeleportToFarm = true,
    AntiAFK = true,
    ESP = false,
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PS99_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 520)
Frame.Position = UDim2.new(0, 10, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(88, 50, 235)
Title.Text = "PS99 | FULL AUTO"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Frame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Frame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 44)
Padding.PaddingLeft = UDim.new(0, 8)
Padding.PaddingRight = UDim.new(0, 8)
Padding.Parent = Frame

local function createToggle(labelText, stateKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = State[stateKey] and Color3.fromRGB(88, 50, 235) or Color3.fromRGB(40, 40, 55)
    btn.Text = (State[stateKey] and "✔ " or "✘ ") .. labelText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        btn.BackgroundColor3 = State[stateKey] and Color3.fromRGB(88, 50, 235) or Color3.fromRGB(40, 40, 55)
        btn.Text = (State[stateKey] and "✔ " or "✘ ") .. labelText
    end)
end

createToggle("Auto Farm", "AutoFarm")
createToggle("Auto Hatch", "AutoHatch")
createToggle("Auto Collect Coins", "AutoCollectCoins")
createToggle("Auto Rank Up", "AutoRankUp")
createToggle("Auto Open Chests", "AutoOpenChests")
createToggle("Auto Equip Best Pets", "AutoEquipBest")
createToggle("Auto Sell Pets", "AutoSell")
createToggle("Auto Quests", "AutoQuests")
createToggle("Teleport To Farm", "TeleportToFarm")
createToggle("Anti-AFK", "AntiAFK")
createToggle("Pet ESP", "ESP")

-- Utility
local function safeTeleport(pos)
    if rootPart then
        rootPart.CFrame = CFrame.new(pos)
    end
end

local function fireRemote(name, ...)
    local remote = getRemote(name)
    if remote then
        pcall(function()
            remote:FireServer(...)
        end)
    end
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if State.AntiAFK then
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Auto Farm loop
local function getBreakables()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (
            obj.Name:find("Coin") or
            obj.Name:find("Breakable") or
            obj.Name:find("Chest") or
            obj.Name:find("Gem") or
            obj.Name:find("Diamond")
        ) then
            table.insert(found, obj)
        end
    end
    return found
end

local function farmLoop()
    while true do
        task.wait(0.05)
        if State.AutoFarm then
            local targets = getBreakables()
            for _, target in ipairs(targets) do
                local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                if primary then
                    if State.TeleportToFarm then
                        safeTeleport(primary.Position + Vector3.new(0, 3, 0))
                    end
                    fireRemote("BreakObject", target)
                    fireRemote("CollectObject", target)
                    task.wait(0.03)
                end
            end
        end
    end
end

-- Auto Collect Coins
local function collectLoop()
    while true do
        task.wait(0.1)
        if State.AutoCollectCoins then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:find("Coin") then
                    safeTeleport(obj.Position)
                    fireRemote("CollectCoin", obj)
                end
            end
        end
    end
end

-- Auto Hatch
local function hatchLoop()
    while true do
        task.wait(1)
        if State.AutoHatch then
            for _, egg in ipairs(workspace:GetDescendants()) do
                if egg:IsA("Model") and egg.Name:find("Egg") then
                    fireRemote("HatchEgg", egg.Name)
                    fireRemote("HatchEgg3x", egg.Name)
                    task.wait(0.5)
                end
            end
        end
    end
end

-- Auto Rank Up
local function rankLoop()
    while true do
        task.wait(2)
        if State.AutoRankUp then
            fireRemote("RankUp")
            fireRemote("ClaimRankReward")
        end
    end
end

-- Auto Open Chests
local function chestLoop()
    while true do
        task.wait(1.5)
        if State.AutoOpenChests then
            for _, chest in ipairs(workspace:GetDescendants()) do
                if chest:IsA("Model") and chest.Name:find("Chest") then
                    local p = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                    if p then
                        safeTeleport(p.Position + Vector3.new(0,3,0))
                        fireRemote("OpenChest", chest)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end

-- Auto Equip Best Pets
local function equipLoop()
    while true do
        task.wait(5)
        if State.AutoEquipBest then
            fireRemote("EquipBestPets")
            fireRemote("AutoEquip")
        end
    end
end

-- Auto Sell
local function sellLoop()
    while true do
        task.wait(3)
        if State.AutoSell then
            fireRemote("SellPets")
            fireRemote("SellDuplicates")
        end
    end
end

-- Auto Quests
local function questLoop()
    while true do
        task.wait(2)
        if State.AutoQuests then
            fireRemote("ClaimQuest")
            fireRemote("CompleteQuest")
            fireRemote("SkipQuest")
        end
    end
end

-- Pet ESP
local espTable = {}
local function updateESP()
    for _, v in ipairs(espTable) do
        if v and v.Parent then v:Destroy() end
    end
    espTable = {}

    if not State.ESP then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Pet") then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primary then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 80, 0, 30)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = primary

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = obj.Name
                lbl.TextColor3 = Color3.fromRGB(180, 100, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 11
                lbl.Parent = bb

                table.insert(espTable, bb)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    updateESP()
end)

-- Spawn all loops
task.spawn(farmLoop)
task.spawn(collectLoop)
task.spawn(hatchLoop)
task.spawn(rankLoop)
task.spawn(chestLoop)
task.spawn(equipLoop)
task.spawn(sellLoop)
task.spawn(questLoop)

print("[PS99] Full Auto Script Loaded."
