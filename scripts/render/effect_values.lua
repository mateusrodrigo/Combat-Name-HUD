local CNH = require("scripts.core.context")
local _ENV = CNH

-- Valores temporais de efeitos: efeito ativo, shake, hit preview, HP preview,
-- boss intro e valores de death effect.
function applyActiveEffect(baseScale, effectMode, championStyle, variationSeed, effectFrames)
    return ActiveEffects.apply(baseScale, effectMode, championStyle, game:GetFrameCount(), variationSeed, effectFrames)
end

function getShakeOffset(enabled, untilFrame, strength)
    -- Shake is reactive feedback when a tracked boss/enemy damages the player.
    if not enabled then return 0, 0 end
    if game:GetFrameCount() > untilFrame then return 0, 0 end

    return math.random(-strength, strength), math.random(-strength, strength)
end

function getHitProgress(untilFrame)
    if untilFrame == nil or untilFrame <= 0 then return 0 end

    local remaining = untilFrame - game:GetFrameCount()
    if remaining <= 0 then return 0 end

    return clamp(remaining / math.max(config.hitEffectFrames, 1), 0, 1)
end

function isHitFeedbackEnabled()
    return config.showHitFlash or config.showHitPunch
end

function getLoopedHitPreviewUntilFrame()
    if not isHitFeedbackEnabled() then return nil end

    local frame = game:GetFrameCount()
    local duration = math.max(config.hitEffectFrames, 1)
    local pause = math.max(12, duration)
    local startFrame = state.previewEffectStartFrame

    if startFrame == nil or startFrame < 0 then
        startFrame = frame
        state.previewEffectStartFrame = frame
    end

    local cycleFrame = (frame - startFrame) % (duration + pause)
    if cycleFrame >= duration then return nil end

    return frame + (duration - cycleFrame)
end

function getLoopedHpPreviewColor()
    local frame = game:GetFrameCount()
    local startFrame = state.previewEffectStartFrame

    if startFrame == nil or startFrame < 0 then
        startFrame = frame
        state.previewEffectStartFrame = frame
    end

    local cycleFrame = (frame - startFrame) % 90

    if cycleFrame < 30 then
        return KColor(0.65, 1, 0.45, 1)
    end

    if cycleFrame < 60 then
        return KColor(1, 0.85, 0.25, 1)
    end

    return KColor(1, 0.25, 0.2, 1)
end

function getLoopedBossIntroPreviewStartFrame()
    if config.bossIntroEffectMode == BOSS_INTRO_EFFECT.DISABLED then return nil end

    local frame = game:GetFrameCount()
    local duration = math.max(config.bossIntroEffectFrames, 1)
    local pause = math.max(18, math.floor(duration * 0.75))
    local startFrame = state.previewEffectStartFrame

    if startFrame == nil or startFrame < 0 then
        startFrame = frame
        state.previewEffectStartFrame = frame
    end

    local cycleFrame = (frame - startFrame) % (duration + pause)
    if cycleFrame >= duration then return nil end

    return frame - cycleFrame
end

function getBossIntroValues(owner, introStartFrame, variationSeed)
    if owner ~= LABEL_OWNER.BOSS then return 1, 0, 0, 1 end
    if config.bossIntroEffectMode == BOSS_INTRO_EFFECT.DISABLED then return 1, 0, 0, 1 end
    if introStartFrame == nil or introStartFrame <= 0 then return 1, 0, 0, 1 end

    local elapsed = game:GetFrameCount() - introStartFrame
    local duration = math.max(config.bossIntroEffectFrames, 1)

    return IntroEffects.getValues(config.bossIntroEffectMode, elapsed, duration, variationSeed)
end

function getDeathEffectValues(label)
    return DeathEffects.getValues(label, game:GetFrameCount())
end
