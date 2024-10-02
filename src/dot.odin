package main

import "core:fmt"
import "core:math/rand"
import "core:math/linalg"
import rl "vendor:raylib"

MovesCount :: 5000

Dna :: struct {
    moves: [MovesCount][2]f32,
    step: i32,
    fitness: f32,
}

Dot :: struct {
    pos, vel, acc: [2]f32,
    alive, finished: bool,
    dna: Dna,
}

dot_draw :: proc(dot: Dot) {
    color := rl.RED
    if !dot.alive do color = rl.GREEN
    rl.DrawCircleV(dot.pos, 5, color)
    rl.DrawCircleLinesV(dot.pos, 6, rl.RAYWHITE)
}

dot_update :: proc(dot: ^Dot, target: Target, dt: f32) {
    if dot.alive {
        dot.acc = dot.dna.moves[dot.dna.step]
        if dot.dna.step < MovesCount - 1 do dot.dna.step += 1
        else do dot.acc = {0, 0}
        dot.pos += dot.vel
        dot.vel += dot.acc * dt
        dot.vel = linalg.clamp(dot.vel, -5, 5)
        if !rl.CheckCollisionPointRec(dot.pos, {0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}) do dot.alive = false
        if rl.CheckCollisionPointCircle(dot.pos, target.pos, target.radius) {
            dot.alive = false
            dot.finished = true
        }
    }
    fmt.println(calculate_fitness(dot^, target))
}

gen_moves :: proc(moves: [][2]f32) {
    for &move in moves {
        move = {
            rand.float32() * 2 - 1,
            rand.float32() * 2 - 1,
        }
    }
}

calculate_fitness :: proc(dot: Dot, target: Target) -> f32 {
    fitness: f32
    fitness += 1/rl.Vector2LengthSqr(target.pos - dot.pos)
    fitness *= 1e+6
    if dot.finished do fitness *= 10
    return fitness
}
