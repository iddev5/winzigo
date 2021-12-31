const std = @import("std");
const winzigo = @import("winzigo");

var core: winzigo = undefined;

pub fn init() !void {
    core = try winzigo.init();
    errdefer core.deinit();

    var window = core.createWindow(.{});
    errdefer window.deinit();

    window.setTitle("Hello");
    window.setSize(512, 512);
}

pub fn update() !bool {
    while (core.pollEvent()) |event| {
        switch (event.ev) {
            .quit => |_| {
                std.log.info("quit", .{});
                return false;
            },
            else => {},
        }
    }
    return true;
}

pub fn deinit() void {
    core.deinit();
    std.log.info("All your window decorations are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
