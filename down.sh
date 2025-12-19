#!/bin/bash

# Shouldn't need to remove links, but just in case...
stow -D -v --dotfiles -t ~ home
