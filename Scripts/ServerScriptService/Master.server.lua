local serverScriptService = game:GetService("ServerScriptService")
local serverStorage = game:GetService("ServerStorage")

local modules = serverScriptService.Modules

local mineSweeper = require(modules.MineSweeper)
local config = require(modules.Config)
local field: Folder = workspace.Mines
local mineTemp: Part = serverStorage.Mine
local fieldSpawnPoint = workspace.FieldSpawnPoint

function init()
    mineTemp.BrickColor = config.defaultColor
    mineSweeper.init({
        field = field,
        mineTemp = mineTemp,
        fieldSpawnPoint = fieldSpawnPoint,
    })
    mineSweeper.createField()
end

init()
