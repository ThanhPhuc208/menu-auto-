local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Deadly Delivery Pro Hub 🚀",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = { Enabled = false }
})

local _G = {
    WalkSpeed = 16,
    GodMode = false,
    AutoLoot = false,
    CustomDistance = 5
}

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local BubbleGui = Instance.new("ScreenGui")
local BubbleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

BubbleGui.Name = "CustomBubbleGui"
BubbleGui.Parent = CoreGui
BubbleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

BubbleButton.Name = "BubbleButton"
BubbleButton.Parent = BubbleGui
BubbleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
BubbleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
BubbleButton.Size = UDim2.new(0, 50, 0, 50)
BubbleButton.Font = Enum.Font.SourceSansBold
BubbleButton.Text = "MENU"
BubbleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BubbleButton.TextSize = 14

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = BubbleButton

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

BubbleButton.MouseButton1Click:Connect(function()
    if CoreGui:FindFirstChild("Rayfield") then
        local mainFrame = CoreGui.Rayfield:FindFirstChild("Main")
        if mainFrame then mainFrame.Visible = not mainFrame.Visible end
    end
end)

local MainTab = Window:CreateTab("Chức Năng", 4483362458)
local ConfigTab = Window:CreateTab("Tùy Chỉnh", 4483362458)

MainTab:CreateButton({
   Name = "Bring All Items & Thực Phẩm Phía Ngoài Thang Máy",
   Callback = function()
       local localPlayer = game.Players.LocalPlayer
       local character = localPlayer.Character
       local elevator = workspace:FindFirstChild("Elevator") or workspace:FindFirstChild("Elevator_Model")
       
       if elevator and character and character:FindFirstChild("HumanoidRootPart") then
           local originalPos = character.HumanoidRootPart.CFrame
           local elevatorPart = elevator:FindFirstChild("PrimaryPart") or elevator:FindFirstChildWhichIsA("BasePart", true)
           
           if elevatorPart then
               local outsideElevator = elevatorPart.CFrame * CFrame.new(0, 0, _G.CustomDistance)
               
               for _, obj in pairs(workspace:GetDescendants()) do
                   if obj:IsA("ProximityPrompt") then
                       local parent = obj.Parent
                       if parent and (parent:IsA("Tool") or parent:IsA("Model") or parent:IsA("Part")) then
                           local part = parent:IsA("Model") and (parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")) or parent
                           if part and part:IsA("BasePart") then
                               character.HumanoidRootPart.CFrame = part.CFrame
                               task.wait(0.1)
                               fireproximityprompt(obj)
                               task.wait(0.1)
                               if character:FindFirstChildOfClass("Tool") or localPlayer.Backpack:FindFirstChild(parent.Name) then
                                   character.HumanoidRootPart.CFrame = outsideElevator
                                   task.wait(0.1)
                                   local tool = character:FindFirstChildOfClass("Tool")
                                   if tool then tool.Parent = workspace end
                               end
                           end
                       end
                   end
               end
               character.HumanoidRootPart.CFrame = originalPos
               Rayfield:Notify({Title = "Thành công", Content = "Đã gom và nhặt thực phẩm về ngoài thang máy!", Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy vị trí Thang máy phù hợp.", Duration = 3})
       end
   end
})

MainTab:CreateToggle({
   Name = "Auto Loot (Tủ & Thùng)",
   CurrentValue = false,
   Flag = "LootToggle",
   Callback = function(Value)
       _G.AutoLoot = Value
       task.spawn(function()
           while _G.AutoLoot do
               for _, obj in pairs(workspace:GetDescendants()) do
                   if obj:IsA("ProximityPrompt") then
                       local name = obj.Parent and obj.Parent.Name:lower() or ""
                       if name:find("box") or name:find("chest") or name:find("cabinet") or name:find("crate") or name:find("container") or name:find("safe") then
                           fireproximityprompt(obj)
                       end
                   end
               end
               task.wait(0.5)
           end
       end)
   end
})

MainTab:CreateToggle({
   Name = "God Mode Tối Ưu (Bất Tử Máu)",
   CurrentValue = false,
   Flag = "GodToggle",
   Callback = function(Value)
       _G.GodMode = Value
       task.spawn(function()
           while _G.GodMode do
               local char = game.Players.LocalPlayer.Character
               if char and char:FindFirstChild("Humanoid") then
                   char.Humanoid.Health = math.max(char.Humanoid.Health, char.Humanoid.MaxHealth)
                   if char:FindFirstChild("ForceField") == nil then
                       Instance.new("ForceField", char)
                   end
               end
               task.wait(0.1)
           end
           local char = game.Players.LocalPlayer.Character
           if char and char:FindFirstChild("ForceField") then
               char.ForceField:Destroy()
           end
       end)
   end
})

ConfigTab:CreateInput({
   Name = "Khoảng Cách Ngoài Thang Máy",
   PlaceholderText = "Mặc định: 5",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local dist = tonumber(Text)
       if dist then _G.CustomDistance = dist end
   end
})

ConfigTab:CreateInput({
   Name = "Tùy Chỉnh Tốc Độ Di Chuyển",
   PlaceholderText = "Mặc định: 16",
   RemoveTextAfterFocusLost = false,
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

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = _G.WalkSpeed
end)

Rayfield:Notify({Title = "Hệ thống", Content = "Đã khởi tạo xong Menu Deadly Delivery!", Duration = 3})

