package main

import rl "vendor:raylib"

PopulationSize :: 100
MovesCount :: 5000
MutationRate :: 0.01
Speed :: 5

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)

    target: Target
    target.radius = 20
    popu: Population
    population_init(&popu)

    rl.InitWindow(600, 600, "Smart Dots")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        target.pos = {
            f32(rl.GetScreenWidth() / 2),
            50,
        }
        dt := rl.GetFrameTime()
        population_update(&popu, target, dt)
        rl.BeginDrawing()
        rl.ClearBackground(rl.GetColor(0x181818ff))
        target_draw(target)
        population_draw(popu)
        rl.EndDrawing()
    }
}
