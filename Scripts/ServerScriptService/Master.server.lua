local serverScriptService = game:GetService("ServerScriptService")
local serverStorage = game:GetService("ServerStorage")

local modules = serverScriptService.Modules

local cell = require(modules.Cell)
local config = require(modules.Configs)
local field = workspace.Mines
local mineTemp = serverStorage.Mine

local allCells = {}

function getCells() return allCells end

function createField()
    for x = 1, config.fieldSize do
        for z = 1, config.fieldSize do
            table.insert(allCells, cell.new(x, z, mineTemp:Clone()))
        end
    end
end

function setupCells()
    for i, cell in allCells do
		cell:init(field, allCells)
    end
end

function randomizeMines()
	for i = 1, config.mineCount do
        local index = math.random(#allCells)
        allCells[index].isMine.Value = true
        allCells[index].object.BrickColor = config.mineColor
	end
end

createField()
setupCells()
randomizeMines()
