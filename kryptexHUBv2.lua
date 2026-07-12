-- kryptex Dungeon Hub
-- Hub script using the provided remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager

pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local player = Players.LocalPlayer

local HubUI = loadstring(game:HttpGet(("https://sirius.menu/%s"):format("ray" .. "field")))()

local settings = {
	OrbitSpeed = 6,
	OrbitDistance = 10,
	OrbitHeight = 4,
	CastDelay = 0.35,
	AutoCast = true,
	AutoEquipBest = false,
	EquipBestDelay = 5,
	AutoSkillPoints = false,
	SkillPointType = "spell",
	SkillPointAmount = 1,
	SkillPointDelay = 5,
	Hardcore = false,
	NoHit = false,
	CalamityModifier = false,
	SoloSafetyPause = false,
	AutoStartOnExecute = false,
	AutoCreateAndStartDungeon = true,
	DungeonStartDelay = 2,
	DungeonStartAttempts = 8,
	DungeonStartRetryDelay = 0.75,
	CharacterSlot = 1,
	AutoSellAfterRun = false,
	AutoSellOnLoad = false,
	AutoSellDelay = 1,
	AutoSellScanTimeout = 5,
	ProtectEquippedItems = true,
	HideName = false,
	AutoTower = false,
	AutoTowerPickDelay = 1.25,
	AutoTowerStartRetry = true,
	TowerStartRetryDelay = 3,
	AutoTowerTreasureRewards = true,
	TreasureRewardTimeout = 8,
	TowerPortals = {},
	SellRarities = {
		common = false,
		uncommon = false,
		rare = false,
		epic = false,
		legendary = false,
		heirloom = false,
		fabled = false,
	},
}

local staticDungeonPresets = {
	{ Map = "Raided Village", Difficulty = "Normal", LevelRequirement = 1, Tier = 0 },
	{ Map = "Raided Village", Difficulty = "Expert", LevelRequirement = 5, Tier = 0 },
	{ Map = "Raided Village", Difficulty = "Chaos", LevelRequirement = 10, Tier = 0 },
	{ Map = "Raided Village", Difficulty = "Calamity", LevelRequirement = 15, Tier = 0 },

	{ Map = "Sunken Fortress", Difficulty = "Normal", LevelRequirement = 20, Tier = 0 },
	{ Map = "Sunken Fortress", Difficulty = "Expert", LevelRequirement = 25, Tier = 0 },
	{ Map = "Sunken Fortress", Difficulty = "Chaos", LevelRequirement = 30, Tier = 0 },
	{ Map = "Sunken Fortress", Difficulty = "Calamity", LevelRequirement = 35, Tier = 0 },

	{ Map = "Cursed Marshes", Difficulty = "Normal", LevelRequirement = 40, Tier = 0 },
	{ Map = "Cursed Marshes", Difficulty = "Expert", LevelRequirement = 45, Tier = 0 },
	{ Map = "Cursed Marshes", Difficulty = "Chaos", LevelRequirement = 50, Tier = 0 },
	{ Map = "Cursed Marshes", Difficulty = "Calamity", LevelRequirement = 55, Tier = 0 },

	{ Map = "Ragnarok Descent", Difficulty = "Normal", LevelRequirement = 60, Tier = 0 },
	{ Map = "Ragnarok Descent", Difficulty = "Expert", LevelRequirement = 65, Tier = 0 },
	{ Map = "Ragnarok Descent", Difficulty = "Chaos", LevelRequirement = 70, Tier = 0 },
	{ Map = "Ragnarok Descent", Difficulty = "Calamity", LevelRequirement = 75, Tier = 0 },

	{ Map = "Thundering Peaks", Difficulty = "Normal", LevelRequirement = 80, Tier = 0 },
	{ Map = "Thundering Peaks", Difficulty = "Expert", LevelRequirement = 85, Tier = 0 },
	{ Map = "Thundering Peaks", Difficulty = "Chaos", LevelRequirement = 90, Tier = 0 },
	{ Map = "Thundering Peaks", Difficulty = "Calamity", LevelRequirement = 95, Tier = 0 },

	{ Map = "Fallen Paradise", Difficulty = "Normal", LevelRequirement = 100, Tier = 0 },
	{ Map = "Fallen Paradise", Difficulty = "Expert", LevelRequirement = 105, Tier = 0 },
	{ Map = "Fallen Paradise", Difficulty = "Chaos", LevelRequirement = 110, Tier = 0 },
	{ Map = "Fallen Paradise", Difficulty = "Calamity", LevelRequirement = 115, Tier = 0 },

	{ Map = "Eternal Domain", Difficulty = "Normal", LevelRequirement = 120, Tier = 0 },
	{ Map = "Eternal Domain", Difficulty = "Expert", LevelRequirement = 125, Tier = 0 },
	{ Map = "Eternal Domain", Difficulty = "Chaos", LevelRequirement = 130, Tier = 0 },
	{ Map = "Eternal Domain", Difficulty = "Calamity", LevelRequirement = 135, Tier = 0 },

	{ Map = "Stardust Citadel", Difficulty = "Normal", LevelRequirement = 140, Tier = 0 },
	{ Map = "Stardust Citadel", Difficulty = "Expert", LevelRequirement = 145, Tier = 0 },
	{ Map = "Stardust Citadel", Difficulty = "Chaos", LevelRequirement = 150, Tier = 0 },
	{ Map = "Stardust Citadel", Difficulty = "Calamity", LevelRequirement = 155, Tier = 0 },

	{ Map = "Ethereal Farlands", Difficulty = "Normal", LevelRequirement = 160, Tier = 0 },
	{ Map = "Ethereal Farlands", Difficulty = "Expert", LevelRequirement = 165, Tier = 0 },
	{ Map = "Ethereal Farlands", Difficulty = "Chaos", LevelRequirement = 170, Tier = 0 },
	{ Map = "Ethereal Farlands", Difficulty = "Calamity", LevelRequirement = 175, Tier = 0 },

	{ Map = "Hellbound Sanctum", Difficulty = "Normal", LevelRequirement = 180, Tier = 0 },
	{ Map = "Hellbound Sanctum", Difficulty = "Expert", LevelRequirement = 185, Tier = 0 },
	{ Map = "Hellbound Sanctum", Difficulty = "Chaos", LevelRequirement = 190, Tier = 0 },
	{ Map = "Hellbound Sanctum", Difficulty = "Calamity", LevelRequirement = 195, Tier = 0 },

	{ Map = "Forsaken Limbo", Difficulty = "Normal", LevelRequirement = 200, Tier = 0 },
	{ Map = "Forsaken Limbo", Difficulty = "Expert", LevelRequirement = 205, Tier = 0 },
	{ Map = "Forsaken Limbo", Difficulty = "Chaos", LevelRequirement = 210, Tier = 0 },
	{ Map = "Forsaken Limbo", Difficulty = "Calamity", LevelRequirement = 215, Tier = 0 },

	{ Map = "Neon District", Difficulty = "Normal", LevelRequirement = 220, Tier = 0 },
	{ Map = "Neon District", Difficulty = "Expert", LevelRequirement = 225, Tier = 0 },
	{ Map = "Neon District", Difficulty = "Chaos", LevelRequirement = 230, Tier = 0 },
	{ Map = "Neon District", Difficulty = "Calamity", LevelRequirement = 235, Tier = 0 },

	{ Map = "The First Sanctuary", Difficulty = "Normal", LevelRequirement = 240, Tier = 0 },
	{ Map = "The First Sanctuary", Difficulty = "Expert", LevelRequirement = 245, Tier = 0 },
	{ Map = "The First Sanctuary", Difficulty = "Chaos", LevelRequirement = 250, Tier = 0 },
	{ Map = "The First Sanctuary", Difficulty = "Calamity", LevelRequirement = 255, Tier = 0 },
}

local dungeonMapAliases = {
	["Ragnarok Descent"] = {
		"Ragnarok Descent",
		"Ragnarök's Descent",
		"Ragnarok's Descent",
		"Ragnarök Descent",
	},
}

local autoFarm = false
local currentEnemy
local orbitConnection
local attackLoopRunning = false
local utilityLoopRunning = false
local dungeonFlowRunning = false
local soloSafetyLoopRunning = false
local hideNameLoopRunning = false
local zurielWatchLoopRunning = false
local zurielSeenAlive = false
local zurielTeleportDone = false
local ephrathSeenAlive = false
local ephrathTeleportDone = false
local ephrathTeleportAt = 0
local grailArenaTeleportDone = false
local towerPortalSlots = {}
local towerPortalPickLocked = false
local towerPortalEventConnected = false
local towerWaveResetConnected = false
local towerTreasureCollecting = false
local towerTreasureClaimedAt = setmetatable({}, { __mode = "k" })
local lastTowerPortalPick = 0
local lastTowerStartRetry = 0
local towerStartRetryRunning = false
local lastVisibleStartButtonName = nil
local lastEquipBest = 0
local lastSkillPoint = 0
local hubIconGui
local hubIconButton
local hookedMinimizeButtons = {}
local hideNameOriginals = setmetatable({}, { __mode = "k" })
local finalBossAttackLock

local ZURIEL_CLEAR_POSITION = Vector3.new(-59.861, -101.444, -1474.841)
local EPHRATH_CLEAR_CFRAME = CFrame.new(-86.484, -40.969, -3942.660)
local GRAIL_ARENA_CFRAME = CFrame.new(1302.258, 433.780, -4008.982)

local function getRemote(name)
	return ReplicatedStorage:FindFirstChild(name) or ReplicatedStorage:WaitForChild(name, 2)
end

local remoteNames = {
	Bolt = "Bolt",
	UseSpell = "useSpell",
	SelectCharacterSlot = "SelectCharacterSlot",
	CreateLobby = "CreateLobby",
	StartLobby = "StartLobby",
	StartDungeon = "StartDungeon",
	AddSkillPoints = "addSkillPoints",
	EquipBest = "EquipBest",
	GetInventory = "getInventory",
	SellItems = "sellItems",
	DisplayPortals = "DisplayPortals",
}

local remotes = {
	Bolt = getRemote(remoteNames.Bolt),
	UseSpell = getRemote(remoteNames.UseSpell),
	SelectCharacterSlot = getRemote(remoteNames.SelectCharacterSlot),
	CreateLobby = getRemote(remoteNames.CreateLobby),
	StartLobby = getRemote(remoteNames.StartLobby),
	StartDungeon = getRemote(remoteNames.StartDungeon),
	AddSkillPoints = getRemote(remoteNames.AddSkillPoints),
	EquipBest = getRemote(remoteNames.EquipBest),
	GetInventory = getRemote(remoteNames.GetInventory),
	SellItems = getRemote(remoteNames.SellItems),
	DisplayPortals = getRemote(remoteNames.DisplayPortals),
}

local function resolveRemote(key)
	local remote = remotes[key]

	if remote and remote.Parent then
		return remote
	end

	local remoteName = remoteNames[key]
	if not remoteName then
		return nil
	end

	remote = getRemote(remoteName)
	remotes[key] = remote
	return remote
end

local getPlayerLevel
local getBestUnlockedDungeon
local playerInfoParagraph

local function notify(title, content)
	pcall(function()
		HubUI:Notify({
			Title = title,
			Content = content,
			Duration = 4,
		})
	end)
end

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getGuiParent()
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and coreGui then
		return coreGui
	end

	return player:WaitForChild("PlayerGui")
end

local function findHubGui()
	local parents = {
		getGuiParent(),
		player:FindFirstChild("PlayerGui"),
	}

	for _, parent in ipairs(parents) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("ScreenGui") and child ~= hubIconGui then
					local name = string.lower(child.Name)

					if name:find("kryptex") then
						return child
					end

					for _, descendant in ipairs(child:GetDescendants()) do
						if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
							local text = string.lower(tostring(descendant.Text))

							if text:find("kryptexhub", 1, true) then
								return child
							end
						end
					end
				end
			end
		end
	end
end

local function restoreLikelyHubFrames(gui)
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = true
		end
	end

	for _, descendant in ipairs(gui:GetDescendants()) do
		if descendant:IsA("GuiObject") then
			local name = string.lower(descendant.Name)

			if name:find("main") or name:find("window") or name:find("container") then
				descendant.Visible = true
			end
		end
	end
end

local function setHubVisible(visible)
	local gui = findHubGui()

	if gui then
		gui.Enabled = visible

		if visible then
			restoreLikelyHubFrames(gui)
		end
	end

	if hubIconButton then
		hubIconButton.Visible = not visible
	end
end

local function hookHubMinimizeButtons()
	local gui = findHubGui()
	if not gui then
		return
	end

	for _, descendant in ipairs(gui:GetDescendants()) do
		if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) and not hookedMinimizeButtons[descendant] then
			local text = descendant:IsA("TextButton") and tostring(descendant.Text) or ""
			local name = string.lower(descendant.Name)

			if text == "-" or name:find("min") then
				hookedMinimizeButtons[descendant] = true

				descendant.Activated:Connect(function()
					task.delay(0.15, function()
						if hubIconButton then
							hubIconButton.Visible = true
						end
					end)
				end)
			end
		end
	end
end

local function makeDraggable(guiObject)
	local dragging = false
	local dragStart
	local startPosition

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

local function createHubIcon()
	if hubIconGui then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "kryptexHUBIcon"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	local button = Instance.new("TextButton")
	button.Name = "OpenButton"
	button.Size = UDim2.new(0, 54, 0, 54)
	button.Position = UDim2.new(0, 18, 0.5, -27)
	button.BackgroundColor3 = Color3.fromRGB(31, 35, 50)
	button.BorderSizePixel = 0
	button.Text = "kH"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Visible = false
	button.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(65, 125, 220)
	stroke.Thickness = 2
	stroke.Parent = button

	button.Activated:Connect(function()
		setHubVisible(true)
	end)

	makeDraggable(button)

	gui.Parent = getGuiParent()
	hubIconGui = gui
	hubIconButton = button
end

local function startHubIconMonitor()
	task.spawn(function()
		while task.wait(0.5) do
			hookHubMinimizeButtons()

			if hubIconButton then
				local gui = findHubGui()

				if gui and not gui.Enabled then
					hubIconButton.Visible = true
				end
			end
		end
	end)
end

local function fireRemote(remote, ...)
	if not remote then
		return false
	end

	local ok, err = pcall(function(...)
		remote:FireServer(...)
	end, ...)

	if not ok then
		notify("Remote Error", tostring(err))
	end

	return ok
end

local function invokeRemote(remote, ...)
	if not remote then
		return nil
	end

	local ok, result = pcall(function(...)
		return remote:InvokeServer(...)
	end, ...)

	if not ok then
		notify("Remote Error", tostring(result))
		return nil
	end

	return result
end

local function useBolt()
	return fireRemote(resolveRemote("Bolt"))
end

local function useSpell(key)
	return fireRemote(resolveRemote("UseSpell"), key)
end

local function selectCharacterSlot(slot)
	settings.CharacterSlot = slot
	return fireRemote(resolveRemote("SelectCharacterSlot"), slot)
end

local function equipBest()
	return fireRemote(resolveRemote("EquipBest"))
end

local function addSkillPoints(statName, amount)
	statName = tostring(statName or "spell")
	amount = math.max(1, math.floor(tonumber(amount) or 1))
	return fireRemote(resolveRemote("AddSkillPoints"), statName, amount)
end

local sellItemTypes = {
	"weapons",
	"armors",
	"helmets",
	"legs",
	"spells",
	"rings",
	"sigils",
}

local sellRarityOptions = {
	{ Key = "common", Label = "Common" },
	{ Key = "uncommon", Label = "Uncommon" },
	{ Key = "rare", Label = "Rare" },
	{ Key = "epic", Label = "Epic" },
	{ Key = "legendary", Label = "Legendary" },
	{ Key = "heirloom", Label = "Secret / Heirloom" },
	{ Key = "fabled", Label = "Fabled" },
}

local towerPortalOptions = {
	{ Name = "Regular", Danger = 0 },
	{ Name = "Treasure", Danger = -1 },
	{ Name = "Endurance", Danger = 1 },
	{ Name = "Speed", Danger = 2 },
	{ Name = "Gathering", Danger = 2 },
	{ Name = "Balance", Danger = 3 },
	{ Name = "Collosus", Danger = 3 },
	{ Name = "Quickfire", Danger = 3 },
	{ Name = "Strength", Danger = 4 },
	{ Name = "Equilibrium", Danger = 4 },
	{ Name = "Duplication", Danger = 5 },
	{ Name = "Combination", Danger = 5 },
	{ Name = "Chance", Danger = 6 },
	{ Name = "Haste", Danger = 6 },
	{ Name = "Overkill", Danger = 8 },
	{ Name = "Dominion", Danger = 9 },
	{ Name = "Evasion", Danger = 10 },
}

local towerPortalDanger = {}

for _, portal in ipairs(towerPortalOptions) do
	towerPortalDanger[portal.Name] = portal.Danger
	settings.TowerPortals[portal.Name] = false
end

local function readValueObject(parent, name)
	local valueObject = parent and parent:FindFirstChild(name)

	if valueObject then
		local ok, value = pcall(function()
			return valueObject.Value
		end)

		if ok then
			return value
		end
	end
end

local function readFirstValueObject(parent, names)
	for _, name in ipairs(names) do
		local value = readValueObject(parent, name)

		if value ~= nil then
			return value
		end
	end
end

local function valueLooksEnabled(value)
	local valueType = typeof(value)

	if valueType == "boolean" then
		return value
	end

	if valueType == "number" then
		return value ~= 0
	end

	if valueType == "string" then
		value = string.lower(value)
		return value == "true" or value == "yes" or value == "equipped" or value == "1"
	end

	return false
end

local function normalizeRarity(rarity)
	rarity = string.lower(tostring(rarity or ""))

	if rarity == "secret" then
		return "heirloom"
	end

	return rarity
end

local function makeSellPayload()
	local payload = {}

	for _, itemType in ipairs(sellItemTypes) do
		payload[itemType] = {}
	end

	return payload
end

local equippedFlagNames = {
	"itemEquipped",
	"equipped",
	"Equipped",
	"isEquipped",
	"IsEquipped",
	"currentlyEquipped",
	"CurrentlyEquipped",
}

local equippedContainerNames = {
	"equipment",
	"equipped",
	"equippeditems",
	"loadout",
	"characterloadout",
	"currentloadout",
	"itemstatsframe",
	"weaponframe",
	"armorframe",
	"helmetframe",
	"legsframe",
	"spellframe",
	"ringframe",
	"sigilframe",
}

local equippedSlotNames = {
	"Armor",
	"E",
	"Q",
	"Hat",
	"Pants",
	"Rings",
	"Sigil",
	"Weapon",
	"Slot1",
	"Slot2",
}

local equippedValueNames = {
	"weapon",
	"armor",
	"helmet",
	"legs",
	"spell",
	"ring",
	"sigil",
	"equippedweapon",
	"equippedarmor",
	"equippedhelmet",
	"equippedlegs",
	"equippedspell",
	"equippedring",
	"equippedsigil",
}

local inventoryTileAncestorNames = {
	"rightside",
	"scrollingframe",
	"inventory",
}

local function hasSelectedSellRarity()
	for _, selected in pairs(settings.SellRarities) do
		if selected then
			return true
		end
	end

	return false
end

local function frameHasAncestorNamed(frame, nameSet)
	local current = frame

	while current do
		if nameSet[string.lower(current.Name)] then
			return true
		end

		current = current.Parent
	end

	return false
end

local function getEquippedContainerNameSet()
	local nameSet = {}

	for _, name in ipairs(equippedContainerNames) do
		nameSet[name] = true
	end

	return nameSet
end

local equippedContainerNameSet = getEquippedContainerNameSet()

local function getEquippedValueNameSet()
	local nameSet = {}

	for _, name in ipairs(equippedValueNames) do
		nameSet[name] = true
	end

	return nameSet
end

local equippedValueNameSet = getEquippedValueNameSet()

local function hasAncestorNamed(frame, wantedName)
	wantedName = string.lower(wantedName)
	local current = frame

	while current do
		if string.lower(current.Name) == wantedName then
			return true
		end

		current = current.Parent
	end

	return false
end

local function isInventoryItemFrame(frame)
	if not frame or not frame:IsA("Frame") then
		return false
	end

	local stats = frame:FindFirstChild("itemStats")

	if not stats or not readValueObject(stats, "GUID") then
		return false
	end

	if frameHasAncestorNamed(frame, equippedContainerNameSet) then
		return false
	end

	if not frame:FindFirstChild("TextButton") then
		return false
	end

	for _, ancestorName in ipairs(inventoryTileAncestorNames) do
		if not hasAncestorNamed(frame, ancestorName) then
			return false
		end
	end

	return frame.Parent and frame.Parent:IsA("ScrollingFrame")
end

local function getInventoryFrames()
	local frames = {}
	local containers = {
		player:FindFirstChild("PlayerGui"),
		getGuiParent(),
	}

	for _, container in ipairs(containers) do
		if container then
			for _, descendant in ipairs(container:GetDescendants()) do
				if descendant.Name == "itemStats" and isInventoryItemFrame(descendant.Parent) then
					table.insert(frames, descendant.Parent)
				end
			end
		end
	end

	return frames
end

local function itemStatsLooksEquipped(stats)
	if not settings.ProtectEquippedItems or not stats then
		return false
	end

	return valueLooksEnabled(readFirstValueObject(stats, equippedFlagNames))
end

local function getEquippedItemsFolder()
	local playerGui = player:FindFirstChild("PlayerGui")
	local inventoryGui = playerGui and playerGui:FindFirstChild("Inventory")
	local inventoryFrame = inventoryGui and inventoryGui:FindFirstChild("Inventory")
	local leftSide = inventoryFrame and inventoryFrame:FindFirstChild("LeftSide")

	return leftSide and leftSide:FindFirstChild("EquippedItems")
end

local function collectEquippedGuidsFromSlots(equippedGuids)
	local equippedItems = getEquippedItemsFolder()

	if not equippedItems then
		return
	end

	for _, slotName in ipairs(equippedSlotNames) do
		local slot = equippedItems:FindFirstChild(slotName)
		local stats = slot and slot:FindFirstChild("itemStats")
		local guid = stats and readValueObject(stats, "GUID")

		if guid and guid ~= "" then
			equippedGuids[guid] = true
		end
	end

	for _, stats in ipairs(equippedItems:GetDescendants()) do
		if stats.Name == "itemStats" then
			local guid = readValueObject(stats, "GUID")

			if guid and guid ~= "" then
				equippedGuids[guid] = true
			end
		end
	end
end

local function collectEquippedGuids()
	local equippedGuids = {}

	if not settings.ProtectEquippedItems then
		return equippedGuids
	end

	collectEquippedGuidsFromSlots(equippedGuids)

	local containers = {
		player,
		player:FindFirstChild("PlayerGui"),
		getGuiParent(),
	}

	for _, container in ipairs(containers) do
		if container then
			for _, descendant in ipairs(container:GetDescendants()) do
				if descendant.Name == "itemStats" then
					local stats = descendant
					local guid = readValueObject(stats, "GUID")

					if guid and (itemStatsLooksEquipped(stats) or frameHasAncestorNamed(stats, equippedContainerNameSet)) then
						equippedGuids[guid] = true
					end
				elseif descendant:IsA("StringValue") and frameHasAncestorNamed(descendant, equippedContainerNameSet) then
					if descendant.Value and descendant.Value ~= "" then
						equippedGuids[descendant.Value] = true
					end
				elseif descendant:IsA("StringValue") then
					local valueName = string.lower(descendant.Name)
					local value = descendant.Value

					if value
						and value ~= ""
						and (equippedValueNameSet[valueName] or valueName:find("equipped", 1, true) or frameHasAncestorNamed(descendant, equippedContainerNameSet))
					then
						equippedGuids[value] = true
					end
				end
			end
		end
	end

	return equippedGuids
end

local function waitForInventoryFrames(timeout)
	local started = os.clock()
	local frames = getInventoryFrames()

	while #frames == 0 and os.clock() - started < timeout do
		task.wait(0.25)
		frames = getInventoryFrames()
	end

	return frames
end

local function refreshInventoryForAutoSell()
	local getInventoryRemote = resolveRemote("GetInventory")

	if getInventoryRemote then
		local result = invokeRemote(getInventoryRemote, player.UserId)
		task.wait(0.75)
		return result
	end
end

local function addItemToSellPayload(payload, seenGuids, equippedGuids, itemType, guid, rarity, locked, equipped)
	itemType = tostring(itemType or "")
	rarity = normalizeRarity(rarity)

	if guid
		and payload[itemType]
		and settings.SellRarities[rarity]
		and not locked
		and not equipped
		and not equippedGuids[guid]
		and not seenGuids[guid]
	then
		seenGuids[guid] = true
		table.insert(payload[itemType], guid)
		return 1
	end

	return 0
end

local function collectAutoSellItems()
	local payload = makeSellPayload()
	local seenGuids = {}
	local count = 0

	refreshInventoryForAutoSell()

	local frames = waitForInventoryFrames(settings.AutoSellScanTimeout)
	local equippedGuids = collectEquippedGuids()
	local protectedCount = 0

	for _ in pairs(equippedGuids) do
		protectedCount += 1
	end

	for _, frame in ipairs(frames) do
		local stats = frame:FindFirstChild("itemStats")
		local guid = readValueObject(stats, "GUID")
		local itemType = tostring(readValueObject(stats, "itemType") or "")
		local rarity = normalizeRarity(readValueObject(stats, "itemRarity"))
		local locked = readValueObject(stats, "itemLocked") == true
		local equipped = itemStatsLooksEquipped(stats)

		count += addItemToSellPayload(payload, seenGuids, equippedGuids, itemType, guid, rarity, locked, equipped)
	end

	return payload, count, protectedCount
end

local function runAutoSell(silent, force)
	if not settings.AutoSellAfterRun and not force then
		return false
	end

	settings.ProtectEquippedItems = true

	if not hasSelectedSellRarity() then
		if not silent then
			notify("Auto Sell", "Turn on at least one rarity first.")
		end

		return false
	end

	local sellRemote = resolveRemote("SellItems")

	if not sellRemote then
		if not silent then
			notify("Auto Sell", "sellItems remote was not found.")
		end

		return false
	end

	local payload, count, protectedCount = collectAutoSellItems()

	if count <= 0 then
		if not silent then
			notify("Auto Sell", "No matching unlocked items found. Protected equipped: " .. tostring(protectedCount))
		end

		return false
	end

	local result = invokeRemote(sellRemote, payload)

	if result then
		notify("Auto Sell", "Sold " .. tostring(count) .. " item(s). Protected equipped: " .. tostring(protectedCount))
		return true
	end

	if not silent then
		notify("Auto Sell", "Sell request did not complete.")
	end

	return false
end

local function isDungeonHost()
	local dungeonSettings = Workspace:FindFirstChild("DungeonSettings")
	local host = dungeonSettings and dungeonSettings:FindFirstChild("Host")

	if not host then
		return true
	end

	return host.Value == player.UserId
end

local function resetTowerPortalSlots()
	towerPortalSlots = {}
	towerPortalPickLocked = false
end

local function normalizePortalName(portalName)
	portalName = tostring(portalName or "")
	portalName = portalName:gsub("^Portal of%s+", "")
	return portalName
end

local function getTowerPortalDanger(portalName)
	return towerPortalDanger[portalName] or 999
end

local function getTreasureRewardPart()
	local treasure = Workspace:FindFirstChild("Treasure")

	return treasure and treasure:FindFirstChild("ringRewardsPart")
end

local function waitForTreasureRewardPart(timeout)
	local started = os.clock()
	local part = getTreasureRewardPart()

	while not part and os.clock() - started < timeout do
		task.wait(0.25)
		part = getTreasureRewardPart()
	end

	return part
end

local function isTreasureRewardOnCooldown(rewardPart)
	local claimedAt = rewardPart and towerTreasureClaimedAt[rewardPart]
	return claimedAt ~= nil and os.clock() - claimedAt < 6
end

local function holdProximityPrompt(prompt)
	if not prompt or not prompt.Enabled then
		return false
	end

	if typeof(fireproximityprompt) == "function" then
		local ok = pcall(function()
			fireproximityprompt(prompt)
		end)

		if ok then
			return true
		end
	end

	local ok = pcall(function()
		prompt:InputHoldBegin()
		task.wait(math.max(prompt.HoldDuration, 0.05) + 0.2)
		prompt:InputHoldEnd()
	end)

	return ok
end

local function waitForRewardPrompt(rewardPart, timeout)
	local started = os.clock()
	local prompt = rewardPart and rewardPart:FindFirstChildWhichIsA("ProximityPrompt", true)

	while (not prompt or not prompt.Enabled) and os.clock() - started < timeout do
		task.wait(0.2)
		prompt = rewardPart and rewardPart:FindFirstChildWhichIsA("ProximityPrompt", true)
	end

	return prompt
end

local function collectTreasureReward()
	if towerTreasureCollecting or not settings.AutoTowerTreasureRewards then
		return
	end

	towerTreasureCollecting = true

	task.spawn(function()
		local rewardPart = waitForTreasureRewardPart(settings.TreasureRewardTimeout)

		if not rewardPart then
			notify("Auto Tower", "Treasure reward part was not found.")
			towerTreasureCollecting = false
			resetTowerPortalSlots()
			return
		end

		if isTreasureRewardOnCooldown(rewardPart) then
			towerTreasureCollecting = false
			resetTowerPortalSlots()
			return
		end

		if not rewardPart:IsA("BasePart") then
			notify("Auto Tower", "Treasure reward part is not a BasePart.")
			towerTreasureCollecting = false
			resetTowerPortalSlots()
			return
		end

		local root = getRoot()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = rewardPart.CFrame
		task.wait(0.35)

		local prompt = waitForRewardPrompt(rewardPart, 3)

		if prompt and holdProximityPrompt(prompt) then
			towerTreasureClaimedAt[rewardPart] = os.clock()
			notify("Auto Tower", "Treasure reward collected.")
		else
			towerTreasureClaimedAt[rewardPart] = os.clock()
			notify("Auto Tower", "Treasure prompt was not ready, continuing tower.")
		end

		task.wait(1)
		towerTreasureCollecting = false
		resetTowerPortalSlots()
	end)
end

local function scanPortalGui()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	local slotNames = {
		[1] = "Left",
		[2] = "Middle",
		[3] = "Right",
	}

	for _, mainGroup in ipairs(playerGui:GetDescendants()) do
		if mainGroup.Name == "MainGroup" then
			for slot, slotName in pairs(slotNames) do
				local frame = mainGroup:FindFirstChild(slotName)
				local inner = frame and frame:FindFirstChild("inner")
				local mainName = inner and inner:FindFirstChild("MainName")

				if frame and frame.Visible and mainName and (mainName:IsA("TextLabel") or mainName:IsA("TextButton")) then
					local portalName = normalizePortalName(mainName.Text)

					if portalName ~= "" then
						towerPortalSlots[slot] = portalName
					end
				end
			end
		end
	end
end

local function getBestTowerPortalSlot()
	scanPortalGui()

	for slot = 1, 3 do
		if towerPortalSlots[slot] == "Treasure" then
			return 2, "Treasure", true
		end
	end

	local bestFocusedSlot
	local bestFocusedName
	local bestFocusedDanger = math.huge
	local bestFallbackSlot
	local bestFallbackName
	local bestFallbackDanger = math.huge

	for slot = 1, 3 do
		local portalName = towerPortalSlots[slot]

		if portalName then
			local danger = getTowerPortalDanger(portalName)

			if settings.TowerPortals[portalName] and danger < bestFocusedDanger then
				bestFocusedSlot = slot
				bestFocusedName = portalName
				bestFocusedDanger = danger
			end

			if danger < bestFallbackDanger then
				bestFallbackSlot = slot
				bestFallbackName = portalName
				bestFallbackDanger = danger
			end
		end
	end

	if bestFocusedSlot then
		return bestFocusedSlot, bestFocusedName, true
	end

	return bestFallbackSlot, bestFallbackName, false
end

local function chooseTowerPortal()
	if not settings.AutoTower or towerPortalPickLocked or not isDungeonHost() then
		return
	end

	local displayPortalsRemote = resolveRemote("DisplayPortals")
	if not displayPortalsRemote then
		return
	end

	local slot, portalName, focused = getBestTowerPortalSlot()

	if not slot then
		return
	end

	towerPortalPickLocked = true
	lastTowerPortalPick = os.clock()

	if portalName == "Treasure" then
		fireRemote(displayPortalsRemote, 2)
		collectTreasureReward()
	else
		task.spawn(function()
			for _ = 1, 3 do
				fireRemote(displayPortalsRemote, slot)
				task.wait(0.35)
			end
		end)
	end

	notify("Auto Tower", "Picked " .. tostring(portalName) .. (focused and " from focus list." or " as safest fallback."))
end

local function scheduleTowerPortalPick(delay)
	if not settings.AutoTower then
		return
	end

	task.delay(delay or settings.AutoTowerPickDelay, function()
		chooseTowerPortal()
	end)
end

local function scheduleStartDungeonAfterWaveChange()
	task.delay(5, function()
		if not settings.AutoTower and not autoFarm then
			return
		end

		local startDungeonRemote = resolveRemote("StartDungeon")
		if startDungeonRemote then
			fireRemote(startDungeonRemote, { true })
		end
	end)
end

local function connectTowerWaveReset()
	if towerWaveResetConnected then
		return
	end

	local dungeonSettings = Workspace:FindFirstChild("DungeonSettings")
	local currentWave = dungeonSettings and dungeonSettings:FindFirstChild("CurrentWave")

	if not currentWave then
		return
	end

	towerWaveResetConnected = true
	currentWave.Changed:Connect(function()
		resetTowerPortalSlots()
		scheduleStartDungeonAfterWaveChange()
	end)
end

local function connectTowerPortalEvents()
	if towerPortalEventConnected then
		return
	end

	local displayPortalsRemote = resolveRemote("DisplayPortals")
	if not displayPortalsRemote then
		return
	end

	towerPortalEventConnected = true
	displayPortalsRemote.OnClientEvent:Connect(function(slot, portalName, action)
		if action == "Reveal" then
			resetTowerPortalSlots()
			scheduleTowerPortalPick(settings.AutoTowerPickDelay + 0.8)
		elseif action == "Display" then
			towerPortalSlots[slot] = normalizePortalName(portalName)
			scheduleTowerPortalPick(settings.AutoTowerPickDelay)
		end
	end)
end

local function isTowerRetryLobbyDummyArea()
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return false
	end

	local dummyCount = 0

	for index = 1, 6 do
		if enemiesFolder:FindFirstChild("Dummy" .. tostring(index)) then
			dummyCount = dummyCount + 1
		end
	end

	return dummyCount >= 3
end

local function hasTowerRetryAliveEnemy()
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return false
	end

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if not enemy.Name:match("^Dummy%d+$")
			and enemy:GetAttribute("Dead") ~= true
			and enemy:GetAttribute("Defeated") ~= true
		then
			local humanoid = enemy:FindFirstChildOfClass("Humanoid") or enemy:FindFirstChild("Humanoid", true)

			if not humanoid or humanoid.Health > 0 then
				return true
			end
		end
	end

	return false
end

local function isGuiEffectivelyVisible(guiObject)
	local current = guiObject
	local playerGui = player:FindFirstChild("PlayerGui")

	while current and current ~= playerGui do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end

		if current:IsA("LayerCollector") and not current.Enabled then
			return false
		end

		current = current.Parent
	end

	return true
end

local function isHubGuiObject(guiObject)
	for _, ancestor in ipairs(guiObject:GetAncestors()) do
		local ancestorName = string.lower(ancestor.Name or "")

		if ancestorName:find("kryptex", 1, true) then
			return true
		end
	end

	return false
end

local function hasStartText(guiObject)
	local text = ""

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
		text = tostring(guiObject.Text or "")
	end

	local combined = string.lower(tostring(guiObject.Name or "") .. " " .. text)

	if not combined:find("start", 1, true) then
		return false
	end

	return not (
		combined:find("auto start", 1, true)
		or combined:find("retry", 1, true)
		or combined:find("delay", 1, true)
		or combined:find("attempt", 1, true)
		or combined:find("lobby", 1, true)
		or combined:find("starter", 1, true)
	)
end

local function isLikelyGameStartGui(guiObject)
	if not isGuiEffectivelyVisible(guiObject) then
		return false
	end

	if isHubGuiObject(guiObject) or not hasStartText(guiObject) then
		return false
	end

	return guiObject:IsA("GuiButton")
		or guiObject:IsA("TextLabel")
		or guiObject:IsA("ImageLabel")
		or guiObject:IsA("Frame")
end

local function getClickableStartGui(guiObject)
	local current = guiObject
	local playerGui = player:FindFirstChild("PlayerGui")

	while current and current ~= playerGui do
		if current:IsA("GuiButton") and isGuiEffectivelyVisible(current) and not isHubGuiObject(current) then
			return current
		end

		current = current.Parent
	end

	return guiObject
end

local function findVisibleGameStartButton()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return nil
	end

	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if isLikelyGameStartGui(descendant) then
			return getClickableStartGui(descendant)
		end
	end

	local camera = Workspace.CurrentCamera
	local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local bestGui
	local bestArea = 0

	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if descendant:IsA("GuiObject") and isGuiEffectivelyVisible(descendant) and not isHubGuiObject(descendant) then
			local size = descendant.AbsoluteSize
			local position = descendant.AbsolutePosition
			local centerX = position.X + size.X / 2
			local centerY = position.Y + size.Y / 2
			local area = size.X * size.Y

			if size.X >= viewportSize.X * 0.25
				and size.Y >= 45
				and centerX >= viewportSize.X * 0.25
				and centerX <= viewportSize.X * 0.75
				and centerY >= viewportSize.Y * 0.30
				and centerY <= viewportSize.Y * 0.75
				and area > bestArea
			then
				bestGui = descendant
				bestArea = area
			end
		end
	end

	return bestGui and getClickableStartGui(bestGui)
end

local function tapGuiObject(guiObject)
	if not guiObject or not guiObject:IsA("GuiObject") then
		return false
	end

	local absolutePosition = guiObject.AbsolutePosition
	local absoluteSize = guiObject.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return false
	end

	local x = absolutePosition.X + absoluteSize.X / 2
	local y = absolutePosition.Y + absoluteSize.Y / 2
	local clicked = false

	if guiObject:IsA("GuiButton") and typeof(getconnections) == "function" then
		pcall(function()
			for _, connection in ipairs(getconnections(guiObject.Activated)) do
				connection:Fire()
				clicked = true
			end
		end)

		pcall(function()
			for _, connection in ipairs(getconnections(guiObject.MouseButton1Click)) do
				connection:Fire()
				clicked = true
			end
		end)
	end

	local ok = false

	if VirtualInputManager then
		ok = pcall(function()
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
			task.wait(0.05)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end)
	end

	return clicked or ok
end

local function isDungeonStartWaiting()
	local dungeonStarted = Workspace:FindFirstChild("dungeonStarted")

	if dungeonStarted and dungeonStarted:IsA("BoolValue") then
		return dungeonStarted.Value ~= true
	end

	return false
end

local function shouldRetryTowerStart()
	if not settings.AutoTowerStartRetry or towerStartRetryRunning or towerTreasureCollecting then
		return false
	end

	local rewardPart = getTreasureRewardPart()
	if rewardPart and not isTreasureRewardOnCooldown(rewardPart) then
		return false
	end

	if isDungeonStartWaiting() then
		return true
	end

	if os.clock() - lastTowerStartRetry < settings.TowerStartRetryDelay then
		return false
	end

	local startButton = findVisibleGameStartButton()
	if startButton then
		lastVisibleStartButtonName = startButton.Name
		return true
	end

	lastVisibleStartButtonName = nil

	if not Workspace:FindFirstChild("Enemies") or rewardPart or hasTowerRetryAliveEnemy() then
		return false
	end

	if towerPortalPickLocked then
		return lastTowerPortalPick > 0 and os.clock() - lastTowerPortalPick >= settings.TowerStartRetryDelay
	end

	scanPortalGui()
	return next(towerPortalSlots) == nil
end

local function retryTowerStartIfNeeded()
	if not shouldRetryTowerStart() then
		return
	end

	local startButton = findVisibleGameStartButton()
	local startDungeonRemote = resolveRemote("StartDungeon")
	if not startDungeonRemote and not startButton then
		return
	end

	lastTowerStartRetry = os.clock()
	towerStartRetryRunning = true

	task.spawn(function()
		local attempts = 0

		while settings.AutoTower or autoFarm do
			attempts = attempts + 1

			if not settings.AutoTower and not autoFarm then
				break
			end

			if Workspace:FindFirstChild("dungeonStarted") and not isDungeonStartWaiting() then
				break
			end

			if startButton and isGuiEffectivelyVisible(startButton) then
				tapGuiObject(startButton)
			else
				startButton = findVisibleGameStartButton()
			end

			if startDungeonRemote then
				fireRemote(startDungeonRemote, { true })
			end

			if not isDungeonStartWaiting() and attempts >= 5 then
				break
			end

			task.wait(isDungeonStartWaiting() and 0.2 or 0.3)
		end

		towerStartRetryRunning = false
	end)
end

local function startAutoTowerWatcher()
	task.spawn(function()
		while task.wait(1) do
			connectTowerPortalEvents()
			connectTowerWaveReset()

			if settings.AutoTower or autoFarm then
				local rewardPart = getTreasureRewardPart()

				if settings.AutoTowerTreasureRewards
					and rewardPart
					and not towerTreasureCollecting
					and not isTreasureRewardOnCooldown(rewardPart)
				then
					fireRemote(resolveRemote("DisplayPortals"), 2)
					collectTreasureReward()
				elseif settings.AutoTower and not towerPortalPickLocked and not towerTreasureCollecting then
					scheduleTowerPortalPick(0.05)
				end

				retryTowerStartIfNeeded()
			end
		end
	end)
end

local function getDungeonMapAttempts(mapName)
	return dungeonMapAliases[mapName] or { mapName }
end

local function makeCreateLobbyPayload(dungeonPreset, mapName, level)
	return {
		Map = mapName,
		Calamity = settings.CalamityModifier,
		Hardcore = settings.Hardcore,
		NoHit = settings.NoHit,
		Difficulty = dungeonPreset.Difficulty or "Calamity",
		LevelRequirement = dungeonPreset.LevelRequirement or level or 0,
		Tier = dungeonPreset.Tier or 0,
		Private = true,
		Easter = false,
	}
end

local function createLobby(dungeonPreset)
	local dungeon, level = getBestUnlockedDungeon()
	dungeonPreset = dungeonPreset or dungeon
	local createLobbyRemote = resolveRemote("CreateLobby")
	local lastResult

	for _, mapName in ipairs(getDungeonMapAttempts(dungeonPreset.Map)) do
		lastResult = invokeRemote(createLobbyRemote, makeCreateLobbyPayload(dungeonPreset, mapName, level))

		if lastResult then
			return lastResult
		end

		task.wait(0.25)
	end

	return lastResult
end

local function startLobby()
	return fireRemote(resolveRemote("StartLobby"))
end

local function startLobbyBurst()
	for attempt = 1, settings.DungeonStartAttempts do
		startLobby()
		task.wait(settings.DungeonStartRetryDelay)
	end
end

local function startDungeon()
	return fireRemote(resolveRemote("StartDungeon"), { true })
end

local function startDungeonBurst()
	for attempt = 1, settings.DungeonStartAttempts do
		startDungeon()
		task.wait(settings.DungeonStartRetryDelay)
	end
end

local function createAndStartDungeon()
	if dungeonFlowRunning then
		return
	end

	dungeonFlowRunning = true
	task.spawn(function()
		local canCreateLobby = resolveRemote("CreateLobby") ~= nil
		local canStartLobby = resolveRemote("StartLobby") ~= nil

		if canCreateLobby and canStartLobby then
			local dungeon, level = getBestUnlockedDungeon()

			if settings.AutoSellAfterRun then
				notify("Auto Sell", "Checking inventory before next run.")
				runAutoSell(true)
				task.wait(settings.AutoSellDelay)
			end

			notify("Dungeon", "Creating " .. tostring(dungeon.Map) .. " " .. tostring(dungeon.Difficulty) .. " for level " .. tostring(level) .. ".")
			createLobby(dungeon)
			task.wait(settings.DungeonStartDelay)
			notify("Dungeon", "Starting lobby.")
			startLobbyBurst()
		elseif resolveRemote("StartDungeon") then
			notify("Dungeon", "Starting dungeon run.")
			startDungeonBurst()
		else
			notify("Dungeon", "Could not find lobby or dungeon start remotes.")
		end

		dungeonFlowRunning = false
	end)
end

local function getEnemiesFolder()
	return Workspace:FindFirstChild("Enemies")
end

local function getEnemyRoot(enemy)
	if not enemy or not enemy.Parent then
		return nil
	end

	if enemy:IsA("BasePart") then
		return enemy
	end

	if enemy:IsA("Model") then
		return enemy:FindFirstChild("HumanoidRootPart")
			or enemy.PrimaryPart
			or enemy:FindFirstChildWhichIsA("BasePart", true)
	end

	return enemy:FindFirstChildWhichIsA("BasePart", true)
end

local function getEnemyHumanoid(enemy)
	if not enemy then
		return nil
	end

	return enemy:FindFirstChildOfClass("Humanoid") or enemy:FindFirstChild("Humanoid", true)
end

local function getNumberValue(container, names)
	if not container then
		return nil
	end

	for _, name in ipairs(names) do
		local attribute = container:GetAttribute(name)
		if typeof(attribute) == "number" then
			return attribute
		end

		local valueObject = container:FindFirstChild(name, true)
		if valueObject and (valueObject:IsA("NumberValue") or valueObject:IsA("IntValue")) then
			return valueObject.Value
		end
	end
end

local function getStringValue(container, names)
	if not container then
		return nil
	end

	for _, name in ipairs(names) do
		local attribute = container:GetAttribute(name)
		if typeof(attribute) == "string" and attribute ~= "" then
			return attribute
		end

		local valueObject = container:FindFirstChild(name, true)
		if valueObject and valueObject:IsA("StringValue") and valueObject.Value ~= "" then
			return valueObject.Value
		end
	end
end

local function getPlayerDataFolder()
	return player:FindFirstChild("data") or player:FindFirstChild("Data")
end

local function getNumberFromValueObject(valueObject)
	if not valueObject then
		return nil
	end

	if valueObject:IsA("NumberValue") or valueObject:IsA("IntValue") then
		return valueObject.Value
	end

	if valueObject:IsA("StringValue") then
		return tonumber(valueObject.Value)
	end
end

local function getPlayerLevelValueObject()
	local dataFolder = getPlayerDataFolder()
	if not dataFolder then
		return nil
	end

	local valueObject = dataFolder:FindFirstChild("level") or dataFolder:FindFirstChild("Level")
	if valueObject then
		return valueObject
	end
end

local function copyDungeonPreset(preset)
	return {
		Map = preset.Map,
		Difficulty = preset.Difficulty,
		LevelRequirement = preset.LevelRequirement,
		Tier = preset.Tier,
	}
end

getPlayerLevel = function()
	local directLevel = getNumberFromValueObject(getPlayerLevelValueObject())
	if directLevel then
		return math.floor(directLevel)
	end

	local containers = {
		getPlayerDataFolder(),
		player,
		player:FindFirstChild("leaderstats"),
		player:FindFirstChild("Stats"),
		player:FindFirstChild("Data"),
		player:FindFirstChild("data"),
		player:FindFirstChild("PlayerData"),
	}

	for _, container in ipairs(containers) do
		local level = getNumberValue(container, {
			"level",
			"Level",
			"Lvl",
			"PlayerLevel",
			"CurrentLevel",
		})

		if level then
			return math.floor(level)
		end
	end

	return 0
end

local function addDungeonPresetFromObject(object, presets)
	if not object then
		return
	end

	local mapName = getStringValue(object, {
		"Map",
		"MapName",
		"Dungeon",
		"DungeonName",
	})

	local levelRequirement = getNumberValue(object, {
		"LevelRequirement",
		"RequiredLevel",
		"LevelReq",
		"MinLevel",
	})

	local tier = getNumberValue(object, { "Tier" })
	local difficulty = getStringValue(object, { "Difficulty" })

	if not mapName and not levelRequirement then
		return
	end

	mapName = mapName or object.Name

	if mapName and mapName ~= "" then
		table.insert(presets, {
			Map = mapName,
			Difficulty = difficulty or "Calamity",
			LevelRequirement = levelRequirement or 0,
			Tier = tier or 0,
		})
	end
end

local function getDungeonPresets()
	local presets = {}

	for _, preset in ipairs(staticDungeonPresets) do
		table.insert(presets, copyDungeonPreset(preset))
	end

	table.sort(presets, function(left, right)
		return (left.LevelRequirement or 0) < (right.LevelRequirement or 0)
	end)

	return presets
end

getBestUnlockedDungeon = function()
	local level = getPlayerLevel()
	local presets = getDungeonPresets()
	local best = presets[1] or copyDungeonPreset(staticDungeonPresets[1])

	for _, preset in ipairs(presets) do
		if level >= (preset.LevelRequirement or 0) then
			best = preset
		end
	end

	return best, level
end

local function getPlayerInfoContent()
	local levelPath = "fallback scan"
	local dungeon, level = getBestUnlockedDungeon()

	if getPlayerLevelValueObject() then
		levelPath = "Players > " .. player.Name .. " > data > level"
	end

	return "User: " .. player.Name
		.. "\nLevel: " .. tostring(level)
		.. "\nBest Dungeon: " .. tostring(dungeon.Map) .. " - " .. tostring(dungeon.Difficulty)
		.. "\nLevel Path: " .. levelPath
end

local function updatePlayerInfoDisplay()
	if not playerInfoParagraph then
		return
	end

	pcall(function()
		playerInfoParagraph:Set({
			Title = "Player Info",
			Content = getPlayerInfoContent(),
		})
	end)
end

local function startPlayerInfoRefresh()
	task.spawn(function()
		while task.wait(2) do
			updatePlayerInfoDisplay()
		end
	end)
end

local function rememberOriginal(instance, property)
	if not instance then
		return
	end

	local state = hideNameOriginals[instance]
	if not state then
		state = {}
		hideNameOriginals[instance] = state
	end

	if state[property] == nil then
		pcall(function()
			state[property] = instance[property]
		end)
	end
end

local function setHiddenProperty(instance, property, value)
	if not instance then
		return
	end

	rememberOriginal(instance, property)

	pcall(function()
		instance[property] = value
	end)
end

local function restoreHiddenNameObjects()
	for instance, properties in pairs(hideNameOriginals) do
		if instance and instance.Parent then
			for property, value in pairs(properties) do
				pcall(function()
					instance[property] = value
				end)
			end
		end
	end
end

local function getLocalPlayerGui()
	return player:FindFirstChild("PlayerGui")
end

local function applyPlayerDataNameHider()
	local playerGui = getLocalPlayerGui()
	local playerData = playerGui and playerGui:FindFirstChild("PlayerData")
	local frame = playerData and playerData:FindFirstChild("Frame")
	local profileFrame = frame and frame:FindFirstChild("Profile")
	local profile = profileFrame and profileFrame:FindFirstChild("Profile")
	local playerName = frame and frame:FindFirstChild("PlayerName")

	if profile and profile:IsA("GuiObject") then
		setHiddenProperty(profile, "Visible", false)
	end

	if playerName and (playerName:IsA("TextLabel") or playerName:IsA("TextButton")) then
		setHiddenProperty(playerName, "Text", "KryptexScripts")
	end
end

local function getLocalWorkspaceCharacter()
	return player.Character or Workspace:FindFirstChild(player.Name)
end

local function applyNameplateHider()
	local character = getLocalWorkspaceCharacter()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local nameplate = root and root:FindFirstChild("MainNameplate")

	if not nameplate then
		return
	end

	local guildTag = nameplate:FindFirstChild("Guildtag", true)
	local playerName = nameplate:FindFirstChild("PlayerName", true)

	if guildTag and guildTag:IsA("GuiObject") then
		setHiddenProperty(guildTag, "Visible", false)
	end

	if playerName and playerName:IsA("GuiObject") then
		setHiddenProperty(playerName, "Visible", false)
	end
end

local function applyHideName()
	applyPlayerDataNameHider()
	applyNameplateHider()
end

local function setHideName(value)
	settings.HideName = value

	if value then
		applyHideName()
		return
	end

	restoreHiddenNameObjects()
end

local function startHideNameLoop()
	if hideNameLoopRunning then
		return
	end

	hideNameLoopRunning = true

	task.spawn(function()
		while task.wait(1) do
			if settings.HideName then
				applyHideName()
			end
		end
	end)
end

local function getCurrentDungeonMapName()
	local dungeonSettings = Workspace:FindFirstChild("DungeonSettings")
	local mapName = getStringValue(dungeonSettings, {
		"Map",
		"MapName",
		"Dungeon",
		"DungeonName",
		"CurrentMap",
		"SessionName",
	})

	if mapName and mapName ~= "" then
		return mapName
	end
end

local function isCurrentDungeonMap(mapName)
	local currentMap = getCurrentDungeonMapName()
	return currentMap and string.lower(currentMap):find(string.lower(mapName), 1, true) ~= nil
end

local function getRawEnemyHealth(enemy)
	local humanoid = getEnemyHumanoid(enemy)
	if humanoid then
		return humanoid.Health
	end

	local health = getNumberValue(enemy, { "Health", "HP", "CurrentHealth" })
	if health then
		return health
	end
end

local function getEnemyHealth(enemy)
	local health = getRawEnemyHealth(enemy)
	if health then
		return health
	end

	return 1
end

local function isEnemyAlive(enemy)
	local enemiesFolder = getEnemiesFolder()
	if not enemy or not enemy.Parent or not enemiesFolder or not enemy:IsDescendantOf(enemiesFolder) then
		return false
	end

	if enemy:GetAttribute("Dead") == true or enemy:GetAttribute("Defeated") == true then
		return false
	end

	return getEnemyRoot(enemy) ~= nil and getEnemyHealth(enemy) > 0
end

local function enemyNameContains(enemy, namePart)
	return enemy and string.find(string.lower(enemy.Name or ""), string.lower(namePart), 1, true) ~= nil
end

local function findAliveEnemyByName(namePart, includeDescendants)
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	local list = includeDescendants and enemiesFolder:GetDescendants() or enemiesFolder:GetChildren()

	for _, enemy in ipairs(list) do
		if enemyNameContains(enemy, namePart) and isEnemyAlive(enemy) then
			return enemy
		end
	end
end

local function isEnemyStillPresentAndNotDead(enemy)
	local enemiesFolder = getEnemiesFolder()

	if not enemy or not enemy.Parent or not enemiesFolder or not enemy:IsDescendantOf(enemiesFolder) then
		return false
	end

	if enemy:GetAttribute("Dead") == true or enemy:GetAttribute("Defeated") == true then
		return false
	end

	local health = getRawEnemyHealth(enemy)
	if health ~= nil and health <= 0 then
		return false
	end

	return true
end

local function findPresentEnemyByName(namePart, includeDescendants)
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	local list = includeDescendants and enemiesFolder:GetDescendants() or enemiesFolder:GetChildren()

	for _, enemy in ipairs(list) do
		if enemyNameContains(enemy, namePart) and isEnemyStillPresentAndNotDead(enemy) then
			return enemy
		end
	end
end

local firstSanctuaryFinalNames = {
	"holy grail",
	"grail arm",
	"shield arm",
	"staff arm",
	"sword arm",
	"yaldabaoth",
}

local firstSanctuaryArmOrder = {
	"Grail Arm",
	"Shield Arm",
	"Staff Arm",
	"Sword Arm",
}

local function isFirstSanctuaryFinalEnemy(enemy)
	local enemyName = string.lower(enemy.Name or "")

	for _, name in ipairs(firstSanctuaryFinalNames) do
		if string.find(enemyName, name, 1, true) then
			return true
		end
	end

	return false
end

local function getThunderingPeaksPriorityEnemy()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	local bestTarget
	local bestDepth = math.huge

	for _, enemy in ipairs(enemiesFolder:GetDescendants()) do
		local enemyName = string.lower(enemy.Name or "")

		if (string.find(enemyName, "powered statue of bravery", 1, true)
			or string.find(enemyName, "powered statue of fidelity", 1, true))
			and isEnemyAlive(enemy)
		then
			local depth = 0
			local parent = enemy.Parent

			while parent and parent ~= enemiesFolder do
				depth = depth + 1
				parent = parent.Parent
			end

			if not bestTarget or depth < bestDepth then
				bestTarget = enemy
				bestDepth = depth
			end
		end
	end

	return bestTarget
end

local function getNearestAliveEnemy()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if isEnemyAlive(enemy) then
			local enemyRoot = getEnemyRoot(enemy)
			local distance = (root.Position - enemyRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearest = enemy
			end
		end
	end

	return nearest
end

local function getNearestAliveNormalEnemy()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if isEnemyAlive(enemy) and not isFirstSanctuaryFinalEnemy(enemy) then
			local enemyRoot = getEnemyRoot(enemy)
			local distance = (root.Position - enemyRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearest = enemy
			end
		end
	end

	return nearest
end

local function getFirstSanctuaryFinalPriorityEnemy()
	if not grailArenaTeleportDone then
		return nil
	end

	if finalBossAttackLock and isEnemyStillPresentAndNotDead(finalBossAttackLock) then
		return finalBossAttackLock
	end

	finalBossAttackLock = nil

	local normalEnemy = getNearestAliveNormalEnemy()
	if normalEnemy then
		return normalEnemy
	end

	local holyGrail = findAliveEnemyByName("Holy Grail", true)
	if holyGrail then
		return holyGrail
	end

	for _, armName in ipairs(firstSanctuaryArmOrder) do
		local arm = findAliveEnemyByName(armName, true)
		if arm then
			return arm
		end
	end

	local yaldabaoth = findAliveEnemyByName("Yaldabaoth", true) or findPresentEnemyByName("Yaldabaoth", true)
	if yaldabaoth then
		finalBossAttackLock = yaldabaoth
		return finalBossAttackLock
	end
end

local function hasFinalBossAttackLock()
	if finalBossAttackLock and isEnemyStillPresentAndNotDead(finalBossAttackLock) then
		return true
	end

	finalBossAttackLock = nil
	return false
end

local function hasAliveEnemies()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return false
	end

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if isEnemyAlive(enemy) then
			return true
		end
	end

	return false
end

local function getLockedEnemy()
	local firstSanctuaryTarget = getFirstSanctuaryFinalPriorityEnemy()
	if firstSanctuaryTarget then
		currentEnemy = firstSanctuaryTarget
		return currentEnemy
	end

	local priorityEnemy = getThunderingPeaksPriorityEnemy()
	if priorityEnemy then
		currentEnemy = priorityEnemy
		return currentEnemy
	end

	if currentEnemy and isEnemyAlive(currentEnemy) then
		return currentEnemy
	end

	currentEnemy = getNearestAliveEnemy()
	return currentEnemy
end

local function getZurielEnemy()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return nil
	end

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if string.find(string.lower(enemy.Name), "zuriel", 1, true) then
			return enemy
		end
	end

	return nil
end

local function getEphrathEnemy()
	return findAliveEnemyByName("Ephrath", true)
end

local function teleportToCFrame(cframe)
	local root = getRoot()
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = cframe
end

local function teleportToZurielClearPosition()
	teleportToCFrame(CFrame.new(ZURIEL_CLEAR_POSITION))
end

local function updateZurielClearTeleport()
	local zuriel = getZurielEnemy()
	local zurielAlive = zuriel and isEnemyAlive(zuriel)

	if zurielAlive then
		zurielSeenAlive = true
		zurielTeleportDone = false
	elseif (zurielSeenAlive or zuriel) and not zurielTeleportDone then
		teleportToZurielClearPosition()
		zurielTeleportDone = true
		zurielSeenAlive = false
		notify("First Boss", "Zuriel cleared. Teleported to next position.")
	end
end

local function updateEphrathAndGrailFlow()
	local ephrath = getEphrathEnemy()

	if ephrath then
		ephrathSeenAlive = true
		ephrathTeleportDone = false
		return
	end

	if ephrathSeenAlive and not ephrathTeleportDone then
		teleportToCFrame(EPHRATH_CLEAR_CFRAME)
		ephrathTeleportDone = true
		ephrathTeleportAt = os.clock()
		currentEnemy = nil
		notify("Second Boss", "Ephrath cleared. Teleported to next position.")
		return
	end

	if ephrathTeleportDone
		and not grailArenaTeleportDone
		and os.clock() - ephrathTeleportAt >= 1.5
		and not getNearestAliveNormalEnemy()
	then
		teleportToCFrame(GRAIL_ARENA_CFRAME)
		grailArenaTeleportDone = true
		currentEnemy = nil
		notify("Final Boss", "Enemy wave cleared. Teleported to Grail arena.")
	end
end

local function startZurielWatchLoop()
	if zurielWatchLoopRunning then
		return
	end

	zurielWatchLoopRunning = true

	task.spawn(function()
		while autoFarm do
			updateZurielClearTeleport()
			updateEphrathAndGrailFlow()
			task.wait(0.25)
		end

		zurielWatchLoopRunning = false
	end)
end

local function orbitEnemy(enemy)
	local enemyRoot = getEnemyRoot(enemy)
	if not enemyRoot then
		return
	end

	local root = getRoot()
	local angle = os.clock() * settings.OrbitSpeed
	local offset = Vector3.new(
		math.cos(angle) * settings.OrbitDistance,
		settings.OrbitHeight,
		math.sin(angle) * settings.OrbitDistance
	)

	root.CFrame = CFrame.lookAt(enemyRoot.Position + offset, enemyRoot.Position)
end

local function castFarmCycle()
	useBolt()
	task.wait(settings.CastDelay)
	useSpell("Q")
	task.wait(settings.CastDelay)
	useSpell("E")
	task.wait(settings.CastDelay)
	useSpell("R")
end

local function startOrbit()
	if orbitConnection then
		orbitConnection:Disconnect()
	end

	orbitConnection = RunService.Heartbeat:Connect(function()
		if not autoFarm then
			return
		end

		local enemy = getLockedEnemy()
		if enemy then
			orbitEnemy(enemy)
		end
	end)
end

local function stopOrbit()
	if orbitConnection then
		orbitConnection:Disconnect()
		orbitConnection = nil
	end

	currentEnemy = nil
end

local function startAttackLoop()
	if attackLoopRunning then
		return
	end

	attackLoopRunning = true

	task.spawn(function()
		while autoFarm do
			local enemy = getLockedEnemy()

			if settings.AutoCast and (enemy or hasFinalBossAttackLock()) then
				castFarmCycle()
			else
				task.wait(0.2)
			end

			if currentEnemy and not isEnemyAlive(currentEnemy) then
				currentEnemy = nil
			end
		end

		attackLoopRunning = false
	end)
end

local function startUtilityLoop()
	if utilityLoopRunning then
		return
	end

	utilityLoopRunning = true

	task.spawn(function()
		while autoFarm do
			local now = os.clock()

			if settings.AutoEquipBest and now - lastEquipBest >= settings.EquipBestDelay then
				equipBest()
				lastEquipBest = now
			end

			if settings.AutoSkillPoints and now - lastSkillPoint >= settings.SkillPointDelay then
				addSkillPoints(settings.SkillPointType, settings.SkillPointAmount)
				lastSkillPoint = now
			end

			task.wait(0.25)
		end

		utilityLoopRunning = false
	end)
end

local function setAutoFarm(value)
	autoFarm = value

	if autoFarm then
		currentEnemy = nil
		lastEquipBest = 0
		lastSkillPoint = 0
		zurielSeenAlive = false
		zurielTeleportDone = false
		ephrathSeenAlive = false
		ephrathTeleportDone = false
		ephrathTeleportAt = 0
		grailArenaTeleportDone = false
		finalBossAttackLock = nil

		local canUseLobby = resolveRemote("CreateLobby") ~= nil and resolveRemote("StartLobby") ~= nil

		if settings.AutoCreateAndStartDungeon and (canUseLobby or not hasAliveEnemies()) then
			createAndStartDungeon()
		end

		startOrbit()
		startAttackLoop()
		startUtilityLoop()
		startZurielWatchLoop()
		notify("Auto Farm", "Started.")
	else
		stopOrbit()
		notify("Auto Farm", "Stopped.")
	end
end

local function setSavedToggle(flagName, value)
	local flags = HubUI.Flags
	local flag = flags and flags[flagName]

	if not flag then
		return
	end

	if type(flag.Set) == "function" then
		pcall(function()
			flag:Set(value)
		end)
	elseif flag.CurrentValue ~= nil then
		flag.CurrentValue = value
	end
end

local function getOtherPlayerNames()
	local names = {}

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			table.insert(names, otherPlayer.Name)
		end
	end

	return names
end

local function isLobbyDummyArea()
	local enemiesFolder = getEnemiesFolder()
	if not enemiesFolder then
		return false
	end

	local dummyCount = 0

	for index = 1, 6 do
		if enemiesFolder:FindFirstChild("Dummy" .. tostring(index)) then
			dummyCount = dummyCount + 1
		end
	end

	return dummyCount >= 3
end

local function pauseForSoloSafety(otherPlayerNames)
	local changed = false

	if autoFarm then
		setAutoFarm(false)
		setSavedToggle("ManualAutoFarm", false)
		changed = true
	end

	if settings.AutoTower then
		settings.AutoTower = false
		resetTowerPortalSlots()
		setSavedToggle("AutoTower", false)
		changed = true
	end

	if changed then
		notify("Solo Safety", "Another player is in this run: " .. table.concat(otherPlayerNames, ", ") .. ". Automation paused.")
	end
end

local function startSoloSafetyLoop()
	if soloSafetyLoopRunning then
		return
	end

	soloSafetyLoopRunning = true

	task.spawn(function()
		while task.wait(0.5) do
			if settings.SoloSafetyPause and (autoFarm or settings.AutoTower) and not isLobbyDummyArea() then
				local otherPlayerNames = getOtherPlayerNames()

				if #otherPlayerNames > 0 then
					pauseForSoloSafety(otherPlayerNames)
				end
			end
		end
	end)
end

local Window = HubUI:CreateWindow({
	Name = "kryptexHUB",
	Icon = 4483362458,
	LoadingTitle = "kryptexHUB",
	LoadingSubtitle = "Dungeon Hub",
	Theme = "Default",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "kryptexHUB",
		FileName = "DungeonSettings",
	},
	KeySystem = false,
})

local LobbyTab = Window:CreateTab("Lobby", 4483362458)
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
local TowerTab = Window:CreateTab("Auto Tower", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

createHubIcon()
startHubIconMonitor()
startAutoTowerWatcher()
startSoloSafetyLoop()

LobbyTab:CreateSection("Player")

playerInfoParagraph = LobbyTab:CreateParagraph({
	Title = "Player Info",
	Content = getPlayerInfoContent(),
})

LobbyTab:CreateSection("Character")

LobbyTab:CreateSlider({
	Name = "Character Slot",
	Range = { 1, 6 },
	Increment = 1,
	Suffix = "Slot",
	CurrentValue = settings.CharacterSlot,
	Flag = "CharacterSlot",
	Callback = function(value)
		settings.CharacterSlot = value
	end,
})

LobbyTab:CreateButton({
	Name = "Select Character",
	Callback = function()
		selectCharacterSlot(settings.CharacterSlot)
	end,
})

LobbyTab:CreateSection("Lobby")

LobbyTab:CreateButton({
	Name = "Detect Level + Dungeon",
	Callback = function()
		local dungeon, level = getBestUnlockedDungeon()
		notify("Dungeon Detect", "Level " .. tostring(level) .. " -> " .. tostring(dungeon.Map) .. " " .. tostring(dungeon.Difficulty))
	end,
})

LobbyTab:CreateButton({
	Name = "Create Best Unlocked Lobby",
	Callback = function()
		createLobby()
	end,
})

LobbyTab:CreateButton({
	Name = "Start Lobby",
	Callback = function()
		task.spawn(startLobbyBurst)
	end,
})

LobbyTab:CreateButton({
	Name = "Start Dungeon Run",
	Callback = function()
		task.spawn(startDungeonBurst)
	end,
})

TowerTab:CreateSection("Portal Picker")

TowerTab:CreateToggle({
	Name = "Auto Tower",
	CurrentValue = settings.AutoTower,
	Flag = "AutoTower",
	Callback = function(value)
		settings.AutoTower = value

		if value then
			resetTowerPortalSlots()
			lastTowerStartRetry = os.clock()
			connectTowerPortalEvents()
			connectTowerWaveReset()
			scheduleTowerPortalPick(0.2)
		end
	end,
})

TowerTab:CreateToggle({
	Name = "Retry Start If Stuck",
	CurrentValue = settings.AutoTowerStartRetry,
	Flag = "AutoTowerStartRetry",
	Callback = function(value)
		settings.AutoTowerStartRetry = value
	end,
})

TowerTab:CreateSlider({
	Name = "Start Retry Delay",
	Range = { 1, 10 },
	Increment = 0.5,
	Suffix = "Sec",
	CurrentValue = settings.TowerStartRetryDelay,
	Flag = "TowerStartRetryDelay",
	Callback = function(value)
		settings.TowerStartRetryDelay = value
	end,
})

TowerTab:CreateSlider({
	Name = "Pick Delay",
	Range = { 0.25, 5 },
	Increment = 0.25,
	Suffix = "Sec",
	CurrentValue = settings.AutoTowerPickDelay,
	Flag = "AutoTowerPickDelay",
	Callback = function(value)
		settings.AutoTowerPickDelay = value
	end,
})

TowerTab:CreateToggle({
	Name = "Collect Treasure Rewards",
	CurrentValue = settings.AutoTowerTreasureRewards,
	Flag = "AutoTowerTreasureRewards",
	Callback = function(value)
		settings.AutoTowerTreasureRewards = value
	end,
})

TowerTab:CreateSlider({
	Name = "Treasure Reward Timeout",
	Range = { 2, 20 },
	Increment = 1,
	Suffix = "Sec",
	CurrentValue = settings.TreasureRewardTimeout,
	Flag = "TreasureRewardTimeout",
	Callback = function(value)
		settings.TreasureRewardTimeout = value
	end,
})

TowerTab:CreateButton({
	Name = "Pick Best Portal Now",
	Callback = function()
		chooseTowerPortal()
	end,
})

TowerTab:CreateParagraph({
	Title = "Fallback",
	Content = "If none of your focused portals are available, Auto Tower picks the least dangerous displayed portal.",
})

TowerTab:CreateSection("Focus Portals")

for _, portal in ipairs(towerPortalOptions) do
	TowerTab:CreateToggle({
		Name = "Focus " .. portal.Name,
		CurrentValue = settings.TowerPortals[portal.Name],
		Flag = "TowerPortal_" .. portal.Name,
		Callback = function(value)
			settings.TowerPortals[portal.Name] = value
		end,
	})
end

AutoFarmTab:CreateSection("Enemy Orbit")

AutoFarmTab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Flag = "ManualAutoFarm",
	Callback = function(value)
		setAutoFarm(value)
	end,
})

AutoFarmTab:CreateToggle({
	Name = "Auto Cast Skills",
	CurrentValue = settings.AutoCast,
	Flag = "AutoCastSkills",
	Callback = function(value)
		settings.AutoCast = value
	end,
})

AutoFarmTab:CreateSection("Lobby Modifiers")

AutoFarmTab:CreateToggle({
	Name = "Hardcore",
	CurrentValue = settings.Hardcore,
	Flag = "HardcoreModifier",
	Callback = function(value)
		settings.Hardcore = value
	end,
})

AutoFarmTab:CreateToggle({
	Name = "One Hit / No Hit",
	CurrentValue = settings.NoHit,
	Flag = "NoHitModifier",
	Callback = function(value)
		settings.NoHit = value
	end,
})

AutoFarmTab:CreateToggle({
	Name = "Calamity Modifier",
	CurrentValue = settings.CalamityModifier,
	Flag = "CalamityModifier",
	Callback = function(value)
		settings.CalamityModifier = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Spin Speed",
	Range = { 1, 25 },
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = settings.OrbitSpeed,
	Flag = "OrbitSpeed",
	Callback = function(value)
		settings.OrbitSpeed = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Distance",
	Range = { 3, 40 },
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = settings.OrbitDistance,
	Flag = "OrbitDistance",
	Callback = function(value)
		settings.OrbitDistance = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Height",
	Range = { -5, 25 },
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = settings.OrbitHeight,
	Flag = "OrbitHeight",
	Callback = function(value)
		settings.OrbitHeight = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Cast Delay",
	Range = { 0.15, 2 },
	Increment = 0.05,
	Suffix = "Sec",
	CurrentValue = settings.CastDelay,
	Flag = "CastDelay",
	Callback = function(value)
		settings.CastDelay = value
	end,
})

AutoFarmTab:CreateSection("Farm Extras")

AutoFarmTab:CreateToggle({
	Name = "Auto Equip Best",
	CurrentValue = settings.AutoEquipBest,
	Flag = "AutoEquipBest",
	Callback = function(value)
		settings.AutoEquipBest = value

		if value then
			equipBest()
		end
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Equip Best Delay",
	Range = { 1, 30 },
	Increment = 1,
	Suffix = "Sec",
	CurrentValue = settings.EquipBestDelay,
	Flag = "EquipBestDelay",
	Callback = function(value)
		settings.EquipBestDelay = value
	end,
})

AutoFarmTab:CreateButton({
	Name = "Equip Best Now",
	Callback = function()
		equipBest()
	end,
})

AutoFarmTab:CreateToggle({
	Name = "Auto Skill Points",
	CurrentValue = settings.AutoSkillPoints,
	Flag = "AutoSkillPoints",
	Callback = function(value)
		settings.AutoSkillPoints = value
	end,
})

AutoFarmTab:CreateDropdown({
	Name = "Skill Point Type",
	Options = { "spell", "physical", "health" },
	CurrentOption = { settings.SkillPointType },
	MultipleOptions = false,
	Flag = "SkillPointType",
	Callback = function(options)
		if type(options) == "table" then
			settings.SkillPointType = options[1] or "spell"
		else
			settings.SkillPointType = options or "spell"
		end
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Skill Points Per Use",
	Range = { 1, 10 },
	Increment = 1,
	Suffix = "Point",
	CurrentValue = settings.SkillPointAmount,
	Flag = "SkillPointAmount",
	Callback = function(value)
		settings.SkillPointAmount = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Skill Point Delay",
	Range = { 1, 30 },
	Increment = 1,
	Suffix = "Sec",
	CurrentValue = settings.SkillPointDelay,
	Flag = "SkillPointDelay",
	Callback = function(value)
		settings.SkillPointDelay = value
	end,
})

AutoFarmTab:CreateButton({
	Name = "Add Skill Point Now",
	Callback = function()
		addSkillPoints(settings.SkillPointType, settings.SkillPointAmount)
	end,
})

AutoFarmTab:CreateSection("Auto Sell")

AutoFarmTab:CreateToggle({
	Name = "Auto Sell After Run",
	CurrentValue = settings.AutoSellAfterRun,
	Flag = "AutoSellAfterRun",
	Callback = function(value)
		settings.AutoSellAfterRun = value
	end,
})

AutoFarmTab:CreateToggle({
	Name = "Auto Sell On Load",
	CurrentValue = settings.AutoSellOnLoad,
	Flag = "AutoSellOnLoad",
	Callback = function(value)
		settings.AutoSellOnLoad = value
	end,
})

AutoFarmTab:CreateToggle({
	Name = "Protect Equipped Items",
	CurrentValue = settings.ProtectEquippedItems,
	Flag = "ProtectEquippedItems",
	Callback = function(value)
		settings.ProtectEquippedItems = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Auto Sell Delay",
	Range = { 0, 5 },
	Increment = 0.25,
	Suffix = "Sec",
	CurrentValue = settings.AutoSellDelay,
	Flag = "AutoSellDelay",
	Callback = function(value)
		settings.AutoSellDelay = value
	end,
})

AutoFarmTab:CreateSlider({
	Name = "Inventory Scan Timeout",
	Range = { 1, 10 },
	Increment = 0.5,
	Suffix = "Sec",
	CurrentValue = settings.AutoSellScanTimeout,
	Flag = "AutoSellScanTimeout",
	Callback = function(value)
		settings.AutoSellScanTimeout = value
	end,
})

for _, rarity in ipairs(sellRarityOptions) do
	AutoFarmTab:CreateToggle({
		Name = "Sell " .. rarity.Label,
		CurrentValue = settings.SellRarities[rarity.Key],
		Flag = "SellRarity_" .. rarity.Key,
		Callback = function(value)
			settings.SellRarities[rarity.Key] = value
		end,
	})
end

AutoFarmTab:CreateButton({
	Name = "Sell Selected Rarities Now",
	Callback = function()
		runAutoSell(false, true)
	end,
})

SettingsTab:CreateSection("Window")

SettingsTab:CreateButton({
	Name = "Hide To Icon",
	Callback = function()
		createHubIcon()
		setHubVisible(false)
	end,
})

SettingsTab:CreateSection("Solo Safety")

SettingsTab:CreateToggle({
	Name = "Pause If Another Player Joins",
	CurrentValue = settings.SoloSafetyPause,
	Flag = "SoloSafetyPause",
	Callback = function(value)
		settings.SoloSafetyPause = value
	end,
})

SettingsTab:CreateSection("Privacy")

SettingsTab:CreateToggle({
	Name = "Hide Name",
	CurrentValue = settings.HideName,
	Flag = "PrivacyHideName",
	Callback = function(value)
		setHideName(value)
	end,
})

SettingsTab:CreateSection("Saved Startup")

SettingsTab:CreateToggle({
	Name = "Auto Start When Executed",
	CurrentValue = settings.AutoStartOnExecute,
	Flag = "AutoStartOnExecute",
	Callback = function(value)
		settings.AutoStartOnExecute = value
	end,
})

SettingsTab:CreateToggle({
	Name = "Create + Start Dungeon With Auto Farm",
	CurrentValue = settings.AutoCreateAndStartDungeon,
	Flag = "AutoCreateAndStartDungeon",
	Callback = function(value)
		settings.AutoCreateAndStartDungeon = value
	end,
})

SettingsTab:CreateSlider({
	Name = "Dungeon Start Delay",
	Range = { 0.5, 8 },
	Increment = 0.5,
	Suffix = "Sec",
	CurrentValue = settings.DungeonStartDelay,
	Flag = "DungeonStartDelay",
	Callback = function(value)
		settings.DungeonStartDelay = value
	end,
})

SettingsTab:CreateSlider({
	Name = "Start Attempts",
	Range = { 1, 20 },
	Increment = 1,
	Suffix = "Try",
	CurrentValue = settings.DungeonStartAttempts,
	Flag = "DungeonStartAttempts",
	Callback = function(value)
		settings.DungeonStartAttempts = value
	end,
})

SettingsTab:CreateSlider({
	Name = "Start Retry Delay",
	Range = { 0.25, 3 },
	Increment = 0.25,
	Suffix = "Sec",
	CurrentValue = settings.DungeonStartRetryDelay,
	Flag = "DungeonStartRetryDelay",
	Callback = function(value)
		settings.DungeonStartRetryDelay = value
	end,
})

pcall(function()
	HubUI:LoadConfiguration()
end)

task.spawn(function()
	task.wait(0.1)
	pcall(startHideNameLoop)
end)

updatePlayerInfoDisplay()
startPlayerInfoRefresh()

local function getFlagValue(flagName, fallback)
	local flags = HubUI.Flags
	local flag = flags and flags[flagName]

	if flag then
		if flag.CurrentValue ~= nil then
			return flag.CurrentValue
		end

		if flag.CurrentOption ~= nil then
			return flag.CurrentOption
		end
	end

	return fallback
end

local function unwrapOption(value, fallback)
	if type(value) == "table" then
		return value[1] or fallback
	end

	return value or fallback
end

local function syncSavedSettings()
	settings.SoloSafetyPause = getFlagValue("SoloSafetyPause", settings.SoloSafetyPause)
	setHideName(getFlagValue("PrivacyHideName", settings.HideName))
	settings.AutoStartOnExecute = getFlagValue("AutoStartOnExecute", settings.AutoStartOnExecute)
	settings.AutoCreateAndStartDungeon = getFlagValue("AutoCreateAndStartDungeon", settings.AutoCreateAndStartDungeon)
	settings.AutoCast = getFlagValue("AutoCastSkills", settings.AutoCast)
	settings.AutoEquipBest = getFlagValue("AutoEquipBest", settings.AutoEquipBest)
	settings.EquipBestDelay = getFlagValue("EquipBestDelay", settings.EquipBestDelay)
	settings.AutoSkillPoints = getFlagValue("AutoSkillPoints", settings.AutoSkillPoints)
	settings.SkillPointType = unwrapOption(getFlagValue("SkillPointType", settings.SkillPointType), settings.SkillPointType)
	settings.SkillPointAmount = getFlagValue("SkillPointAmount", settings.SkillPointAmount)
	settings.SkillPointDelay = getFlagValue("SkillPointDelay", settings.SkillPointDelay)
	settings.AutoSellAfterRun = getFlagValue("AutoSellAfterRun", settings.AutoSellAfterRun)
	settings.AutoSellOnLoad = getFlagValue("AutoSellOnLoad", settings.AutoSellOnLoad)
	settings.AutoSellDelay = getFlagValue("AutoSellDelay", settings.AutoSellDelay)
	settings.AutoSellScanTimeout = getFlagValue("AutoSellScanTimeout", settings.AutoSellScanTimeout)
	settings.ProtectEquippedItems = getFlagValue("ProtectEquippedItems", settings.ProtectEquippedItems)
	settings.AutoTower = getFlagValue("AutoTower", settings.AutoTower)
	settings.AutoTowerPickDelay = getFlagValue("AutoTowerPickDelay", settings.AutoTowerPickDelay)
	settings.AutoTowerStartRetry = getFlagValue("AutoTowerStartRetry", settings.AutoTowerStartRetry)
	settings.TowerStartRetryDelay = getFlagValue("TowerStartRetryDelay", settings.TowerStartRetryDelay)
	settings.AutoTowerTreasureRewards = getFlagValue("AutoTowerTreasureRewards", settings.AutoTowerTreasureRewards)
	settings.TreasureRewardTimeout = getFlagValue("TreasureRewardTimeout", settings.TreasureRewardTimeout)

	if settings.AutoTower then
		lastTowerStartRetry = os.clock()
	end

	for _, rarity in ipairs(sellRarityOptions) do
		settings.SellRarities[rarity.Key] = getFlagValue("SellRarity_" .. rarity.Key, settings.SellRarities[rarity.Key])
	end

	for _, portal in ipairs(towerPortalOptions) do
		settings.TowerPortals[portal.Name] = getFlagValue("TowerPortal_" .. portal.Name, settings.TowerPortals[portal.Name])
	end

	settings.Hardcore = getFlagValue("HardcoreModifier", settings.Hardcore)
	settings.NoHit = getFlagValue("NoHitModifier", settings.NoHit)
	settings.CalamityModifier = getFlagValue("CalamityModifier", settings.CalamityModifier)
	settings.OrbitSpeed = getFlagValue("OrbitSpeed", settings.OrbitSpeed)
	settings.OrbitDistance = getFlagValue("OrbitDistance", settings.OrbitDistance)
	settings.OrbitHeight = getFlagValue("OrbitHeight", settings.OrbitHeight)
	settings.CastDelay = getFlagValue("CastDelay", settings.CastDelay)
	settings.DungeonStartDelay = getFlagValue("DungeonStartDelay", settings.DungeonStartDelay)
	settings.DungeonStartAttempts = getFlagValue("DungeonStartAttempts", settings.DungeonStartAttempts)
	settings.DungeonStartRetryDelay = getFlagValue("DungeonStartRetryDelay", settings.DungeonStartRetryDelay)
	settings.CharacterSlot = getFlagValue("CharacterSlot", settings.CharacterSlot)
end

task.delay(1, function()
	syncSavedSettings()

	if settings.AutoSellOnLoad and hasSelectedSellRarity() then
		task.wait(settings.AutoSellDelay)
		runAutoSell(false, true)
	end

	if settings.AutoStartOnExecute then
		setAutoFarm(true)
	end
end)

notify("kryptexHUB", "Loaded dungeon script.")
