const std = @import("std");
const winzigo = @import("winzigo");

pub fn main() anyerror!void {
    var core = try winzigo.Core.init();
    defer core.deinit();

    var window = core.createWindow(.{});
    defer window.deinit();

    var is_running: bool = true;
    while (is_running) {
        if (core.pollEvent()) |event| {
            switch (event.ev) {
                .key_press => |ev| {
                    if (ev.key == .escape) is_running = false;
                    std.log.info("key pressed {s}", .{@tagName(ev.key)});
                },
                .key_release => |ev| {
                    std.log.info("key released {s}", .{@tagName(ev.key)});
                },
                .button_press => |ev| {
                    std.log.info("button pressed {s}", .{@tagName(ev.button)});
                },
                .button_release => |ev| {
                    std.log.info("button released {s}", .{@tagName(ev.button)});
                },
                .mouse_scroll => |ev| {
                    std.log.info("mouse scroll {s}", .{@tagName(ev.scroll_dir)});
                },
                .mouse_motion => |ev| {
                    std.log.info("mouse pos x: {} y: {}", .{ ev.x, ev.y });
                },
                .quit => |_| {
                    std.log.info("quit", .{});
                    is_running = false;
                },
            }
        }

        std.log.info("A State: {}", .{core.getKeyDown(.a)});
        std.os.nanosleep(0, 16000000);
    }
    std.log.info("All your queued events are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
