--Custom options
local blockMovement = false
local canAngle = true
local pixelsToMove = 15
local notesChar = {
    ['boyfriend'] = {''},
    ['dad'] = {''},
    ['gf'] = {'GF Sing','GF sings too'},
    ['extra'] = {'No Animation','Extra sings too'}
}

--This will get override so it doesn't matter if you change it
local timeToReset

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
    if blockMovement or d == nil or char == nil then
        cancelTimer('resetTargetOffset')
        onTimerCompleted('resetTargetOffset')
        return
    end
    timeToReset = stepCrochet * (0.0011 / getPropertyFromClass("flixel.FlxG", "sound.music.pitch")) * getProperty(char..".singDuration")
    if d == 0 or d == 3 then
        callMethod('camGame.targetOffset.set',{d == 3 and pixelsToMove or -pixelsToMove, 0})
        if canAngle then
            doTweenAngle('angleCamera','camGame', (d == 3 and pixelsToMove or -pixelsToMove) * 0.01, timeToReset, 'quintOut')
        end
    else
        callMethod('camGame.targetOffset.set',{0, d == 1 and pixelsToMove or -pixelsToMove})
        if canAngle then
            doTweenAngle('angleCamera','camGame',0, timeToReset, 'quintOut')
        end
    end
    runTimer('resetTargetOffset', timeToReset)
end

function onTimerCompleted(t)
    if t == 'resetTargetOffset' then
        setProperty('camGame.targetOffset.x', 0)
        setProperty('camGame.targetOffset.y', 0)
        if canAngle then
            doTweenAngle('angleCamera','camGame',0, timeToReset, 'quintOut')
        end
    end
end

function onEvent(n,v1,v2)
    if n == 'Block Camera Movement' then
        blockMovement = not blockMovement
    elseif n == 'Block Angle' then
        canAngle = not canAngle
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
            startTween('tweenDuet','game',{defaultCamZoom = getVar('duetCamera')[3] + 0.05}, v1, {ease = 'sineInOut', onUpdate = 'updateCamZoom'})
        else
            if getVar('duetCamera') == nil then
                setVar('duetCamera', {(getMidpointX("boyfriend") - getMidpointX('dad')) / 2 , 400, getProperty('defaultCamZoom') - 0.05})
            end
            callMethod('camFollow.setPosition',{getVar('duetCamera')[1], getVar('duetCamera')[2]})
            startTween('tweenDuet','game',{defaultCamZoom = getVar('duetCamera')[3]}, v1, {ease = 'sineInOut', onUpdate = 'updateCamZoom'})
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