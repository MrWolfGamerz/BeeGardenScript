-- kryptexHUBv2
-- Simple one-page mobile-friendly event hub.
-- Toggles: UFO, Spooky, Treasure Hunt.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

local settings = {
	CowName = "Cow",
	UFOName = "UFO",
	GhostNames = { "FastGhost", "NormalGhost", "SlowGhost" },
	DigPileName = "DigPile",

	TeleportHeight = 4,
	ActionDelay = 0.2,

	UFODelay = 0.5,
	SpookyDelay = 0.2,
	SpookySlapDistance = 4,

	TreasureDelay = 0.35,
	TreasureUiWaitTime = 8,
	TreasureLineCheckDelay = 0.02,
	TreasureHitDelay = 0.06,
	TreasurePileCooldown = 35,
}

local autoUFO = false
local autoSpooky = false
local autoTreasure = false

local ufoLoopRunning = false
local spookyLoopRunning = false
local treasureLoopRunning = false
local completedDigPiles = {}

local statusLabel
local ufoButton
local spookyButton
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
	local character = getCharacter()
	return character:WaitForChild("HumanoidRootPart")
end

local function isInsideLocalCharacter(instance)
	local character = player.Character
	return character and instance:IsDescendantOf(character)
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

local function isWorldObjectActive(instance)
	if not instance or not instance.Parent or isInsideLocalCharacter(instance) then
		return false
	end

	local humanoid = instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then
		return false
	end

	if instance:GetAttribute("Active") == false or instance:GetAttribute("Dead") == true then
		return false
	end

	return getPivot(instance) ~= nil
end

local function getNearestNamedObject(name)
	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(Workspace:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")

		if targetType and instance.Name == name and isWorldObjectActive(instance) then
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

local function getNearestNamedObjectFromList(names)
	local root = getRoot()
	local nearest
	local nearestDistance = math.huge

	for _, instance in ipairs(Workspace:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")

		if targetType and isWorldObjectActive(instance) then
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

local function getPromptPosition(prompt)
	local parent = prompt.Parent
	local pivot = parent and getPivot(parent)
	return pivot and pivot.Position
end

local function getNearestPrompt(holder)
	local root = getRoot()
	local nearestPrompt
	local nearestDistance = math.huge

	for _, descendant in ipairs(holder:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") and descendant.Enabled then
			local position = getPromptPosition(descendant)

			if position then
				local distance = (root.Position - position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearestPrompt = descendant
				end
			end
		end
	end

	return nearestPrompt
end

local function holdPrompt(prompt)
	if not prompt or not prompt.Enabled then
		return false
	end

	if prompt.Parent then
		teleportTo(prompt.Parent, 3)
	end

	task.wait(settings.ActionDelay)

	local success = pcall(function()
		prompt:InputHoldBegin()
		task.wait(math.max(prompt.HoldDuration, 0.05) + 0.15)
		prompt:InputHoldEnd()
	end)

	task.wait(settings.ActionDelay)
	return success
end

local function getToolsInBackpack()
	local tools = {}

	for _, child in ipairs(backpack:GetChildren()) do
		if child:IsA("Tool") then
			table.insert(tools, child)
		end
	end

	return tools
end

local function getSlotTool(slotNumber)
	return getToolsInBackpack()[slotNumber]
end

local function toolNameHas(tool, fragments)
	local lowerName = string.lower(tool.Name)

	for _, fragment in ipairs(fragments) do
		if string.find(lowerName, fragment) then
			return true
		end
	end

	return false
end

local function findEquippedToolMatching(fragments)
	local character = player.Character
	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and toolNameHas(child, fragments) then
			return child
		end
	end
end

local function findBackpackToolMatching(fragments)
	for _, tool in ipairs(getToolsInBackpack()) do
		if toolNameHas(tool, fragments) then
			return tool
		end
	end
end

local function equipTool(tool)
	if not tool then
		return nil
	end

	local character = getCharacter()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	if tool.Parent ~= character then
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

local function updateToggleButtons()
	if ufoButton then
		ufoButton.Text = autoUFO and "UFO: ON" or "UFO: OFF"
		ufoButton.BackgroundColor3 = autoUFO and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end

	if spookyButton then
		spookyButton.Text = autoSpooky and "Spooky: ON" or "Spooky: OFF"
		spookyButton.BackgroundColor3 = autoSpooky and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end

	if treasureButton then
		treasureButton.Text = autoTreasure and "Treasure Hunt: ON" or "Treasure Hunt: OFF"
		treasureButton.BackgroundColor3 = autoTreasure and Color3.fromRGB(34, 126, 76) or Color3.fromRGB(126, 47, 47)
	end
end

local function doUFORun()
	local cow = getNearestNamedObject(settings.CowName)
	if not cow then
		setStatus("UFO: waiting for Cow.")
		return false
	end

	setStatus("UFO: picking up Cow.")
	teleportTo(cow, settings.TeleportHeight)
	task.wait(settings.ActionDelay)

	local cowPrompt = getNearestPrompt(cow)
	if cowPrompt then
		holdPrompt(cowPrompt)
	else
		setStatus("UFO: Cow has no prompt.")
		return false
	end

	local ufo = getNearestNamedObject(settings.UFOName)
	if not ufo then
		setStatus("UFO: waiting for UFO.")
		return false
	end

	setStatus("UFO: turning in Cow.")
	teleportTo(ufo, settings.TeleportHeight)
	task.wait(settings.ActionDelay)

	local ufoPrompt = getNearestPrompt(ufo)
	if ufoPrompt then
		holdPrompt(ufoPrompt)
	else
		task.wait(0.75)
	end

	return true
end

local function startUFOFarm()
	if ufoLoopRunning then
		return
	end

	ufoLoopRunning = true

	task.spawn(function()
		while autoUFO do
			doUFORun()
			task.wait(settings.UFODelay)
		end

		ufoLoopRunning = false
		setStatus("UFO stopped.")
	end)
end

local function equipSlapper()
	local tool = findEquippedToolMatching({ "slap" })
		or getSlotTool(2)
		or findBackpackToolMatching({ "slap" })

	if not tool then
		setStatus("Spooky: put the slapper in slot 2.")
		return nil
	end

	return equipTool(tool)
end

local function doSpookyRun()
	local ghost = getNearestNamedObjectFromList(settings.GhostNames)
	if not ghost then
		setStatus("Spooky: waiting for ghosts.")
		return false
	end

	local slapper = equipSlapper()
	if not slapper then
		return false
	end

	setStatus("Spooky: slapping " .. ghost.Name .. ".")
	teleportBeside(ghost, settings.SpookySlapDistance, 1)
	task.wait(settings.ActionDelay)
	activateTool(slapper)
	task.wait(settings.SpookyDelay)
	return true
end

local function startSpookyFarm()
	if spookyLoopRunning then
		return
	end

	spookyLoopRunning = true

	task.spawn(function()
		while autoSpooky do
			doSpookyRun()
			task.wait(settings.SpookyDelay)
		end

		spookyLoopRunning = false
		setStatus("Spooky stopped.")
	end)
end

local function getEventsFolder()
	return Workspace:FindFirstChild("Events") or Workspace:FindFirstChild("Event") or Workspace
end

local function getNearestDigPile()
	local root = getRoot()
	local nearest
	local nearestDistance = math.huge
	local eventsFolder = getEventsFolder()

	for _, instance in ipairs(eventsFolder:GetDescendants()) do
		local targetType = instance:IsA("Model") or instance:IsA("BasePart")
		local completedAt = completedDigPiles[instance]
		local recentlyDone = completedAt and os.clock() - completedAt < settings.TreasurePileCooldown

		if targetType and instance.Name == settings.DigPileName and not recentlyDone and isWorldObjectActive(instance) then
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
	local tool = findEquippedToolMatching({ "dig", "shovel", "spade", "trowel" })
		or findBackpackToolMatching({ "dig", "shovel", "spade", "trowel" })
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

local function getGuiColor(guiObject)
	if not guiObject:IsA("GuiObject") then
		return nil
	end

	local imageSuccess, imageTransparency = pcall(function()
		return guiObject.ImageTransparency
	end)

	if imageSuccess and imageTransparency < 0.95 then
		local colorSuccess, color = pcall(function()
			return guiObject.ImageColor3
		end)

		if colorSuccess then
			return color
		end
	end

	local backgroundSuccess, backgroundTransparency = pcall(function()
		return guiObject.BackgroundTransparency
	end)

	if not backgroundSuccess or backgroundTransparency < 0.95 then
		local colorSuccess, color = pcall(function()
			return guiObject.BackgroundColor3
		end)

		if colorSuccess then
			return color
		end
	end
end

local function isGreenGui(guiObject)
	local color = getGuiColor(guiObject)
	local size = guiObject.AbsoluteSize

	return color
		and color.G > 0.45
		and color.G > color.R * 1.25
		and color.G > color.B * 1.25
		and size.X > 4
		and size.Y > 4
end

local function isWhiteGui(guiObject)
	local color = getGuiColor(guiObject)
	local size = guiObject.AbsoluteSize

	return color
		and color.R > 0.82
		and color.G > 0.82
		and color.B > 0.82
		and size.X > 1
		and size.Y > 1
end

local function findTreasurePieces()
	local digEvent = getDigEventGui()
	if not digEvent or not digEvent:IsA("GuiObject") or not isGuiVisible(digEvent) then
		return nil, nil, nil
	end

	local greenBar
	local greenArea = 0
	local whiteLine
	local whiteScore = math.huge

	for _, guiObject in ipairs(digEvent:GetDescendants()) do
		if guiObject:IsA("GuiObject") and isGuiVisible(guiObject) then
			local size = guiObject.AbsoluteSize
			local area = size.X * size.Y

			if isGreenGui(guiObject) and area > greenArea then
				greenArea = area
				greenBar = guiObject
			end

			if isWhiteGui(guiObject) then
				local lowerName = string.lower(guiObject.Name)
				local thinness = math.min(size.X, size.Y)
				local bonus = string.find(lowerName, "line") and -10 or 0
				local score = thinness + bonus

				if score < whiteScore then
					whiteScore = score
					whiteLine = guiObject
				end
			end
		end
	end

	return digEvent, greenBar, whiteLine
end

local function lineInsideGreen(greenBar, whiteLine)
	if not greenBar or not whiteLine then
		return false
	end

	local greenPosition = greenBar.AbsolutePosition
	local greenSize = greenBar.AbsoluteSize
	local linePosition = whiteLine.AbsolutePosition
	local lineSize = whiteLine.AbsoluteSize
	local padding = 2

	local lineCenterX = linePosition.X + lineSize.X / 2
	local lineCenterY = linePosition.Y + lineSize.Y / 2

	local insideX = lineCenterX >= greenPosition.X - padding and lineCenterX <= greenPosition.X + greenSize.X + padding
	local insideY = lineCenterY >= greenPosition.Y - padding and lineCenterY <= greenPosition.Y + greenSize.Y + padding

	if lineSize.Y > lineSize.X then
		return insideX
	end

	return insideX and insideY
end

local function runTreasureMinigame()
	local sawUi = false
	local waitingStarted = os.clock()
	local clicks = 0

	while autoTreasure do
		local digEvent, greenBar, whiteLine = findTreasurePieces()

		if digEvent then
			sawUi = true

			if greenBar and whiteLine then
				if lineInsideGreen(greenBar, whiteLine) then
					clicks = clicks + 1
					setStatus("Treasure: keeping line green. Clicks: " .. clicks)
					activateDigTool()
					task.wait(settings.TreasureHitDelay)
				else
					task.wait(settings.TreasureLineCheckDelay)
				end
			else
				setStatus("Treasure: looking for green bar and white line.")
				task.wait(0.2)
			end
		elseif sawUi then
			setStatus("Treasure: pile finished.")
			return true
		elseif os.clock() - waitingStarted > settings.TreasureUiWaitTime then
			setStatus("Treasure: UI did not open, moving on.")
			return false
		else
			task.wait(0.1)
		end
	end

	return sawUi
end

local function doTreasureRun()
	local digPile = getNearestDigPile()
	if not digPile then
		setStatus("Treasure: waiting for DigPile in Workspace.Events.")
		return false
	end

	setStatus("Treasure: moving to DigPile.")
	teleportTo(digPile, 3)
	task.wait(settings.ActionDelay)

	local prompt = getNearestPrompt(digPile)
	if prompt then
		holdPrompt(prompt)
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

local function startTreasureFarm()
	if treasureLoopRunning then
		return
	end

	treasureLoopRunning = true

	task.spawn(function()
		while autoTreasure do
			doTreasureRun()
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
	return corner
end

local function createStroke(parent, color)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 1
	stroke.Transparency = 0.35
	stroke.Parent = parent
	return stroke
end

local tapButtons = {}

local function isGuiActuallyVisible(guiObject)
	local current = guiObject

	while current and current:IsA("GuiObject") do
		if not current.Visible then
			return false
		end

		current = current.Parent
	end

	return true
end

local function pointInsideGui(guiObject, point)
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	local padding = 10

	return point.X >= position.X - padding
		and point.X <= position.X + size.X + padding
		and point.Y >= position.Y - padding
		and point.Y <= position.Y + size.Y + padding
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
	button.Size = UDim2.new(1, 0, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(126, 47, 47)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 15
	button.AutoButtonColor = true
	button.Parent = parent

	createCorner(button, 7)
	createStroke(button, Color3.fromRGB(80, 85, 105))
	connectTap(button, callback)
	return button
end

local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart
	local startPosition

	dragHandle.InputBegan:Connect(function(input)
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
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

local existingGui = playerGui:FindFirstChild("kryptexHUBv2")
if existingGui then
	existingGui:Destroy()
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
	local isTap = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch

	if not isTap or not screenGui.Parent then
		return
	end

	local point = Vector2.new(input.Position.X, input.Position.Y)

	for index = #tapButtons, 1, -1 do
		local item = tapButtons[index]
		local button = item.Button

		if button
			and button.Parent
			and button:IsDescendantOf(screenGui)
			and isGuiActuallyVisible(button)
			and pointInsideGui(button, point) then
			item.Callback()
			return
		end
	end
end)

local isTouch = UserInputService.TouchEnabled
local hubWidth = isTouch and 280 or 310
local hubHeight = 280

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(hubWidth, hubHeight)
main.Position = isTouch and UDim2.fromOffset(18, 118) or UDim2.new(0, 30, 0.5, -hubHeight / 2)
main.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

createCorner(main, 8)
createStroke(main, Color3.fromRGB(95, 100, 130))

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
	updateToggleButtons()

	if autoUFO then
		setStatus("UFO started.")
		startUFOFarm()
	else
		setStatus("Stopping UFO.")
	end
end)

spookyButton = createButton(body, "Spooky: OFF", function()
	autoSpooky = not autoSpooky
	updateToggleButtons()

	if autoSpooky then
		setStatus("Spooky started.")
		startSpookyFarm()
	else
		setStatus("Stopping Spooky.")
	end
end)

treasureButton = createButton(body, "Treasure Hunt: OFF", function()
	autoTreasure = not autoTreasure
	updateToggleButtons()

	if autoTreasure then
		setStatus("Treasure Hunt started.")
		startTreasureFarm()
	else
		setStatus("Stopping Treasure Hunt.")
	end
end)

local minimized = false

connectTap(closeButton, function()
	autoUFO = false
	autoSpooky = false
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
updateToggleButtons()
