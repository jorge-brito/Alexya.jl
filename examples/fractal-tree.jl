# Example adapted from Daniel Shiffman - The Coding Train
# https://youtu.be/0jjeOYMjmDU?list=PLRqwX-V7Uu6ZiZxtDDRCi6uhfTH4FilpH

using Alexya

@layout aside()

createCanvas(800, 600) # create a Canvas

slider = @create Slider(0:π/12:2π; startat=π/4)
φ = π/4

function draw(w, h)
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

loop!(draw)