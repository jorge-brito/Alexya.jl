"""
This example was adapted from Daniel Shiffman's "Snake Game Redux" video,
from 'The Coding Train' Youtube channel.

https://www.youtube.com/watch?v=OMoVcohRgZA&t=1658s
"""
module SnakeGame

using Alexya

createCanvas(800, 600, title = "Snake Game")

include("snake.jl")
include("utils.jl")
include("draw.jl")
include("controls.jl")

loop!(setup, draw)

end