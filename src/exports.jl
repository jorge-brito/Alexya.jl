export Gtk, startapp, destroy, width, height, size, point, mapr, ↦, getFPS!, @protected, @on

export Vec, 
       getindex, 
       +, -, /, *, ==, <, >, <=, >=, |, 
       transform,
       rotm2d,
       rot,
       î, ĵ,
       angle,
       withangle,
       normalize,
       withmag,
       randv

export resize!

export GtkWidget,
       show,
       showall,
       size,
       getprop, set!, on!, off!, value, value!, add!,
       Box,
       Paned,
       @grid, span, rspan, cspan, Grid, CellSpan, GridCell, ↓, →, 
       Window,
       Button,
       Label, @label_str,
       Entry,
       Slider,
       Canvas,
       ColorButton,
       Switch

export margin,
       align,
       @margin,
       @valign,
       @halign,
       @hexpand,
       @vexpand,
       @columnhg,
       @rowhg,
       GridSpacing,
       @spacing

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

export uselayout!, aside, nolayout, create, @create, @layout, CURRENT_LAYOUT

export onclick!, onclicked!, onmousemotion!, onkeypress!, onkeyrelease!, key