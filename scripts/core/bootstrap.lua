local CNH = require("scripts.core.context")
local _ENV = CNH

-- Inicializacao minima do Isaac: registra o mod, cria handles globais de jogo,
-- json e fonte. O resto do estado/config fica em modulos proprios.
CombatNameHUD = RegisterMod(MOD_NAME, 1)


game = Game()
json = require("json")
font = Font()

font:Load("font/pftempestasevencondensed.fnt")
