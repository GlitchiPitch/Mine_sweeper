--[[
	build a lobby and game place where mine field will be created
	delete all generate functions and add those object into workspace like modls etc.
		-- 103 line
		-- 170 line

	add restart function
		-- clear tables and destroy objects
]]
-- export type Mine: {
-- 	mineCandidatePrompt: ProximityPrompt,
-- 	openPrompt: ProximityPrompt,
-- }
local serverScriptService = game:GetService("ServerScriptService")
local configs = require(serverScriptService.Modules.Configs)
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

local Cell = {}
Cell.__index = Cell

function Cell.new(x, z, obj: BasePart)
	local self = setmetatable({}, Cell)
	self.object = obj
	self.isMine = obj.IsMine :: BoolValue
	self.isOpened = obj.IsOpened :: BoolValue
	self.isMineCandidate = obj.IsMineCandidate :: BoolValue
	self.gui = obj.Surface :: SurfaceGui

	self.x = x
	self.z = z

	return self
end

function Cell:init(field: Folder, allCells: {})
	self.object.Parent = field
	self.object.Position = Vector3.new(self.x * self.object.Size.X, 5, self.z * self.object.Size.Z)

	local mineCandidate: ProximityPrompt = self.object.MineCandidate.ProximityPrompt
	local open: ProximityPrompt = self.object.Open.ProximityPrompt

	self.isMineCandidate.Changed:Connect(function(value: boolean)
		local mineCandidateImage: ImageLabel = self.gui.MineCandidate
		mineCandidateImage.Visible = value
		self.object.BrickColor = value and configs.candidateMineColor or configs.defaultColor
	end)

	self.isOpened.Changed:Connect(function(value: boolean)
		if value then

			mineCandidate.Enabled = false
			open.Enabled = false

			self.object.BrickColor = configs.openedColor
			local surroundedMines = 0
			for _, cellIndex in surroundedCellIndexies do
				local cell = getCellByAxis(allCells, self.x + cellIndex[1], self.z + cellIndex[2])
				if cell and cell.isMine.Value then
					surroundedMines += 1
				end
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
		self:mineCandidateAction()
	end)

	open.Triggered:Connect(function()
		if self.isMine.Value then
			self:mineAction()
		else
			self:openAction()
		end
	end)
end

function Cell:mineAction()
	createExplosion(self.object)
	self.object.BrickColor = configs.mineColor
	local mineImage: ImageLabel = self.gui.Mine
	mineImage.Visible = true
	-- reload
end

function Cell:mineCandidateAction()
	self.isMineCandidate.Value = not self.isMineCandidate.Value
end

function Cell:openAction()
	self.isOpened.Value = true
end

-- add surface gui into mine template
function Cell:showSurroundedGui(text)
	local textLabel: TextLabel = self.gui.Count
	textLabel.Visible = true
	textLabel.Text = text

end

return Cell
