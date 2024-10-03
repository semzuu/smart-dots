package main

import "core:math/rand"

Dna :: struct {
    moves: [][2]f32,
    step: i32,
}

dna_init :: proc(dna: ^Dna) {
    dna.step = 0
    if dna.moves != nil do delete_slice(dna.moves, context.temp_allocator)
    dna.moves = make_slice([][2]f32, MovesCount, context.temp_allocator)
}

dna_mutate :: proc(dna: Dna) -> Dna {
    new_dna: Dna
    dna_init(&new_dna)
    for i in 0..<MovesCount {
        chance := rand.float32()
        if chance < MutationRate do new_dna.moves[i] = random_vector()
        else do new_dna.moves[i] = dna.moves[i]
    }
    return new_dna
}

dna_crossover :: proc(parents: []Dna) -> Dna {
    baby: Dna
    dna_init(&baby)
    for i in 0..<MovesCount {
        selected := rand.choice(parents)
        baby.moves[i] = selected.moves[i]
    }
    return baby
}
