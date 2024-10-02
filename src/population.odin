package main

import "core:math"
import "core:fmt"
import rl "vendor:raylib"

Population :: struct {
    gen, alive_count, best_index: int,
    dots: [PopulationSize]Dot,
}

population_init :: proc(popu: ^Population) {
    popu.alive_count = PopulationSize
    for &dot in popu.dots {
        dot = Dot{
            alive = true,
            pos = {300, 600 - 10},
        }
        gen_moves(dot.dna.moves[:])
    }
}

next_gen :: proc(popu: ^Population) {
    population_init(popu)
    popu.gen += 1
}

population_update :: proc(popu: ^Population, target: Target, dt: f32) {
    if popu.alive_count > 0 {
        alive: int
        for &dot in popu.dots {
            if dot.alive do alive += 1
            dot_update(&dot, target, dt)
        }
        if popu.alive_count != alive do fmt.println(alive)
        popu.alive_count = alive
    } else {
        min_fitness := f32(math.F32_MAX)
        for &dot, i in popu.dots {
            dot.dna.fitness = calculate_fitness(dot, target)
            if dot.dna.fitness < min_fitness {
                min_fitness = dot.dna.fitness
                popu.best_index = i
            }
        }
        next_gen(popu)
    }
}

population_draw :: proc(popu: Population) {
    for dot, i in popu.dots {
        if i == popu.best_index {
            dot_draw(dot, true)
        } else {
            dot_draw(dot)
        }
    }
    gen := rl.TextFormat("Gen: %d", popu.gen)
    rl.DrawText(gen, 10, 10, 16, rl.RAYWHITE)
}
