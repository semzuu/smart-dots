package main

import "core:math/linalg"
import rl "vendor:raylib"

MovesCount :: 5000

Dna :: struct {
    moves: [MovesCount][2]f32,
    step: i32,
}

Dot :: struct {
    pos, vel, acc: [2]f32,
    alive: bool,
    dna: Dna,
}

dot_draw :: proc(dot: Dot) {
    rl.DrawCircleV(dot.pos, 5, rl.RED)
    rl.DrawCircleLinesV(dot.pos, 6, rl.RAYWHITE)
}

dot_update :: proc(dot: ^Dot, dt: f32) {
    if dot.alive {
        dot.acc = dot.dna.moves[dot.dna.step]
        if dot.dna.step < MovesCount - 1 do dot.dna.step += 1
        else do dot.acc = {0, 0}
        dot.pos += dot.vel
        dot.vel += dot.acc * dt
        dot.vel = linalg.clamp(dot.vel, -5, 5)
        if !rl.CheckCollisionPointRec(dot.pos, {0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}) do dot.alive = false
    }
}
