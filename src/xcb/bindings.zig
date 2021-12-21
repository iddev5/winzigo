const xcb_connection_t = opaque {};
const xcb_window_t = opaque {};
const xcb_colormap_t = opaque {};
const xcb_visualid_t = opaque {};

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

pub const Connection = xcb_connection_t;
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

pub const KeyPressEvent = struct {
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

extern "xcb" fn xcb_connect(displayname: [*]const u8, screenp: ?*c_int) ?*Connection;
pub fn connect(displayname: []const u8, screenp: ?*c_int) !*Connection {
    if (xcb_connect(displayname.ptr, screenp)) |connection| {
        return connection;
    }
    return error.CannotConnectToServer;
}

extern "xcb" fn xcb_disconnect(c: *Connection) void;
pub fn disconnect(c: *Connection) void {
    return xcb_disconnect(c);
}

extern "xcb" fn xcb_get_setup(c: *Connection) ?*Setup;
pub fn getSetup(c: *Connection) !*Setup {
    if (xcb_get_setup(c)) |setup| {
        return setup;
    }
    return error.CannotRetriveSetup;
}

extern "xcb" fn xcb_setup_roots_iterator(r: *const Setup) ScreenIterator;
pub fn setupRootsIterator(r: *const Setup) ScreenIterator {
    return xcb_setup_roots_iterator(r);
}

extern "xcb" fn xcb_generate_id(c: *Connection) Window;
pub fn generateId(c: *Connection) Window {
    return xcb_generate_id(c);
}

extern "xcb" fn xcb_create_window(
    c: *Connection,
    depth: u8,
    wid: Window,
    parent: Window,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    border_width: u16,
    _class: u16,
    visual: VisualId,
    value_mask: u32,
    value_list: ?[*]const u32,
) VoidCookie;
pub fn createWindow(
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
    return xcb_create_window(
        c,
        depth,
        wid,
        parent,
        x,
        y,
        width,
        height,
        border_width,
        @enumToInt(_class),
        visual,
        value_mask,
        value_list,
    );
}

extern "xcb" fn xcb_destroy_window(c: *Connection, window: Window) void;
pub fn destroyWindow(c: *Connection, window: Window) void {
    return xcb_destroy_window(c, window);
}

extern "xcb" fn xcb_change_window_attributes(
    c: *Connection,
    window: Window,
    value_mask: u32,
    value_list: ?[*]const u32,
) VoidCookie;
pub fn changeWindowAttributes(c: *Connection, window: Window, value_mask: u32, value_list: []const u32) VoidCookie {
    return xcb_change_window_attributes(c, window, value_mask, value_list.ptr);
}

extern "xcb" fn xcb_configure_window(
    c: *Connection,
    window: Window,
    value_mask: u16,
    value_list: ?*const anyopaque,
) VoidCookie;
pub fn configureWindow(
    c: *Connection,
    window: Window,
    value_mask: u16,
    value_list: ?*const anyopaque,
) VoidCookie {
    return xcb_configure_window(c, window, value_mask, value_list);
}

extern "xcb" fn xcb_change_property(
    c: *Connection,
    mode: u8,
    window: Window,
    property: Atom,
    _type: Atom,
    format: u8,
    data_len: u32,
    data: ?*const anyopaque,
) VoidCookie;
pub fn changeProperty(
    c: *Connection,
    mode: PropMode,
    window: Window,
    property: Atom,
    _type: Atom,
    format: u8,
    data_len: u32,
    data: ?*const anyopaque,
) VoidCookie {
    return xcb_change_property(c, @enumToInt(mode), window, property, _type, format, data_len, data);
}

extern "xcb" fn xcb_map_window(c: *Connection, window: Window) VoidCookie;
pub fn mapWindow(c: *Connection, window: Window) VoidCookie {
    return xcb_map_window(c, window);
}

extern "xcb" fn xcb_flush(c: *Connection) c_int;
pub fn flush(c: *Connection) i32 {
    return @intCast(i32, xcb_flush(c));
}

extern "xcb" fn xcb_wait_for_event(c: *Connection) ?*GenericEvent;
pub fn waitForEvent(c: *Connection) ?*GenericEvent {
    return xcb_wait_for_event(c);
}

extern "xcb" fn xcb_poll_for_event(c: *Connection) ?*GenericEvent;
pub fn pollForEvent(c: *Connection) ?*GenericEvent {
    return xcb_poll_for_event(c);
}

pub fn eventResponse(event: *GenericEvent) EventType {
    return @intToEnum(EventType, event.response_type & 0x7f);
}

extern "xcb" fn xcb_intern_atom(c: *Connection, only_if_exists: u8, name_len: u16, name: ?[*]const u8) InternAtomCookie;
pub fn internAtom(c: *Connection, only_if_exists: bool, name_len: u16, name: []const u8) InternAtomCookie {
    return xcb_intern_atom(c, @boolToInt(only_if_exists), name_len, name.ptr);
}

extern "xcb" fn xcb_intern_atom_reply(c: *Connection, cookie: InternAtomCookie, e: ?**GenericError) *InternAtomReply;
pub fn internAtomReply(c: *Connection, cookie: InternAtomCookie, e: ?**GenericError) *InternAtomReply {
    return xcb_intern_atom_reply(c, cookie, e);
}

extern "xcb" fn xcb_query_keymap(c: *Connection) QueryKeymapCookie;
pub fn queryKeymap(c: *Connection) QueryKeymapCookie {
    return xcb_query_keymap(c);
}

extern "xcb" fn xcb_query_keymap_reply(c: *Connection, cookie: QueryKeymapCookie, e: ?**GenericError) *QueryKeymapReply;
pub fn queryKeymapReply(c: *Connection, cookie: QueryKeymapCookie, e: ?**GenericError) *QueryKeymapReply {
    return xcb_query_keymap_reply(c, cookie, e);
}

extern "xcb" fn xcb_get_keyboard_mapping(c: *Connection, first_keycode: KeyCode, count: u8) KeyboardMappingCookie;
pub fn getKeyboardMapping(c: *Connection, first_keycode: KeyCode, count: u8) KeyboardMappingCookie {
    return xcb_get_keyboard_mapping(c, first_keycode, count);
}

extern "xcb" fn xcb_get_keyboard_mapping_reply(c: *Connection, cookie: KeyboardMappingCookie, e: ?**GenericError) *KeyboardMappingReply;
pub fn getKeyboardMappingReply(c: *Connection, cookie: KeyboardMappingCookie, e: ?**GenericError) *KeyboardMappingReply {
    return xcb_get_keyboard_mapping_reply(c, cookie, e);
}

extern "xcb" fn xcb_get_keyboard_mapping_keysyms(r: *const KeyboardMappingReply) [*]KeySym;
pub fn getKeyboardMappingKeysyms(r: *const KeyboardMappingReply) [*]KeySym {
    return xcb_get_keyboard_mapping_keysyms(r);
}
