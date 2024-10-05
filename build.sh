#! /bin/sh

set -xe

odin build src -strict-style -vet -out:smart_dots
