local CNH = require("scripts.core.context")
local _ENV = CNH

-- Carrega a tabela local de nomes vanilla para uso pelos helpers de entidade.
-- Ela serve como fallback quando XMLData/REPENTOGON nao estao disponiveis.

builtInEntityNames = {}
local builtInNamesLoaded, builtInNames = pcall(require, "scripts.entities.names")
if builtInNamesLoaded and type(builtInNames) == "table" then
    builtInEntityNames = builtInNames
end