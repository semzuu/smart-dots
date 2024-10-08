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
    fitness *= 1e2
    if dot.hit do fitness *= 1e-9
    if dot.finished {
        fitness *= MovesCount / f32(dot.last_step)
        fitness *= 1e3
    } 
    return fitness
}

Dot :: struct {
    last_step: int,
    fitness: f32,
    pos, vel, acc: [2]f32,
    finished, hit: bool,
    dna: Dna,
}

dot_init :: proc(dot: ^Dot) {
    old_moves := dot.dna.moves
    temp := Dot{
        pos = {
            f32(rl.GetScreenWidth() / 2),
            f32(rl.GetScreenHeight() - 50),
        },
    }
    dot^ = temp
    dot.dna.moves = old_moves
}

dot_draw :: proc(dot: Dot, best: bool = false) {
    color := rl.RED
    if best {
        color = rl.YELLOW
        rl.DrawCircleLinesV(dot.pos, 6, rl.RAYWHITE)
    }
    if dot.finished || dot.hit do color = rl.GREEN
    rl.DrawCircleV(dot.pos, 5, color)
    rl.DrawLineV(dot.pos, dot.pos + rl.Vector2Normalize(dot.vel)*15, color)
}

dot_update :: proc(dot: ^Dot, step: int, target: Target, obstacles: [dynamic]Obstacle, dt: f32) {
    if !dot.finished && !dot.hit {
        dot.acc = dot.dna.moves[step]
        dot.pos += dot.vel
        dot.vel += dot.acc * dt
        dot.vel = linalg.clamp(dot.vel, -Speed, Speed)
        if !rl.CheckCollisionPointRec(dot.pos, {0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}) {
            dot.hit = true
        }
        for obstacle in obstacles do if rl.CheckCollisionPointRec(dot.pos, obstacle) {
            dot.hit = true
        } 
        if rl.CheckCollisionPointCircle(dot.pos, target.pos, target.radius) {
            dot.finished = true
            dot.last_step = step
        }
    }
}
