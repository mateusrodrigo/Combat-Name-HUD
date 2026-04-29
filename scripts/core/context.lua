-- Contexto compartilhado do Combat Name HUD. Os modulos escrevem aqui para
-- manter compatibilidade com o estilo antigo do main.lua sem concentrar tudo em
-- um unico arquivo gigante.
local context = rawget(_G, "CombatNameHUDContext")

if context == nil then
    context = {}
    setmetatable(context, { __index = _G })
    rawset(_G, "CombatNameHUDContext", context)
end

return context
