using Dates

framerate(10)

snake = Snake()
# The game's resolution
rez = 20
# The player's score
score = 0
# Last time the food was eaten
last_eaten = now()
# If the game is paused
paused = false

function createFood()
    # The food will be created in a random location each time
    global food = [rand(0:w-1), rand(0:h-1)]
    # The timer will be reseted
    global last_eaten = now()
end

@use function setup()
    width, height = @width, @height
    global w = width ÷ rez
    global h = height ÷ rez
    createFood()
end

@use function update()
    width, height = @width, @height
    # If the game is paused
    # draw the paused screen
    if paused
        draw(Screen{:Paused})
        return;
    end
    # Save the current transformation state
    gsave()
    # then scale by the resolution variable
    scale(rez)
    background("black")

    # if the player has eaten the food
    if eat(snake, food)
        createFood()
        global score += 1
    end

    # If 10 seconds has passed and
    # the player didn't have eaten the food
    # then a new one will be created
    now() - last_eaten > Second(10) && createFood()

    update(snake)
    show(snake)
    
    # Draw the food
    # the food is just one yellowgreen rectangle
    sethue("yellowgreen")
    rect(point(food), 1, 1, :fill)

    # If the game ended
    if gameover(snake)
        draw(Screen{:GameOver})
        return;
    end

    grestore()
    # Shows the player score on the top left
    fontsize(16)
    sethue("white")
    text("Score: $score", 15, 30)
end
