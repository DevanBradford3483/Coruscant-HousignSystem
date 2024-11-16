local TweenService = game:GetService("TweenService")
local DataStore = game:GetService("DataStoreService"):GetDataStore("HousingDataStoreV1DEV")
local HousingModule = require(game:GetService("ServerScriptService"):WaitForChild("HousingSystem"):WaitForChild("HousingModule", 10))
local ProximityPrompt = Instance.new("ProximityPrompt", script.Parent.BackPad)
ProximityPrompt.ActionText, ProximityPrompt.HoldDuration = "Interact", 0.5
local Key, DoorsMoving, TriggerDebounce = "_HousingDev", false, false

local function OpenDoor()
	local Door = script.Parent.Door
	local LeftDoorOrigin, RightDoorOrigin = Door.Left.Base.CFrame, Door.Right.Base.CFrame
	DoorsMoving = true
	TweenService:Create(Door.Left.Base, TweenInfo.new(1), {CFrame = Door.Left.Reach.CFrame}):Play()
	TweenService:Create(Door.Right.Base, TweenInfo.new(1), {CFrame = Door.Right.Reach.CFrame}):Play()
	task.wait(4)
	TweenService:Create(Door.Left.Base, TweenInfo.new(1), {CFrame = LeftDoorOrigin}):Play()
	TweenService:Create(Door.Right.Base, TweenInfo.new(1), {CFrame = RightDoorOrigin}):Play()
	DoorsMoving = false
end

local function AccessGranted()
	spawn(function()
		ProximityPrompt.Enabled = false
		for _ = 1, 2 do
			script.Parent.LED.Color = Color3.new(0.25098, 1, 0.27451)
			task.wait(0.5)
			script.Parent.LED.Color = Color3.new(0.647059, 0, 0)
			task.wait(0.5)
		end
		ProximityPrompt.Enabled = true
	end)
	script.Parent.AccessGranted:Play()
	OpenDoor()
end

local function AccessDenied()
	spawn(function()
		ProximityPrompt.Enabled = false
		for _ = 1, 2 do
			script.Parent.LED.Color = Color3.new(1, 0, 0.0156863)
			task.wait(0.5)
			script.Parent.LED.Color = Color3.new(0.647059, 0, 0)
			task.wait(0.5)
		end
		ProximityPrompt.Enabled = true
	end)
	script.Parent.AccessDenied:Play()
end

ProximityPrompt.Triggered:Connect(function(Player)
	local Data = DataStore:GetAsync(Key)
	if not TriggerDebounce and not DoorsMoving then
		for _, Housing in ipairs(Data) do
			if Housing.HousingID == script.Parent.Configuration.ApartmentId.Value then
				if table.find(Housing.AuthorizedUsers, Player.UserId) then
					AccessGranted()
				else
					AccessDenied()
				end
			end
		end
		TriggerDebounce = true
		task.wait(2)
		TriggerDebounce = false
	end
end)
