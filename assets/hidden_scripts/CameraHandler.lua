--Custom options
local blockMovement = false
local canAngle = false
local pixelsToMove = 15

local notesChar = {
    ['boyfriend'] = {''},
    ['dad'] = {''},
    ['gf'] = {'GF Sing','GF sings too'},
    ['extra'] = {'No Animation','Extra sings too'}
}

--This gets overriden so it doesn't matter if you change it
local timeToReset

--Do not change unless you know what you're doing
setVar('blockMovement', blockMovement)
setVar('canAngle', canAngle)

function onStartCountdown()
    setVar('duetCamera', {(getMidpointX("boyfriend") - getMidpointX('dad')) / 2 , getMidpointY('dad'), getProperty('defaultCamZoom') - 0.05})
end

function goodNoteHit(i, d, t, s)
    moveTargetOffset(i, d, t)
end

function opponentNoteHit(i, d, t, s)
    moveTargetOffset(i, d, t)
end

function moveTargetOffset(i, d, t)
    local char = isCompatibleCharacter(t)
    if getProperty('notes.members['..i..'].gfNote') then
        char = 'gf'
    end
    if getVar('blockMovement') or d == nil or char == nil then
        cancelTimer('resetTargetOffset')
        onTimerCompleted('resetTargetOffset')
        return
    end
    timeToReset = stepCrochet * (0.0011 / getPropertyFromClass("flixel.FlxG", "sound.music.pitch")) * getProperty(char..".singDuration")
    local moveX, moveY = 0, 0
    if d == 0 or d == 3 then
        moveX = d == 3 and pixelsToMove or -pixelsToMove
    else
        moveY = d == 1 and pixelsToMove or -pixelsToMove
    end
    callMethod('camGame.targetOffset.set',{moveX, moveY})
    if canAngle then
        doTweenAngle('angleCamera','camGame',moveX * 0.01, timeToReset, 'quintOut')
    end
    runTimer('resetTargetOffset', timeToReset)
end

function onTimerCompleted(t)
    if t == 'resetTargetOffset' then
        callMethod('camGame.targetOffset.set',{0, 0})
        if canAngle then
            doTweenAngle('angleCamera','camGame',0, timeToReset, 'quintOut')
        end
    end
end

function onEvent(n,v1,v2)
    if n == 'Block Camera Movement' then
        setVar('blockMovement', not getVar('blockMovement'))
    elseif n == 'Block Angle' then
        setVar('canAngle', not getVar('canAngle'))
    elseif n == 'Duet Section' then
        if not getProperty('camZooming') then
            setProperty('camZooming', true)
        end
        if v1 == '' or v1 == nil then
            v1 = 0.1        
        end
        if getProperty('isCameraOnForcedPos') then
            local destination = mustHitSection and 'boyfriend' or 'dad'
            if gfSection then
                destination = 'gf'
            end
            cameraSetTarget(destination)
            startTween('tweenDuet','game',{defaultCamZoom = getVar('duetCamera')[3] + 0.05}, v1, {ease = 'quintInOut', onUpdate = 'updateCamZoom'})
        else
            callMethod('camFollow.setPosition',{getVar('duetCamera')[1], getVar('duetCamera')[2]})
            startTween('tweenDuet','game',{defaultCamZoom = getVar('duetCamera')[3]}, v1, {ease = 'quintInOut', onUpdate = 'updateCamZoom'})
        end
        if v2 ~= nil and v2 ~= '' then
            cancelTween('tweenDuet')
            local finalZoom = getVar('duetCamera')[3]
            if getProperty('isCameraOnForcedPos') then
                finalZoom = finalZoom + 0.05
            end
            setProperty('defaultCamZoom', finalZoom)
            callMethod('camGame.snapToTarget',{''})
        end
        setProperty('isCameraOnForcedPos', not getProperty('isCameraOnForcedPos'))
    end
end

function findBannedNote(t)
    for i,v in ipairs(banNotes) do
        if v == t then
            return true
        end
    end
    return false
end

function isCompatibleCharacter(t)
    for char, noteTypes in pairs(notesChar) do
        if getProperty(char..'.isPlayer') ~= nil then
            for _, finalType in ipairs(noteTypes) do
                if finalType == t and mustHitSection == getProperty(char..'.isPlayer') then
                    return char
                end
            end
        end
    end
    return nil
end

function updateCamZoom()
    setProperty('camGame.zoom', getProperty('defaultCamZoom'))
end