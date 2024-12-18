package main

import "core:math/linalg"
import rl "vendor:raylib"

Obstacle :: rl.Rectangle

PopulationSize :: 100
ElitesCount :: 2
MovesCount :: 5000
MutationRate :: 0.01
Speed :: 10

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)

    rl.InitWindow(600, 600, "Smart Dots")
    defer rl.CloseWindow()

    hold, paused: bool
    start_pos: [2]f32

    obstacles: [dynamic]Obstacle
    target: Target
    target.radius = 20
    popu: Population
    population_init(&popu)
    defer population_deinit(&popu)
    target.pos = {
        f32(rl.GetScreenWidth() / 2),
        50,
    }

    for !rl.WindowShouldClose() {
        free_all(context.allocator)
        dt := rl.GetFrameTime()
        if rl.IsKeyPressed(.SPACE) do paused = !paused
        if !hold && rl.IsMouseButtonDown(.LEFT) {
            hold = true
            start_pos = rl.GetMousePosition()
        }
        if rl.IsMouseButtonReleased(.LEFT) {
            hold = false
            end_pos := rl.GetMousePosition()
            g := linalg.greater_than_equal_array(start_pos, end_pos)
            if g[0] || g[1] do start_pos, end_pos = end_pos, start_pos
            append(&obstacles, Obstacle{start_pos.x, start_pos.y, end_pos.x-start_pos.x, end_pos.y-start_pos.y})
        }
        if rl.IsKeyPressed(.C) do clear(&obstacles)
        if rl.IsKeyPressed(.R) {
            population_init(&popu)
        } 
        if rl.IsMouseButtonReleased(.RIGHT) do target.pos = rl.GetMousePosition()
        if !paused {
            population_update(&popu, target, obstacles, dt)
        }
        rl.BeginDrawing()
        rl.ClearBackground(rl.GetColor(0x181818ff))
        if hold {
            mouse := rl.GetMousePosition()
            rec := Obstacle{start_pos.x, start_pos.y, mouse.x-start_pos.x, mouse.y-start_pos.y}
            rl.DrawRectangleRec(rec, rl.ColorAlpha(rl.BLUE, 0.3))
        }
        target_draw(target)
        for obstacle in obstacles do obstacle_draw(obstacle)
        population_draw(popu)
        if paused {
            text, size := cstring("PAUSED"), i32(16)
            rl.DrawText(text, rl.GetScreenWidth()-rl.MeasureText(text, size)-10, 10, size, rl.RAYWHITE)
        }
        rl.EndDrawing()
    }
}

obstacle_draw :: proc(obstacle: Obstacle) {
    rl.DrawRectangleRec(obstacle, rl.BLUE)
}
