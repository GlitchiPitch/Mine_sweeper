local serverScriptService = game:GetService("ServerScriptService")
local config = require(serverScriptService.Modules.Config)
local surroundedCellIndexies = {
	{ -1, -1 },
	{ -1, 0 },
	{ -1, 1 },
	{ 0, -1 },
	{ 1, -1 },
	{ 1, 0 },
	{ 1, 1 },
	{ 0, 1 },
}

local data: {
	field: Folder,
	mineTemp: Part & {
		MineCandidate: ProximityPrompt,
		Open: ProximityPrompt,
	},
	fieldSpawnPoint: Part,
}

local allCells = {}
local level = 0
local startPoint: Vector3

function createExplosion(object: BasePart)
	local exploison = Instance.new("Explosion")
	exploison.BlastRadius = 500
	exploison.BlastPressure = 500
	exploison.Parent = workspace
	exploison.Position = object.Position
end

function getCellByAxis(allCells, x, z)
	for _, cell in pairs(allCells) do
		if cell.x == x and cell.z == z then
			return cell
		end
	end
end

function checkWin()
	for i, cell in allCells do
		if (not cell.isOpened.Value and not cell.isMine.Value) or (cell.isMine.Value and not cell.isMineCandidate.Value) then
			return false
		end
	end
	return true
end

local Cell = {}; Cell.__index = Cell

function Cell.new(x, z)
	local self = setmetatable({}, Cell)
	
	self.object = data.mineTemp:Clone()
	self.isMine = self.object.IsMine :: BoolValue
	self.isOpened = self.object.IsOpened :: BoolValue
	self.isMineCandidate = self.object.IsMineCandidate :: BoolValue
	self.gui = self.object.Surface :: SurfaceGui

	self.x = x
	self.z = z

	return self
end

function Cell:init()
	self.object.BrickColor = BrickColor.new("Medium green")
	self.object.Parent = data.field
	self.object.Position = Vector3.new(self.x * self.object.Size.X, 0, self.z * self.object.Size.Z) + startPoint

	local mineCandidate: ProximityPrompt = self.object.MineCandidate.ProximityPrompt
	local open: ProximityPrompt = self.object.Open.ProximityPrompt

	self.isMineCandidate.Changed:Connect(function(value: boolean)
		local mineCandidateImage: ImageLabel = self.gui.MineCandidate
		mineCandidateImage.Visible = value
		self.object.BrickColor = value and config.candidateMineColor or config.defaultColor
	end)

	self.isOpened.Changed:Connect(function(value: boolean)
		if value then

			mineCandidate.Enabled = false
			open.Enabled = false

			self.object.BrickColor = config.openedColor
			local surroundedMines = 0
			for _, cellIndex in surroundedCellIndexies do
				local cell = getCellByAxis(allCells, self.x + cellIndex[1], self.z + cellIndex[2])
				if cell and cell.isMine.Value then surroundedMines += 1 end
			end

			if surroundedMines == 0 then
				for _, cellIndex in surroundedCellIndexies do
					local cell = getCellByAxis(allCells, self.x + cellIndex[1], self.z + cellIndex[2])
					if cell then
						cell.isOpened.Value = true
					end
				end
			end

			self:showSurroundedGui(surroundedMines)
		end
	end)

	mineCandidate.Triggered:Connect(function()
		self.isMineCandidate.Value = not self.isMineCandidate.Value
	end)

	open.Triggered:Connect(function()
		if self.isMine.Value then
			createExplosion(self.object)
			self.object.BrickColor = config.mineColor
			local mineImage: ImageLabel = self.gui.Mine
			mineImage.Visible = true

			task.wait(5)
			createField(false)
		else
			self.isOpened.Value = true
			if checkWin() then
				createField(true)
			end
		end
	end)
end

-- add surface gui into mine template
function Cell:showSurroundedGui(text)
	local textLabel: TextLabel = self.gui.Count
	textLabel.Visible = true
	textLabel.Text = text
end

function createField(upgrade: boolean)

	for i, player in game.Players:GetPlayers() do
		player:LoadCharacter()
		local leaderstats = player:FindFirstChild('leaderstats')
		if upgrade == true then
			local wins = leaderstats:FindFirstChild('Wins') :: IntValue
			wins.Value += 1
		elseif upgrade == false then
			local losses = leaderstats:FindFirstChild('Losses') :: IntValue
			losses.Value += 1
		end
	end

	data.field:ClearAllChildren()
	allCells = {}
	
    local fs = 10 + level
	local mineCount = math.floor(fs ^ 2 / 3)

	startPoint = Vector3.new(-(fs * data.mineTemp.Size.X / 2),0,-(fs * data.mineTemp.Size.Z / 2))
    for x = 1, fs do
        for z = 1, fs do
            table.insert(allCells, Cell.new(x, z))
        end
    end
    
    -- setup cells
    for i, cell in allCells do
		cell:init(data.field, allCells)
    end
    
    -- randomize mines
    for i = 1, mineCount do
        local index = math.random(#allCells)
        allCells[index].isMine.Value = true
		allCells[index].object.BrickColor = BrickColor.Red()
	end

	level += upgrade and 1 or 0
	if level > 20 then
		level = 0
	end
end

function init(data_)
	data = data_
end

return {
	init = init,
	createField = createField,
}
