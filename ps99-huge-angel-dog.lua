-- PS99 | Huge Angel Dog Grinder
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local function getRemote(path)
    local obj = ReplicatedStorage
    for _, seg in ipairs(path:split("/")) do
        obj = obj:WaitForChild(seg, 5)
        if not obj then return nil end
    end
    return obj
end

local function fireRemote(path, ...)
    local remote = getRemote(path)
    if remote then pcall(function() remote:FireServer(...) end) end
end

local function teleport(pos)
    if rootPart then
        rootPart.CFrame = CFrame.new(pos)
        task.wait(0.1)
    end
end

local State = {
    Running     = true,
    AutoCollect = true,
    AutoRankUp  = true,
    HugeFound   = false,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HugeAngelGrinder"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 200)
Frame.Position = UDim2.new(0, 10, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Header.Text = "👼 HUGE ANGEL DOG GRINDER"
Header.TextColor3 = Color3.fromRGB(0, 0, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 13
Header.Parent = Frame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 24)
StatusLabel.Position = UDim2.new(0, 5, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Searching..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Frame

local HatchCount = Instance.new("TextLabel")
HatchCount.Size = UDim2.new(1, -10, 0, 24)
HatchCount.Position = UDim2.new(0, 5, 0, 68)
HatchCount.BackgroundTransparency = 1
HatchCount.Text = "Angel Hatches: 0"
HatchCount.TextColor3 = Color3.fromRGB(255, 215, 0)
HatchCount.Font = Enum.Font.Gotham
HatchCount.TextSize = 12
HatchCount.TextXAlignment = Enum.TextXAlignment.Left
HatchCount.Parent = Frame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, -10, 0, 32)
StopBtn.Position = UDim2.new(0, 5, 0, 155)
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StopBtn.Text = "⏹ STOP GRINDER"
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 13
StopBtn.Parent = Frame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

StopBtn.MouseButton1Click:Connect(function()
    State.Running = false
    StatusLabel.Text = "Status: Stopped"
    StopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    StopBtn.Text = "Stopped"
end)

local function notify(title, msg)
    local notif = Instance.new("ScreenGui")
    notif.ResetOnSpawn = false
    notif.Parent = player.PlayerGui
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 300, 0, 80)
    bg.Position = UDim2.new(0.5, -150, 0, 20)
    bg.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    bg.Parent = notif
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🎉 " .. title .. "\n" .. msg
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = bg
    task.delay(6, function() notif:Destroy() end)
end

local hatchCount = 0

local function checkForHugeAngel()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (
            obj.Name:find("Huge Angel") or
            obj.Name:find("HugeAngel") or
            obj.Name:find("Huge_Angel")
        ) then
            State.HugeFound = true
            State.Running = false
            StatusLabel.Text = "🎉 HUGE ANGEL FOUND!"
            notify("HUGE ANGEL DOG!", "Check your inventory boss!")
            return true
        end
    end
    return false
end

local function findAngelEgg()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (
            obj.Name:find("Angel Egg") or obj.Name:find("AngelEgg") or
            obj.Name:find("Heaven Egg") or obj.Name:find("HeavenEgg")
        ) then
            return obj
        end
    end
    return nil
end

task.spawn(function()
    while State.Running and not State.HugeFound do
        task.wait(0.05)
        if checkForHugeAngel() then break end
        local egg = findAngelEgg()
        if egg then
            local primary = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
            if primary then
                teleport(primary.Position + Vector3.new(0, 3, 0))
                StatusLabel.Text = "Status: Hatching Angel Egg..."
                fireRemote("Remotes/HatchEgg", egg.Name)
                fireRemote("Remotes/HatchEgg3x", egg.Name)
                fireRemote("Remotes/HatchEgg10x", egg.Name)
                fireRemote("Remotes/BuyAndHatch", egg.Name)
                hatchCount = hatchCount + 1
                HatchCount.Text = "Angel Hatches: " .. hatchCount
            end
        else
            StatusLabel.Text = "Status: Searching for Angel Egg..."
        end
        if State.AutoCollect then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (
                    obj.Name:find("Coin") or obj.Name:find("Gem") or obj.Name:find("Drop")
                ) then
                    teleport(obj.Position)
                    fireRemote("Remotes/CollectCoin", obj)
                end
            end
        end
        if State.AutoRankUp then
            fireRemote("Remotes/RankUp")
            fireRemote("Remotes/ClaimRankReward")
        end
    end
    if State.HugeFound then
        StatusLabel.Text = "🏆 DONE — Huge Angel Secured"
    end
end)

print("[HugeAngelGrinder] Running — good luck boss.")
