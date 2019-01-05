const Runtime = require('./Runtime');
const handler = require('./handler');

async function main() {
  const run = new Runtime();
  await run(handler);
}

main();