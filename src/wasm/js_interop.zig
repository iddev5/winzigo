pub const CanvasId = u32;

pub extern fn wzCanvasInit(width: u32, height: u32) CanvasId;
pub extern fn wzCanvasDeinit(canvas: CanvasId) void;
pub extern fn wzCanvasSetTitle(canvas: CanvasId, title: [*]const u8, len: usize) void;
pub extern fn wzCanvasSetSize(canvas: CanvasId, width: u32, height: u32) void;
pub extern fn wzCanvasGetWidth(canvas: CanvasId) u32;
pub extern fn wzCanvasGetHeight(canvas: CanvasId) u32;
pub extern fn wzEventShift() c_int;
