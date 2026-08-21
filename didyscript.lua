-- [[ ADVANCED DYNAMIC QUEST & LEVEL FARM INTEGRATION ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui")
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

local Config = {
    FlySpeed = 280, MaxPing = 90, BlacklistServers = {}, StoredFruits = {},
    -- Dữ liệu nạp đầy đủ cấu trúc: Tên quái, Level tối thiểu/tối đa, Tọa độ bãi, Tên NPC, Tên Quest, ID Quest
    Islands = {
        {N="Bandits", M=1, X=10, V=Vector3.new(100,20,100), NPC="Bandit Quest Giver", QName="Bandits", QID=1},
        {N="Monkeys", M=10, X=30, V=Vector3.new(1200,30,-500), NPC="Monkey Quest Giver", QName="Monkeys", QID=1}
    }
}

-- [GUI SETUP]
if CG:FindFirstChild("SigmaHub") then CG.SigmaHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 240, 0, 140) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA QUEST FARM ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 40) StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Text = "Khởi tạo luồng..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100) StatusLabel.BackgroundTransparency = 1

P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly") or Instance.new("BodyVelocity")
    bv.Name = "SigmaFly" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 15 and dir.Unit * Config.FlySpeed or Vector3.new(0,0,0)
end

-- Hàm tương tác ngầm để nhận nhiệm vụ từ NPC bypass hội thoại
local function ForceAcceptQuest(npcName, questName, questId)
    local npc = W:FindFirstChild("NPCs") and W.NPCs:FindFirstChild(npcName) or W:FindFirstChild(npcName)
    if npc and Rem then
        -- Kích hoạt remote nhận quest trực tiếp gửi lên hệ thống server
        Rem:InvokeServer("StartQuest", questName, questId)
    end
end

-- Kiểm tra xem tài khoản hiện tại đã có quest đang chạy chưa
local function HasActiveQuest()
    local data = P:FindFirstChild("Data")
    if data and data:FindFirstChild("Quest") and data.Quest.Value ~= "" then
        return true
    end
    return false
end

-- Quét thực thể đặc biệt (Fruit/Boss)
local function CheckVIPStatus()
    for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and table.find({"Dough King", "Rip Indra", "Cake Prince", "Darkbeard"}, m.Name) then return true, m, "Boss" end
    end
    for _, o in ipairs(W:GetChildren()) do
        if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then return true, o, "Fruit" end
    end
    return false, nil, nil
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            local hasVIP, obj, mode = CheckVIPStatus()
            if hasVIP then
                -- [LOGIC XỬ LÝ MỤC TIÊU VIP UƯ TIÊN]
                if mode == "Fruit" and obj:FindFirstChild("Handle") then
                    StatusLabel.Text = "Ưu tiên: Bay cướp Trái Ác Quỷ!"
                    ApplyFly(root, obj.Handle.Position)
                    if (root.Position - obj.Handle.Position).Magnitude <= 12 then
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        root.CFrame = obj.Handle.CFrame task.wait(0.2)
                        local held = P:FindFirstChild("Backpack"):FindFirstChild(obj.Name) or C:FindFirstChild(obj.Name)
                        if held and Rem and not Config.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) Config.StoredFruits[held.Name] = true end
                    end
                elseif mode == "Boss" and obj:FindFirstChild("HumanoidRootPart") then
                    StatusLabel.Text = "Săn Boss: " .. obj.Name
                    root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                    if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                    if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                end
            else
                -- [LOGIC CHUẨN: FARM LEVEL THEO NHIỆM VỤ]
                local lvl = P:FindFirstChild("Data") and P.Data:FindFirstChild("Level") and P.Data.Level.Value or 1
                local active = Config.Islands[1]
                for _, i in ipairs(Config.Islands) do if lvl >= i.M and lvl <= i.X then active = i break end end
                
                if not HasActiveQuest() then
                    -- Bước 1: Chưa có quest -> Bay đến vị trí NPC để lấy nhiệm vụ
                    StatusLabel.Text = "Hệ thống: Đi nhận Quest " .. active.QName
                    -- Tìm NPC trên map để lấy tọa độ đứng tương tác
                    local npcObj = W:FindFirstChild("NPCs") and W.NPCs:FindFirstChild(active.NPC) or W:FindFirstChild(active.NPC)
                    local npcPos = npcObj and npcObj:FindFirstChild("HumanoidRootPart") and npcObj.HumanoidRootPart.Position or active.V
                    
                    if (root.Position - npcPos).Magnitude > 15 then
                        ApplyFly(root, npcPos)
                    else
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        root.CFrame = CFrame.new(npcPos)
                        task.wait(0.2)
                        ForceAcceptQuest(active.NPC, active.QName, active.QID)
                    end
                else
                    -- Bước 2: Đã có quest -> Di chuyển ra bãi quái và đấm không animation
                    if (root.Position - active.V).Magnitude > 50 then
                        StatusLabel.Text = "Hệ thống: Bay ra đảo farm..."
                        ApplyFly(root, active.V)
                    else
                        if root:FindFirstChild("SigmaFly") then root.SigmaFly:Destroy() end
                        local targetMob = nil
                        for _, m in ipairs((W:FindFirstChild("Enemies") or W):GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m.Name == active.N then targetMob = m break end
                        end
                        
                        if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                            StatusLabel.Text = "Farm: " .. active.N .. " (Đúng Quest)"
                            root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                            if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                            if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                        else
                            StatusLabel.Text = "Chờ quái hồi sinh..."
                        end
                    end
                end
            end
        end
    end
end)
