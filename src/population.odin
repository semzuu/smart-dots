package main

import "core:slice"
import "core:math/rand"
import rl "vendor:raylib"

tournament_select :: proc(pool: []Dot, popu: Population) -> Dna {
    size := 5
    tournament: [5]Dot
    best_fit, best_index := f32(0), 0
    for i in 0..<size {
        tournament[i] = rand.choice(pool)
        if tournament[i].fitness > best_fit {
            best_fit = tournament[i].fitness
            best_index = i
        }
    }
    return tournament[best_index].dna
}

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
    slice.sort_by(popu.dots, proc(i, j: Dot) -> bool {
        return i.fitness < j.fitness
    })
    for i in 0..<PopulationSize {
        if i < ElitesCount do dot_init(&popu.dots[i])
        else {
            parents: [2]Dna
            for &parent in parents do parent = tournament_select(popu.dots, popu^)
            dot_init(&popu.dots[i])
            dna_crossover(&popu.dots[i].dna, parents[:])
            dna_mutate(&popu.dots[i].dna)
        }
    }
}

Population :: struct {
    gen, alive_count, finished_count, best_index: int,
    dots: []Dot,
    max_fitness, avg_fitness, sum_fitness: f32,
}

population_init :: proc(popu: ^Population) {
    popu.alive_count = PopulationSize
    if popu.dots != nil do delete(popu.dots)
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
    text: cstring
    for dot, i in popu.dots {
        dot_draw(dot, i == popu.best_index)
    }
    text = rl.TextFormat("Gen: %d", popu.gen)
    rl.DrawText(text, 10, 10, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Alive: %d", popu.alive_count)
    rl.DrawText(text, 10, 30, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Finished: %d", popu.finished_count)
    rl.DrawText(text, 10, 50, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Avg Fit: %f", popu.avg_fitness)
    rl.DrawText(text, 10, 70, text_size, rl.RAYWHITE)

    text = rl.TextFormat("Max Fit: %f", popu.max_fitness)
    rl.DrawText(text, 10, 90, text_size, rl.RAYWHITE)
}
