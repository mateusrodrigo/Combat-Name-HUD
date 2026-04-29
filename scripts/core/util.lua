local CNH = require("scripts.core.context")
local _ENV = CNH

-- Utilitarios pequenos compartilhados por varios modulos.
function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end
