package main

import "core:math/rand"

Dna :: struct {
    moves: [][2]f32,
}

dna_init :: proc(dna: ^Dna) {
    if dna.moves != nil do delete(dna.moves)
    dna.moves = make([][2]f32, MovesCount)
}

dna_mutate :: proc(dna: ^Dna) {
    for i in 0..<MovesCount {
        chance := rand.float32()
        if chance < MutationRate do dna.moves[i] = random_vector()
        else do dna.moves[i] = dna.moves[i]
    }
}

dna_crossover :: proc(baby: ^Dna, parents: []Dna) {
    mid := rand.int_max(MovesCount)
    for i in 0..<MovesCount {
        if i < mid {
            baby.moves[i] = parents[0].moves[i]
        } else {
            baby.moves[i] = parents[1].moves[i]
        }
    }
}
