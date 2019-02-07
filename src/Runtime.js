const readline = require('readline');
const { KafkaConsumer } = require('node-rdkafka');
const { promisify } = require('util');

function Runtime(options, consumerOptions) {
  const consumer = new KafkaConsumer(consumerOptions, {});

  consumer.on('ready', () => {
    console.log(options, 'Subscribing to topics');
    consumer.subscribe([options.topic]);
  })

  consumer.on('ready', () => console.log('Runtime consumer ready!'));

  consumer.connect();

  return async function run(handlerFn) {

    const running = new Promise((resolve, reject) => {
      consumer.on('data', async message => {
        let json;
        try {
          json = JSON.parse(message.value.toString());
        } catch (err) {
          throw new Error('Failed to parse JSON from line: ' + message.value);
        }
        let arrayOfMessages = [];
        try {
          arrayOfMessages = await handlerFn(json);
        } catch (err) {
          return reject(err);
        }

        // console.log writes and flushes one line per message, unlike process.stdout.write
        arrayOfMessages.forEach(message => console.log(JSON.stringify(message)));

        consumer.commitMessage(message);
        consumer.consume(1);
      });

      consumer.on('error', reject);
      consumer.on('disconnect', reject);

      consumer.consume(1);
    });

    running.catch(err => {
      consumer.removeAllListeners();
      consumer.disconnect();
    })

    return running;
  }
}

Runtime.validateHandler = fn => typeof fn === 'function';

module.exports = Runtime;
