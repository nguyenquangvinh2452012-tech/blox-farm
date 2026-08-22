-- [[ REDZ-STYLE FAST ATTACK + SMART FARM + AUTO GHOST NOCLIP ]] --

_G.BoneFarm = true
_G.SuperFastAttack = true

local BoneQuestGiverCFrame = CFrame.new(-9516.993, 172.017, 6078.465)
local BoneMobNames = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Armor"}

-- 1. SUPER FAST ATTACK (Chuẩn Redz Hub)
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local AttackRig = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework.RigController)

task.spawn(function()
    while task.wait() do
        if _G.SuperFastAttack then
            pcall(function()
                local ActiveController = CombatFramework.activeController
                if ActiveController and ActiveController.blades and ActiveController.blades then
                    ActiveController.timeToNextAttack = -(math.huge)
                    ActiveController.attacking = false
                    ActiveController.increment = 3
                    AttackRig.activeToCode:_attack()
                end
            end)
        end
    end
end)

-- 2. LOGIC GOM QUÁI THEO CỤM (5-7 CON)
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
    local enemiesFolder = game:GetService("Workspace").Enemies:GetChildren()
    
    for _, mob in pairs(enemiesFolder) do
        if table.find(BoneMobNames, mob.Name) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            table.insert(tempCluster, mob)
            count = count + 1
            if count >= 7 then break end
        end
    end
    return tempCluster
end

-- 3. VÒNG LẶP ĐIỀU KHIỂN FARM + TỰ ĐỘNG XUYÊN TƯỜNG (NOCLIP)
task.spawn(function()
    while task.wait() do
        if _G.BoneFarm then
            pcall(function()
                local Character = game.Players.LocalPlayer.Character
                local PlayerRoot = Character:FindFirstChild("HumanoidRootPart")
                if not PlayerRoot then return end

                -- [TỰ ĐỘNG XUYÊN TƯỜNG] Tắt va chạm của nhân vật khi đang farm để không bị kẹt địa hình
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end

                -- TIẾN HÀNH FARM THEO CỤM
                if isClusterDead() then
                    CurrentTargetCluster = findNewMobCluster()
                    if #CurrentTargetCluster == 0 then
                        if (PlayerRoot.Position - BoneQuestGiverCFrame.Position).Magnitude > 20 then
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
                    -- Đứng trên đầu quái 5 studs để né đòn và đấm xuống cho mượt
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

print("[-] Đã kích hoạt Bone Farm + Tự động xuyên tường chống kẹt map!")
