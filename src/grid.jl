mutable struct GridCell
    w::Maybe{GtkWidget}
    r::Int
    c::Int
    GridCell(w::GtkWidget) = new(w, 1, 1)
    GridCell(w::GtkWidget, r::Int, c::Int) = new(w, r, c)
    GridCell(cell::GridCell) = cell
    GridCell(::Tuple) = new(missing, 1, 1)
end

"""
        span(widget, r, c)

Creates a `GridCell` containing `widget` that spans `r` rows and `c` columns.

# Examples

```julia
julia> span(mybutton, 2, 2)
CellSpan(GtkButton..., 2, 2)
```
"""
span(w::GtkWidget, r::Int, c::Int) = [(x == y == 1 ? GridCell(w, r, c) : ()) for x=1:r, y=1:c]

span(::Tuple, r::Int, c::Int) = [() for x=1:r, y=1:c]

"""
        widget → N::Int

Returns `CellSpan` object for `widget` that spans `N` columns.

# Examples

```julia
julia> label"I span 4 columns" → 4
CellSpan(GtkSlider..., 1, 4)
```
"""
→(w::Union{GtkWidget, Tuple}, N::Int) = span(w, 1, N)
"""
        widget ↓ N::Int

Returns `CellSpan` object for `widget` that spans `N` rows.

# Examples

```julia
julia> Slider(1:100) ↓ 2
CellSpan(GtkSlider..., 2, 1)
```
"""
↓(w::Union{GtkWidget, Tuple}, N::Int) = span(w, N, 1)
→(M::Matrix, N::Int) = (w = M[1, 1]; span(w.w, w.r, w.c + N - 1))
↓(M::Matrix, N::Int) = (w = M[1, 1]; span(w.w, w.r + N - 1, w.c))
"""
        widget → r:c

Returns a `GridCell` object for `widget` that spans `r` rows and `c` columns.

# Examples

```julia
julia> Box((), :h) → 3:4
CellSpan(GtkBox..., 3, 4)
```
"""
→(w::Union{GtkWidget, Tuple}, a::UnitRange) = span(w, a.start, a.stop)

const Cell = Union{GtkWidget, GridCell, Tuple}
const Rows = Vector{Cell}

"""

        Grid(rows::Matrix)

Creates a new `GtkGrid` widget.

The `rows` parameter is a `Matrix` that contains the `GridCells`. A `GridCell` can
be either a `GtkWidget`, a `CellSpan` object or a empty tuple `()`.

The position of each element in the `rows` matrix will determine its position
on the `Grid`.

An `CellSpan` object represents a cell that spans multiple rows or/and columns. 
An empty tuple indicates an empty cell.

# Examples

```julia
grid = Grid(@margin(10), [
    button  slider
    ()      label
])

grid = Grid(@margin(10), [
    # the button will span 2 rows 
    CellSpan(button, 2, 1)  slider
    ()                      label
])

grid = Grid(@margin(10), [
    # the button will span 2 rows 
    button ↓ 2  slider
    # the label will span 2 columns 
    label → 2
])

grid = Grid(@margin(10)) do
    [
        # the textarea will span 3 rows and 2 columns
        textarea → 3:2  switch
        ()  ()            ()
        ()  ()            ()
        toolbar → 2     button
    ]
end
```
"""
function Grid(rows::Matrix{GridCell}; props...)
    grid = Gtk.GtkGrid()
    
    for (index, cell) in pairs(rows)
        if cell.w isa GtkWidget
            i, j = Tuple(index)
            r, c = cell.r, cell.c
            x = j:j + c - 1
            y = i:i + r - 1
            grid[x, y] = cell.w
        end
    end

    length(props) > 0 && set!(grid; props...)
    return grid
end

Grid(rows::Matrix; props...) = Grid(GridCell.(rows)::Matrix{GridCell}; props...)

Grid(rows::Function; props...) = Grid(rows(); props...)