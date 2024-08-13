const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var input_buffer = std.ArrayList(u8).init(allocator);
    defer input_buffer.deinit();

    const stdin = std.io.getStdIn().reader();
    var buf: [4096]u8 = undefined;

    while (true) {
        const bytesRead = try stdin.read(buf[0..]);
        if (bytesRead == 0) break; // No more data to read, i.e., EOF
        try input_buffer.appendSlice(buf[0..bytesRead]);
    }

    const program = input_buffer.items;
    var tape = std.ArrayList(u8).initCapacity(allocator, 30000) catch {
        std.debug.print("Failed to allocate memory for tape.\n", .{});
        return;
    };
    defer tape.deinit();

    // Initialize the tape with zeros
    while (tape.items.len < 30000) {
        try tape.append(0);
    }

    var cell_index: usize = 0;
    var user_input = std.ArrayList(u8).init(allocator);
    defer user_input.deinit();

    var ip: usize = 0; // Instruction pointer

    var loop_table = std.AutoHashMap(usize, usize).init(allocator);
    defer loop_table.deinit();

    var loop_stack = std.ArrayList(usize).init(allocator);
    defer loop_stack.deinit();

    while (ip < program.len) {
        const instruction = program[ip];

        switch (instruction) {
            '[' => {
                loop_stack.append(ip) catch {
                    std.debug.print("Error: Unable to append to loop_stack.\n", .{});
                    return;
                };
            },
            ']' => {
                if (loop_stack.items.len > 0) {
                    const loop_start_index = loop_stack.pop();
                    loop_table.put(loop_start_index, ip) catch {
                        std.debug.print("Error: Unable to insert into loop_table.\n", .{});
                        return;
                    };
                    loop_table.put(ip, loop_start_index) catch {
                        std.debug.print("Error: Unable to insert into loop_table.\n", .{});
                        return;
                    };
                } else {
                    std.debug.print("Error: No matching '[' for ']' at index {}.\n", .{ip});
                    return;
                }
            },
            else => {},
        }
        ip += 1;
    }

    ip = 0;
    while (ip < program.len) {
        const instruction = program[ip];
        var increment_ip = true;

        switch (instruction) {
            '+' => {
                tape.items[cell_index] += 1;
                if (tape.items[cell_index] == 256) {
                    tape.items[cell_index] = 0;
                }
            },
            '-' => {
                if (tape.items[cell_index] == 0) {
                    tape.items[cell_index] = 255;
                } else {
                    tape.items[cell_index] -= 1;
                }
            },
            '<' => {
                if (cell_index > 0) {
                    cell_index -= 1; // Only decrement if above 0 to avoid underflow
                }
            },
            '>' => {
                cell_index += 1;
                if (cell_index >= tape.items.len) {
                    try tape.append(0); // Ensure tape can grow as needed
                }
            },
            '.' => {
                const output = tape.items[cell_index];
                try std.io.getStdOut().writeAll(&[_]u8{output});
            },
            ',' => {
                if (user_input.items.len == 0) {
                    const line = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096);
                    if (line) |actualLine| {
                        try user_input.appendSlice(actualLine);
                    }
                }
                if (user_input.items.len != 0) {
                    tape.items[cell_index] = user_input.items[0];
                    user_input.items = user_input.items[1..];
                }
            },
            '[' => {
                if (tape.items[cell_index] == 0) {
                    // Jump forward to the matching ']'
                    ip = loop_table.get(ip).?; // Unwrap safely
                    increment_ip = false;
                }
            },
            ']' => {
                if (tape.items[cell_index] != 0) {
                    // Jump back to the matching '['
                    ip = loop_table.get(ip).?; // Unwrap safely
                    increment_ip = false;
                }
            },
            else => {},
        }

        if (increment_ip) {
            ip += 1;
        }
    }
}
