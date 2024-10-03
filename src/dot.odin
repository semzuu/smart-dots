package main

import "core:math/rand"
import "core:math/linalg"
import rl "vendor:raylib"

random_vector :: proc() -> [2]f32 {
    return {
        rand.float32() * 2 * Speed - Speed,
        rand.float32() * 2 * Speed - Speed,
    }
}

gen_moves :: proc(moves: [][2]f32) {
    for &move in moves {
        move = random_vector()
    }
}

calculate_fitness :: proc(dot: Dot, target: Target) -> f32 {
    fitness: f32
    fitness = 1 / rl.Vector2DistanceSqrt(target.pos, dot.pos)
    fitness *= fitness
    if dot.finished {
        fitness += 1 / f32(dot.dna.step)
        fitness *= 1e3
    } 
    return fitness
}

Dot :: struct {
    fitness: f32,
    pos, vel, acc: [2]f32,
    alive, finished: bool,
    dna: Dna,
}

dot_init :: proc(dot: ^Dot) {
    temp := Dot{
        alive = true,
        pos = {
            f32(rl.GetScreenWidth() / 2),
            f32(rl.GetScreenHeight() - 10),
        },
    }
    dna_init(&temp.dna)
    dot^ = temp
}

dot_draw :: proc(dot: Dot, best: bool = false) {
    color := rl.RED
    if best {
        color = rl.YELLOW
        rl.DrawCircleLinesV(dot.pos, 6, rl.RAYWHITE)
    }
    if !dot.alive do color = rl.GREEN
    rl.DrawCircleV(dot.pos, 5, color)
}

dot_update :: proc(dot: ^Dot, target: Target, dt: f32) {
    if dot.alive {
        dot.acc = dot.dna.moves[dot.dna.step]
        if dot.dna.step < MovesCount - 1 do dot.dna.step += 1
        else do dot.alive = false
        dot.pos += dot.vel
        dot.vel += dot.acc * dt
        dot.vel = linalg.clamp(dot.vel, -Speed, Speed)
        if !rl.CheckCollisionPointRec(dot.pos, {0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}) do dot.alive = false
        if rl.CheckCollisionPointCircle(dot.pos, target.pos, target.radius) {
            dot.alive = false
            dot.finished = true
        }
    }
}
