-- [[ W-AZURE FINAL: MOB SELECTOR + QUEST SYNC + FAST ATTACK ]] --

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- // CẤU HÌNH CƠ BẢN
getgenv().Config = {
    AutoFarm = false,
    FastAttack = false,
    SelectedMob = "Living Zombie", -- Mặc định đánh con này
    QuestID = "HauntedCastleQuest2", -- Quest mặc định
    Mon = "Living Zombie"
}

-- Danh sách quái tại Haunted Castle (Sea 3)
local Mobs = {
    "Reborn Skeleton", -- Lv 1975
    "Living Zombie",   -- Lv 2000
    "Demonic Soul",    -- Lv 2025
    "Posessed Mummy"   -- Lv 2050
}

-- // 1. GIAO DIỆN MENU (W-AZURE STYLE)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local MobBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "WAzureFinal"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Khung chính
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Tiêu đề
Title.Parent = MainFrame
Title.Text = "W-AZURE BONE HUB"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Nút Chọn Quái (Mob Selector)
MobBtn.Parent = MainFrame
MobBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
MobBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
MobBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
MobBtn.Text = "Mob: Living Zombie"
MobBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
MobBtn.Font = Enum.Font.GothamBold
MobBtn.TextSize = 14

-- Nút Bật/Tắt Auto Farm
ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
ToggleBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ khi tắt
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 16

-- Trạng thái
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12

-- // 2. XỬ LÝ SỰ KIỆN NÚT BẤM
local currentMobIndex = 2 -- Bắt đầu từ Living Zombie

MobBtn.MouseButton1Click:Connect(function()
    currentMobIndex = currentMobIndex + 1
    if currentMobIndex > #Mobs then currentMobIndex = 1 end
    
    local mobName = Mobs[currentMobIndex]
    getgenv().Config.SelectedMob = mobName
    getgenv().Config.Mon = mobName
    MobBtn.Text = "Mob: " .. mobName
    
    -- Cập nhật Quest ID tương ứng với quái
    if mobName == "Reborn Skeleton" then getgenv().Config.QuestID = "HauntedCastleQuest1"
    elseif mobName == "Living Zombie" then getgenv().Config.QuestID = "HauntedCastleQuest2"
    elseif mobName == "Demonic Soul" then getgenv().Config.QuestID = "HauntedCastleQuest3"
    elseif mobName == "Posessed Mummy" then getgenv().Config.QuestID = "HauntedCastleQuest4"
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().Config.AutoFarm = not getgenv().Config.AutoFarm
    if getgenv().Config.AutoFarm then
        ToggleBtn.Text = "AUTO FARM: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- Xanh khi bật
        getgenv().Config.FastAttack = true
    else
        ToggleBtn.Text = "AUTO FARM: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        getgenv().Config.FastAttack = false
        StatusLabel.Text = "Status: Paused"
    end
end)

-- // 3. HÀM HỖ TRỢ FARM (FAST ATTACK + EQUIP + BRING)
local function EquipMelee()
    pcall(function()
        if not LP.Character:FindFirstChildOfClass("Tool") then
            for _, v in pairs(LP.Backpack:GetChildren()) do
                if v.ToolTip == "Melee" then
                    LP.Character.Humanoid:EquipTool(v)
                    break
                end
            end
        end
    end)
end

-- Fast Attack V2 (No Animation)
task.spawn(function()
    while true do
        if getgenv().Config.FastAttack then
            pcall(function()
                local Combat = require(LP.PlayerScripts.CombatFramework)
                local AC = Combat.activeController
                if AC and AC.blades then
                    AC.timeToNextAttack = 0
                    AC.hitboxMagnitude = 55
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange", tostring(AC.currentWeaponModel))
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", AC.blades, 3, "")
                end
            end)
        end
        RunService.Heartbeat:Wait()
    end
end)

-- // 4. LOGIC FARM CHÍNH
task.spawn(function()
    while true do
        task.wait()
        if getgenv().Config.AutoFarm then
            pcall(function()
                local QuestGUI = LP.PlayerGui.Main.Quest
                -- A. NHẬN QUEST
                if not QuestGUI.Visible then
                    StatusLabel.Text = "Status: Taking Quest " .. getgenv().Config.SelectedMob
                    LP.Character.HumanoidRootPart.CFrame = CFrame.new(-9516, 172, 6078) -- Vị trí Quest Giver
                    task.wait(0.5)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", getgenv().Config.QuestID, 1)
                else
                    -- B. ĐÁNH QUÁI (Theo tên đã chọn)
                    StatusLabel.Text = "Status: Farming " .. getgenv().Config.SelectedMob
                    EquipMelee()
                    
                    -- Tìm đúng con quái đã chọn trong Menu
                    local Target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == getgenv().Config.SelectedMob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            Target = v
                            break
                        end
                    end
                    
                    if Target then
                        -- Tắt va chạm
                        for _, p in pairs(LP.Character:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                        
                        -- Bay đến quái
                        LP.Character.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                        
                        -- Gom quái (Bring Mob)
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == getgenv().Config.SelectedMob and (v.HumanoidRootPart.Position - Target.HumanoidRootPart.Position).Magnitude < 300 then
                                v.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                            end
                        end
                        
                        -- Click đánh ảo
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(800, 600))
                    else
                        -- Không thấy quái thì đứng chờ ở spawn point của quái đó
                        -- (Tạm thời bay về Quest Giver để an toàn)
                        StatusLabel.Text = "Status: Waiting for spawn..."
                        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-9516, 172, 6078)
                    end
                end
            end)
        end
    end
end)

print("W-AZURE FINAL LOADED")
