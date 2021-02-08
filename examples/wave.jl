using Alexya, Alexya.Widgets

createCanvas(800, 600, Layout{:split, 600}; title = "Wave")

@add Label("Frequency: ";     @margin(10))
@add freq = Slider(0:π/6:2π;  @margin(10), start=1)

@add Label("Phase: ";         @margin(10))
@add phase = Slider(0:π/6:2π; @margin(10), start=0)

@add Label("Amplitude: ";     @margin(10))
@add amp = Slider(0:π/6:2π;   @margin(10), start=1)

draw!() do w, h
    background("white")
    origin()

    f, ϕ, A = value.([freq, phase, amp])

    points = 50 .* [Point(x, A*cos(f*x + ϕ)) for x in -2π:π/32:2π]

    sethue("black")
    poly(points, :stroke)
end

loop!()