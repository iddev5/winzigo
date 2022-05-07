const std = @import("std");
const winzigo = @import("winzigo");

var core: winzigo = undefined;

pub fn init() !void {
    core = try winzigo.init();
    errdefer core.deinit();

    var window = core.createWindow(.{});
    errdefer window.deinit();

    _ = window;
}

pub fn update() !bool {
    while (core.pollEvent()) |event| {
        switch (event.ev) {
            .key_press => |ev| {
                if (ev.key == .escape) return false;
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
                std.log.info("mouse scroll x: {} y: {}", .{ ev.scroll_x, ev.scroll_y });
            },
            .mouse_motion => |ev| {
                std.log.info("mouse pos x: {} y: {}", .{ ev.x, ev.y });
            },
            .mouse_enter => |ev| {
                std.log.info("mouse entered window at x: {} y: {}", .{ ev.x, ev.y });
            },
            .mouse_leave => |ev| {
                std.log.info("mouse left window at x: {} y: {}", .{ ev.x, ev.y });
            },
            .focus_in => |_| {
                std.log.info("gained focus", .{});
            },
            .focus_out => |_| {
                std.log.info("lost focus", .{});
            },
            .window_resize => |ev| {
                std.log.info("window resized, width: {} height: {}", .{ ev.width, ev.height });
            },
            .quit => |_| {
                std.log.info("quit", .{});
                return false;
            },
        }
    }

    return true;
}

pub fn deinit() void {
    core.deinit();
    std.log.info("All your queued events are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
