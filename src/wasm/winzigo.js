const original_title = document.title;
const text_decoder = new TextDecoder();
let log_buf = "";

const winzigo = {
  self: {
    canvases: [],
    wasm: undefined,
  },

  init(wasm) {
    self.wasm = wasm;
    self.canvases = new Array();

    let findCv = function (ev) {
      return self.canvases.findIndex((el) => el.canvas === ev.currentTarget);
    }

    // Unmapped:
    // - kp_enter
    let convertKeyCode = function (code) {
      const mapKeyCode = {
        KeyA: 0,
        KeyB: 1,
        KeyC: 2,
        KeyD: 3,
        KeyE: 4,
        KeyF: 5,
        KeyG: 6,
        KeyH: 7,
        KeyI: 8,
        KeyJ: 9,
        KeyK: 10,
        KeyL: 11,
        KeyM: 12,
        KeyN: 13,
        KeyO: 14,
        KeyP: 15,
        KeyQ: 16,
        KeyR: 17,
        KeyS: 18,
        KeyT: 19,
        KeyU: 20,
        KeyV: 21,
        KeyW: 22,
        KeyX: 23,
        KeyY: 24,
        KeyZ: 25,
        Digit0: 26,
        Digit1: 27,
        Digit2: 28,
        Digit3: 29,
        Digit4: 30,
        Digit5: 31,
        Digit6: 32,
        Digit7: 33,
        Digit8: 34,
        Digit9: 35,
        Enter: 78,
        Escape: 79,
        Backspace: 105,
        Tab: 80,
        Space: 106,
        Minus: 107,
        Equal: 108,
        BracketLeft: 109,
        BracketRight: 110,
        Backslash: 111,
        Unknown: 118, // unknown
        Semicolon: 112,
        Unknown: 113, // apostrophe
        Unknown: 117, // grave
        Comma: 114,
        Period: 115,
        Slash: 116,
        CapsLock: 91,
        PrintScreen: 92,
        Unknown: 93, // scroll_lock
        Unknown: 94, // pause
        Insert: 100,
        Home: 96,
        PageUp: 98,
        Delete: 95,
        End: 97,
        PageDown: 99,
        ArrowRight: 102,
        ArrowLeft: 101,
        ArrowDown: 104,
        ArrowUp: 103,
        NumLock: 90,
        NumpadDivide: 61,
        NumpadMultiply: 62,
        NumpadSubtract: 63,
        NumpadAdd: 64,
        Unknown: 118, // unknown
        Numpad1: 66,
        Numpad2: 67,
        Numpad3: 68,
        Numpad4: 69,
        Numpad5: 70,
        Numpad6: 71,
        Numpad7: 72,
        Numpad8: 73,
        Numpad9: 74,
        Numpad0: 65,
        Unknown: 118, //unknown
        Unknown: 118,
        Unknown: 118,
        NumpadDecimal: 75, // kp_decimal
        Unknown: 118, // unknown
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        Unknown: 118,
        F1: 36,
        F2: 37,
        F3: 38,
        F4: 39,
        F5: 40,
        F6: 41,
        F7: 42,
        F8: 43,
        F9: 44,
        F10: 45,
        F11: 46,
        F12: 47,
        F13: 48,
        F14: 49,
        F15: 50,
        F16: 51,
        F17: 52,
        F18: 53,
        F19: 54,
        F20: 55,
        F21: 56,
        F22: 57,
        F23: 58,
        F24: 59,
        F25: 60,
      };

      const k = mapKeyCode[code];
      if (k != undefined)
        return k;
      return 118; // Unknown
    }

    window.addEventListener("keypress", (ev) => {
      self.wasm.exports.wasmKeyDown(findCv(ev), convertKeyCode(ev.code));
    });
  },

  wzGetString(str, len) {
    const memory = self.wasm.exports.memory.buffer;
    return text_decoder.decode(new Uint8Array(memory, str, len));
  },

  wzLogWrite(str, len) {
    log_buf += winzigo.wzGetString(str, len);
  },

  wzLogFlush() {
    console.log(log_buf);
    log_buf = "";
  },

  wzPanic(str, len) {
    throw Error(winzigo.wzGetString(str, len));
  },

  wzCanvasInit(width, height) {
    let canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;

    let findCv = function (ev) {
      return self.canvases.findIndex((el) => el.canvas === ev.currentTarget);
    }

    canvas.addEventListener("contextmenu", (ev) => ev.preventDefault());

    canvas.addEventListener("mouseup", (ev) => {
      self.wasm.exports.wasmMouseUp(findCv(ev), ev.clientX, ev.clientY, ev.button);
    });

    canvas.addEventListener("mousedown", (ev) => {
      self.wasm.exports.wasmMouseDown(findCv(ev), ev.clientX, ev.clientY, ev.button);
    });

    canvas.addEventListener("mousemove", (ev) => {
      self.wasm.exports.wasmMouseMotion(findCv(ev), ev.clientX, ev.clientY);
    });

    canvas.addEventListener("mouseenter", (ev) => {
      const cv = findCv(ev);
      document.title = self.canvases[cv].title;
      self.wasm.exports.wasmMouseEnter(cv, ev.clientX, ev.clientY);
    })

    canvas.addEventListener("mouseleave", (ev) => {
      self.wasm.exports.wasmMouseLeave(findCv(ev), ev.clientX, ev.clientY);
    })

    canvas.addEventListener("wheel", (ev) => {
      self.wasm.exports.wasmMouseWheel(findCv(ev), ev.deltaX, ev.deltaY);
    });

    document.body.appendChild(canvas);
    return self.canvases.push({ canvas: canvas, title: undefined }) - 1;
  },

  wzCanvasDeinit(canvas) {
    if (self.canvases[canvas] != undefined) {
      self.canvases.splice(canvas, 1);
    }
  },

  wzCanvasSetTitle(canvas, title, len) {
    const str = len > 0 ?
      winzigo.wzGetString(title, len) :
      original_title;
    self.canvases[canvas].title = str;
  },

  wzCanvasSetSize(canvas, width, height) {
    const cv = self.canvases[canvas];
    if (width > 0 && height > 0) {
      cv.canvas.width = width;
      cv.canvas.height = height;
    }
  },
};

export { winzigo };
