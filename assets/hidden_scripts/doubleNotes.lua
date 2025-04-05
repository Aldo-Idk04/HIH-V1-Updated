--Vars for the script is not recommended to get changed
local ghostsCreated = 0

--Global settings it affects all the characters
local cancelFrame = false --Is gonna froze on the first frame of ghost's animation
local cancelFade = true --if true, the fade will be cancelled if the ghost is still visible
local moveTo = 300 --The distance the ghost will move
local scaleTo = 1.1 --Multiplier of ghost's scale
local forcedColors = false --Colors will be forced to the ones in directionColor (it will override healthColor and noteColor)
local alphaGhost = 0.6 --Alpha of the ghost
local alphaCancelMult = 0.7 -- Percent of the alpha of the alphaGhost to cancel the fade
local tweensDuration = 
{
    scale = 0.4,
    move = 0.4,
    alpha = 0.4
}
local tweensType = 
{
    scale = 'CircIn', 
    move = 'expoOut',
    alpha = 'linear'
}

--[[
    Custom settings for the characters it can be changed (except info, don't change that)
    You can add your own characters just respect the keys (mom is a template and extra too)
    Explanation of the keys:
    - info: The info of the character (name, description, etc) [Don't change it]
    - notes: The notes that the character will react to
    - effects: The effects that the character will react to
        - healthColor: The ghost will have the health color of the character
        - noteColor: The ghost will have the note color (rgbColors has to be enabled)
        - solidColor: The ghost will have a solid color
        - moveGhost: The ghost will move
        - instantMove: The ghost will move instantly
        - scaleGhost: The ghost will scale
        - instantScale: The ghost will scale instantly
        - enabled: The ghost will be enabled
--]]

local chars = {
    ['boyfriend'] = 
    {        
        side = true,
        ['info'] = {},
        ['notes'] = 
        {
            '',
            'GF sings too',
            'Extra sings too',
            'P1'
        }, 
        ['effects'] = 
        {
            healthColor = true,
            noteColor = false,
            solidColor = false,
            moveGhost = false,
            instantMove = false,
            comeChar = false,
            scaleGhost = false,
            instantScale = false,
            enabled = true
        }
    },
    ['dad'] = 
    {
            side = false,
            ['info'] = {},
            ['notes'] = 
            {
                '',
                'GF sings too',
                'Extra sings too',
                'P2'
            }, 
            ['effects'] =         
            {
                healthColor = true,
                noteColor = false,
                solidColor = false,
                moveGhost = false,
                instantMove = false,
                comeChar = false,
                scaleGhost = false,
                instantScale = false,
                enabled = true
            }
    },
    ['gf'] = 
    {
        side = '',
        ['info'] = {},
        ['notes'] = 
        {
            'GF Sing',
            'GF sings too',
            'Extra sings too'
        }, 
        ['effects'] = 
        {
            healthColor = true,
            noteColor = false,
            solidColor = false,
            moveGhost = false,
            instantMove = false,
            comeChar = false,
            scaleGhost = false,
            instantScale = false,
            enabled = true
        }
    },
    ['extra'] = {
        side = '',
        ['info'] = {},
        ['notes'] = {
            'No Animation',
            'Extra sings too',
            '3rd Player'
        }, 
        ['effects'] = 
        {
            healthColor = true,
            noteColor = false,
            solidColor = false,
            moveGhost = false,
            instantMove = false,
            comeChar = false,
            scaleGhost = false,
            instantScale = false,
            enabled = true
        }
    },
    ['mom'] = {
        side = '',
        ['info'] = {},
        ['notes'] = 
        {
            'noteName',
            'noteName2',
        },
        ['effects'] = 
        {
            healthColor = true,
            noteColor = false,
            solidColor = false,
            moveGhost = false,
            instantMove = false,
            comeChar = false,
            scaleGhost = false,
            instantScale = false,
            enabled = true
        }
    }
}

--[[
    This will override noteColor and healthColor on case forcedColors is true it affects all the characters

    The colors are in RGB format

    Keys of the directions
        0 is Left Arrow
        1 is Down Arrow
        2 is Up Arrow
        3 is Right Arrow
--]]
local directionColor =
{
    [0] = {255,255,0},
    [1] = {0,255,0},
    [2] = {0,0,255},
    [3] = {255,0,0}
}

--Don't change anything from this part, unless you know what are you doing (which i hope, you do)

local eventsNames = 
{
    'Change Scale Ghost',
    'Change Move Ghost',
    'Toggle Cancel Ghost Frame',
    'Toggle Cancel Ghost Fade',
    'Toggle Forced Colors For Ghost',
    'Toggle HealthColor Ghost',
    'Toggle Solid Color Ghost',
    'Toggle Move Ghost',
    'Toggle Scale Ghost',
    'Toggle Ghost For One',
    'Toggle Instant Ghost Move',
    'Toggle Instant Ghost Scale',
    'Toggle Note Colors For Ghost',
    'Toggle Ghost For All',
}

local curPath = currentModDirectory..'/custom_events/'
if currentModDirectory == nil then
    curPath = 'custom_events/'
end

for _,events in ipairs(eventsNames) do
    if not checkFileExists(curPath..events..'.txt') then
        if _ < 3 then
            saveFile(curPath..events..".txt", 'The new value of the respective effect')
        elseif _ > 5 then
            saveFile(curPath..events..".txt", 'Is gonna toggle the opposite\nvalue 1 is the character that is gonna be affected')
        else
            saveFile(curPath..events..".txt", 'Is gonna toggle the opposite')
        end
    end
end

function goodNoteHit(i,d,t,s)
    handleNoteHit(i,d,t,s,true)
end

function opponentNoteHit(i,d,t,s)
    handleNoteHit(i,d,t,s,false)
end

function handleNoteHit(i,d,t,s,mt)
    local validChars = {}
    for charName, charData in pairs(chars) do
        local side = charData.side
        local isGFNote = getPropertyFromGroup("notes", i, 'gfNote')
        local shouldProcess = (side == mt or side == '')
        local finalType = t
        for _, gType in ipairs(charData['notes']) do
            if shouldProcess and (finalType == gType and not isGFNote or isGFNote and charName == 'gf') then
                table.insert(validChars, {charName = charName, charData = charData})
                break
            end
        end
    end
    if #validChars == 0 then
        return
    end

    for _, char in ipairs(validChars) do
        local charName = char.charName
        local charData = char.charData
        local shouldMakeGhost = (charData['info'][1] == getPropertyFromGroup("notes", i, 'strumTime'))
        local finalType = t
        for _, gType in ipairs(charData['notes']) do
            if not s then 
                if (finalType == gType and not getPropertyFromGroup("notes", i, 'gfNote') or getPropertyFromGroup("notes", i, 'gfNote') and charName == 'gf') then
                    charData['info'][3] = false
                    if shouldMakeGhost then
                        createGhost(charName, charData['info'][5], charData['info'][6])
                        charData['info'][2] = getProperty(charName..'.animation.name')
                        charData['info'][3] = true
                    end
                    charData['info'][1] = getPropertyFromGroup("notes", i, 'strumTime')
                    charData['info'][5] = d
                    charData['info'][6] = getProperty(charName .. ".animation.name")
                end
            else
                local shouldProcess = (charData.side == mt or charData.side == '')
                if charData['info'][3] and shouldProcess and (finalType == gType and not getPropertyFromGroup("notes", i, 'gfNote') or getPropertyFromGroup("notes", i, 'gfNote') and charName == 'gf') and charData['effects'].enabled then
                    playAnim(charName, charData['info'][2], true)
                    if cancelFade and charData['info'][7] ~= nil then
                        for _, ghosts in pairs(charData['info'][7]) do
                            if getProperty(ghosts..".alpha") >= (getProperty(charName..".alpha") * (alphaGhost * alphaCancelMult)) or getProperty(ghosts..'.colorTransform.alphaMultiplier') >= (getProperty(charName..".colorTransform.alphaMultiplier") * (alphaGhost * alphaCancelMult)) then
                                cancelTween(ghosts..'fadeOut')
                                if not cancelFrame then
                                    playAnim(ghosts, getProperty(ghosts..".animation.name"), true)
                                    setProperty(ghosts..'.holdTimer', 0)
                                end
                                if charData['effects'].solidColor then
                                    setProperty(ghosts..".colorTransform.alphaMultiplier", getProperty(charName..".colorTransform.alphaMultiplier") * alphaGhost)
                                    startTween(ghosts..'fadeOut', ghosts..'.colorTransform', {alphaMultiplier = 0}, tweensDuration.alpha, {ease = tweensType.alpha, onComplete = 'onTweenCompleted'})
                                else
                                    setProperty(ghosts..".alpha", getProperty(charName..".alpha") * alphaGhost)
                                    doTweenAlpha(ghosts..'fadeOut', ghosts, 0, tweensDuration.alpha, tweensType.alpha)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function createGhost(char,d,anim)
    if not chars[char]['effects'].enabled or lowQuality or not getProperty(char..'.visible') or getProperty(char..".alpha") < 0.1 then
        return
    end
    local tag = 'animGhost'..ghostsCreated..char
    local X = getProperty(char..'.x')
    local Y = getProperty(char..'.y')
    local curChar = getProperty(char..".curCharacter")
    local isP = getProperty(char..'.isPlayer')
    createInstance(tag, "objects.Character", {X,Y,curChar,isP})
    addInstance(tag)
    playAnim(tag,anim,true)
    if cancelFrame then
        setProperty(tag..'.skipDance',true)
        setProperty(tag..".animation.curAnim.paused", true)
        setProperty(tag..".animation.curAnim.curFrame", 0)
    end
    setProperty(tag..'.antialiasing',getProperty(char..'.antialiasing'))
    setProperty(tag..".scale.x", getProperty(char..'.scale.x'))
    setProperty(tag..".scale.y", getProperty(char..'.scale.y'))
    setProperty(tag..'.flipX', getProperty(char..'.flipX'))
    setProperty(tag..'.flipY', getProperty(char..'.flipY'))
    if chars[char]['effects'].solidColor then
        setProperty(tag..".colorTransform.alphaMultiplier", getProperty(char..".colorTransform.alphaMultiplier") * alphaGhost)
        startTween(tag..'fadeOut', tag..'.colorTransform', {alphaMultiplier = 0}, tweensDuration.alpha, {ease = 'linear', onComplete = 'onTweenCompleted'})
        for i,v in ipairs({'red','green','blue'}) do
            setProperty(tag..".colorTransform."..v..'Offset', 255)
            setProperty(tag..".colorTransform."..v..'Multiplier', 0)
        end
        if chars[char]['effects'].healthColor then
            for i,v in ipairs({'red','green','blue'}) do
                setProperty(tag..".colorTransform."..v..'Offset', getProperty(char..".healthColorArray["..(i - 1).."]"))
            end
        end
        if chars[char]['effects'].noteColor then
            takeColor = chars[char].side and 'playerStrums' or 'opponentStrums'
            if chars[char].side == '' then
                takeColor = getProperty(char..'.isPlayer') and 'playerStrums' or 'opponentStrums'
            end
            if forcedColors then
                for i,v in ipairs({'red','green','blue'}) do
                    setProperty(tag..".colorTransform."..v..'Offset', directionColor[d][i])
                end
            else 
                for i,v in ipairs({'red','green','blue'}) do
                    setProperty(tag..".colorTransform."..v..'Offset', getProperty(takeColor..'.members['..d..'].rgbShader.parent.shader.data.r.value')[i] * 255)
                end
            end
        end
    else
        setProperty(tag..".alpha", getProperty(char..".alpha") * alphaGhost)
        doTweenAlpha(tag..'fadeOut', tag, 0, tweensDuration.alpha, "linear")
        if chars[char]['effects'].healthColor then
            setProperty(tag..".color", getIconColor(char))
        end
        if chars[char]['effects'].noteColor then
            local takeColor = chars[char].side and 'playerStrums' or 'opponentStrums'
            if chars[char].side == '' then
                takeColor = getProperty(char..'.isPlayer') and 'playerStrums' or 'opponentStrums'
            end
            local finalColor = {}   
            if forcedColors and not getPropertyFromGroup(takeColor,d,'useRGBShader') then
                table.insert(finalColor, directionColor[d])
            else        
                for i = 1,3 do
                    finalColor[i] = getProperty(takeColor..'.members['..d..'].rgbShader.parent.shader.data.r.value')[i] * 255
                end
            end
            setProperty(tag..".color", getColorFromHex(rgbToHex(finalColor)))
        end
    end
    --[[local behind = char
    for _,v in ipairs ({'boyfriend','dad','gf'}) do
        if char == v then
            behind = behind..'Group'
            break
        end
    end--]]
    --God I hate this part
    if chars[char]['effects'].moveGhost then
        if chars[char]['effects'].instantMove then
            if d == 0 then
                setProperty(tag..'.x', getProperty(char..'.x') + (-moveTo))
            elseif d == 1 then
                setProperty(tag..'.y', getProperty(char..'.y') + moveTo)
            elseif d == 2 then
                setProperty(tag..'.y', getProperty(char..'.y') + (-moveTo))
            elseif d == 3 then
                setProperty(tag..'.x', getProperty(char..'.x') + (moveTo))
            end
        else
            --[[local finalMove = moveTo
            if d == 0 or d == 3 then
                finalMove = getProperty(char..'.x') + (d == 0 and -moveTo or moveTo)
            else
                finalMove = getProperty(char..'.y') + (d == 1 and moveTo or -moveTo)
            end
            if chars[char]['effects'].comeChar then
                callMethod(tag..'.setPosition',{getProperty(char..'.x') + getRandomFloat(-moveTo, moveTo), getProperty(char..'.y') + getRandomFloat(-moveTo, moveTo)})
                if d == 0 or d == 3 then
                    finalMove = getProperty(char..'.x')
                else
                    finalMove = getProperty(char..'.y')
                end
            end
            if d == 0 then
                doTweenX(tag.."move", tag, finalMove, tweensDuration.move,tweensType.move)
            elseif d == 1 then
                doTweenY(tag.."move", tag, finalMove, tweensDuration.move,tweensType.move)
            elseif d == 2 then
                doTweenY(tag.."move", tag, finalMove, tweensDuration.move,tweensType.move)
            elseif d == 3 then
                doTweenX(tag.."move", tag, finalMove, tweensDuration.move,tweensType.move)
            end--]]
            local axisMap = {
                [0] = {property = '.x', multiplier = -1},
                [1] = {property = '.y', multiplier = 1},  
                [2] = {property = '.y', multiplier = -1}, 
                [3] = {property = '.x', multiplier = 1} 
            }
            
            local axis = axisMap[d]
            if axis then
                local finalMove = getProperty(char .. axis.property) + (moveTo * axis.multiplier)
            
                if chars[char]['effects'].comeChar then
                    callMethod(tag .. '.setPosition', {
                        getProperty(char .. '.x') + getRandomFloat(-moveTo, moveTo),
                        getProperty(char .. '.y') + getRandomFloat(-moveTo, moveTo)
                    })
                    finalMove = getProperty(char .. axis.property)
                end
            
                local tweenFunction = axis.property == '.x' and doTweenX or doTweenY
                tweenFunction(tag .. "move", tag, finalMove, tweensDuration.move, tweensType.move)
            end
        end
    end
    if chars[char]['effects'].scaleGhost then
        if chars[char]['effects'].instantScale then
            setProperty(tag..'.scale.x', getProperty(char..'.scale.x') * scaleTo)
            setProperty(tag..'.scale.y', getProperty(char..'.scale.y') * scaleTo)
        else
            doTweenX(tag..'scaleGhostX',tag..'.scale',getProperty(char..".scale.x") * scaleTo, tweensDuration.scale, tweensType.scale)
            doTweenY(tag..'scaleGhostY',tag..'.scale',getProperty(char..".scale.y") * scaleTo, tweensDuration.scale, tweensType.scale)
        end
    end
    if getProperty(char..'Group.visible') ~= nil  then
        setObjectOrder(tag, getObjectOrder(char..'Group') - 1)
    else
        setObjectOrder(tag, getObjectOrder(char) - 1)
    end
    --setObjectOrder(tag, getObjectOrder(behind)-1)
    if cancelFade then
        if chars[char]['info'][7] == nil then
            chars[char]['info'][7] = {}
        end
        table.insert(chars[char]['info'][7],tag)
    end
    ghostsCreated = ghostsCreated + 1
end

function onTweenCompleted(t)
    if string.find(t,'animGhost') and string.find(t,'fadeOut') then
        t = t:gsub('fadeOut','')
        if cancelFade then
            local char = t:match("animGhost%d+(%a+)")
            if char and chars[char] and chars[char]['info'][7] then
                for i, ghostTag in ipairs(chars[char]['info'][7]) do
                    if ghostTag == t then
                        table.remove(chars[char]['info'][7], i)
                        break
                    end
                end
            end
        end
        callMethod(t..'.kill',{''})
        callMethod(t..'.destroy',{''})
        callMethod('remove', {instanceArg(t)})
        callMethod('variables.remove', {t})
    end
end

function onTimerCompleted(t)
    if t:find('animGhost') ~= nil then
        onTweenCompleted(t)
    end 
end

function onEvent(n,v1)
    if n == 'Change Scale Ghost' then
        scaleTo = tonumber(v1)
    elseif n == 'Change Move Ghost' then
        moveTo = tonumber(v1)
    elseif n == 'Toggle Cancel Ghost Frame' then
        cancelFrame = not cancelFrame
    elseif n == 'Toggle Cancel Ghost Fade' then
        cancelFade = not cancelFade
    elseif n == 'Toggle Forced Colors For Ghost' then
        forcedColors = not forcedColors
    elseif n == 'Toggle HealthColor Ghost' then
        chars[tostring(v1)]['effects'].healthColor = not chars[tostring(v1)]['effects'].healthColor
    elseif n == 'Toggle Solid Color Ghost' then
        chars[tostring(v1)]['effects'].solidColor = not chars[tostring(v1)]['effects'].solidColor         
    elseif n == 'Toggle Move Ghost' then
        chars[tostring(v1)]['effects'].moveGhost = not chars[tostring(v1)]['effects'].moveGhost
    elseif n == 'Toggle Scale Ghost' then
        chars[tostring(v1)]['effects'].scaleGhost = not chars[tostring(v1)]['effects'].scaleGhost
    elseif n == 'Toggle Ghost For One' then
        chars[tostring(v1)]['effects'].enabled = not chars[tostring(v1)]['effects'].enabled
    elseif n == 'Toggle Instant Ghost Move' then
        chars[tostring(v1)]['effects'].instantMove = not chars[tostring(v1)]['effects'].instantMove
    elseif n == 'Toggle Instant Ghost Scale' then
        chars[tostring(v1)]['effects'].instantScale = not chars[tostring(v1)]['effects'].instantScale
    elseif n == 'Toggle Ghost For All' then
        for charName, charData in pairs(chars) do
            charData['effects'].enabled = not charData['effects'].enabled
        end
    elseif n == 'Toggle Note Colors For Ghost' then
        chars[tostring(v1)]['effects'].noteColor = not chars[tostring(v1)]['effects'].noteColor
    end
end

--I could use stringformat and unpack but...now i got really lazy
function getIconColor(chr)
    return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end
    
function rgbToHex(array)
    return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end