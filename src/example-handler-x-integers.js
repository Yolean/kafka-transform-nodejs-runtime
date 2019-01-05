module.exports = async json => {
  if (Number.isInteger(json.x)) {
    await new Promise(resolve => setTimeout(resolve, Math.random() * 2));
    return [{ x: json.x + 1 }];
  }
  else throw new Error('This example handler intentionally crashes on non-integers. Got: ' + json.x);
}
