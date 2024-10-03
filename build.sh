#! /bin/sh

set -xe

odin build src -strict-style -out:smart_dots -o:speed -vet
