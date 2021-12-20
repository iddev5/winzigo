const xcb = @import("xcb/Core.zig");

pub const Button = enum(u8) {
    left,
    right,
    middle,
};

pub const Key = enum(u8) {
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,

    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,

    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    f13,
    f14,
    f15,
    f16,
    f17,
    f18,
    f19,
    f20,
    f21,
    f22,
    f23,
    f24,
    f25,

    kp_divide,
    kp_multiply,
    kp_subtract,
    kp_add,
    kp_0,
    kp_1,
    kp_2,
    kp_3,
    kp_4,
    kp_5,
    kp_6,
    kp_7,
    kp_8,
    kp_9,
    kp_decimal,
    kp_equal,
    kp_enter,

    @"return",
    escape,
    tab,
    left_shift,
    right_shift,
    left_control,
    right_control,
    left_alt,
    right_alt,
    left_super,
    right_super,
    menu,
    num_lock,
    caps_lock,
    print,
    scroll_lock,
    pause,
    delete,
    home,
    end,
    page_up,
    page_down,
    insert,
    left,
    right,
    up,
    down,
    backspace,
    space,
    minus,
    equal,
    left_bracket,
    right_bracket,
    backslash,
    semicolon,
    apostrophe,
    comma,
    period,
    slash,
    grave,
    unknown,
};

pub const Event = struct {
    window: Window,
    ev: union(enum) {
        key_press: struct {
            key: Key,
        },
        key_release: struct {
            key: Key,
        },
        button_press: struct {
            button: Button,
        },
        button_release: struct {
            button: Button,
        },
        mouse_scroll: struct {
            scroll_x: i2,
            scroll_y: i2,
        },
        mouse_motion: struct {
            x: u32,
            y: u32,
        },
        quit: void,
    },
};

pub const WindowInfo = struct {
    title: ?[]const u8 = null,
    width: u16 = 256,
    height: u16 = 256,
};
fn CoreType() type {
    return xcb;
}

fn WindowType() type {
    return xcb.Window;
}

pub const Core = struct {
    internal: CoreType(),

    pub fn init() !Core {
        return Core{ .internal = try CoreType().init() };
    }

    pub fn deinit(core: *Core) void {
        core.internal.deinit();
    }

    pub fn createWindow(core: *Core, info: WindowInfo) Window {
        return .{ .internal = core.internal.createWindow(info) };
    }

    pub fn pollEvent(core: *Core) ?Event {
        return core.internal.pollEvent();
    }

    pub fn waitEvent(core: *Core) ?Event {
        return core.internal.waitEvent();
    }

    pub fn getKeyDown(core: *Core, key: Key) bool {
        return core.internal.getKeyDown(key);
    }
};

pub const Window = struct {
    internal: WindowType(),

    pub fn init(info: WindowInfo) Window {
        return .{ .internal = WindowType().init(info) };
    }

    pub fn initFromInternal(internal: WindowType()) Window {
        return .{ .internal = internal };
    }

    pub fn deinit(window: *Window) void {
        window.internal.deinit();
    }

    pub fn setTitle(window: *Window, title: []const u8) void {
        window.internal.setTitle(title);
    }

    pub fn setSize(window: *Window, width: u16, height: u16) void {
        window.internal.setSize(width, height);
    }
};
