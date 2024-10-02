package main

import "core:fmt"
import "core:time"
import "core:math/rand"
import rl "vendor:raylib"

gen_moves :: proc(moves: [][2]f32) {
    for &move in moves {
        move = {
            rand.float32() * 2 - 1,
            rand.float32() * 2 - 1,
        }
    }
}

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)

    dot := Dot{
        alive = true,
        pos = {300, 600 - 10},
    }
    gen_moves(dot.dna.moves[:])

    rl.InitWindow(600, 600, "Smart Dots")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        dot_update(&dot, dt)
        rl.BeginDrawing()
        rl.ClearBackground(rl.GetColor(0x181818ff))
        dot_draw(dot)
        rl.EndDrawing()
    }
}
