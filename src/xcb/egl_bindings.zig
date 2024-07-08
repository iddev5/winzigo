const std = @import("std");

const EGL = @This();

pub const Display = *anyopaque;
pub const Surface = *anyopaque;
pub const Config = *anyopaque;
pub const Context = *anyopaque;

// Window types are (mostly) handles
pub const NativeWindowType = c_int;
pub const Attrib = c_int;

pub const NONE = 0x3038;
pub const PLATFORM_XCB_EXT = 0x31dc;
pub const PLATFORM_XCB_SCREEN_EXT = 0x31de;

pub const alpha_size = 0x3021;
pub const blue_size = 0x3022;
pub const green_size = 0x3023;
pub const red_size = 0x3024;
pub const depth_size = 0x3025;
pub const stencil_size = 0x3026;

pub const render_buffer = 0x3086;
pub const back_buffer = 0x3084;

pub const colorspace = 0x3087;
pub const colorspace_srgb = 0x3089;
pub const colorspace_linear = 0x308a;

pub const surface_type = 0x3033;
pub const renderable_type = 0x3040;
pub const color_buffer_type = 0x303f;
pub const conformant = 0x3042;

pub const rgb_buffer = 0x308e;

pub const window_bit = 0x0004;
pub const opengl_bit = 0x0008;

pub const context_major_version = 0x3098;
pub const context_minor_version = 0x30fb;
pub const context_opengl_profile_mask = 0x30fd;
pub const context_opengl_core_profile_bit = 0x00000001;

pub const Api = enum(i32) {
    opengl_es = 0x30a0,
    opengl = 0x30a2,
};

eglGetProcAddress: *const fn (procname: [*:0]const u8) *anyopaque,
eglInitialize: *const fn (display: Display, major: *c_int, minor: *c_int) bool,
eglBindAPI: *const fn (api: c_int) bool,
eglChooseConfig: *const fn (display: Display, attrib_list: [*]const Attrib, configs: *Config, config_size: c_int, num_config: *c_int) bool,
eglCreateWindowSurface: *const fn (display: Display, config: Config, win: NativeWindowType, attrib_list: [*]const Attrib) ?Surface,
eglCreateContext: *const fn (display: Display, config: Config, share_context: ?Context, attrib_list: [*]const Attrib) ?Context,
eglMakeCurrent: *const fn (display: Display, draw: Surface, read: Surface, ctx: Context) bool,
eglSwapBuffers: *const fn (display: Display, surface: Surface) bool,

eglGetPlatformDisplayEXT: *const fn (platform: c_int, native_display: *anyopaque, attrib_list: [*]const Attrib) ?Display,

pub fn loadEGL() !EGL {
    var egl: EGL = undefined;
    var lib = try std.DynLib.open("libEGL.so");
    inline for (@typeInfo(EGL).Struct.fields) |field| {
        const name = field.name ++ "\x00";
        if (std.mem.endsWith(u8, field.name, "EXT")) {
            @field(egl, field.name) = @ptrCast(egl.getProcAddress(name));
        } else {
            @field(egl, field.name) = lib.lookup(field.type, field.name) orelse return error.SymbolNotFound;
        }
    }

    return egl;
}

pub fn loadExtensions(egl: *const EGL) !void {
    egl.eglGetPlatformDisplayExt = egl.getProcAddress("eglGetPlatformDisplayEXT");
}

pub fn getProcAddress(egl: *const EGL, procname: [:0]const u8) *anyopaque {
    return egl.eglGetProcAddress(procname);
}

pub fn initialize(egl: *const EGL, display: Display) !struct { i32, i32 } {
    var major: i32 = undefined;
    var minor: i32 = undefined;
    const res = egl.eglInitialize(display, &major, &minor);
    if (!res)
        return error.InitializationError;

    return .{ major, minor };
}

pub fn bindApi(egl: *const EGL, api: Api) !void {
    if (!egl.eglBindAPI(@intFromEnum(api)))
        return error.CannotBindApi;
}

pub fn chooseConfig(egl: *const EGL, display: Display, attrib_list: []const Attrib) !Config {
    var count: i32 = undefined;
    var config: Config = undefined;
    if (!egl.eglChooseConfig(display, attrib_list.ptr, &config, 1, &count) or (count != 1))
        return error.CannotChooseConfig;

    return config;
}

pub fn createWindowSurface(egl: *const EGL, display: Display, config: Config, window: NativeWindowType, attrib_list: []const Attrib) !Surface {
    return egl.eglCreateWindowSurface(display, config, window, attrib_list.ptr) orelse
        error.CannotCreateSurface;
}

pub fn createContext(egl: *const EGL, display: Display, config: Config, share_context: ?Context, attrib_list: []const Attrib) !Context {
    return egl.eglCreateContext(display, config, share_context, attrib_list.ptr) orelse
        error.CannotCreateContext;
}

pub fn makeCurrent(egl: *const EGL, display: Display, draw: Surface, read: Surface, ctx: Context) !void {
    if (!egl.eglMakeCurrent(display, draw, read, ctx))
        return error.CannotMakeCurrent;
}

pub fn swapBuffers(egl: *const EGL, display: Display, surface: Surface) !void {
    if (!egl.eglSwapBuffers(display, surface))
        return error.CannotSwapBuffers;
}

pub fn getPlatformDisplay(egl: *const EGL, platform: c_int, native_display: *anyopaque, attrib_list: []const Attrib) ?Display {
    return egl.eglGetPlatformDisplayEXT(platform, native_display, attrib_list.ptr);
}
