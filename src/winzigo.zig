const xcb = @import("xcb/Core.zig");

pub const Button = enum(u8) {
    left,
    right,
    middle,
};

pub const ScrollDir = enum(u8) {
    up,
    down,
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
    ten,
    unknown,
};

pub const Event = struct {
    window: *Window,
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
            scroll_dir: ScrollDir,
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
    
    pub fn pollEvent(core: *Core) ?xcb.Event {
        return core.internal.pollEvent();
    }
    
    pub fn waitEvent(core: *Core) ?xcb.Event {
        return core.internal.waitEvent();
    }
};

pub const Window = struct {
    internal: WindowType(),
  
    pub fn init(info: WindowInfo) Window {
        return .{ .internal = WindowType().init(info) };
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
