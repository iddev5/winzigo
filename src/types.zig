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
    unknown,
};

pub const Event = union(enum) {
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
};

pub const WindowInfo = struct {
    title: ?[]const u8 = null,
    width: u16 = 256,
    height: u16 = 256,
};
