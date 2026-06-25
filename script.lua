-- Chờ trò chơi tải xong hoàn toàn
repeat task.wait() until game:IsLoaded()

-- Khởi tạo Thư viện Giao diện Orion UI (Thay thế Rayfield để sửa lỗi không hiện menu)
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

local Window = OrionLib:MakeWindow({
    Name = "Deadly Delivery Pro Hub 🚀", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "Đang tải Premium Hub..."
})

-- Các biến lưu thông số tùy chỉnh toàn cục
_G.WalkSpeed = 16
_G.GodMode = false
_G.AutoLoot = false
_G.CustomDistance = 6  -- Khoảng cách đứng ngoài phía trước thang máy

-- -----------------------------------------------------------------------------
-- TẠO BONG BÓNG DI CHUYỂN & ẨN/HIỆN MENU GỐC
-- -----------------------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Xóa bong bóng cũ nếu có để tránh trùng lặp
if CoreGui:FindFirstChild("DeadlyBubbleGui") then
    CoreGui.DeadlyBubbleGui:Destroy()
end

local BubbleGui = Instance.new("ScreenGui")
local BubbleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

BubbleGui.Name = "DeadlyBubbleGui"
BubbleGui.Parent = CoreGui
BubbleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

BubbleButton.Name = "BubbleButton"
BubbleButton.Parent = BubbleGui
BubbleButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
BubbleButton.Position = UDim2.new(0.15, 0, 0.45, 0)
BubbleButton.Size = UDim2.new(0, 55, 0, 55)
BubbleButton.Font = Enum.Font.SourceSansBold
BubbleButton.Text = "MENU"
BubbleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BubbleButton.TextSize = 14

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = BubbleButton

-- Tính năng kéo thả (Drag) mượt mà cho bong bóng nổi
local dragging, dragInput, dragStart, startPos
BubbleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = BubbleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
BubbleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        BubbleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click bong bóng nổi để Ẩn / Hiện Menu Orion
BubbleButton.MouseButton1Click:Connect(function()
    if CoreGui:FindFirstChild("Orion") then
        local mainFrame = CoreGui.Orion:FindFirstChild("Main")
        if mainFrame then mainFrame.Visible = not mainFrame.Visible end
    end
end)

-- -----------------------------------------------------------------------------
-- PHÂN CHIA MENU CHỨC NĂNG
-- -----------------------------------------------------------------------------
local MainTab = Window:MakeTab({ Name = "Chức Năng Chính", Icon = "rbxassetid://4483362458", Premium = false })
local ConfigTab = Window:MakeTab({ Name = "Cài Đặt / Tùy Chỉnh", Icon = "rbxassetid://4483362458", Premium = false })

-- 1. Tính năng mang vật phẩm và thực phẩm ra phía ngoài thang máy
MainTab:AddButton({
    Name = "Bring All Items & Thực Phẩm (Ra ngoài Thang Máy)",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        local character = localPlayer.Character
        -- Quét tìm Thang máy trong toàn bộ Workspace
        local elevator = workspace:FindFirstChild("Elevator") or workspace:FindFirstChild("Elevator_Model") or workspace:FindFirstChild("ThangMay")
        
        if elevator and character and character:FindFirstChild("HumanoidRootPart") then
            local originalPos = character.HumanoidRootPart.CFrame
            local elevatorPart = elevator:FindFirstChild("PrimaryPart") or elevator:FindFirstChildWhichIsA("BasePart", true)
            
            if elevatorPart then
                -- Tính toán vị trí đứng "phía bên ngoài" cửa thang máy dựa trên khoảng cách tùy chỉnh
                local outsideElevator = elevatorPart.CFrame * CFrame.new(0, 0, _G.CustomDistance)
                
                -- Quét tất cả các ProximityPrompt nhặt đồ ăn và vật phẩm trên bản đồ
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local parent = obj.Parent
                        if parent and (parent:IsA("Tool") or parent:IsA("Model") or parent:IsA("Part") or obj.Name:lower():find("item") or obj.Name:lower():find("food")) then
                            local part = parent:IsA("Model") and (parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")) or parent
                            if part and part:IsA("BasePart") then
                                -- Dịch chuyển đến nhặt đồ
                                character.HumanoidRootPart.CFrame = part.CFrame
                                task.wait(0.12)
                                fireproximityprompt(obj)
                                task.wait(0.12)
                                
                                -- Kiểm tra nếu nhặt thành công thì đem thả ra khu vực ngoài thang máy
                                if character:FindFirstChildOfClass("Tool") or localPlayer.Backpack:FindFirstChild(parent.Name) then
                                    character.HumanoidRootPart.CFrame = outsideElevator
                                    task.wait(0.1)
                                    local tool = character:FindFirstChildOfClass("Tool")
                                    if tool then tool.Parent = workspace end -- Thả xuống đất tại Thang máy
                                end
                            end
                        end
                    end
                end
                -- Quay trở lại vị trí đứng ban đầu của bạn để an toàn
                character.HumanoidRootPart.CFrame = originalPos
                OrionLib:MakeNotification({Name = "Thành công!", Content = "Đã gom xong vật phẩm & đồ ăn về thang máy.", Time = 4})
            end
        else
            OrionLib:MakeNotification({Name = "Lỗi", Content = "Không tìm thấy cấu trúc Thang máy trên bản đồ.", Time = 4})
        end
    end
})

-- 2. Tính năng Auto Loot các thùng, tủ, két sắt chứa tài nguyên
MainTab:AddToggle({
    Name = "Auto Loot (Tự động mở Tủ & Thùng)",
    Default = false,
    Callback = function(Value)
        _G.AutoLoot = Value
        task.spawn(function()
            while _G.AutoLoot do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local name = obj.Parent and obj.Parent.Name:lower() or ""
                        if name:find("box") or name:find("chest") or name:find("cabinet") or name:find("crate") or name:find("container") or name:find("safe") or name:find("drawer") then
                            fireproximityprompt(obj)
                        end
                    end
                end
                task.wait(0.5) -- Giới hạn vòng lặp để tránh gây giật lag (Crash game)
            end
        end)
    end
})

-- 3. Tính năng God Mode hiệu quả nhất (Tăng cường ForceField chống quái cắn)
MainTab:AddToggle({
    Name = "God Mode (Bất Tử Máu Toàn Diện)",
    Default = false,
    Callback = function(Value)
        _G.GodMode = Value
        task.spawn(function()
            while _G.GodMode do
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    -- Liên tục hồi máu và chặn sát thương từ quái vật
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                    if char:FindFirstChild("ForceField") == nil then
                        Instance.new("ForceField", char)
                    end
                end
                task.wait(0.1)
            end
            -- Tắt tính năng sẽ tự hủy khiên bất tử
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("ForceField") then
                char.ForceField:Destroy()
            end
        end)
    end
})

-- --- TAB: CÁC Ô TÙY CHỈNH CHỈ SỐ ---

-- 4. Ô nhập tùy chỉnh khoảng cách thả đồ trước thang máy
ConfigTab:AddInput({
    Name = "Khoảng Cách Đứng Ngoài Thang Máy",
    Default = "6",
    Numeric = true,
    Finished = true,
    Callback = function(Text)
        local dist = tonumber(Text)
        if dist then 
            _G.CustomDistance = dist 
            OrionLib:MakeNotification({Name = "Hệ thống", Content = "Đã chỉnh khoảng cách thang máy thành: " .. dist, Time = 2})
        end
    end
})

-- 5. Ô nhập tùy chỉnh Tốc độ di chuyển (Speed)
ConfigTab:AddInput({
    Name = "Tùy Chỉnh Tốc Độ (Speed)",
    Default = "16",
    Numeric = true,
    Finished = true,
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed then
            _G.WalkSpeed = speed
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = _G.WalkSpeed
            end
        end
    end
})

-- Giữ nguyên tốc độ chạy đã cài đặt sau mỗi lần nhân vật hồi sinh (Reset)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = _G.WalkSpeed
end)

-- Hoàn tất khởi tạo
OrionLib:Init()
