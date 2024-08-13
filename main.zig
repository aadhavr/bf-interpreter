const std = @import("std");

pub fn main() void {
    const allocator = std.heap.page_allocator;
    var input_buffer = try std.ArrayList(u8).init(allocator);
    defer input_buffer.deinit();

    const stdin = std.io.getStdIn().reader();
    try stdin.readAllBuffer(&input_buffer);

    var program = input_buffer.items;
    var tape = try std.ArrayList(u8).initCapacity(allocator, 30000);
    var cell_index: usize = 0;

    var user_input: []u8 = &[_]u8{}; // Placeholder for future use
    var ip: usize = 0; // Instruction pointer

    while (ip < program.len) {
        const instruction = program[ip];

        switch (instruction) {
            '+' => {
                tape[cell_index] += 1;
                if (tape[cell_index] == 256) {
                    tape[cell_index] = 0;
                }
            },
            '-' => {
                tape[cell_index] -= 1;
                if (tape[cell_index] == -1) {
                    tape[cell_index] = 255;
                }
            },
            '<' => {
                cell_index -= 1;
            },
            '>' => {
                cell_index += 1;
                if (cell_index == tape.items.len) {
                    try tape.append(0);
                }
            },
            '.' => {
                std.debug.print("{c}", .{tape[cell_index]});
            },
            ',' => {
                if (user_input.items.len == 0) {
                    try stdin.readUntilDelimiterOrEof(&user_input, '\n'); // Read a line
                    user_input.append('\n') catch {}; // Append newline manually
                }
                if (user_input.items.len != 0) {
                    const char = user_input.items[0];
                    user_input.items = user_input.items[1..]; // Remove the first character
                    tape[cell_index] = char; // Store ASCII value
                }
            },
            else => {
                // Handle unexpected instruction
            },
        }

        ip += 1;
    }
}
