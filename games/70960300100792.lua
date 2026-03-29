local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green  = Color3.fromHex("#10C550")
local Blue   = Color3.fromHex("#257AF7")

local autoCash           = false
local autoBronze         = false
local autoCollectCoins   = false
local autoAttack         = false
local autoChopTree       = false
local autoBuy            = false
local rangeRock          = false
local isRunning          = true

local selectedPotionTypes = {}
local merchantCache       = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")

local DropperClickRemote       = Remotes:WaitForChild("DropperClick")
local BronzeDropperClickRemote = Remotes:WaitForChild("BronzeDropperClick")
local CollectPartRemote        = Remotes:WaitForChild("CollectPart")
local MobAttackMltRemote       = Remotes:WaitForChild("MobAttackMlt")
local TreeHitRemote            = Remotes:WaitForChild("TreeHit")
local MerchantRemote           = Remotes:WaitForChild("Merchant")
local RockAttackStateRemote    = Remotes:WaitForChild("RockAttackState")
local RockDamagedRemote        = Remotes:WaitForChild("RockDamaged")
local SetOreRemote             = Remotes:WaitForChild("SetOre")

local POTION_KEYWORDS = {
	["x2 XP"]             = { "x2 xp" },
	["x2 Reading Points"] = { "x2 reading" },
	["x2 Rebirth Points"] = { "x2 rebirth" },
	["x2 Cash"]           = { "x2 cash" },
	["x2 Coins"]          = { "x2 coins" },
	["x2 Diamonds"]       = { "x2 diamonds" },
	["x2 Bones"]          = { "x2 bones" },
	["x2 Energy"]         = { "x2 energy" },
	["x2 Bronze"]         = { "x2 bronze" },
	["x2 Wood"]           = { "x2 wood" },
	["x2 Rocks"]          = { "x2 rocks" },
}

local function normalizeItemName(txt)
	if not txt or txt == "" then return nil end
	local lower = txt:lower():match("^%s*(.-)%s*$")
	for canonical, keywords in pairs(POTION_KEYWORDS) do
		if lower == canonical:lower() then
			return canonical
		end
		for _, kw in ipairs(keywords) do
			if lower:find(kw, 1, true) then
				return canonical
			end
		end
	end
	return nil
end

local SKIP_TEXT = { ["buy"] = true, ["close"] = true, ["open"] = true, ["stock"] = true }

local function isNoise(txt)
	return txt:match("^[%d%.%,]+[%a]*$") ~= nil
end

local function scanMerchantSlots()
	local result = {}
	local seen   = {}
	local player = Players.LocalPlayer

	local function scanContainer(root)
		if not root then return end
		for i = 1, 9 do
			local slotName = "Slot" .. i
			if not seen[slotName] then
				local slot = root:FindFirstChild(slotName, true)
				if slot then
					seen[slotName] = true
					local itemName = nil
					local stock    = nil

					for _, child in ipairs(slot:GetDescendants()) do
						if child:IsA("TextLabel") or child:IsA("TextButton") then
							local txt = (child.Text or ""):match("^%s*(.-)%s*$") or ""
							if txt ~= "" then
								local lower = txt:lower()
								if lower:match("^stock") then
									stock = tonumber(txt:match("%d+"))
								elseif not SKIP_TEXT[lower] and not isNoise(txt) then
									local canonical = normalizeItemName(txt)
									if canonical then
										itemName = canonical
									end
								end
							end
						elseif child:IsA("IntValue") or child:IsA("NumberValue") then
							local n = child.Name:lower()
							if n:find("stock") or n:find("amount") or n:find("count") then
								stock = child.Value
							end
						end
					end

					if itemName then
						result[slotName] = { name = itemName, stock = stock }
					end
				end
			end
		end
	end

	pcall(scanContainer, player and player:FindFirstChild("PlayerGui"))
	pcall(scanContainer, workspace)
	pcall(scanContainer, ReplicatedStorage)

	return result
end

task.spawn(function()
	while isRunning do
		local newCache = scanMerchantSlots()
		if next(newCache) ~= nil then
			merchantCache = newCache
		end
		task.wait(2)
	end
end)

task.spawn(function()
	while isRunning do
		if autoCash then pcall(function() DropperClickRemote:FireServer() end) end
		if autoBronze then pcall(function() BronzeDropperClickRemote:FireServer() end) end
		if autoAttack then pcall(function() MobAttackMltRemote:FireServer() end) end
		if autoChopTree then pcall(function() TreeHitRemote:FireServer() end) end
		task.wait()
	end
end)

task.spawn(function()
	while isRunning do
		if rangeRock then
			local char = Players.LocalPlayer.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			
			local map    = workspace:FindFirstChild("GrassMap")
			local nature = map and map:FindFirstChild("Nature")
			local rocks  = nature and nature:FindFirstChild("Rocks")
			local rock   = rocks and rocks:FindFirstChild("LowPolyMossyRockOne")
			
			if hrp and rock then
				pcall(function() SetOreRemote:FireServer(rock) end)
				pcall(function() SetOreRemote:FireServer(rock.Name) end) 
				
				pcall(function() RockAttackStateRemote:FireServer(true) end)
				pcall(function() RockDamagedRemote:FireServer() end)
			end
		end
		task.wait(0.1)
	end
end)

task.spawn(function()
	while isRunning do
		if autoBuy and next(selectedPotionTypes) ~= nil then
			for slotName, slotData in pairs(merchantCache) do
				local stockOk = (slotData.stock == nil) or (slotData.stock >= 1)
				if stockOk and selectedPotionTypes[slotData.name] then
					pcall(function() MerchantRemote:FireServer("Buy", slotName) end)
				end
			end
		end
		task.wait()
	end
end)

local function tryCollect(obj)
	if autoCollectCoins and obj:IsA("BasePart") and string.match(obj.Name, "^%d+$") then
		pcall(function() CollectPartRemote:FireServer(obj.Name) end)
	end
end

workspace.DescendantAdded:Connect(tryCollect)

local Window = WindUI:CreateWindow({
	Title = "Opus | Dropper Incremental",
	Folder = "Opus/Dropper Incremental",
	Icon = "solar:gamepad-bold",
	NewElements = true,
	HideSearchBar = false,
	Size = UDim2.fromOffset(600, 450),
	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
	OpenButton = {
		Title = "Open UI",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
	},
})

Window:Tag({
	Title = "Beta",
	Color = Color3.fromHex("#1c1c1c"),
	Border = true,
})

local MainSection = Window:Section({
	Title = "Main",
	Opened = true
})

local MainTab = MainSection:Tab({
	Title = "Main",
	Icon = "solar:home-2-bold",
	IconColor = Blue,
	IconShape = "Square",
	Border = true,
})

MainTab:Section({ Title = "Droppers" })

local DropperGroup = MainTab:Group()

DropperGroup:Toggle({
	Title = "Auto Cash",
	Callback = function(state) autoCash = state end,
})

DropperGroup:Toggle({
	Title = "Auto Bronze",
	Callback = function(state) autoBronze = state end,
})

MainTab:Section({ Title = "Farming" })

local CoinsGroup = MainTab:Group()

CoinsGroup:Toggle({
	Title = "Auto Collect Coins",
	Callback = function(state)
		autoCollectCoins = state
		if state then
			for _, obj in pairs(workspace:GetDescendants()) do
				tryCollect(obj)
			end
		end
	end,
})

local TreeGroup = MainTab:Group()

TreeGroup:Toggle({
	Title = "Auto Chop Tree",
	Callback = function(state) autoChopTree = state end,
})

local AttackGroup = MainTab:Group()

AttackGroup:Toggle({
	Title = "Auto Attack",
	Callback = function(state) autoAttack = state end,
})

MainTab:Section({ Title = "Merchant" })

local MerchantGroup = MainTab:Group()

MerchantGroup:Toggle({
	Title = "Auto Buy",
	Callback = function(state) autoBuy = state end,
})

MerchantGroup:Dropdown({
	Title = "",
	Multi = true,
	AllowEmpty = true,
	Values = { "x2 XP", "x2 Reading Points", "x2 Rebirth Points", "x2 Cash", "x2 Coins", "x2 Diamonds", "x2 Bones", "x2 Energy", "x2 Bronze", "x2 Wood", "x2 Rocks" },
	Callback = function(selected)
		selectedPotionTypes = {}
		if type(selected) == "table" then
			for k, v in pairs(selected) do
				if type(k) == "string" and v then
					selectedPotionTypes[k] = true
				elseif type(v) == "string" then
					selectedPotionTypes[v] = true
				end
			end
		elseif type(selected) == "string" then
			selectedPotionTypes[selected] = true
		end
	end,
})

local ExploitsTab = MainSection:Tab({
	Title = "Exploits",
	Icon = "solar:bomb-bold",
	IconColor = Purple,
	IconShape = "Square",
	Border = true,
})

ExploitsTab:Section({ Title = "Spoof & Range" })

local RangeGroup = ExploitsTab:Group()

RangeGroup:Toggle({
	Title = "Rock",
	Callback = function(state) 
		rangeRock = state 
		if not state then
			pcall(function() RockAttackStateRemote:FireServer(false) end)
		end
	end,
})

if type(Window.Destroy) == "function" then
	local oldDestroy = Window.Destroy
	Window.Destroy = function(self, ...)
		isRunning        = false
		autoCash         = false
		autoBronze       = false
		autoCollectCoins = false
		autoAttack       = false
		autoChopTree     = false
		autoBuy          = false
		rangeRock        = false
		return oldDestroy(self, ...)
	end
end

pcall(function() MainTab:Select() end)
