local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Range = 15
local Enabled = true

RunService.RenderStepped:Connect(function()

	if not Enabled then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	for _, Item in pairs(workspace.Items:GetChildren()) do

		if Item:IsA("BasePart") then

			local Distance =
				(Item.Position - Root.Position).Magnitude

			if Distance <= Range then
				firetouchinterest(
					Root,
					Item,
					0
				)

				firetouchinterest(
					Root,
					Item,
					1
				)
			end
		end
	end
end)
