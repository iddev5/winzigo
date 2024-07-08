const Window = @This();

const std = @import("std");
const xcb = @import("bindings.zig");
const EGL = @import("egl_bindings.zig");
const Core = @import("Core.zig");
const types = @import("../main.zig");
const egl_types = @import("../egl.zig");

core: *Core,
window: u32 = undefined,
width: u16,
height: u16,

pub fn init(core: *Core, info: types.WindowInfo) !*Window {
    var self = try core.allocator.create(Window);
    errdefer core.allocator.destroy(self);

    self.core = core;
    self.window = xcb.generateId(core.connection);
    _ = xcb.createWindow(
        core.connection,
        0,
        self.window,
        core.screen.root,
        0,
        0,
        info.width,
        info.height,
        0,
        xcb.WindowClass.InputOutput,
        core.screen.root_visual,
        0,
        null,
    );

    var value = @intFromEnum(xcb.EventMask.KeyPress);
    value |= @intFromEnum(xcb.EventMask.KeyRelease);
    value |= @intFromEnum(xcb.EventMask.ButtonPress);
    value |= @intFromEnum(xcb.EventMask.ButtonRelease);
    value |= @intFromEnum(xcb.EventMask.PointerMotion);
    value |= @intFromEnum(xcb.EventMask.FocusChange);
    value |= @intFromEnum(xcb.EventMask.EnterWindow);
    value |= @intFromEnum(xcb.EventMask.LeaveWindow);
    value |= @intFromEnum(xcb.EventMask.StructureNotify);

    _ = xcb.changeWindowAttributes(
        core.connection,
        self.window,
        @intFromEnum(xcb.Cw.EventMask),
        &[_]u32{value},
    );

    _ = xcb.mapWindow(core.connection, self.window);

    if (info.title) |t| self.setTitle(t);

    return self;
}

pub fn deinit(window: *Window) void {
    xcb.destroyWindow(window.core.connection, window.window);
    window.core.allocator.destroy(window);
}

pub fn setTitle(window: *Window, title: []const u8) void {
    _ = xcb.changeProperty(
        window.core.connection,
        .Replace,
        window.window,
        @intFromEnum(xcb.Defines.Atom.WmName),
        @intFromEnum(xcb.Defines.Atom.String),
        @bitSizeOf(u8),
        @as(u32, @intCast(title.len)),
        @as(*const anyopaque, @ptrCast(title)),
    );
}

pub fn setSize(window: *Window, width: u16, height: u16) void {
    const pair: [2]c_int = .{ width, height };
    _ = xcb.configureWindow(
        window.core.connection,
        window.window,
        @intFromEnum(xcb.Defines.Config.WindowWidth) | @intFromEnum(xcb.Defines.Config.WindowHeight),
        @as(*anyopaque, @ptrCast(@constCast(&pair))),
    );
    window.width = width;
    window.height = height;
}

pub fn getSize(window: *Window) types.Dim {
    const cookie = xcb.getGeometry(window.core.connection, window.window);
    const reply = xcb.getGeometryReply(window.core.connection, cookie, null);
    defer std.c.free(reply);

    return .{ .width = reply.width, .height = reply.height };
}

pub fn createGLContext(win: *Window) !egl_types.GLContext {
    const egl = try EGL.loadEGL();

    const display = egl.getPlatformDisplay(
        EGL.PLATFORM_XCB_EXT,
        win.core.connection,
        &.{ EGL.PLATFORM_XCB_SCREEN_EXT, 0, EGL.NONE },
    ) orelse return error.NoEglDisplay;

    const version = try egl.initialize(display);
    if (version[0] < 1 or (version[0] == 1 and version[1] < 5))
        return error.IncorrectVersion;

    try egl.bindApi(.opengl);

    const config_attribs = &[_]EGL.Attrib{
        EGL.surface_type,      EGL.window_bit,
        EGL.conformant,        EGL.opengl_bit,
        EGL.renderable_type,   EGL.opengl_bit,
        EGL.color_buffer_type, EGL.rgb_buffer,

        EGL.red_size,          8,
        EGL.green_size,        8,
        EGL.blue_size,         8,
        EGL.depth_size,        24,
        EGL.stencil_size,      8,

        EGL.NONE,
    };
    const config = try egl.chooseConfig(display, config_attribs);

    const surface_attribs = &[_]EGL.Attrib{
        EGL.colorspace,    EGL.colorspace_linear,
        EGL.render_buffer, EGL.back_buffer,

        EGL.NONE,
    };
    const surface = try egl.createWindowSurface(display, config, @intCast(win.window), surface_attribs);

    const context_attribs = &[_]EGL.Attrib{
        EGL.context_major_version,       4,
        EGL.context_minor_version,       1,
        EGL.context_opengl_profile_mask, EGL.context_opengl_core_profile_bit,

        EGL.NONE,
    };
    const context = try egl.createContext(display, config, null, context_attribs);
    try egl.makeCurrent(display, surface, surface, context);

    return .{
        .egl = egl,
        .display = display,
        .surface = surface,
        .context = context,
    };
}
