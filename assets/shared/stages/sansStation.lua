for i,v in ipairs({'behindTrees','frontTrees','sansStation'}) do
    makeLuaSprite(v,'stages/sansStation/'..v,585,215)
    scaleObject(v, 0.8,0.8)
    if v == 'frontTrees' then
        setScrollFactor(v, 0.9, 0.9)
    end
    addLuaSprite(v, v == 'frontTrees')
end

--[[local RGBRAY = {0.0,20,255}
local center = {0, 0}

function onStartCountdown()
    makeLuaSprite('rays')
    setSpriteShader('rays', 'godRay')
    for i,v in ipairs ({'R','G','B'}) do
        setShaderFloat('rays', v, RGBRAY[i])
    end

    createInstance('raysCam', 'flixel.FlxCamera', {})
    setProperty('raysCam.bgColor')

    for i,v in ipairs ({'HUD','Other'}) do
        callMethodFromClass('flixel.FlxG', 'cameras.remove', {instanceArg('cam'..v),false}) 
    end
    for i,v in ipairs ({'raysCam','camHUD','camOther'}) do
        callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg(v),false}) 
    end
    --runHaxeCode([[
    --    getVar('raysCam').filters = [new ShaderFilter(game.getLuaObject("rays").shader)];
    --    game.boyfriendGroup.camera = getVar('raysCam');
    --    game.gfGroup.camera = getVar('raysCam');
    --    game.dadGroup.camera = getVar('raysCam');
    --]]

    --[[setProperty('boyfriend.camera', instanceArg('raysCam'), false, true)
    setProperty('gf.camera', instanceArg('raysCam'), false, true)
    setProperty('dad.camera', instanceArg('raysCam'), false, true)

    setSpriteShader("boyfriend", "garage")
    setShaderFloatArray("boyfriend", "color", {0.8, 0.8, 1., 0.5})
    setShaderFloat("boyfriend", "shadowLength", 25.)
    setShaderBool("boyfriend", "flipped", true)

    setSpriteShader("dad", "garage")
    setShaderFloatArray("dad", "color", {0.8, 0.8, 1., 0.5})
    setShaderFloat("dad", "shadowLength", 25.)
    setShaderBool("dad", "flipped", true)

    setSpriteShader("gf", "garage")
    setShaderFloatArray("gf", "color", {0.8, 0.8, 1., 0.5})
    setShaderFloat("gf", "shadowLength", 25.)
    setShaderBool("gf", "flipped", true)
end

function onUpdatePost()
	setProperty('raysCam.zoom', getProperty("camGame.zoom"))
    setProperty('raysCam.alpha', getProperty("camGame.alpha"))
    setProperty('raysCam.visible', getProperty("camGame.visible"))
    setProperty('raysCam.angle', getProperty("camGame.angle"))
    setProperty('raysCam.zoom', getProperty("camGame.zoom"))
	setProperty('raysCam.scroll.x', getProperty("camGame.scroll.x"))
	setProperty('raysCam.scroll.y', getProperty("camGame.scroll.y"))

	setShaderFloatArray('rays', 'LightPos', {
		(center[1] - getProperty("camGame.scroll.x") / getProperty("camGame.zoom")) / screenWidth,
		(center[2] - getProperty("camGame.scroll.y") / getProperty("camGame.zoom")) / screenHeight
	})
end--]]