const Core = @This();
const std = @import("std");
const xcb = @import("bindings.zig");
pub const Window = @import("Window.zig");

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

pub fn getKeyDown(core: *Core, key: Key) bool {
    // Convert key to keysym
    const keysym: u32 = core.translateKey(key);

    // Get keysyms from keycode
    const keyboard_mapping_req = xcb.getKeyboardMapping(core.connection, core.setup.min_keycode, core.setup.max_keycode - core.setup.min_keycode + 1);
    var keyboard_mapping = xcb.getKeyboardMappingReply(core.connection, keyboard_mapping_req, null);
    defer std.c.free(keyboard_mapping);

    const keysyms = xcb.getKeyboardMappingKeysyms(keyboard_mapping);

    // Convert keysym to keycode
    var keycode: u8 = 0;
    var i: usize = 0;
    while (i < 256) : (i += 1) {
        if (keysyms[i * keyboard_mapping.keysyms_per_keycode] == keysym) {
            keycode = @intCast(u8, i + core.setup.min_keycode);
            break;
        }
    }

    // Get all key states
    const cookie = xcb.queryKeymap(core.connection);
    const key_states = xcb.queryKeymapReply(core.connection, cookie, null);

    // Get the specific key state from keycode
    return key_states.keys[keycode / 8] & (@intCast(u8, 1) << @intCast(u3, (keycode % 8))) != 0;
}

const types = @import("../main.zig");

const Event = types.Event;
const Button = types.Button;
const ScrollDir = types.ScrollDir;
const Key = types.Key;

inline fn xcbToWindow(window: *Window) types.Window {
    return types.Window.initFromInternal(window.*);
}

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

inline fn translateKeycode(core: *Core, keycode: u8) Key {
    const keyboard_mapping_req = xcb.getKeyboardMapping(core.connection, keycode, 1);
    var keyboard_mapping = xcb.getKeyboardMappingReply(core.connection, keyboard_mapping_req, null);
    defer std.c.free(keyboard_mapping);

    const keysyms = xcb.getKeyboardMappingKeysyms(keyboard_mapping);

    return switch (keysyms[0]) {
        xk.XK_a => .a,
        xk.XK_b => .b,
        xk.XK_c => .c,
        xk.XK_d => .d,
        xk.XK_e => .e,
        xk.XK_f => .f,
        xk.XK_g => .g,
        xk.XK_h => .h,
        xk.XK_i => .i,
        xk.XK_j => .j,
        xk.XK_k => .k,
        xk.XK_l => .l,
        xk.XK_m => .m,
        xk.XK_n => .m,
        xk.XK_o => .o,
        xk.XK_p => .p,
        xk.XK_q => .q,
        xk.XK_r => .r,
        xk.XK_s => .s,
        xk.XK_t => .t,
        xk.XK_u => .u,
        xk.XK_v => .v,
        xk.XK_w => .w,
        xk.XK_x => .x,
        xk.XK_y => .y,
        xk.XK_z => .z,

        xk.XK_0 => .zero,
        xk.XK_1 => .one,
        xk.XK_2 => .two,
        xk.XK_3 => .three,
        xk.XK_4 => .four,
        xk.XK_5 => .five,
        xk.XK_6 => .six,
        xk.XK_7 => .seven,
        xk.XK_8 => .eight,
        xk.XK_9 => .nine,

        xk.XK_F1 => .f1,
        xk.XK_F2 => .f2,
        xk.XK_F3 => .f3,
        xk.XK_F4 => .f4,
        xk.XK_F5 => .f5,
        xk.XK_F6 => .f6,
        xk.XK_F7 => .f7,
        xk.XK_F8 => .f8,
        xk.XK_F9 => .f9,
        xk.XK_F10 => .f10,
        xk.XK_F11 => .f11,
        xk.XK_F12 => .f12,
        xk.XK_F13 => .f13,
        xk.XK_F14 => .f14,
        xk.XK_F15 => .f15,
        xk.XK_F16 => .f16,
        xk.XK_F17 => .f17,
        xk.XK_F18 => .f18,
        xk.XK_F19 => .f19,
        xk.XK_F20 => .f20,
        xk.XK_F21 => .f21,
        xk.XK_F22 => .f22,
        xk.XK_F23 => .f23,
        xk.XK_F24 => .f24,
        xk.XK_F25 => .f25,

        xk.XK_KP_Divide => .kp_divide,
        xk.XK_KP_Multiply => .kp_multiply,
        xk.XK_KP_Subtract => .kp_subtract,
        xk.XK_KP_Add => .kp_add,

        xk.XK_KP_Insert => .kp_0,
        xk.XK_KP_End => .kp_1,
        xk.XK_KP_Down => .kp_2,
        xk.XK_KP_Page_Down => .kp_3,
        xk.XK_KP_Left => .kp_4,
        xk.XK_KP_Begin => .kp_5,
        xk.XK_KP_Right => .kp_6,
        xk.XK_KP_Home => .kp_7,
        xk.XK_KP_Up => .kp_8,
        xk.XK_KP_Page_Up => .kp_9,
        xk.XK_KP_Delete => .kp_decimal,
        xk.XK_KP_Equal => .kp_equal,
        xk.XK_KP_Enter => .kp_enter,

        xk.XK_Return => .@"return",
        xk.XK_Escape => .escape,
        xk.XK_Tab => .tab,
        xk.XK_Shift_L => .left_shift,
        xk.XK_Shift_R => .right_shift,
        xk.XK_Control_L => .left_control,
        xk.XK_Control_R => .right_control,
        xk.XK_Meta_L, xk.XK_Alt_L => .left_alt,
        xk.XK_Meta_R, xk.XK_Alt_R, xk.XK_Mode_switch => .right_alt,
        xk.XK_Super_L => .left_super,
        xk.XK_Super_R => .right_super,
        xk.XK_Menu => .menu,
        xk.XK_Num_Lock => .num_lock,
        xk.XK_Caps_Lock => .caps_lock,
        xk.XK_Print => .print,
        xk.XK_Scroll_Lock => .scroll_lock,
        xk.XK_Pause => .pause,
        xk.XK_Delete => .delete,
        xk.XK_Home => .home,
        xk.XK_End => .end,
        xk.XK_Page_Up => .page_up,
        xk.XK_Page_Down => .page_down,
        xk.XK_Insert => .insert,
        xk.XK_Left => .left,
        xk.XK_Right => .right,
        xk.XK_Up => .up,
        xk.XK_Down => .down,
        xk.XK_BackSpace => .backspace,
        xk.XK_space => .space,
        xk.XK_minus => .minus,
        xk.XK_equal => .equal,
        xk.XK_bracketleft => .left_bracket,
        xk.XK_bracketright => .right_bracket,
        xk.XK_backslash => .backslash,
        xk.XK_semicolon => .semicolon,
        xk.XK_apostrophe => .apostrophe,
        xk.XK_comma => .comma,
        xk.XK_period => .period,
        xk.XK_slash => .slash,
        xk.XK_grave => .grave,
        else => .unknown,
    };
}

inline fn translateKey(core: *Core, key: Key) u32 {
    _ = core;
    return switch (key) {
        .a => xk.XK_a,
        .b => xk.XK_b,
        .c => xk.XK_c,
        .d => xk.XK_d,
        .e => xk.XK_e,
        .f => xk.XK_f,
        .g => xk.XK_g,
        .h => xk.XK_h,
        .i => xk.XK_i,
        .j => xk.XK_j,
        .k => xk.XK_k,
        .l => xk.XK_l,
        .m => xk.XK_m,
        .n => xk.XK_n,
        .o => xk.XK_o,
        .p => xk.XK_p,
        .q => xk.XK_q,
        .r => xk.XK_r,
        .s => xk.XK_s,
        .t => xk.XK_t,
        .u => xk.XK_u,
        .v => xk.XK_v,
        .w => xk.XK_w,
        .x => xk.XK_x,
        .y => xk.XK_y,
        .z => xk.XK_z,

        .zero => xk.XK_0,
        .one => xk.XK_1,
        .two => xk.XK_2,
        .three => xk.XK_3,
        .four => xk.XK_4,
        .five => xk.XK_5,
        .six => xk.XK_6,
        .seven => xk.XK_7,
        .eight => xk.XK_8,
        .nine => xk.XK_9,

        .f1 => xk.XK_F1,
        .f2 => xk.XK_F2,
        .f3 => xk.XK_F3,
        .f4 => xk.XK_F4,
        .f5 => xk.XK_F5,
        .f6 => xk.XK_F6,
        .f7 => xk.XK_F7,
        .f8 => xk.XK_F8,
        .f9 => xk.XK_F9,
        .f10 => xk.XK_F10,
        .f11 => xk.XK_F11,
        .f12 => xk.XK_F12,
        .f13 => xk.XK_F13,
        .f14 => xk.XK_F14,
        .f15 => xk.XK_F15,
        .f16 => xk.XK_F16,
        .f17 => xk.XK_F17,
        .f18 => xk.XK_F18,
        .f19 => xk.XK_F19,
        .f20 => xk.XK_F20,
        .f21 => xk.XK_F21,
        .f22 => xk.XK_F22,
        .f23 => xk.XK_F23,
        .f24 => xk.XK_F24,
        .f25 => xk.XK_F25,

        .kp_divide => xk.XK_KP_Divide,
        .kp_multiply => xk.XK_KP_Multiply,
        .kp_subtract => xk.XK_KP_Subtract,
        .kp_add => xk.XK_KP_Add,

        .kp_0 => xk.XK_KP_Insert,
        .kp_1 => xk.XK_KP_End,
        .kp_2 => xk.XK_KP_Down,
        .kp_3 => xk.XK_KP_Page_Down,
        .kp_4 => xk.XK_KP_Left,
        .kp_5 => xk.XK_KP_Begin,
        .kp_6 => xk.XK_KP_Right,
        .kp_7 => xk.XK_KP_Home,
        .kp_8 => xk.XK_KP_Up,
        .kp_9 => xk.XK_KP_Page_Up,
        .kp_decimal => xk.XK_KP_Delete,
        .kp_equal => xk.XK_KP_Equal,
        .kp_enter => xk.XK_KP_Enter,

        .@"return" => xk.XK_Return,
        .escape => xk.XK_Escape,
        .tab => xk.XK_Tab,
        .left_shift => xk.XK_Shift_L,
        .right_shift => xk.XK_Shift_R,
        .left_control => xk.XK_Control_L,
        .right_control => xk.XK_Control_R,
        .left_alt => xk.XK_Alt_L,
        .right_alt => xk.XK_Alt_R,
        .left_super => xk.XK_Super_L,
        .right_super => xk.XK_Super_R,
        .menu => xk.XK_Menu,
        .num_lock => xk.XK_Num_Lock,
        .caps_lock => xk.XK_Caps_Lock,
        .print => xk.XK_Print,
        .scroll_lock => xk.XK_Scroll_Lock,
        .pause => xk.XK_Pause,
        .delete => xk.XK_Delete,
        .home => xk.XK_Home,
        .end => xk.XK_End,
        .page_up => xk.XK_Page_Up,
        .page_down => xk.XK_Page_Down,
        .insert => xk.XK_Insert,
        .left => xk.XK_Left,
        .right => xk.XK_Right,
        .up => xk.XK_Up,
        .down => xk.XK_Down,
        .backspace => xk.XK_BackSpace,
        .space => xk.XK_space,
        .minus => xk.XK_minus,
        .equal => xk.XK_equal,
        .left_bracket => xk.XK_bracketleft,
        .right_bracket => xk.XK_bracketright,
        .backslash => xk.XK_backslash,
        .semicolon => xk.XK_semicolon,
        .apostrophe => xk.XK_apostrophe,
        .comma => xk.XK_comma,
        .period => xk.XK_period,
        .slash => xk.XK_slash,
        .grave => xk.XK_grave,
        .unknown => unreachable,
    };
}

fn handleEvent(core: *Core, event: ?*xcb.GenericEvent) ?Event {
    if (event) |ev| {
        switch (xcb.eventResponse(ev)) {
            .KeyPress => {
                const kp = @ptrCast(*xcb.KeyPressEvent, ev);
                return Event{
                    .window = xcbToWindow(core.window),
                    .ev = .{ .key_press = .{ .key = core.translateKeycode(kp.detail) } },
                };
            },
            .KeyRelease => {
                const kp = @ptrCast(*xcb.KeyReleaseEvent, ev);
                const key = core.translateKeycode(kp.detail);

                if (core.pollEvent()) |next| {
                    if (next.ev == .key_press and next.ev.key_press.key == key) {
                        return null;
                    }
                }

                return Event{
                    .window = xcbToWindow(core.window),
                    .ev = .{ .key_release = .{ .key = key } },
                };
            },
            .ButtonPress => {
                const bp = @ptrCast(*xcb.ButtonPressEvent, ev);
                switch (bp.detail) {
                    1, 2, 3 => return Event{
                        .window = xcbToWindow(core.window),
                        .ev = .{ .button_press = .{ .button = core.translateButton(bp.detail) } },
                    },
                    4, 5 => return Event{
                        .window = xcbToWindow(core.window),
                        .ev = .{ .mouse_scroll = .{ .scroll_dir = core.translateScrollDir(bp.detail) } },
                    },
                    else => {},
                }
            },
            .ButtonRelease => {
                const br = @ptrCast(*xcb.ButtonReleaseEvent, ev);
                switch (br.detail) {
                    1, 2, 3 => return Event{
                        .window = xcbToWindow(core.window),
                        .ev = .{ .button_release = .{ .button = core.translateButton(br.detail) } },
                    },
                    else => {},
                }
            },
            .MotionNotify => {
                const mn = @ptrCast(*xcb.MotionNotifyEvent, ev);
                return Event{
                    .window = xcbToWindow(core.window),
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
                        .window = xcbToWindow(core.window),
                        .ev = .{ .quit = .{} },
                    };
                }
            },
            // else => {},
        }
    }
    return null;
}
