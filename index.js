console.log(process.argv);
if (process.argv.length !== 3) {
  throw new Error('First argument must be the handler to be require\'d');
}

const handlerRequire = process.argv[2];
const handlerFn = require(handlerRequire);

const Runtime = require('./src/Runtime');
Runtime.validateHandler(handlerFn);

process.on('unhandledRejection', (err, p) => {
  throw err;
});

async function main(handlerFn) {
  const run = new Runtime();
  await run(handlerFn);
}

main(handlerFn);
