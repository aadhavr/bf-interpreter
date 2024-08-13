# Zig Brainfuck Interpreter

This repository contains a Brainfuck interpreter written in Zig. It allows you to run Brainfuck code, a programming language with eight commands.

## Features

- Interpret and execute Brainfuck code.
- Handle dynamic memory allocation for Brainfuck's tape.
- Input and output operations as specified by Brainfuck's design.

## Getting Started

### Prerequisites

- Install [Zig](https://ziglang.org/download/) on your system.

### Building the Project

To build the interpreter, run the following command in the root of the project:

```bash
zig build-exe src/main.zig
```

### Usage

To run a Brainfuck program, use the executable generated from the build process:

```bash
./main < path/to/your/brainfuck_program.bf
```

Or you can directly input the Brainfuck code:

```bash
echo "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>." | ./main
```

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Licensing

This project is licensed under the MIT License.