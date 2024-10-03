package main

import "core:math/rand"

Dna :: struct {
    moves: [MovesCount][2]f32,
    step: i32,
}

dna_mutate :: proc(dna: Dna) -> Dna {
    new_dna: Dna
    for i in 0..<MovesCount {
        chance := rand.float32()
        if chance < MutationRate do new_dna.moves[i] = random_vector()
        else do new_dna.moves[i] = dna.moves[i]
    }
    return new_dna
}
