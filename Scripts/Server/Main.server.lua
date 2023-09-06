local ServerScriptService = game:GetService("ServerScriptService")

local Cell = require(ServerScriptService.Modules.Cell)

local Field = Instance.new('Folder')
Field.Parent = workspace

local VALUE = 10

-- for x = 1, VALUE do
--     for z = 1, VALUE do
--         local cell = Cell.new(x, z)
--         local object = cell:CreateObject(Field)
--         cell:SetupObject(object, x, z)
--     end
-- end


Cell:Init()
Cell:RandomizeMines()