const Runtime = require('./src/Runtime');


process.on('unhandledRejection', (err, p) => {
  throw err;
});

async function main() {
  const run = new Runtime();
  await run(async json => {
    if (Number.isInteger(json.x)) return { x: json.x + 1 };
    else throw new Error('I like Integers! Only!');
  });
}

main();