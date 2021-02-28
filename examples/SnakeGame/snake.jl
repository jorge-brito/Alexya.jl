mutable struct Snake
    body::Vector
    dir::Vector{<:Real}
    len::Int
    Snake() = begin
        new([ [0, 0] ], [1, 0], 1)
    end
end

function update(snake::Snake)
    head = copy(last(snake.body))
    head += snake.dir
    popfirst!(snake.body)
    push!(snake.body, head)
end

function show(snake::Snake)
    for pos in snake.body
        sethue("white")
        rect(point(pos), 1, 1, :fill)
    end
end

function grow(snake::Snake)
    head = last(snake.body)
    snake.len += 1
    push!(snake.body, head)
end

function eat(snake::Snake, food::Vector)
    if food == last(snake.body)
        grow(snake)
        return true
    else
        return false
    end
end

function gameover(this::Snake)
    x, y = last(this.body)

    if x > w-1 || x < 0 || y > h-1 || y < 0
        return true
    end
    
    for part in this.body[1:end-1]
        if part == [x, y]
            return true
        end
    end

    return false
end