package main

import "core:slice"
import "core:math/rand"
import rl "vendor:raylib"

update_stats :: proc(popu: ^Population, target: Target) {
    popu.max_fitness, popu.avg_fitness, popu.sum_fitness = f32(0), f32(0), f32(0)
    dead, finished: int
    for &dot, i in popu.dots {
        dot.fitness = calculate_fitness(dot, target)
        popu.sum_fitness += dot.fitness
        if dot.fitness > popu.max_fitness {
            popu.max_fitness = dot.fitness
            popu.best_index = i
        }
        if dot.finished do finished += 1
        if dot.finished || dot.hit do dead += 1
    }
    popu.finished_count = finished
    popu.dead_count = dead
    popu.avg_fitness = popu.sum_fitness / PopulationSize
}

next_gen :: proc(popu: ^Population) {
    defer {
        popu.step = 0
        popu.finished_count = 0
        popu.dead_count = 0
        popu.gen += 1
    }
    slice.reverse_sort_by(popu.dots, proc(i, j: Dot) -> bool {
        return i.fitness < j.fitness
    })
    pool: [dynamic]Dna
    for dot in popu.dots {
        norm := (dot.fitness / popu.max_fitness) * 100
        for _ in 0..<norm do append(&pool, dot.dna)
    }
    for i in 0..<PopulationSize {
        if i < ElitesCount do dot_init(&popu.dots[i])
        else {
            parents: [2]Dna
            for &parent in parents do parent = rand.choice(pool[:])
            dot_init(&popu.dots[i])
            dna_crossover(&popu.dots[i].dna, parents[:])
            dna_mutate(&popu.dots[i].dna)
        }
    }
}

Population :: struct {
    gen, step, dead_count, finished_count, best_index: int,
    dots: []Dot,
    max_fitness, avg_fitness, sum_fitness: f32,
}

population_init :: proc(popu: ^Population) {
    popu.gen = 0
    if popu.dots != nil do population_deinit(popu)
    popu.dots = make([]Dot, PopulationSize)
    for &dot in popu.dots {
        dot_init(&dot)
        dna_init(&dot.dna)
        gen_moves(dot.dna.moves[:])
    }
}

population_deinit :: proc(popu: ^Population) {
    for &dot in popu.dots {
        delete(dot.dna.moves)
    }
    delete(popu.dots)
}

population_update :: proc(popu: ^Population, target: Target, obstacles: [dynamic]Obstacle, dt: f32) {
    if popu.dead_count < PopulationSize && popu.step < MovesCount {
        for &dot in popu.dots {
            dot_update(&dot, popu.step, target, obstacles, dt)
        }
        popu.step += 1
        update_stats(popu, target)
    } else {
        next_gen(popu)
    }
}

population_draw :: proc(popu: Population) {
    text_size := i32(16)
    text: cstring
    for dot, i in popu.dots {
        dot_draw(dot, i == popu.best_index)
    }
    text = rl.TextFormat("Gen: %d", popu.gen)
    rl.DrawText(text, 10, 10, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Step: %d", popu.step)
    rl.DrawText(text, 10, 30, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Finished: %d", popu.finished_count)
    rl.DrawText(text, 10, 50, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Avg Fit: %f", popu.avg_fitness)
    rl.DrawText(text, 10, 70, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Max Fit: %f", popu.max_fitness)
    rl.DrawText(text, 10, 90, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Dead: %d", popu.dead_count)
    rl.DrawText(text, 10, 110, text_size, rl.RAYWHITE)
}
