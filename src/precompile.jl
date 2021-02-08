function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    isdefined(Alexya, Symbol("@widget")) && precompile(Tuple{getfield(Alexya, Symbol("@widget")), Expr})
    for T in Any[
        Alexya.Canvas             ,
        Alexya.ComboBoxText       ,
        Alexya.Alignment          ,
        Alexya.AspectFrame        ,
        Alexya.Button             ,
        Alexya.CheckButton        ,
        Alexya.Expander           ,
        Alexya.EventBox           ,
        Alexya.Frame              ,
        Alexya.LinkButton         ,
        Alexya.RadioButton        ,
        Alexya.ToggleButton       ,
        Alexya.VolumeButton       ,
        Alexya.Window             ,
        Alexya.Dialog             ,
        Alexya.FileChooserDialog  ,
        Alexya.Box                ,
        Alexya.ButtonBox          ,
        Alexya.Statusbar          ,
        Alexya.Grid               ,
        Alexya.Layoutc            ,
        Alexya.Notebook           ,
        Alexya.NullContainer      ,
        Alexya.Overlay            ,
        Alexya.Paned              ,
        Alexya.RadioButtonGroup   ,
        Alexya.TableWidget        ,
        Alexya.Entry              ,
        Alexya.Image              ,
        Alexya.Label              ,
        Alexya.ProgressBar        ,
        Alexya.Scale              ,
        Alexya.SpinButton         ,
        Alexya.Spinner            ,
        Alexya.Switch             ,
        Alexya.TextView           ,
        Alexya.FileChooserNative  
    ] 
        precompile(Tuple{typeof(T)})
    end
end