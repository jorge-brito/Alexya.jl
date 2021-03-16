@testset "Grid" begin
    win = Window("Grid test", 1280, 720) do 
        a = button"a"
        b = button"b"
        c = button"c"
        d = button"d"
        e = button"e"
        f = button"f"
        Grid(@homogeneous, [
            a → 2:2     b ↓ 2
            c     d     e
                f → 3
        ])
    end

    showall(win)
    destroy(win)
end

@testset "Grid" begin
    win = Window("Grid test", 1280, 720) do 
        a = button"a"
        b = button"b"
        c = button"c"
        d = button"d"
        e = button"e"
        f = button"f"
        Grid(@homogeneous) do 
        [
            a → 2:2     b ↓ 2
            c     d     e
                f → 3
        ]
        end
    end

    showall(win)
    destroy(win)
end