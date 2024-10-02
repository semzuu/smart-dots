package main

import rl "vendor:raylib"

Target :: struct {
    pos: [2]f32,
    radius: f32,
}

target_draw :: proc(target: Target) {
    rl.DrawCircleV(target.pos, target.radius, rl.MAGENTA)
}
