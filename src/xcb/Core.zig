const Core = @This();
const std = @import("std");
const types = @import("../types.zig");
const xcb = @import("bindings.zig");
const Window = @import("Window.zig");

connection: *xcb.Connection,
screen: *xcb.Screen,
window: *Window,
wm_protocols: *xcb.InternAtomReply,
wm_delete_window: *xcb.InternAtomReply,

pub fn init() !Core {
    var core: Core = undefined;

    core.connection = try xcb.connect("", null);

    const screen_iter = xcb.setupRootsIterator(try xcb.getSetup(core.connection));
    core.screen = screen_iter.data.?;

    const wm_protocols_atom = xcb.internAtom(core.connection, true, "WM_PROTOCOLS".len, "WM_PROTOCOLS");
    const wm_protocols_reply = xcb.internAtomReply(core.connection, wm_protocols_atom, null);

    const wm_delete_window_atom = xcb.internAtom(core.connection, false, "WM_DELETE_WINDOW".len, "WM_DELETE_WINDOW");
    const wm_delete_window_reply = xcb.internAtomReply(core.connection, wm_delete_window_atom, null);

    core.wm_protocols = wm_protocols_reply;
    core.wm_delete_window = wm_delete_window_reply;

    return core;
}

pub fn deinit(core: *Core) void {
    xcb.disconnect(core.connection);
}

pub fn createWindow(core: *Core, info: types.WindowInfo) Window {
    var window = Window.init(core, info);
    _ = xcb.changeProperty(
        core.connection,
        .Replace,
        window.window,
        core.wm_protocols.atom,
        4,
        32,
        1,
        &core.wm_delete_window.atom,
    );

    // TODO: Actually support multiple window
    core.window = &window;
    return window;
}

pub fn pollEvent(core: *Core) ?Event {
    _ = xcb.flush(core.connection);
    var event = xcb.pollForEvent(core.connection);
    defer if (event) |ev| std.c.free(ev);

    return core.handleEvent(event);
}

pub fn waitEvent(core: *Core) ?Event {
    _ = xcb.flush(core.connection);
    var event = xcb.waitForEvent(core.connection);
    defer if (event) |ev| std.c.free(ev);

    return core.handleEvent(event);
}

const ButtonType = types.ButtonType;
const ScrollDir = types.ScrollDir;

pub const Event = struct {
    window: *Window,
    ev: types.Event,
};

inline fn toButtonType(but: u8) ButtonType {
    // Note: xcb headers are docs seem to be confusing here
    // xproto.h mentions code 2 to be right and 3 to be middle.
    // But in practice 2 is middle and 3 is right (confusing!)
    //
    // This has also been confirmed with glfw enum IDs
    return switch (but) {
        1 => .left,
        2 => .middle,
        3 => .right,
        else => unreachable,
    };
}

inline fn toScrollDir(but: u8) ScrollDir {
    return switch (but) {
        4 => .up,
        5 => .down,
        else => unreachable,
    };
}

fn handleEvent(core: *Core, event: ?*xcb.GenericEvent) ?Event {
    if (event) |ev| {
        switch (xcb.eventResponse(ev)) {
            .KeyPress => {
                const kp = @ptrCast(*xcb.KeyPressEvent, ev);
                return Event{
                    .window = core.window,
                    .ev = .{ .key_press = .{ .scancode = kp.detail } },
                };
            },
            .KeyRelease => {
                // TODO: XServer sometimes return this as KeyRelease + KeyPress pairs
                // This causes problem because we dont know when the key is
                // actually released. Solve this using delta time
                const kp = @ptrCast(*xcb.KeyReleaseEvent, ev);
                return Event{
                    .window = core.window,
                    .ev = .{ .key_release = .{ .scancode = kp.detail } },
                };
            },
            .ButtonPress => {
                const bp = @ptrCast(*xcb.ButtonPressEvent, ev);
                switch (bp.detail) {
                    1, 2, 3 => return Event{
                        .window = core.window,
                        .ev = .{ .button_press = .{ .button = toButtonType(bp.detail) } },
                    },
                    4, 5 => return Event{
                        .window = core.window,
                        .ev = .{ .mouse_scroll = .{ .scroll_dir = toScrollDir(bp.detail) } },
                    },
                    else => {},
                }
            },
            .ButtonRelease => {
                const br = @ptrCast(*xcb.ButtonReleaseEvent, ev);
                switch (br.detail) {
                    1, 2, 3 => return Event{
                        .window = core.window,
                        .ev = .{ .button_release = .{ .button = toButtonType(br.detail) } },
                    },
                    else => {},
                }
            },
            .MotionNotify => {
                const mn = @ptrCast(*xcb.MotionNotifyEvent, ev);
                return Event{
                    .window = core.window,
                    .ev = .{ .mouse_motion = .{
                        .x = @intCast(u32, mn.event_x),
                        .y = @intCast(u32, mn.event_y),
                    } },
                };
            },
            .ClientMessage => {
                const cm = @ptrCast(*xcb.ClientMessageEvent, event);
                if (cm.data.data32[0] == core.wm_delete_window.atom) {
                    return Event{
                        .window = core.window,
                        .ev = .{ .quit = .{} },
                    };
                }
            },
            // else => {},
        }
    }
    return null;
}
