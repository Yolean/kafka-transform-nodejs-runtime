const fs = require('fs');
const readline = require('readline');
const stream = require('stream');

// Inspired by https://medium.com/@wietsevenema/node-js-using-for-await-to-read-lines-from-a-file-ead1f4dd8c6f
function readLines({ input }) {
  const output = new stream.PassThrough({ objectMode: true });
  const rl = readline.createInterface({ input });
  rl.on('line', line => output.write(line));
  rl.on('close', () => output.push(null));
  return output;
}

function Runtime(file = '/dev/stdin') {
  const input = fs.createReadStream(file);

  return async function run(handlerFn) {
    for await (const line of readLines({ input })) {
      let json;
      try {
        json = JSON.parse(line);
      } catch (err) {
        throw new Error('Failed to parse JSON from line: ' + line);
      }
      const arrayOfMessages = await handlerFn(json);
      // console.log writes and flushes one line per message, unlike process.stdout.write
      arrayOfMessages.forEach(message => console.log(JSON.stringify(message)));
    }
  }
}

module.exports = Runtime;