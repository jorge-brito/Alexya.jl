using Alexya

@layout aside()
createCanvas(800, 600; title = "Wave")

@create Label("Frequency: ";     @margin(10))
freq = @create Slider(0:π/6:2π;  @margin(10), startat=1)

@create Label("Phase: ";         @margin(10))
phase = @create Slider(0:π/6:2π; @margin(10), startat=0)

@create Label("Amplitude: ";     @margin(10))
amp = @create Slider(0:π/6:2π;   @margin(10), startat=1)

function draw(w, h)
    background("white")
    origin()

    f, ϕ, A = value.([freq, phase, amp])

    points = 80 .* [Point(x, A*cos(f*x + ϕ)) for x in -2π:π/32:2π]

    sethue("black")
    poly(points, :stroke)
end

loop!(draw)