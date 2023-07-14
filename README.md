# codegen
Code generation library and tools

## Requirements
- neovim

## Building blocks
The idea is that most codegen out there assumes too much about your codebase.

We want to empower users to create their own codegen actions. This repo
contains those reusable building blocks and the end user will use them to
create custom codegen tools appropriate to their own codebase. Everyone's needs are
different but the tools used to fulfill those needs are common enough to warrant
a dedicated library. That's what this `py-codegen` is about.

Manipulating and querying code is different for every programming language.

We should try as much as possible to create reusable functions that works 
for any lang but there will always be features specific to a lang.
