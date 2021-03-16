LEFT = [-1, 0]
RIGHT = [1, 0]
UP = [0, -1]
DOWN = [0, 1]

move(::Val{:left}) = begin
    snake.dir = LEFT
end

move(::Val{:right}) = begin
    snake.dir = RIGHT
end

move(::Val{:up}) = begin
    snake.dir = UP
end

move(::Val{:down}) = begin
    snake.dir = DOWN
end

@use function keypress(event)
    dir = snake.dir
    if event.keyval == keyboard("w") && dir != DOWN
        move(Val(:up))
    elseif event.keyval == keyboard("s") && dir != UP
        move(Val(:down))
    elseif event.keyval == keyboard("a") && dir != RIGHT
        move(Val(:left))
    elseif event.keyval == keyboard("d") && dir != LEFT
        move(Val(:right))
    elseif event.keyval == 32 || event.keyval == 65307
        global paused = !paused
    end
end