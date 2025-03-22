for i,v in ipairs({'behindTrees','frontTrees','sansStation'}) do
    makeLuaSprite(v,'stages/sansStation/'..v,585,215)
    scaleObject(v, 0.8,0.8)
    if v == 'frontTrees' then
        setScrollFactor(v, 0.9, 0.9)
    end
    addLuaSprite(v, v == 'frontTrees')
end