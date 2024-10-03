package main

import "core:math"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"

Population :: struct {
    gen, alive_count, best_index: int,
    dots: [PopulationSize]Dot,
    max_fitness, avg_fitness: f32,
}

population_init :: proc(popu: ^Population) {
    popu.alive_count = PopulationSize
    for &dot in popu.dots {
        dot_init(&dot)
        gen_moves(dot.dna.moves[:])
    }
}

next_gen :: proc(popu: ^Population) {
    defer {
        popu.alive_count = PopulationSize
        popu.gen += 1
    }
    pool := popu.dots
    best_moves := pool[popu.best_index].dna.moves
    dot_init(&popu.dots[0])
    popu.dots[0].dna.moves = best_moves
    for count in 1..<PopulationSize {
        for {
            parent := rand.int_max(PopulationSize)
            chance := rand.float32()
            if chance < pool[parent].dna.fitness/popu.max_fitness {
                popu.dots[count] = mutate(pool[parent])
                break
            }
        }
    }
}

mutate :: proc(dot: Dot) -> Dot {
    baby: Dot
    dot_init(&baby)
    for i in 0..<MovesCount {
        chance := rand.float32()
        if chance < MutationRate do baby.dna.moves[i] = random_vector()
        else do baby.dna.moves[i] = dot.dna.moves[i]
    }
    return baby
}

update_stats :: proc(popu: ^Population, target: Target) {
    popu.max_fitness, popu.avg_fitness = f32(0), f32(0)
    for &dot, i in popu.dots {
        dot.dna.fitness = calculate_fitness(dot, target)
        popu.avg_fitness += dot.dna.fitness
        if dot.dna.fitness > popu.max_fitness {
            popu.max_fitness = dot.dna.fitness
            popu.best_index = i
        }
    }
    popu.avg_fitness /= PopulationSize
}

population_update :: proc(popu: ^Population, target: Target, dt: f32) {
    if popu.alive_count > 0 {
        alive: int
        for &dot in popu.dots {
            if dot.alive do alive += 1
            dot_update(&dot, target, dt)
        }
        popu.alive_count = alive
        update_stats(popu, target)
    } else {
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

    alive := rl.TextFormat("Alive: %d", popu.alive_count)
    rl.DrawText(alive, 10, 30, 16, rl.RAYWHITE)

    avg := rl.TextFormat("Avg Fit: %.2f", popu.avg_fitness)
    rl.DrawText(avg, 10, 50, 16, rl.RAYWHITE)

    max := rl.TextFormat("Max Fit: %.2f", popu.max_fitness)
    rl.DrawText(max, 10, 70, 16, rl.RAYWHITE)
}
