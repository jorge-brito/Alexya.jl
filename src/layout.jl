abstract type Layout end

function createLayout end

mutable struct Panels{T, N} <: Layout
    box::GtkContainer
    panels::GtkPaned
    empty::Bool
end

const VPanels{N} = Panels{:v, N}
const HPanels{N} = Panels{:h, N}

function createLayout(::Type{Panels{T, N}}, canvas::GtkCanvas, win::GtkWindow) where {T, N}
    box = Box(T == :v ? :h : :v; @margin(10), spacing = 10)
    position = T == :h ? width(win) : height(win)
    panels = Paned([canvas, box], T; position)
    add!(win, panels)
    return Panels{T, N}(box, panels, true)
end

function add!(w::GtkWidget, layout::Panels{T, N}, win::GtkWindow) where {T, N}
    if layout.empty
        wd = width(win)
        ht = height(win)
        if T == :h
            resize!(win, wd + N, ht)
            position = wd
        else
            resize!(win, wd, ht + N)
            position = ht
        end
        set!(layout.panels; position)
        layout.empty = false
    end

    add!(layout.box, w)
    return w;
end