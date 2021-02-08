# Example adapted from The Coding Train
# https://youtu.be/0jjeOYMjmDU?list=PLRqwX-V7Uu6ZiZxtDDRCi6uhfTH4FilpH

using Alexya, Alexya.Widgets

createCanvas(800, 600, Layout{:splitv, 520}) # create a Canvas

@add slider = Slider(0:π/12:2π; start=π/4, @margin(20))
φ = π/4

draw!() do w, h
    global φ = value(slider)

    background("#515151")
    origin(w/2, h)
    sethue("white")
    branch(150)
end

function branch(len)
    line(O, Point(0, -len), :stroke)
    translate(0, -len)
    
    if len > 4
        gsave()
        rotate(φ)
        branch(.67len)
        grestore()

        gsave()
        rotate(-φ)
        branch(.67len)
        grestore()
    end
end

loop!()