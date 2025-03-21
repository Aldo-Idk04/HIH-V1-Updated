for i,v in ipairs({'behindTrees','frontTrees','sansStation'}) do
    makeLuaSprite(v,'stages/sansStation/'..v,525,100)
    scaleObject(v, 0.85,0.85)
    if v == 'frontTrees' then
        setScrollFactor(v, 0.9, 0.9)
    end
    addLuaSprite(v, v == 'frontTrees')
end