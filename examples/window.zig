const std = @import("std");
const winzigo = @import("winzigo");

pub fn main() anyerror!void {
    var core = try winzigo.init();
    defer core.deinit();

    var window = core.createWindow(.{});
    defer window.deinit();

    window.setTitle("Hello");
    window.setSize(512, 512);

    var is_running: bool = true;
    while (is_running) {
        if (core.pollEvent()) |event| {
            switch (event.ev) {
                .quit => |_| {
                    std.log.info("quit", .{});
                    is_running = false;
                },
                else => {},
            }
        }
    }
    std.log.info("All your window decorations are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
