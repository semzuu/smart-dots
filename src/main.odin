package main

import rl "vendor:raylib"

PopulationSize :: 100
MovesCount :: 5000
MutationRate :: 0.02
Speed :: 5

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)

    target := Target{
        {300, 100},
        20,
    }
    popu: Population
    population_init(&popu)

    rl.InitWindow(600, 600, "Smart Dots")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        population_update(&popu, target, dt)
        rl.BeginDrawing()
        rl.ClearBackground(rl.GetColor(0x181818ff))
        target_draw(target)
        population_draw(popu)
        rl.EndDrawing()
    }
}
