local context = require("scripts.core.context")

-- main.lua fica propositalmente pequeno: ele limpa o contexto compartilhado do
-- mod e carrega os modulos na ordem em que suas dependencias sao usadas.
for key in pairs(context) do
    context[key] = nil
end

local modules = {
    "scripts.effects.active_effects",            -- IDs e calculos dos efeitos enquanto o label esta ativo.
    "scripts.effects.death_effects",             -- IDs e calculos dos efeitos tocados quando o label morre.
    "scripts.effects.intro_effects",             -- IDs e calculos dos efeitos de entrada dos bosses.
    "scripts.effects.champion_label_styles",     -- Paleta/efeitos tematicos usados por champions.
    "scripts.entities.names",                    -- Fallback local para nomes vanilla de entidades.

    "scripts.core.constants",                  -- Nome/versao, enums e constantes compartilhadas.
    "scripts.core.bootstrap",                  -- Registro do mod, handles do Isaac, json e fonte.
    "scripts.core.config",                     -- Config padrao, resets e helpers derivados da config.
    "scripts.core.state",                      -- Estado runtime nao salvo e limpeza de labels.
    "scripts.core.mcm_bridge",                 -- Resolucao opcional do Mod Config Menu.
    "scripts.entities.name_registry",          -- Carrega fallback local de nomes vanilla.
    "scripts.core.save_load",                  -- Save/load apenas da config persistente.

    "scripts.core.util",                       -- Utilitarios pequenos compartilhados.
    "scripts.entities.safe",                   -- Leituras seguras e filtros de entidades.
    "scripts.entities.name_resolver",          -- Resolucao de nomes via XMLData, fallback e EntityConfig.
    "scripts.render.label_settings",           -- Config concreta para owner boss/enemy.
    "scripts.render.label_format",             -- Prefixos e descriptors de champion no texto final.
    "scripts.preview.names",                   -- Pool e randomizacao dos nomes mostrados no MCM.
    "scripts.render.positioning",              -- Conversao de posicoes fixed/world/preview para tela.
    "scripts.render.effect_values",            -- Valores de active/death effects, hit preview, shake e intro.
    "scripts.render.colors",                   -- Cores configuradas, HP color, alpha, tint e hit flash.
    "scripts.render.champion_styles",          -- Identificacao e aplicacao visual dos champion labels.
    "scripts.render.text_draw",                -- Primitivas de desenho de texto e efeitos por letra.
    "scripts.render.draw_effects",             -- Desenho por letra: rainbow, wave, dissolve e slash.
    "scripts.render.preview_reference",        -- Referencia do player nos previews above/below.
    "scripts.render.active_labels",            -- Criacao e desenho comum dos labels ativos.
    "scripts.render.death_labels",             -- Spawn, desenho e limpeza dos labels de morte.
    "scripts.render.champion_preview",         -- Preview rotativo dos champion styles no MCM.
    "scripts.render.info_showcase",            -- Vitrine fixed da aba Info do MCM.
    "scripts.mcm.labels_offsets",              -- Labels de opcoes e getters/setters de offsets no MCM.

    "scripts.entities.enemy_tracker",          -- Label temporario do inimigo comum atingido.
    "scripts.entities.room_state",             -- Limpeza de estado ao trocar de sala.
    "scripts.entities.boss_tracker",           -- Rastreamento, agrupamento e morte de bosses.
    "scripts.entities.damage",                 -- Callback de dano, hits, shake e selecao de labels.
    "scripts.preview.state",                   -- Expiracao e limpeza dos previews do MCM.

    "scripts.render.boss_stack",               -- Stack fixed, overflow e slots reservados de boss.
    "scripts.render.boss_preview",             -- Previews de boss, spacing e collapse no MCM.
    "scripts.render.boss",                     -- Render real dos boss labels em combate.
    "scripts.render.enemy",                    -- Render do inimigo rastreado e preview de enemy.
    "scripts.mcm.helpers",                     -- Helpers reutilizaveis para criar opcoes do MCM.
    "scripts.mcm.info",                        -- Aba Info do Mod Config Menu.
    "scripts.mcm.general",                     -- Aba General do Mod Config Menu.
    "scripts.mcm.boss",                        -- Aba Boss do Mod Config Menu.
    "scripts.mcm.enemy",                       -- Aba Enemy do Mod Config Menu.
    "scripts.mcm.index",                       -- Registro final e fallback do Mod Config Menu.
    "scripts.core.callbacks"                   -- Ligacao final com callbacks do Isaac.
}

for _, moduleName in ipairs(modules) do
    if package and package.loaded then
        package.loaded[moduleName] = nil
    end

    require(moduleName)
end
