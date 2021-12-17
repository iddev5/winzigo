const Core = @This();
const std = @import("std");
const types = @import("../types.zig");
const xcb = @import("bindings.zig");
const Window = @import("Window.zig");

connection: *xcb.Connection,
setup: *xcb.Setup,
screen: *xcb.Screen,
window: *Window,
wm_protocols: *xcb.InternAtomReply,
wm_delete_window: *xcb.InternAtomReply,

pub fn init() !Core {
    var core: Core = undefined;

    core.connection = try xcb.connect("", null);
    core.setup = try xcb.getSetup(core.connection);

    const screen_iter = xcb.setupRootsIterator(core.setup);
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
    std.c.free(core.wm_protocols);
    std.c.free(core.wm_delete_window);
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

pub const Event = struct {
    window: *Window,
    ev: types.Event,
};

const Button = types.Button;
const ScrollDir = types.ScrollDir;
const Key = types.Key;

inline fn translateButton(core: *Core, but: u8) Button {
    // Note: xcb headers are docs seem to be confusing here
    // xproto.h mentions code 2 to be right and 3 to be middle.
    // But in practice 2 is middle and 3 is right (confusing!)
    //
    // This has also been confirmed with glfw enum IDs
    _ = core;
    return switch (but) {
        1 => .left,
        2 => .middle,
        3 => .right,
        else => unreachable,
    };
}

inline fn translateScrollDir(core: *Core, but: u8) ScrollDir {
    _ = core;
    return switch (but) {
        4 => .up,
        5 => .down,
        else => unreachable,
    };
}

const xk = @import("keys.zig");

inline fn translateKey(core: *Core, keycode: u8) Key {
    const keyboard_mapping_req = xcb.getKeyboardMapping(core.connection, keycode, 1);
    var keyboard_mapping = xcb.getKeyboardMappingReply(core.connection, keyboard_mapping_req, null);
    defer std.c.free(keyboard_mapping);

    const keysyms = xcb.getKeyboardMappingKeysyms(keyboard_mapping);
    return switch (keysyms[1]) {
        xk.XK_A => .a,
        xk.XK_B => .b,
        xk.XK_C => .c,
        xk.XK_D => .d,
        xk.XK_E => .e,
        xk.XK_F => .f,
        xk.XK_G => .g,
        xk.XK_H => .h,
        xk.XK_I => .i,
        xk.XK_J => .j,
        xk.XK_K => .k,
        xk.XK_L => .l,
        xk.XK_M => .m,
        xk.XK_N => .m,
        xk.XK_O => .o,
        xk.XK_P => .p,
        xk.XK_Q => .q,
        xk.XK_R => .r,
        xk.XK_S => .s,
        xk.XK_T => .t,
        xk.XK_U => .u,
        xk.XK_V => .v,
        xk.XK_W => .w,
        xk.XK_X => .x,
        xk.XK_Y => .y,
        xk.XK_Z => .z,
        else => .unknown,
    };
}

fn handleEvent(core: *Core, event: ?*xcb.GenericEvent) ?Event {
    if (event) |ev| {
        switch (xcb.eventResponse(ev)) {
            .KeyPress => {
                const kp = @ptrCast(*xcb.KeyPressEvent, ev);
                return Event{
                    .window = core.window,
                    .ev = .{ .key_press = .{ .key = core.translateKey(kp.detail) } },
                };
            },
            .KeyRelease => {
                // TODO: XServer sometimes return this as KeyRelease + KeyPress pairs
                // This causes problem because we dont know when the key is
                // actually released. Solve this using delta time
                const kp = @ptrCast(*xcb.KeyReleaseEvent, ev);
                return Event{
                    .window = core.window,
                    .ev = .{ .key_release = .{ .key = core.translateKey(kp.detail) } },
                };
            },
            .ButtonPress => {
                const bp = @ptrCast(*xcb.ButtonPressEvent, ev);
                switch (bp.detail) {
                    1, 2, 3 => return Event{
                        .window = core.window,
                        .ev = .{ .button_press = .{ .button = core.translateButton(bp.detail) } },
                    },
                    4, 5 => return Event{
                        .window = core.window,
                        .ev = .{ .mouse_scroll = .{ .scroll_dir = core.translateScrollDir(bp.detail) } },
                    },
                    else => {},
                }
            },
            .ButtonRelease => {
                const br = @ptrCast(*xcb.ButtonReleaseEvent, ev);
                switch (br.detail) {
                    1, 2, 3 => return Event{
                        .window = core.window,
                        .ev = .{ .button_release = .{ .button = core.translateButton(br.detail) } },
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
