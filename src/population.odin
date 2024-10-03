package main

import "core:slice"
import "core:math/rand"
import rl "vendor:raylib"

roulette_select :: proc(pool: []Dot, popu: Population) -> Dna {
    for {
        parent := rand.int_max(PopulationSize)
        chance := rand.float32()
        if chance < pool[parent].fitness / popu.sum_fitness {
            return pool[parent].dna
        }
    }
}

update_stats :: proc(popu: ^Population, target: Target) {
    popu.max_fitness, popu.avg_fitness, popu.sum_fitness = f32(0), f32(0), f32(0)
    alive, finished: int
    for &dot, i in popu.dots {
        dot.fitness = calculate_fitness(dot, target)
        popu.sum_fitness += dot.fitness
        if dot.fitness > popu.max_fitness {
            popu.max_fitness = dot.fitness
            popu.best_index = i
        }
        if dot.alive do alive += 1
        if dot.finished do finished += 1
    }
    popu.alive_count, popu.finished_count = alive, finished
    popu.avg_fitness = popu.sum_fitness / PopulationSize
}

next_gen :: proc(popu: ^Population) {
    defer {
        popu.finished_count = 0
        popu.alive_count = PopulationSize
        popu.gen += 1
    }
    best_moves := popu.dots[popu.best_index].dna.moves
    dot_init(&popu.dots[0])
    popu.dots[0].dna.moves = best_moves
    pool := popu.dots
    slice.sort_by(pool, proc(i, j: Dot) -> bool {
        return i.fitness < j.fitness
    })
    for count in 1..<PopulationSize {
        parents: [2]Dna
        for &parent in parents do parent = roulette_select(pool, popu^)
        dot_init(&popu.dots[count])
        popu.dots[count].dna = dna_mutate(dna_crossover(parents[:]))
    }
}

Population :: struct {
    gen, alive_count, finished_count, best_index: int,
    dots: []Dot,
    max_fitness, avg_fitness, sum_fitness: f32,
}

population_init :: proc(popu: ^Population) {
    popu.alive_count = PopulationSize
    if popu.dots != nil do delete_slice(popu.dots, context.temp_allocator)
    popu.dots = make_slice([]Dot, PopulationSize, context.temp_allocator)
    for &dot in popu.dots {
        dot_init(&dot)
        gen_moves(dot.dna.moves[:])
    }
}

population_update :: proc(popu: ^Population, target: Target, dt: f32) {
    if popu.alive_count > 0 {
        for &dot in popu.dots {
            dot_update(&dot, target, dt)
        }
        update_stats(popu, target)
    } else {
        next_gen(popu)
    }
}

population_draw :: proc(popu: Population) {
    text_size := i32(16)
    for dot, i in popu.dots {
        dot_draw(dot, i == popu.best_index)
    }
    gen := rl.TextFormat("Gen: %d", popu.gen)
    rl.DrawText(gen, 10, 10, text_size, rl.RAYWHITE)

    alive := rl.TextFormat("Alive: %d", popu.alive_count)
    rl.DrawText(alive, 10, 30, text_size, rl.RAYWHITE)

    finished := rl.TextFormat("Finished: %d", popu.finished_count)
    rl.DrawText(finished, 10, 50, text_size, rl.RAYWHITE)

    avg := rl.TextFormat("Avg Fit: %f", popu.avg_fitness)
    rl.DrawText(avg, 10, 70, text_size, rl.RAYWHITE)

    max := rl.TextFormat("Max Fit: %f", popu.max_fitness)
    rl.DrawText(max, 10, 90, text_size, rl.RAYWHITE)
}
