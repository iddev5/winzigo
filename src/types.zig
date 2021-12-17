pub const ButtonType = enum(u8) {
    left,
    right,
    middle,
};

pub const ScrollDir = enum(u8) {
    up,
    down,
};

pub const Event = union(enum) {
    key_press: struct {
        scancode: u8,
    },
    key_release: struct {
        scancode: u8,
    },
    button_press: struct {
        button: ButtonType,
    },
    button_release: struct {
        button: ButtonType,
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
    title: ?[]const u8,
    width: u16 = 256,
    height: u16 = 256,
};
