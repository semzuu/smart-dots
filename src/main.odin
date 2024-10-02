package main

import rl "vendor:raylib"

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)

    target := Target{
        {300, 100},
        20,
    }
    dot := Dot{
        alive = true,
        pos = {300, 600 - 10},
    }
    gen_moves(dot.dna.moves[:])

    rl.InitWindow(600, 600, "Smart Dots")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        dot_update(&dot, target, dt)
        rl.BeginDrawing()
        rl.ClearBackground(rl.GetColor(0x181818ff))
        target_draw(target)
        dot_draw(dot)
        rl.EndDrawing()
    }
}
