-- [[ W-AZURE STYLE MENU + PACKET QUEST + ZERO ANIMATION FAST ATTACK ]] --

-- Tạo giao diện Menu UI đơn giản (Bảo đảm bật loadstring là hiện)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleFarm = Instance.new("TextButton")
local ToggleAttack = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "WAzureCustomHub"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể giữ chuột để di chuyển Menu trên màn hình

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "W-AZURE BONE v1.2"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

-- Cấu hình các biến trạng thái ban đầu (Mặc định TẮT để bạn chủ động bật trên giao diện)
_G.BoneFarm = false
_G.SuperFastAttack = false

ToggleFarm.Parent = MainFrame
ToggleFarm.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleFarm.Size = UDim2.new(0, 200, 0, 40)
ToggleFarm.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFarm.Text = "Bone Farm: OFF"
ToggleFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFarm.TextSize = 14

ToggleFarm.MouseButton1Click:Connect(function()
    _G.BoneFarm = not _G.BoneFarm
    if _G.BoneFarm then
        ToggleFarm.Text = "Bone Farm: ON"
        ToggleFarm.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleFarm.Text = "Bone Farm: OFF"
        ToggleFarm.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        _G.SuperFastAttack = false
        ToggleAttack.Text = "Fast Attack: OFF"
        ToggleAttack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

ToggleAttack.Parent = MainFrame
ToggleAttack.Position = UDim2.new(0.05, 0, 0.6, 0)
ToggleAttack.Size = UDim2.new(0, 200, 0, 40)
ToggleAttack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleAttack.Text = "Fast Attack: OFF"
ToggleAttack.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAttack.TextSize = 14

ToggleAttack.MouseButton1Click:Connect(function()
    _G.SuperFastAttack = not _G.SuperFastAttack
    if _G.SuperFastAttack then
        ToggleAttack.Text = "Fast Attack: ON"
        ToggleAttack.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleAttack.Text = "Fast Attack: OFF"
        ToggleAttack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- VÀI ĐẶT THÔNG SỐ TOẠ ĐỘ & QUÁI
local BoneQuestGiverCFrame = CFrame.new(-9516.993, 172.017, 6078.465)
local BoneMobNames = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Armor"}

-- HÀM TỰ ĐỘNG CẦM VŨ KHÍ TỐI ƯU
local function autoEquipWeapon()
    local Player = game.Players.LocalPlayer
    if not Player.Character then return end
    if Player.Character:FindFirstChildOfClass("Tool") then return end
    local Backpack = Player:FindFirstChild("Backpack")
    if Backpack then
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or string.find(tool.Name, "Combat") or string.find(tool.Name, "Human") or string.find(tool.Name, "Art")) then
                Player.Character.Humanoid:EquipTool(tool)
                break
            end
        end
    end
end

-- 1. FIX FAST ATTACK KHÔNG HOẠT ẢNH TRỰC TIẾP QUA SỰ KIỆN NET (Bypass Click)
task.spawn(function()
    while task.wait() do
        if _G.SuperFastAttack then
            pcall(function()
                autoEquipWeapon()
                local Player = game.Players.LocalPlayer
                local Tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                if Tool then
                    -- Gửi tín hiệu kích hoạt đòn đánh gốc trực tiếp lên server, triệt tiêu hoàn toàn animation của Client
                    game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.floor(workspace.DistributedTime * 1000))
                    Tool:Activate()
                end
            end)
        end
    end
end)

-- 2. HỆ THỐNG GOM QUÁI THÔNG MINH
local CurrentTargetCluster = {}

local function isClusterDead()
    if #CurrentTargetCluster == 0 then return true end
    for _, mob in pairs(CurrentTargetCluster) do
        if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            return false
        end
    end
    return true
end

local function findNewMobCluster()
    local tempCluster = {}
    local count = 0
    local enemiesFolder = game:GetService("Workspace"):FindFirstChild("Enemies") and game:GetService("Workspace").Enemies:GetChildren() or game:GetService("Workspace"):GetChildren()
    for _, mob in pairs(enemiesFolder) do
        if table.find(BoneMobNames, mob.Name) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            table.insert(tempCluster, mob)
            count = count + 1
            if count >= 6 then break end
        end
    end
    return tempCluster
end

-- 3. VÒNG LẶP CHÍNH: TỰ NHẬN QUEST BẰNG PACKET + GOM QUÁI XUYÊN TƯỜNG
task.spawn(function()
    while task.wait() do
        if _G.BoneFarm then
            pcall(function()
                local Character = game.Players.LocalPlayer.Character
                local PlayerRoot = Character:FindFirstChild("HumanoidRootPart")
                if not PlayerRoot then return end

                -- Luôn luôn bật Noclip để di chuyển không bị khựng
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                -- KHÔNG CLICK NPC - Gửi Packet nhận thẳng Nhiệm vụ "Skeleton" cấp 2500+ (Đổi tên nếu cần nhận quest khác)
                local PlayerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui and not PlayerGui.Main:FindFirstChild("Quest") then
                    -- Bay về chạm nhẹ vào tọa độ NPC để đảm bảo khoảng cách hợp lệ với Server
                    if (PlayerRoot.Position - BoneQuestGiverCFrame.Position).Magnitude > 15 then
                        PlayerRoot.CFrame = BoneQuestGiverCFrame
                        task.wait(0.3)
                    end
                    -- Gọi lệnh nhận quest trực tiếp của Blox Fruits
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "HauntedCastleQuest2", 1)
                end

                -- XỬ LÝ GOM QUÁI VÀ ĐÁNH TRẬN
                if isClusterDead() then
                    CurrentTargetCluster = findNewMobCluster()
                    if #CurrentTargetCluster == 0 then
                        if (PlayerRoot.Position - BoneQuestGiverCFrame.Position).Magnitude > 15 then
                            PlayerRoot.CFrame = BoneQuestGiverCFrame
                        end
                        return
                    end
                end

                local MainMob = nil
                for _, mob in pairs(CurrentTargetCluster) do
                    if mob and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        MainMob = mob
                        break
                    end
                end

                if MainMob then
                    local TargetCFrame = MainMob.HumanoidRootPart.CFrame
                    -- Đứng khựng ngay trên đầu cụm quái để dội sát thương xuống
                    PlayerRoot.CFrame = TargetCFrame * CFrame.new(0, 6, 0)

                    for _, mob in pairs(CurrentTargetCluster) do
                        if mob and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            mob.HumanoidRootPart.CFrame = TargetCFrame
                            mob.HumanoidRootPart.CanCollide = false
                            if mob.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                                mob.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                            end
                        end
                    end
                    _G.SuperFastAttack = true
                end
            end)
        else
            _G.SuperFastAttack = false
        end
    end
end)

print("[+] Code Đã Vá Lỗi: Tự Động Nhận Quest Packet + Tích Hợp Menu Trực Quan Trên Màn Hình!")
