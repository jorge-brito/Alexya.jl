struct SpriteImage
    pattern::Cairo.CairoPattern
    width::Real
    height::Real
end

function SpriteImage(pattern::Cairo.CairoPattern; filter = Cairo.FILTER_NEAREST)
    surface = Cairo.pattern_get_surface(pattern)
    w, h = surface.width, surface.height
    Cairo.pattern_set_filter(pattern, filter)
    return SpriteImage(pattern, w, h)
end

function loadsprite(path::String)
    img = readpng(path)
    pattern = Cairo.CairoPattern(img)
    return SpriteImage(pattern)
end

function drawsprite(sprite::SpriteImage, 
    xpos::Real = 0, ypos::Real = 0, 
    width::Real = sprite.width, 
    height::Real = sprite.height; centered = false)

    gsave()
    cr = Luxor.get_current_cr()
    w, h = sprite.width, sprite.height
    
    if centered
        xpos, ypos = xpos - (width/2), ypos - (height/2)
    end

    translate(xpos, ypos)
    scale(width/w, height/h)
    Cairo.set_source(cr, sprite.pattern)
    Cairo.paint(cr)
    grestore()
end

function drawsprite(sprite::SpriteImage, pos::Point, size::UnitRange; centered = false)
    drawsprite(sprite, pos.x, pos.y, size.start, size.stop; centered)
end