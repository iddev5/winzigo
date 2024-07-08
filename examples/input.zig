const std = @import("std");
const winzigo = @import("winzigo");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var core = try winzigo.init(allocator);
    defer core.deinit();

    var window = try core.createWindow(.{});
    defer window.deinit();

    var is_running: bool = true;
    while (is_running) {
        while (core.pollEvent()) |event| {
            switch (event.ev) {
                .quit => |_| {
                    std.log.info("quit", .{});
                    is_running = false;
                },
                else => {},
            }
        }

        if (core.getKeyDown(.a)) {
            std.log.info("key .a is currently down", .{});
        }
        std.posix.nanosleep(0, 16000000);
    }
    std.log.info("All your inputs are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
