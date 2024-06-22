--[[
	build a lobby and game place where mine field will be created
	delete all generate functions and add those object into workspace like modls etc.
		-- 103 line
		-- 170 line

	add restart function
		-- clear tables and destroy objects
]]


local CELL_COUNT = 10
local MINES_COUNT = 10

local VALUE = 10

local Field = Instance.new('Folder')
Field.Parent = workspace

local CANDIDATE_MINE_COLOR = Color3.new(0.9, 0.9, 0.05)
local DEFAULT_COLOR = Color3.new(0.07, 0.8, 0.4)

local CELL_SIZE = Vector3.new(10, 1, 10)

local Cell = {}

Cell.__index = Cell

Cell.All = {}

function Cell.new(x, z)
	local self = setmetatable({}, Cell)
	self.IsMine = false
	self.IsOpened = false
	self.IsMineCandidate = false
	self.CellObject = nil

	self.x = x
	self.z = z

	self.CellCount = CELL_COUNT

	table.insert(Cell.All, self)
	return self
end

function Cell:Init() 
    for x = 1, VALUE do
        for z = 1, VALUE do
            local cell = self.new(x, z)
            local object = cell:CreateObject(Field)
            cell:SetupObject(object, x, z)
        end
    end
end

function Cell:CreateObject(Parent)
	local p = Instance.new("Part")
	p.Anchored = true
    p.Color = DEFAULT_COLOR
	p.Parent = Parent
	p.Size = CELL_SIZE

	self:CreatePrompts(p)
	self.CellObject = p
	return p
end

function Cell:GetCellByAxis(x, z)
	for _, cell in pairs(Cell.All) do
		if cell.x == x and cell.z == z then
			return cell
		end
	end
end

function Cell:SurroundedCells()

	local cells = {
		self:GetCellByAxis(self.x - 1, self.z - 1),
		self:GetCellByAxis(self.x - 1, self.z),
		self:GetCellByAxis(self.x - 1, self.z + 1),
		self:GetCellByAxis(self.x, self.z - 1),
		self:GetCellByAxis(self.x + 1, self.z - 1),
		self:GetCellByAxis(self.x + 1, self.z),
		self:GetCellByAxis(self.x + 1, self.z + 1),
		self:GetCellByAxis(self.x, self.z + 1),
	}

    local finalCells = {}

	for _, cell in pairs(cells) do
		if cell then
			table.insert(finalCells, cell)
		end
	end
	return finalCells
end

function Cell:SurroundedMines()
	local counter = 0
	for _, cell in pairs(self:SurroundedCells()) do
		if cell.IsMine then counter += 1 end
	end
    return counter
end

-- this function remake to getPromptsFromCloneTemplate
function Cell:CreatePrompts(part)
	local mineCanAtt = Instance.new("Attachment")
	mineCanAtt.Parent = part
	mineCanAtt.CFrame = CFrame.new(1, 2, 0)
	local openAtt = Instance.new("Attachment")
	openAtt.Parent = part
	openAtt.CFrame = CFrame.new(-1, 2, 0)

	local mineCandidate = Instance.new("ProximityPrompt")
	mineCandidate.Parent = mineCanAtt
	mineCandidate.KeyboardKeyCode = Enum.KeyCode.M
	mineCandidate.ActionText = ""
    mineCandidate.MaxActivationDistance = 10
	mineCandidate.Triggered:Connect(function()
		self:MineCandidateAction()
	end)

	local open = Instance.new("ProximityPrompt")
	open.Parent = openAtt
	open.KeyboardKeyCode = Enum.KeyCode.N
	open.ActionText = ""
    open.MaxActivationDistance = 10
	open.Triggered:Connect(function()
		if self.IsMine then
			self:MineAction()
		else
			self:OpenAction()
		end
	end)
end

function Cell:MineAction()
	local exploison = Instance.new("Explosion")
	exploison.BlastRadius = 500
	exploison.BlastPressure = 500
	exploison.Parent = workspace
	exploison.Position = self.CellObject.Position

    self.CellObject.Color = Color3.new(1, 0, 0)

    -- reload 
end

function Cell:MineCandidateAction() 
    if not self.IsMineCandidate then
        self.CellObject.Color = CANDIDATE_MINE_COLOR
        self.IsMineCandidate = true
    else
        self.CellObject.Color = DEFAULT_COLOR
        self.IsMineCandidate = false
    end
end

function Cell:OpenAction()
	if not self.IsOpened then
		self.CellCount -= 1
        local text = self:SurroundedMines()
		self:ShowSurroundedGui(text)
	end
	self.IsOpened = true
end

-- remake this function to get from clone template
function Cell:ShowSurroundedGui(text)
	local gui = Instance.new("BillboardGui")
	gui.Parent = self.CellObject
	gui.Size = UDim2.fromScale(8, 8)
    gui.MaxDistance = 100

	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = gui
	textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.Text = text
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 1

	local tween = game:GetService("TweenService")
		:Create(gui, TweenInfo.new(2), { StudsOffsetWorldSpace = Vector3.new(0, 10, 0) })
	tween:Play()
end

function Cell:SetupObject(part, x, z)
	part.Position = Vector3.new(x * CELL_SIZE.X, 5, z * CELL_SIZE.Z)
end

function Cell:RandomizeMines()
	local allCells = table.clone(Cell.All)
	local pickedCells = {}

	for i = 1, MINES_COUNT do
        local index = math.random(#allCells)
		local currCell = allCells[index]
		table.remove(allCells, table.find(allCells, currCell, 1))
		table.insert(pickedCells, index)
	end

	for _, pickedCell in pairs(pickedCells) do
        Cell.All[pickedCell].IsMine = true
		-- Cell.All[pickedCell].CellObject.Color = Color3.new(1, 0, 0)
	end
end

return Cell
