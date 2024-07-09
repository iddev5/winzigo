const std = @import("std");

const Xcb = @This();

pub const Defines = struct {
    pub const CopyFromParent = 0;
    pub const Atom = enum(u32) {
        String = 31,
        WmName = 39,
    };
    pub const Config = enum(u32) {
        WindowWidth = 4,
        WindowHeight = 8,
    };
};

pub const Connection = opaque {};
pub const Setup = extern struct {
    status: u8,
    pad0: u8,
    protocol_major_version: u16,
    protocol_minor_version: u16,
    length: u16,
    release_number: u32,
    resource_id_base: u32,
    resource_id_mask: u32,
    motion_buffer_size: u32,
    vendor_len: u16,
    maximum_request_length: u16,
    roots_len: u8,
    pixmap_formats_len: u8,
    image_byte_order: u8,
    bitmap_format_bit_order: u8,
    bitmap_format_scanline_unit: u8,
    bitmap_format_scanline_pad: u8,
    min_keycode: KeyCode,
    max_keycode: KeyCode,
    pad1: [4]u8,
};

pub const SetupIterator = extern struct {
    data: ?*Setup,
    rem: c_int,
    index: c_int,
};

pub const Window = u32;

pub const WindowClass = enum(u16) {
    CopyFromParent,
    InputOutput,
    InputOnly,
};

pub const Colormap = u32;
pub const VisualId = u32;

pub const Screen = extern struct {
    root: Window,
    default_colormap: Colormap,
    white_pixel: u32,
    black_pixel: u32,
    current_input_masks: u32,
    width_in_pixels: u16,
    height_in_pixels: u16,
    width_in_millimeters: u16,
    height_in_millimeters: u16,
    min_installed_maps: u16,
    max_installed_maps: u16,
    root_visual: VisualId,
    backing_stores: u8,
    save_unders: u8,
    root_depth: u8,
    allowed_depths_len: u8,
};

pub const ScreenIterator = extern struct {
    data: ?*Screen,
    rem: c_int,
    index: c_int,
};

pub const VoidCookie = extern struct {
    sequence: c_uint,
};

pub const Cw = enum(u32) {
    BackPixmap = 1,
    BackPixel = 2,
    BorderPixmap = 4,
    BorderPixel = 8,
    BitGravity = 16,
    WinGravity = 32,
    BackingStore = 64,
    BackingPlanes = 128,
    BackingPixel = 256,
    OverrideRedirect = 512,
    SaveUnder = 1024,
    EventMask = 2048,
    DontPropagate = 4096,
    Colormap = 8192,
    Cursor = 16384,
};

pub const EventMask = enum(u32) {
    NoEvent = 0,
    KeyPress = 1,
    KeyRelease = 2,
    ButtonPress = 4,
    ButtonRelease = 8,
    EnterWindow = 16,
    LeaveWindow = 32,
    PointerMotion = 64,
    StructureNotify = 131072,
    FocusChange = 2097152,
};

pub const EventType = enum(u32) {
    KeyPress = 2,
    KeyRelease = 3,
    ButtonPress = 4,
    ButtonRelease = 5,
    MotionNotify = 6,
    EnterNotify = 7,
    LeaveNotify = 8,
    FocusIn = 9,
    FocusOut = 10,
    MapNotify = 19,
    ReparentNotify = 21,
    ConfigureNotify = 22,
    ClientMessage = 33,
};

pub const GenericEvent = extern struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    pad: [7]u32,
    full_sequence: u32,
};

pub const Timestamp = u32;
pub const KeyCode = u8;
pub const KeySym = u32;

pub const KeyPressEvent = extern struct {
    response_type: u8,
    detail: KeyCode,
    sequence: u16,
    time: Timestamp,
    root: Window,
    event: Window,
    child: Window,
    root_x: i16,
    root_y: i16,
    event_x: i16,
    event_y: i16,
    state: u16,
    same_screen: u8,
    pad0: u8,
};

pub const KeyReleaseEvent = KeyPressEvent;

pub const Button = u8;

pub const ButtonPressEvent = extern struct {
    response_type: u8,
    detail: Button,
    sequence: u16,
    time: Timestamp,
    root: Window,
    event: Window,
    child: Window,
    root_x: i16,
    root_y: i16,
    event_x: i16,
    event_y: i16,
    state: u16,
    same_screen: u8,
};

pub const ButtonReleaseEvent = ButtonPressEvent;

pub const MotionNotifyEvent = extern struct {
    response_type: u8,
    detail: Button,
    sequence: u16,
    time: Timestamp,
    root: Window,
    event: Window,
    child: Window,
    root_x: i16,
    root_y: i16,
    event_x: i16,
    event_y: i16,
    state: u16,
    same_screen: u8,
    pad0: u8,
};

pub const ClientMessageData = extern union {
    data8: [20]u8,
    data16: [10]u16,
    data32: [5]u32,
};

pub const ClientMessageEvent = extern struct {
    response_type: u8,
    format: u8,
    sequence: u16,
    window: Window,
    _type: Atom,
    data: ClientMessageData,
};

pub const NotifyMode = enum(u8) {
    normal,
    grab,
    ungrab,
    while_grabbed,
};

pub const FocusInEvent = extern struct {
    response_type: u8,
    detail: u8,
    sequence: u16,
    event: Window,
    mode: NotifyMode,
    pad0: [3]u8,
};

pub const FocusOutEvent = FocusInEvent;

pub const EnterNotifyEvent = extern struct {
    response_type: u8,
    detail: u8,
    sequence: u16,
    time: Timestamp,
    root: Window,
    event: Window,
    child: Window,
    root_x: i16,
    root_y: i16,
    event_x: i16,
    event_y: i16,
    state: u16,
    mode: u8,
    same_screen_focus: u8,
};

pub const LeaveNotifyEvent = EnterNotifyEvent;

pub const ConfigureNotifyEvent = struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    event: Window,
    window: Window,
    above_sibling: Window,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    border_width: u16,
    override_redirect: u8,
    pad1: u8,
};

pub const Atom = u32;

pub const PropMode = enum(u8) {
    Replace,
    Prepend,
    Append,
};

pub const InternAtomCookie = VoidCookie;

pub const InternAtomReply = extern struct {
    response: u8,
    pad0: u8,
    sequence: u16,
    length: u32,
    atom: Atom,
};

pub const GenericError = opaque {};

pub const QueryKeymapCookie = VoidCookie;

pub const QueryKeymapReply = extern struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    length: u32,
    keys: [32]u8,
};

pub const KeyboardMappingCookie = VoidCookie;

pub const KeyboardMappingReply = extern struct {
    response_type: u8,
    keysyms_per_keycode: u8,
    sequence: u16,
    length: u32,
    pad0: [24]u8,
};

pub const GeometryCookie = VoidCookie;

pub const GeometryReply = extern struct {
    response_type: u8,
    depth: u8,
    sequence: u16,
    length: u16,
    root: Window,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    border_width: u16,
};

xcb_connect: *const fn (displayname: [*]const u8, screenp: ?*c_int) callconv(.C) ?*Connection,
xcb_disconnect: *const fn (c: *Connection) callconv(.C) void,
xcb_get_setup: *const fn (c: *Connection) callconv(.C) ?*Setup,
xcb_setup_roots_iterator: *const fn (r: *const Setup) callconv(.C) ScreenIterator,
xcb_generate_id: *const fn (c: *Connection) callconv(.C) Window,
xcb_create_window: *const fn (c: *Connection, depth: u8, wid: Window, parent: Window, x: i16, y: i16, width: u16, height: u16, border_width: u16, _class: u16, visual: VisualId, value_mask: u32, value_list: ?[*]const u32) callconv(.C) VoidCookie,
xcb_destroy_window: *const fn (c: *Connection, window: Window) callconv(.C) void,
xcb_change_window_attributes: *const fn (c: *Connection, window: Window, value_mask: u32, value_list: ?[*]const u32) callconv(.C) VoidCookie,
xcb_configure_window: *const fn (c: *Connection, window: Window, value_mask: u16, value_list: ?*const anyopaque) callconv(.C) VoidCookie,
xcb_change_property: *const fn (c: *Connection, mode: u8, window: Window, property: Atom, _type: Atom, format: u8, data_len: u32, data: ?*const anyopaque) callconv(.C) VoidCookie,
xcb_map_window: *const fn (c: *Connection, window: Window) callconv(.C) VoidCookie,
xcb_flush: *const fn (c: *Connection) callconv(.C) c_int,
xcb_wait_for_event: *const fn (c: *Connection) callconv(.C) ?*GenericEvent,
xcb_poll_for_event: *const fn (c: *Connection) callconv(.C) ?*GenericEvent,
xcb_intern_atom: *const fn (c: *Connection, only_if_exists: u8, name_len: u16, name: ?[*]const u8) callconv(.C) InternAtomCookie,
xcb_intern_atom_reply: *const fn (c: *Connection, cookie: InternAtomCookie, e: ?**GenericError) callconv(.C) *InternAtomReply,
xcb_query_keymap: *const fn (c: *Connection) callconv(.C) QueryKeymapCookie,
xcb_query_keymap_reply: *const fn (c: *Connection, cookie: QueryKeymapCookie, e: ?**GenericError) callconv(.C) *QueryKeymapReply,
xcb_get_keyboard_mapping: *const fn (c: *Connection, first_keycode: KeyCode, count: u8) callconv(.C) KeyboardMappingCookie,
xcb_get_keyboard_mapping_reply: *const fn (c: *Connection, cookie: KeyboardMappingCookie, e: ?**GenericError) callconv(.C) *KeyboardMappingReply,
xcb_get_keyboard_mapping_keysyms: *const fn (r: *const KeyboardMappingReply) callconv(.C) [*]KeySym,
xcb_get_geometry: *const fn (c: *Connection, window: Window) callconv(.C) GeometryCookie,
xcb_get_geometry_reply: *const fn (c: *Connection, cookie: GeometryCookie, e: ?**GenericError) callconv(.C) *GeometryReply,

pub fn loadXcb() !Xcb {
    var xcb: Xcb = undefined;
    var lib = try std.DynLib.open("libxcb.so");
    inline for (@typeInfo(Xcb).Struct.fields) |field| {
        @field(xcb, field.name) = lib.lookup(field.type, field.name) orelse return error.SymbolNotFound;
    }

    return xcb;
}

pub fn connect(xcb: *const Xcb, displayname: []const u8, screenp: ?*c_int) !*Connection {
    if (xcb.xcb_connect(displayname.ptr, screenp)) |connection| {
        return connection;
    }
    return error.CannotConnectToServer;
}

pub fn disconnect(xcb: *const Xcb, c: *Connection) void {
    return xcb.xcb_disconnect(c);
}

pub fn getSetup(xcb: *const Xcb, c: *Connection) !*Setup {
    if (xcb.xcb_get_setup(c)) |setup| {
        return setup;
    }
    return error.CannotRetriveSetup;
}

pub fn setupRootsIterator(xcb: *const Xcb, r: *const Setup) ScreenIterator {
    return xcb.xcb_setup_roots_iterator(r);
}

pub fn generateId(xcb: *const Xcb, c: *Connection) Window {
    return xcb.xcb_generate_id(c);
}

pub fn createWindow(
    xcb: *const Xcb,
    c: *Connection,
    depth: u8,
    wid: Window,
    parent: Window,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    border_width: u16,
    _class: WindowClass,
    visual: VisualId,
    value_mask: u32,
    value_list: ?[*]const u32,
) VoidCookie {
    return xcb.xcb_create_window(
        c,
        depth,
        wid,
        parent,
        x,
        y,
        width,
        height,
        border_width,
        @intFromEnum(_class),
        visual,
        value_mask,
        value_list,
    );
}

pub fn destroyWindow(xcb: *const Xcb, c: *Connection, window: Window) void {
    return xcb.xcb_destroy_window(c, window);
}

pub fn changeWindowAttributes(xcb: *const Xcb, c: *Connection, window: Window, value_mask: u32, value_list: []const u32) VoidCookie {
    return xcb.xcb_change_window_attributes(c, window, value_mask, value_list.ptr);
}

pub fn configureWindow(
    xcb: *const Xcb,
    c: *Connection,
    window: Window,
    value_mask: u16,
    value_list: ?*const anyopaque,
) VoidCookie {
    return xcb.xcb_configure_window(c, window, value_mask, value_list);
}

pub fn changeProperty(
    xcb: *const Xcb,
    c: *Connection,
    mode: PropMode,
    window: Window,
    property: Atom,
    _type: Atom,
    format: u8,
    data_len: u32,
    data: ?*const anyopaque,
) VoidCookie {
    return xcb.xcb_change_property(c, @intFromEnum(mode), window, property, _type, format, data_len, data);
}

pub fn mapWindow(xcb: *const Xcb, c: *Connection, window: Window) VoidCookie {
    return xcb.xcb_map_window(c, window);
}

pub fn flush(xcb: *const Xcb, c: *Connection) i32 {
    return @as(i32, @intCast(xcb.xcb_flush(c)));
}

pub fn waitForEvent(xcb: *const Xcb, c: *Connection) ?*GenericEvent {
    return xcb.xcb_wait_for_event(c);
}

pub fn pollForEvent(xcb: *const Xcb, c: *Connection) ?*GenericEvent {
    return xcb.xcb_poll_for_event(c);
}

pub fn eventResponse(xcb: *const Xcb, event: *GenericEvent) EventType {
    _ = xcb;
    return @as(EventType, @enumFromInt(event.response_type & 0x7f));
}

pub inline fn internAtom(xcb: *const Xcb, c: *Connection, only_if_exists: bool, name_len: u16, name: []const u8) InternAtomCookie {
    return xcb.xcb_intern_atom(c, @intFromBool(only_if_exists), name_len, name.ptr);
}

pub fn internAtomReply(xcb: *const Xcb, c: *Connection, cookie: InternAtomCookie, e: ?**GenericError) *InternAtomReply {
    return xcb.xcb_intern_atom_reply(c, cookie, e);
}

pub fn queryKeymap(xcb: *const Xcb, c: *Connection) QueryKeymapCookie {
    return xcb.xcb_query_keymap(c);
}

pub fn queryKeymapReply(xcb: *const Xcb, c: *Connection, cookie: QueryKeymapCookie, e: ?**GenericError) *QueryKeymapReply {
    return xcb.xcb_query_keymap_reply(c, cookie, e);
}

pub fn getKeyboardMapping(xcb: *const Xcb, c: *Connection, first_keycode: KeyCode, count: u8) KeyboardMappingCookie {
    return xcb.xcb_get_keyboard_mapping(c, first_keycode, count);
}

pub fn getKeyboardMappingReply(xcb: *const Xcb, c: *Connection, cookie: KeyboardMappingCookie, e: ?**GenericError) *KeyboardMappingReply {
    return xcb.xcb_get_keyboard_mapping_reply(c, cookie, e);
}

pub fn getKeyboardMappingKeysyms(xcb: *const Xcb, r: *const KeyboardMappingReply) [*]KeySym {
    return xcb.xcb_get_keyboard_mapping_keysyms(r);
}

pub fn getGeometry(xcb: *const Xcb, c: *Connection, window: Window) GeometryCookie {
    return xcb.xcb_get_geometry(c, window);
}

pub fn getGeometryReply(xcb: *const Xcb, c: *Connection, cookie: GeometryCookie, e: ?**GenericError) *GeometryReply {
    return xcb.xcb_get_geometry_reply(c, cookie, e);
}
