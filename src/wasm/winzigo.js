const original_title = document.title;
const text_decoder = new TextDecoder();

const main = {

self: {
  canvases: [],
  wasm: undefined,
},

wzInit(wasm) {
  self.wasm = wasm;
  self.canvases = new Array();
},

wzCanvasInit(width, height) {
  let canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;

  canvas.addEventListener("mousedown", (ev) => {
    console.log(`mouse down at x: ${ev.x} y: ${ev.y}`);
  });

  document.body.appendChild(canvas);
  return self.canvases.push({ canvas }) - 1;
},

wzCanvasDeinit(canvas) {
  if (self.canvases[canvas] != undefined) {
    self.canvases.splice(canvas, 1);
  }
},

wzCanvasSetTitle(canvas, title, titleLen) {
  document.title = titleLen > 0 ?
    text_decoder.decode(new Uint8Array(self.wasm.exports.memory.buffer, title, titleLen)) :
    original_title;
},

wzCanvasSetSize(canvas, width, height) {
  const cv = self.canvases[canvas];
  if (width > 0 && height > 0) {
    cv.width = width;
    cv.height = height;
  }
},

};

export { main };
