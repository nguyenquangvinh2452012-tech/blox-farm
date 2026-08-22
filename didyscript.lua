-- [[ SMART BONE FARM + AUTO EQUIP WEAPON ]] --

_G.BoneFarm = true
_G.SuperFastAttack = true

local BoneQuestGiverCFrame = CFrame.new(-9516.993, 172.017, 6078.465)
local BoneMobNames = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Armor"}

-- HÀM TỰ ĐỘNG CHỌN VÀ TRANG BỊ VŨ KHÍ TỐI ƯU (Melee -> Sword -> Fruit)
local function autoEquipWeapon()
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    if not Character then return end
    
    -- Nếu trên tay đã cầm sẵn một món vũ khí rồi thì bỏ qua không cần lấy nữa
    if Character:FindFirstChildOfClass("Tool") then return end
    
    -- Quét balo để tìm món đồ ưu tiên
    local Backpack = Player:FindFirstChild("Backpack")
    if Backpack then
        local targetTool = nil
        
        -- Bước 1: Ưu tiên tìm Melee (Các loại võ như Godhuman, Superhuman, Sangvine Art...)
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or string.find(tool.Name, "Combat") or string.find(tool.Name, "Human") or string.find(tool.Name, "Art")) then
                targetTool = tool
                break
            end
        end
        
        -- Bước 2: Nếu không thấy Melee, tìm Kiếm (Sword)
        if not targetTool then
            for _, tool in pairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == "Sword" or string.find(tool.Name, "Blade") or string.find(tool.Name, "Katana")) then
                    targetTool = tool
                    break
                end
            end
        end
        
        -- Bước 3: Nếu vẫn không có, lấy đại Trái ác quỷ hoặc thứ gì có trong balo
        if not targetTool then
            targetTool = Backpack:FindFirstChildOfClass("Tool")
        end
        
        -- Tiến hành móc vũ khí ra tay
        if targetTool then
            Player.Character.Humanoid:EquipTool(targetTool)
        end
    end
end

-- 1. FAST ATTACK THẾ HỆ MỚI 
local VirtualInputManager = game:GetService("VirtualInputManager")
task.spawn(function()
    while task.wait() do
        if _G.SuperFastAttack then
            pcall(function()
                -- Gọi hàm tự động lấy vũ khí ra tay liên tục đề phòng bị game tự cất đồ
                autoEquipWeapon()
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                
                local Player = game.Players.LocalPlayer
                if Player.Character and Player.Character:FindFirstChildOfClass("Tool") then
                    Player.Character:FindFirstChildOfClass("Tool"):Activate()
                end
            end)
        end
    end
end)

-- 2. HỆ THỐNG GOM QUÁI THÔNG MINH (5-7 CON)
local CurrentTargetCluster = {}

local function isClusterDead()
    if #CurrentTargetCluster == 0 then return true end
    local aliveCount = 0
    for _, mob in pairs(CurrentTargetCluster) do
        if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            aliveCount = aliveCount + 1
        end
    end
    return aliveCount == 0
end

local function findNewMobCluster()
    local tempCluster = {}
    local count = 0
    local enemiesFolder = game:GetService("Workspace"):FindFirstChild("Enemies") and game:GetService("Workspace").Enemies:GetChildren() or game:GetService("Workspace"):GetChildren()
    
    for _, mob in pairs(enemiesFolder) do
        if table.find(BoneMobNames, mob.Name) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            table.insert(tempCluster, mob)
            count = count + 1
            if count >= 7 then break end
        end
    end
    return tempCluster
end

-- 3. VÒNG LẶP ĐIỀU KHIỂN CHÍNH + AUTO GHOST NOCLIP
task.spawn(function()
    while task.wait() do
        if _G.BoneFarm then
            pcall(function()
                local Character = game.Players.LocalPlayer.Character
                local PlayerRoot = Character:FindFirstChild("HumanoidRootPart")
                if not PlayerRoot then return end

                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end

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
                    PlayerRoot.CFrame = TargetCFrame * CFrame.new(0, 5, 0)

                    for _, mob in pairs(CurrentTargetCluster) do
                        if mob and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 and mob ~= MainMob then
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
            CurrentTargetCluster = {}
        end
    end
end)

print("[+] Code Đã Thêm Tự Động Chọn Vũ Khí! Bật Phát Chạy Luôn Không Cần Chọn Tay.")
