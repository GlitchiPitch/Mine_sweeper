local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local modules = ServerScriptService.Modules

local cell = require(modules.Cell)
local config = require(modules.Configs)
local field = workspace.Mines
local mineTemp = ServerStorage.Mine

local allCells = {}

function createField()
    for x = 1, config.fieldSize do
        for z = 1, config.fieldSize do
            table.insert(allCells, cell.new(x, z))
        end
    end
end

function randomizeMines()
	for i = 1, config.mine_count do
        local index = math.random(#allCells)
        allCells[index].isMine = true
	end
end

-- Cell:Init()
-- Cell:RandomizeMines()