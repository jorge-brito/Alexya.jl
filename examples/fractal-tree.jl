# Example adapted from Daniel Shiffman - The Coding Train
# https://youtu.be/0jjeOYMjmDU?list=PLRqwX-V7Uu6ZiZxtDDRCi6uhfTH4FilpH

using Alexya


@init "Fractal Tree" 800 600 # create a Canvas
@layout aside(:v, 200)

slider = @create Slider(0:π/12:2π; init=π/4, @margin(20))
φ = π/4

@use function update()
    global φ = value(slider)

    background("#515151")
    origin((@width)/2, @height)
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

start()