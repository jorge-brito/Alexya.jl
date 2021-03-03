# Exports from utils.jl
export Gtk, point, mapr, ↦, abs, getFPS!, @protected, @on
export Vec, 
       getindex, 
       +, -, /, *, ==, <, >, <=, >=, 
       transform,
       rotm2d,
       rotate,
       î, ĵ,
       angle,
       withangle,
       normalize,
       setmag!,
       randv

export resize!

# Exports from gtk.jl
export GtkWidget,
       show,
       showall,
       getprop,
       set!,
       on!,
       off!,
       value,
       value!,
       add!,
       Box,
       Paned,
       Grid,
       GridCell,
       GridCells,
       Span,
       rspan,
       cspan,
       ↓,
       →,
       @grid,
       Window,
       Button,
       Label,
       @label_str,
       Entry,
       Slider,
       Canvas,
       ColorButton

# Exports from helpers.jl
export margin,
       align,
       @margin,
       @valign,
       @halign,
       @hexpand,
       @vexpand,
       @columnhg,
       @rowhg

# Exports from canvas.jl
export loop!, 
    DrawingApp, 
    createCanvas, 
    framerate!,
    dontloop!,
    @size, 
    @window, 
    @canvas, 
    @height, 
    @width, 
    CURRENT_DRAWINGAPP

# Exports from layout.jl
export uselayout!, aside, nolayout, create, @create, @layout, CURRENT_LAYOUT

# Exports from events.jl
export onclick!, onclicked!, onmousemotion!, onkeypress!, onkeyrelease!, key