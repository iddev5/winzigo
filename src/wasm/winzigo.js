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

    canvas.addEventListener("contextmenu", (ev) => ev.preventDefault());

    canvas.addEventListener("mouseup", (ev) => {
      self.wasm.exports.wasmMouseClick(self.canvases.length, ev.clientX, ev.clientY, ev.button, 1);
    });

    canvas.addEventListener("mousedown", (ev) => {
      self.wasm.exports.wasmMouseClick(self.canvases.length, ev.clientX, ev.clientY, ev.button, 0);
    });

    document.body.appendChild(canvas);
    return self.canvases.push({ canvas }) - 1;
  },

  wzCanvasDeinit(canvas) {
    if (self.canvases[canvas] != undefined) {
      self.canvases.splice(canvas, 1);
    }
  },

  wzCanvasSetTitle(canvas, title, len) {
    document.title = len > 0 ?
      winzigo.wzGetString(title, len) :
      original_title;
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
