macro inline_widget(ex)
    gname, name = ex.args
    quote
        function $(esc(name))(args...; props...)
            widget = $(esc(gname))(args...)
            length(props) > 0 && set!(widget; props...)
            return widget
        end
    end
end

macro container_widget(ex)
    gname, name = ex.args
    quote
        function $(esc(name))(children::Union{Function, GtkWidget, Tuple, Vector}, args...; props...)
            widget = $(esc(gname))(args...)
            length(props) > 0 && set!(widget; props...)
            add!(widget, children)
            return widget
        end
    end
end

function SpinButton(range::AbstractRange; init::Real = middle(range), props...)
    spin = GtkSpinButton(range)
    length(props) > 0 && set!(spin; props...)
    set_gtk_property!(GAccessor.adjustment(spin), :value, init)
    return spin
end

@inline_widget GtkLabel --> Label

macro label_str(text)
    :( Label($(esc(text))) )
end

@inline_widget GtkEntry --> Entry

macro entry_str(text)
    :( Entry(text = $(esc(text))) )
end

@inline_widget GtkScale         -->  Scale
@inline_widget GtkButton        -->  Button
@inline_widget GtkSpinner       -->  Spinner
@inline_widget GtkTextView      -->  TextView
@inline_widget GtkStatusbar     -->  StatusBar
@inline_widget Gtk.GtkSwitch    -->  Switch
@inline_widget GtkLinkButton    -->  LinkButton
@inline_widget GtkFontButton    -->  FontButton
@inline_widget GtkAppChooser    -->  AppChooser
@inline_widget GtkColorButton   -->  ColorButton
@inline_widget GtkProgressBar   -->  ProgressBar
@inline_widget GtkFileChooser   -->  FileChooser
@inline_widget GtkCheckButton   -->  CheckBox
@inline_widget GtkToggleButton  -->  ToggleButton
@inline_widget GtkComboBoxText  -->  TextList
@inline_widget GtkVolumeButton  -->  VolumeButton
@inline_widget GtkCanvas        -->  Canvas
    
function ColorButton(color::Colorant; props...)
    ColorButton(convert(Gtk.GdkRGBA, color); props...)
end

function ColorButton(color::String; props...)
    ColorButton(parse(Colorant, color); props...)
end

macro colorbtn_str(color)
    :( ColorButton($(esc(color))) )
end

function Slider(range::AbstractRange; init::Real = middle(range), props...)
    slider = Scale(false, range; props...)
    set_gtk_property!(GAccessor.adjustment(slider), :value, init)
    return slider
end

macro button_str(text)
    :( Button($(esc(text))) )
end

@container_widget GtkBox --> Box
@container_widget GtkFrame --> Frame
@container_widget GtkPaned --> Paned
@container_widget GtkWindow --> Window
@container_widget GtkMenuBar --> MenuBar
@container_widget GtkToolbar --> Toolbar
@container_widget GtkTreeView --> TreeView
@container_widget GtkNotebook --> Notebook
@container_widget GtkScrolledWindow --> ScrolledWindow