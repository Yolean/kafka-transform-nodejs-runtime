module.exports = function defaultHandlerFunction(x) {
  console.error('[defaultHandlerFunction] Received: ' + x);
  throw new Error('[defaultHandlerFunction] Please replace this handler at ' + __filename);
}