-- kryptexHUBv2
-- Simple one-page mobile-friendly hub. No place ID check.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager

pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

local settings = {
	CowName = "Cow",
	CowPrefix = "Cow_cow_",
	UFOName = "UFO",
	GhostNames = { "FastGhost", "NormalGhost", "SlowGhost" },
	GhostPrefixes = { "FastGhost_", "NormalGhost_", "SlowGhost_" },
	MaterialNames = { "Meteoron", "Snowflake","CandyPickup", "PumpkinPickup", "Candy", "SnowflakePickup", "MeteoronPickup", "AlienPickup" },
	DigPileName = "DigPile",

	TeleportHeight = 4,
	ActionDelay = 0.08,

	UFODelay = 0.08,
	UFOPickupConfirmTime = 1.25,
	UFOFailedCowCooldown = 8,
	UFODeliverTimeout = 12,
	UFOStayUnderDelay = 0.08,
	UFOUnderOffset = 2,
	UFOTouchTurnInDelay = 0.2,
	SpookyDelay = 0.04,
	SpookyEquipWait = 0.05,
	SpookySlapDistance = 3,
	SpookySwingRepeats = 3,
	SpookySwingDelay = 0.025,
	SpookySwingHoldTime = 0.02,

	MaterialDelay = 0.1,
	MaterialCollectDelay = 0.25,
	MaterialHoverHeight = 1.6,

	TreasureDelay = 0.01,
	TreasureUiWaitTime = 8,
	TreasureUiPollDelay = 0.03,
	TreasureHoverHeight = 0.5,
	TreasurePileCooldown = 35,
}

local autoUFO = false
local autoSpooky = false
local autoMaterials = false
local autoTreasure = false

local ufoLoopRunning = false
local spookyLoopRunning = false
local materialsLoopRunning = false
local treasureLoopRunning = false
local spookySlotSelected = false
local currentSpookyTarget
local failedCows = {}
local completedDigPiles = {}

local statusLabel
local ufoButton
local spookyButton
local materialsButton
local treasureButton

local function setStatus(message)
	if statusLabel then
		statusLabel.Text = message
	end
end

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getPivot(instance)
	if instance:IsA("Model") then
		return instance:GetPivot()
	end

	if instance:IsA("BasePart") then
		return instance.CFrame
	end

	if instance:IsA("Attachment") then
		return instance.WorldCFrame
	end
end

local function isInsideCharacter(instance)
	local character = player.Character
	return character and instance:IsDescendantOf(character)
end

local function isActiveWorldObject(instance)
	if not instance or not instance.Parent or isInsideCharacter(instance) then
		return false
	end

	local humanoid = instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		return false
	end

	if instance:GetAttribute("Active") == false or instance:GetAttribute("Dead") == true then
		return false
	end

	if instance:GetAttribute("Defeated") == true then
		return false
	end

	local health = instance:GetAttribute("Health")
	if typeof(health) == "number" and health <= 0 then
		return false
	end

	return getPivot(instance) ~= nil
end

local function teleportTo(instance, height)
	local pivot = getPivot(instance)
	if not pivot then
		return false
	end

	getRoot().CFrame = pivot + Vector3.new(0, height or settings.TeleportHeight, 0)
	return true
end

local function teleportBeside(instance, distance, height)
	local pivot = getPivot(instance)
	if not pivot then
		return false
	end

	local root = getRoot()
	local direction = root.Position - pivot.Position
	direction = Vector3.new(direction.X, 0, direction.Z)

	if direction.Magnitude < 1 then
		direction = Vector3.new(0, 0, 1)
	end

	local target = pivot.Position + direction.Unit * distance + Vector3.new(0, height or 1, 0)
	root.CFrame = CFrame.lookAt(target, pivot.Position)
	return true
end

local function getNearestNamed(name, rootObject)
	local root = getRoot()
	local searchRoot = rootObject or Workspace
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(searchRoot:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")

		if targetType and instance.Name == name and isActiveWorldObject(instance) then
			local pivot = getPivot(instance)

			if pivot then
				local distance = (root.Position - pivot.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = instance
				end
			end
		end
	end

	return nearest
end

local function getNearestFromNames(names, rootObject)
	local root = getRoot()
	local searchRoot = rootObject or Workspace
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(searchRoot:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")

		if targetType and isActiveWorldObject(instance) then
			for _, name in ipairs(names) do
				if instance.Name == name then
					local pivot = getPivot(instance)

					if pivot then
						local distance = (root.Position - pivot.Position).Magnitude

						if distance < nearestDistance then
							nearestDistance = distance
							nearest = instance
						end
					end

					break
				end
			end
		end
	end

	return nearest
end

local function getNearestByNameMatch(nameMatches, rootObject, instanceMatches)
	local root = getRoot()
	local searchRoot = rootObject or Workspace
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(searchRoot:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")

		if targetType and nameMatches(instance.Name) and (not instanceMatches or instanceMatches(instance)) and isActiveWorldObject(instance) then
			local pivot = getPivot(instance)

			if pivot then
				local distance = (root.Position - pivot.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = instance
				end
			end
		end
	end

	return nearest
end

local function nameStartsWith(name, prefix)
	return string.sub(name, 1, #prefix) == prefix
end

local function isCowName(name)
	return name == settings.CowName or nameStartsWith(name, settings.CowPrefix)
end

local function getNearestCow()
	return getNearestByNameMatch(function(name)
		return isCowName(name)
	end, nil, function(instance)
		local failedAt = failedCows[instance]
		return not failedAt or os.clock() - failedAt > settings.UFOFailedCowCooldown
	end)
end

local function getHeldCow()
	local character = player.Character
	if not character then
		return nil
	end

	for _, instance in ipairs(character:GetDescendants()) do
		if isCowName(instance.Name) then
			return instance
		end
	end
end

local function playerHasCow()
	return getHeldCow() ~= nil
end

local function getNearestGhost()
	for index, ghostName in ipairs(settings.GhostNames) do
		local ghostPrefix = settings.GhostPrefixes[index]
		local ghost = getNearestByNameMatch(function(name)
			if name == ghostName then
				return true
			end

			if ghostPrefix and nameStartsWith(name, ghostPrefix) then
				return true
			end

			return false
		end)

		if ghost then
			return ghost
		end
	end
end

local function getPromptPosition(prompt)
	local pivot = prompt.Parent and getPivot(prompt.Parent)
	return pivot and pivot.Position
end

local function getNearestPrompt(holder)
	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, descendant in ipairs(holder:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") and descendant.Enabled then
			local position = getPromptPosition(descendant)

			if position then
				local distance = (root.Position - position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = descendant
				end
			end
		end
	end

	return nearest
end

local function triggerPrompt(prompt)
	if not prompt or not prompt.Enabled then
		return false
	end

	local success = pcall(function()
		prompt:InputHoldBegin()
		task.wait(math.max(prompt.HoldDuration, 0.05) + 0.15)
		prompt:InputHoldEnd()
	end)

	task.wait(settings.ActionDelay)
	return success
end

local function holdPrompt(prompt)
	if not prompt or not prompt.Enabled then
		return false
	end

	if prompt.Parent then
		teleportTo(prompt.Parent, 3)
	end

	task.wait(settings.ActionDelay)
	return triggerPrompt(prompt)
end

local function getBackpackTools()
	local tools = {}

	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Tool") then
			table.insert(tools, child)
		end
	end

	return tools
end

local function getSlotTool(slotNumber)
	return getBackpackTools()[slotNumber]
end

local function toolNameContains(tool, fragments)
	local lowerName = string.lower(tool.Name)

	for _, fragment in ipairs(fragments) do
		if string.find(lowerName, fragment) then
			return true
		end
	end

	return false
end

local function findEquippedTool(fragments)
	local character = player.Character
	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and toolNameContains(child, fragments) then
			return child
		end
	end
end

local function getAnyEquippedTool()
	local character = player.Character
	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child
		end
	end
end

local function findBackpackTool(fragments)
	for _, tool in ipairs(getBackpackTools()) do
		if toolNameContains(tool, fragments) then
			return tool
		end
	end
end

local function equipTool(tool)
	if not tool then
		return nil
	end

	local humanoid = getCharacter():FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	if tool.Parent ~= player.Character then
		humanoid:EquipTool(tool)
		task.wait(0.1)
	end

	return tool
end

local function activateTool(tool)
	if not tool then
		return false
	end

	return pcall(function()
		tool:Activate()
	end)
end

local function tapKey(keyCode)
	if not VirtualInputManager then
		return false
	end

	return pcall(function()
		VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
		task.wait(0.025)
		VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
	end)
end

local function tapPrimaryAction()
	if not VirtualInputManager then
		return false
	end

	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
	local x = viewport.X / 2
	local y = viewport.Y / 2

	return pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
		task.wait(settings.SpookySwingHoldTime)
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end)
end

local function updateButtons()
	if ufoButton then
		ufoButton.Text = autoUFO and "UFO: ON" or "UFO: OFF"
		ufoButton.BackgroundColor3 = autoUFO and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end

	if spookyButton then
		spookyButton.Text = autoSpooky and "Spooky: ON" or "Spooky: OFF"
		spookyButton.BackgroundColor3 = autoSpooky and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end

	if materialsButton then
		materialsButton.Text = autoMaterials and "Materials: ON" or "Materials: OFF"
		materialsButton.BackgroundColor3 = autoMaterials and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end

	if treasureButton then
		treasureButton.Text = autoTreasure and "Treasure Hunt: ON" or "Treasure Hunt: OFF"
		treasureButton.BackgroundColor3 = autoTreasure and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end
end

local function getUFOUnderCFrame(ufo)
	if not ufo then
		return nil
	end

	if ufo:IsA("Model") then
		local success, cframe, size = pcall(function()
			return ufo:GetBoundingBox()
		end)

		if not success then
			return getPivot(ufo)
		end

		local position = cframe.Position
		return CFrame.new(position.X, position.Y - size.Y / 2 - settings.UFOUnderOffset, position.Z)
	end

	if ufo:IsA("BasePart") then
		local position = ufo.Position
		return CFrame.new(position.X, position.Y - ufo.Size.Y / 2 - settings.UFOUnderOffset, position.Z)
	end

	local pivot = getPivot(ufo)
	if not pivot then
		return nil
	end

	return pivot + Vector3.new(0, -settings.UFOUnderOffset, 0)
end

local function teleportUnderUFO(ufo)
	local cframe = getUFOUnderCFrame(ufo)
	if not cframe then
		return false
	end

	getRoot().CFrame = cframe
	return true
end

local function waitForCowPickup(cow)
	local startedAt = os.clock()

	while autoUFO and os.clock() - startedAt < settings.UFOPickupConfirmTime do
		if playerHasCow() then
			return true
		end

		if cow and isInsideCharacter(cow) then
			return true
		end

		task.wait(0.05)
	end

	return playerHasCow()
end

local function markCowFailed(cow, reason)
	if cow then
		failedCows[cow] = os.clock()
	end

	setStatus("UFO: skipping cow, " .. reason)
end

local function deliverHeldCow()
	local ufo = getNearestNamed(settings.UFOName)
	if not ufo then
		setStatus("UFO: holding Cow, waiting for UFO.")
		return false
	end

	local startedAt = os.clock()

	while autoUFO and playerHasCow() and os.clock() - startedAt < settings.UFODeliverTimeout do
		setStatus("UFO: staying under UFO until Cow is gone.")
		teleportUnderUFO(ufo)

		local prompt = getNearestPrompt(ufo)
		if prompt then
			triggerPrompt(prompt)
		else
			task.wait(settings.UFOTouchTurnInDelay)
		end

		teleportUnderUFO(ufo)
		task.wait(settings.UFOStayUnderDelay)
	end

	if playerHasCow() then
		setStatus("UFO: Cow still held, retrying delivery.")
		return false
	end

	setStatus("UFO: Cow delivered.")
	return true
end

local function doUFO()
	if playerHasCow() then
		return deliverHeldCow()
	end

	local cow = getNearestCow()
	if not cow then
		setStatus("UFO: waiting for Cow_cow_.")
		return false
	end

	setStatus("UFO: picking up " .. cow.Name .. ".")
	teleportTo(cow, settings.TeleportHeight)
	task.wait(settings.ActionDelay)

	local cowPrompt = getNearestPrompt(cow)
	if not cowPrompt then
		markCowFailed(cow, "no prompt found.")
		return false
	end

	if not holdPrompt(cowPrompt) then
		markCowFailed(cow, "prompt failed.")
		return false
	end

	if not waitForCowPickup(cow) then
		markCowFailed(cow, "pickup did not confirm.")
		return false
	end

	return deliverHeldCow()
end

local function startUFO()
	if ufoLoopRunning then
		return
	end

	ufoLoopRunning = true

	task.spawn(function()
		while autoUFO do
			doUFO()
			task.wait(settings.UFODelay)
		end

		ufoLoopRunning = false
		setStatus("UFO stopped.")
	end)
end

local function selectSlapperSlot()
	tapKey(Enum.KeyCode.Two)
	task.wait(settings.SpookyEquipWait)
end

local function doSpooky()
	if currentSpookyTarget and not isActiveWorldObject(currentSpookyTarget) then
		currentSpookyTarget = nil
	end

	local ghost = currentSpookyTarget or getNearestGhost()
	if not ghost then
		setStatus("Spooky: waiting for FastGhost_, NormalGhost_, or SlowGhost_.")
		return false
	end

	currentSpookyTarget = ghost
	setStatus("Spooky: locked on " .. ghost.Name .. ".")
	teleportBeside(ghost, settings.SpookySlapDistance, 1)
	task.wait(settings.ActionDelay)

	for _ = 1, settings.SpookySwingRepeats do
		activateTool(findEquippedTool({ "slap" }) or getAnyEquippedTool())
		tapPrimaryAction()
		task.wait(settings.SpookySwingDelay)
	end

	if not isActiveWorldObject(ghost) then
		currentSpookyTarget = nil
		setStatus("Spooky: target down, finding next ghost.")
	end

	task.wait(settings.SpookyDelay)
	return true
end

local function startSpooky()
	if spookyLoopRunning then
		return
	end

	spookyLoopRunning = true
	spookySlotSelected = false
	currentSpookyTarget = nil

	task.spawn(function()
		if not spookySlotSelected then
			setStatus("Spooky: pressing 2 once.")
			selectSlapperSlot()
			spookySlotSelected = true
		end

		while autoSpooky do
			doSpooky()
			task.wait(settings.SpookyDelay)
		end

		spookyLoopRunning = false
		currentSpookyTarget = nil
		setStatus("Spooky stopped.")
	end)
end

local function getWorkshop()
	return Workspace:FindFirstChild("Workshop", true) or Workspace:FindFirstChild("WorkShop", true)
end

local function getNearestMaterial()
	local workshop = getWorkshop()
	local material = workshop and getNearestFromNames(settings.MaterialNames, workshop)
	return material or getNearestFromNames(settings.MaterialNames)
end

local function getPromptHoverHeight(prompt)
	if not prompt then
		return settings.MaterialHoverHeight
	end

	local maxDistance = prompt.MaxActivationDistance or 10
	return math.clamp(settings.MaterialHoverHeight, 0.5, math.max(maxDistance - 1, 0.5))
end

local function doMaterials()
	local material = getNearestMaterial()
	if not material then
		setStatus("Materials: waiting for Meteoron, Snowflake, or Candy.")
		return false
	end

	setStatus("Materials: collecting " .. material.Name .. ".")
	teleportTo(material, settings.MaterialHoverHeight)
	task.wait(settings.MaterialCollectDelay)

	local prompt = getNearestPrompt(material)
	if prompt then
		teleportTo(prompt.Parent or material, getPromptHoverHeight(prompt))
		task.wait(settings.ActionDelay)
		triggerPrompt(prompt)
	else
		task.wait(settings.MaterialCollectDelay)
	end

	return true
end

local function startMaterials()
	if materialsLoopRunning then
		return
	end

	materialsLoopRunning = true

	task.spawn(function()
		while autoMaterials do
			doMaterials()
			task.wait(settings.MaterialDelay)
		end

		materialsLoopRunning = false
		setStatus("Materials stopped.")
	end)
end

local function getEventsFolder()
	return Workspace:FindFirstChild("Events") or Workspace:FindFirstChild("Event") or Workspace
end

local function getNearestDigPile()
	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(getEventsFolder():GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")
		local completedAt = completedDigPiles[instance]
		local recentlyDone = completedAt and os.clock() - completedAt < settings.TreasurePileCooldown

		if targetType and instance.Name == settings.DigPileName and not recentlyDone and isActiveWorldObject(instance) then
			local pivot = getPivot(instance)

			if pivot then
				local distance = (root.Position - pivot.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = instance
				end
			end
		end
	end

	return nearest
end

local function equipDigTool()
	local tool = findEquippedTool({ "dig", "shovel", "spade", "trowel" })
		or findBackpackTool({ "dig", "shovel", "spade", "trowel" })
		or getSlotTool(1)

	if not tool then
		setStatus("Treasure: put shovel/dig tool in slot 1.")
		return nil
	end

	return equipTool(tool)
end

local function activateDigTool()
	return activateTool(equipDigTool())
end

local function getDigEventGui()
	local main = playerGui:FindFirstChild("Main")
	local frames = main and main:FindFirstChild("Frames")
	local digEvent = frames and frames:FindFirstChild("DigEvent")
	return digEvent or playerGui:FindFirstChild("DigEvent", true)
end

local function isGuiVisible(guiObject)
	local current = guiObject

	while current and current:IsA("GuiObject") do
		if not current.Visible then
			return false
		end

		current = current.Parent
	end

	return true
end

local function runTreasureMinigame()
	local sawUi = false
	local waitingStarted = os.clock()

	while autoTreasure do
		local digEvent = getDigEventGui()
		local digUiOpen = digEvent and digEvent:IsA("GuiObject") and isGuiVisible(digEvent)

		if digUiOpen then
			sawUi = true
			setStatus("Treasure: your turn to click. Waiting for this pile to finish.")
			task.wait(settings.TreasureUiPollDelay)
		elseif sawUi then
			setStatus("Treasure: pile finished.")
			return true
		elseif os.clock() - waitingStarted > settings.TreasureUiWaitTime then
			setStatus("Treasure: UI did not open, trying the next pile.")
			return false
		else
			task.wait(settings.TreasureUiPollDelay)
		end
	end

	return sawUi
end

local function doTreasure()
	local digPile = getNearestDigPile()
	if not digPile then
		setStatus("Treasure: waiting for DigPile in Workspace.Events.")
		return false
	end

	setStatus("Treasure: moving to DigPile and starting it.")
	teleportTo(digPile, settings.TreasureHoverHeight)
	task.wait(settings.ActionDelay)

	local prompt = getNearestPrompt(digPile)
	if prompt then
		teleportTo(prompt.Parent or digPile, settings.TreasureHoverHeight)
		task.wait(settings.ActionDelay)
		triggerPrompt(prompt)
	else
		activateDigTool()
	end

	task.wait(settings.TreasureDelay)

	local completed = runTreasureMinigame()
	if completed then
		completedDigPiles[digPile] = os.clock()
	end

	return completed
end

local function startTreasure()
	if treasureLoopRunning then
		return
	end

	treasureLoopRunning = true

	task.spawn(function()
		while autoTreasure do
			doTreasure()
			task.wait(settings.TreasureDelay)
		end

		treasureLoopRunning = false
		setStatus("Treasure stopped.")
	end)
end

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function createStroke(parent)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 85, 105)
	stroke.Thickness = 1
	stroke.Transparency = 0.35
	stroke.Parent = parent
end

local tapButtons = {}

local function pointInside(guiObject, point)
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	local padding = 10
	return point.X >= position.X - padding and point.X <= position.X + size.X + padding and point.Y >= position.Y - padding and point.Y <= position.Y + size.Y + padding
end

local function guiVisible(guiObject)
	local current = guiObject

	while current and current:IsA("GuiObject") do
		if not current.Visible then
			return false
		end

		current = current.Parent
	end

	return true
end

local function connectTap(button, callback)
	local lastTap = 0

	local function fire()
		local now = os.clock()
		if now - lastTap < 0.12 then
			return
		end

		lastTap = now

		local success, err = pcall(callback)
		if not success then
			setStatus("Button error: " .. tostring(err))
		end
	end

	button.Active = true
	button.Selectable = true

	table.insert(tapButtons, {
		Button = button,
		Callback = fire,
	})

	pcall(function()
		button.Activated:Connect(fire)
	end)

	pcall(function()
		button.MouseButton1Click:Connect(fire)
	end)

	pcall(function()
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				fire()
			end
		end)
	end)
end

local function createButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
	button.BackgroundColor3 = Color3.fromRGB(126, 47, 47)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.AutoButtonColor = true
	button.Parent = parent

	createCorner(button, 7)
	createStroke(button)
	connectTap(button, callback)
	return button
end

local function makeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = frame.Position

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
			frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
end

local oldGui = playerGui:FindFirstChild("kryptexHUBv2")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "kryptexHUBv2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
pcall(function()
	screenGui.DisplayOrder = 1000
end)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

UserInputService.InputEnded:Connect(function(input)
	local isTap = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	if not isTap or not screenGui.Parent then
		return
	end

	local point = Vector2.new(input.Position.X, input.Position.Y)

	for index = #tapButtons, 1, -1 do
		local item = tapButtons[index]
		local button = item.Button

		if button and button.Parent and button:IsDescendantOf(screenGui) and guiVisible(button) and pointInside(button, point) then
			item.Callback()
			return
		end
	end
end)

local isTouch = UserInputService.TouchEnabled
local hubWidth = isTouch and 280 or 310
local hubHeight = 315

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(hubWidth, hubHeight)
main.Position = isTouch and UDim2.fromOffset(18, 118) or UDim2.new(0, 30, 0.5, -hubHeight / 2)
main.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

createCorner(main, 8)
createStroke(main)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(31, 34, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

createCorner(titleBar, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "kryptexHUBv2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(32, 26)
minimizeButton.Position = UDim2.new(1, -72, 0, 8)
minimizeButton.BackgroundColor3 = Color3.fromRGB(55, 59, 75)
minimizeButton.BorderSizePixel = 0
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 18
minimizeButton.AutoButtonColor = true
minimizeButton.Parent = titleBar

createCorner(minimizeButton, 6)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 26)
closeButton.Position = UDim2.new(1, -36, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(126, 47, 47)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.AutoButtonColor = true
closeButton.Parent = titleBar

createCorner(closeButton, 6)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -20, 1, -56)
body.Position = UDim2.fromOffset(10, 50)
body.BackgroundTransparency = 1
body.Parent = main

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = body

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 48)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 33, 42)
statusLabel.BorderSizePixel = 0
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Ready. Pick a toggle."
statusLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
statusLabel.TextSize = 13
statusLabel.TextWrapped = true
statusLabel.Parent = body

createCorner(statusLabel, 6)

ufoButton = createButton(body, "UFO: OFF", function()
	autoUFO = not autoUFO
	updateButtons()

	if autoUFO then
		setStatus("UFO started.")
		startUFO()
	else
		setStatus("Stopping UFO.")
	end
end)

spookyButton = createButton(body, "Spooky: OFF", function()
	autoSpooky = not autoSpooky
	updateButtons()

	if autoSpooky then
		setStatus("Spooky started.")
		startSpooky()
	else
		setStatus("Stopping Spooky.")
	end
end)

materialsButton = createButton(body, "Materials: OFF", function()
	autoMaterials = not autoMaterials
	updateButtons()

	if autoMaterials then
		setStatus("Materials started.")
		startMaterials()
	else
		setStatus("Stopping Materials.")
	end
end)

treasureButton = createButton(body, "Treasure Hunt: OFF", function()
	autoTreasure = not autoTreasure
	updateButtons()

	if autoTreasure then
		setStatus("Treasure Hunt started.")
		startTreasure()
	else
		setStatus("Stopping Treasure Hunt.")
	end
end)

local minimized = false

connectTap(closeButton, function()
	autoUFO = false
	autoSpooky = false
	autoMaterials = false
	autoTreasure = false
	screenGui:Destroy()
end)

connectTap(minimizeButton, function()
	minimized = not minimized
	body.Visible = not minimized
	minimizeButton.Text = minimized and "+" or "-"
	main.Size = minimized and UDim2.fromOffset(hubWidth, 42) or UDim2.fromOffset(hubWidth, hubHeight)
end)

makeDraggable(main, titleBar)
updateButtons()
