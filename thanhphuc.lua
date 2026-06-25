local Radius = 25

while task.wait(0.1) do
	local Character = script.Parent
	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		continue
	end

	for _, Item in ipairs(workspace.Items:GetChildren()) do

		if Item:IsA("BasePart") then

			local Distance =
				(Item.Position - Root.Position).Magnitude

			if Distance <= Radius then

				Item.Position =
					Item.Position:Lerp(
						Root.Position,
						0.15
					)

			end
		end
	end
end
