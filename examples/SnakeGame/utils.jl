abstract type Screen{T} end

function draw(::Type{Screen{:Paused}})
    gsave()
    origin()
    background(colorant"#fff")

    sethue("#1e1e1e")
    fontsize(32)
    text("Game Paused!", Point(0, -20), halign=:center, valign=:center)
    fontsize(22)
    sethue("#2f2f2f")
    text("Press 'spacebar' to unpause", Point(0, 20), halign=:center, valign=:center)
    grestore()
end

function draw(::Type{Screen{:GameOver}})
    origin()
    background("red")
    sethue("white")

    fontsize(32)
    text("Game Over", Point(0, -20), halign=:center, valign=:center)
    fontsize(22)
    text("Your score: $score", Point(0, 20), halign=:center, valign=:center)
    noLoop()
end