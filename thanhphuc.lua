-- ====================================================================
-- 1. SCRIPT KHỞI TẠO DỮ LIỆU NGƯỜI CHƠI (Đặt trong ServerScriptService)
-- ====================================================================
game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local foodCarrying = Instance.new("IntValue")
	foodCarrying.Name = "FoodCarrying"
	foodCarrying.Value = 0
	foodCarrying.Parent = leaderstats
	
	local totalDelivered = Instance.new("IntValue")
	totalDelivered.Name = "TotalDelivered"
	totalDelivered.Value = 0
	totalDelivered.Parent = leaderstats
end)

-- ====================================================================
-- 2. SCRIPT NHẶT THỰC PHẨM (Đặt bên trong từng Part vật phẩm FoodItem)
-- ====================================================================
local foodItem = script.Parent
local isPickedUp = false
local foodValue = 1 

foodItem.Touched:Connect(function(otherPart)
	if isPickedUp then return end
	
	local character = otherPart.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	
	if player then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local foodInventory = leaderstats:FindFirstChild("FoodCarrying")
			if foodInventory then
				isPickedUp = true
				foodInventory.Value = foodInventory.Value + foodValue
				foodItem:Destroy() 
			end
		end
	end
end)

-- ====================================================================
-- 3. SCRIPT KHU VỰC THANG MÁY (Đặt bên trong Part vùng ElevatorDropZone)
-- ====================================================================
local dropZone = script.Parent

dropZone.Touched:Connect(function(otherPart)
	local character = otherPart.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	
	if player then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local foodInventory = leaderstats:FindFirstChild("FoodCarrying")
			local totalScore = leaderstats:FindFirstChild("TotalDelivered")
			
			if foodInventory and foodInventory.Value > 0 then
				totalScore.Value = totalScore.Value + foodInventory.Value
				foodInventory.Value = 0
			end
		end
	end
end)

