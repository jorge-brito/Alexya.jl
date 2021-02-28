using Alexya

@layout aside(240)

createCanvas(800, 800; title = "Vector Field")

@create label"Vector density (δ)"
density = @create Slider(1:30; startat = 12, @margin(10))

X_entry = Entry("100 * sin(2t) - y", width_chars = 16)
Y_entry = Entry("100 * cos(2t) + x", width_chars = 16)

@create Grid(@margin(5), row_spacing = 10, [
    label"F₁(x, y) = " X_entry
    label"F₂(x, y) = " Y_entry
])

global t = 0

F(x, y) = begin
    X = Meta.parse(value(X_entry))
    Y = Meta.parse(value(Y_entry))
    return @eval begin
        t = $t
        x = $x
        y = $y
        [$X, $Y]
    end
end

function draw(width, height)
    background("black")
    δ = value(density)
    w = Int(width ÷ δ)
    h = Int(height ÷ δ)
    origin()
    setline(1)
    for x in -width/2:w:width/2
        for y in -height/2:h:height/2
            try
                v = F(-x, -y)
                θ = atan(v[2], v[1]) + π
                s = Point(x, y)

                if abs(v) <= w/2
                    e = s + point(v)
                else
                    e = s + (w/2) * Point(cos(θ), sin(θ))
                end

                color = HSL(floor(Int, rad2deg(θ)), Int(abs(v) ÷ 2), abs(v) / width)

                sethue(color)
                
                try arrow(s, e)
                catch e end
            catch e
                background("black")
                sethue("red")
                fontsize(20)
                text("Syntax error", O, halign=:center)
                println(e)
            end
        end
    end

    global t += 0.1
    t > 10 && global t = 0
end

loop!(draw) # Start the loop
