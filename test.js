const Runtime = require('./src/Runtime');


process.on('unhandledRejection', (err, p) => {
  throw err;
});

async function main() {
  const run = new Runtime();
  await run(async json => {
    if (Number.isInteger(json.x)) {
      await new Promise(resolve => setTimeout(resolve, Math.random() * 2));
      return [{ x: json.x + 1 }];
    }
    else throw new Error('I like Integers! Only!');
  });
}

main();