-- [[ SIGMA ULTIMATE BONE & DOUGH KING MULTI-TASK PIPELINE ]]
local P, W, R = game:GetService("Players").LocalPlayer, game:GetService("Workspace"), game:GetService("ReplicatedStorage")
local VU, TS, HS, CG = game:GetService("VirtualUser"), game:GetService("TeleportService"), game:GetService("HttpService"), game:GetService("CoreGui")

if not game:IsLoaded() then game.Loaded:Wait() end
local C = P.Character or P.CharacterAdded:Wait()
local Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF")

local Config = {
    FlySpeed = 290, MaxPing = 95, BlacklistServers = {}, StoredFruits = {},
    -- Tên các loại quái rớt Xương (Bones) chất lượng cao tại Đảo Linh Hồn Sea 3
    BoneMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"},
    BossTargets = {"Dough King", "Cake Prince"}
}

-- [GUI SETUP]
if CG:FindFirstChild("SigmaHub") then CG.SigmaHub:Destroy() end
local SG = Instance.new("ScreenGui", CG) SG.Name = "SigmaHub"
local Frame = Instance.new("Frame", SG) Frame.Size = UDim2.new(0, 250, 0, 140) Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) Frame.BorderSizePixel = 2 Frame.Active = true Frame.Draggable = true
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, 0, 0, 30) Title.Text = "★ SIGMA BONE & BOSS HUNTER ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local StatusLabel = Instance.new("TextLabel", Frame) StatusLabel.Size = UDim2.new(1, 0, 0, 40) StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.Text = "Đang rà soát mục tiêu..." StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 180) StatusLabel.BackgroundTransparency = 1

P.Idled:Connect(function() VU:Button2Down(Vector2.new(0, 0), W.CurrentCamera.CFrame) task.wait(0.1) VU:Button2Up(Vector2.new(0, 0), W.CurrentCamera.CFrame) end)

local function ApplyFly(root, targetPos)
    local bv = root:FindFirstChild("SigmaFly")
    if not bv then
        bv = Instance.new("BodyVelocity") bv.Name = "SigmaFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root
    end
    local dir = (targetPos - root.Position)
    bv.Velocity = dir.Magnitude > 12 and dir.Unit * Config.FlySpeed or Vector3.new(0,0,0)
end

local function ForceStreamArea(pos)
    if P.RequestStreamAroundAsync then pcall(function() P:RequestStreamAroundAsync(pos) end) end
end

-- Máy quét thực thể liên kết Server (VIP Target Acquisition Scanner)
local function ScanServerEntities()
    local enemies = W:FindFirstChild("Enemies") or W
    
    -- 1. Ưu tiên tối cao: Tìm Dough King hoặc Cake Prince
    for _, m in ipairs(enemies:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
            if table.find(Config.BossTargets, m.Name) then
                return "Boss", m
            end
        end
    end
    
    -- 2. Ưu tiên số 2: Tìm Trái ác quỷ rơi tự do
    for _, o in ipairs(W:GetChildren()) do
        if o:IsA("Tool") and (string.find(o.Name, "Fruit") or o:FindFirstChild("Handle")) then
            return "Fruit", o
        end
    end
    
    -- 3. Mặc định: Tìm quái rớt Xương (Bones)
    for _, m in ipairs(enemies:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
            if table.find(Config.BoneMobs, m.Name) then
                return "Bone", m
            end
        end
    end
    
    return "None", nil
end

task.spawn(function()
    while task.wait(0.01) do
        local root = C:FindFirstChild("HumanoidRootPart")
        if root then
            if not Rem then Rem = R:FindFirstChild("Remotes") or R:FindFirstChild("CommF") end
            
            local mode, obj = ScanServerEntities()
            
            if mode == "Boss" and obj:FindFirstChild("HumanoidRootPart") then
                -- [XỬ LÝ BOSS VIP DOUGH KING]
                StatusLabel.Text = "VIP: Đang mukbang sát thương Boss " .. obj.Name
                ForceStreamArea(obj.HumanoidRootPart.Position)
                root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                
                if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                
            elseif mode == "Fruit" and obj:FindFirstChild("Handle") then
                -- [XỬ LÝ TRÁI ÁC QUỶ SPARK]
                StatusLabel.Text = "VIP: Phát hiện Fruit! Đang lao tới hốt..."
                ForceStreamArea(obj.Handle.Position)
                if (root.Position - obj.Handle.Position).Magnitude > 12 then
                    ApplyFly(root, obj.Handle.Position)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = obj.Handle.CFrame task.wait(0.2)
                    local held = P:FindFirstChild("Backpack"):FindFirstChild(obj.Name) or C:FindFirstChild(obj.Name)
                    if held and Rem and not Config.StoredFruits[held.Name] then Rem:InvokeServer("StoreFruit", held.Name, C) Config.StoredFruits[held.Name] = true end
                end
                
            elseif mode == "Bone" and obj:FindFirstChild("HumanoidRootPart") then
                -- [MUKBANG QUÁI XƯƠNG ĐÉO CẦN QUEST]
                StatusLabel.Text = "Mukbang Bones: " .. obj.Name
                local mobPos = obj.HumanoidRootPart.Position
                ForceStreamArea(mobPos)
                
                if (root.Position - mobPos).Magnitude > 45 then
                    ApplyFly(root, mobPos)
                else
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0)
                    
                    -- Đấm tầng gói tin siêu tốc x50 dọn bãi gom xương cực nhanh
                    if Rem then Rem:InvokeServer("Attack", "Combat", true) Rem:InvokeServer("Attack", "Combat", false) end
                    if C.Humanoid:FindFirstChild("Animator") then for _, t in ipairs(C.Humanoid.Animator:GetPlayingAnimationTracks()) do t:Stop(0) end end
                end
                
            else
                -- Khi b bãi trống quái và server sạch bóng Boss -> Tự động đi lượm rương vàng cày tiền
                StatusLabel.Text = "Hết mục tiêu! Đang dọn rương kiếm Beli..."
                local chest = W:FindFirstChild("Chest1") or W:FindFirstChild("Chest2") or W:FindFirstChild("Chest3")
                if chest then 
                    local fly = root:FindFirstChild("SigmaFly") if fly then fly:Destroy() end
                    root.CFrame = chest.CFrame task.wait(0.1) 
                else
                    StatusLabel.Text = "Trống Map! Đang rà soát luồng ngầm..."
                end
            end
        end
    end
end)
