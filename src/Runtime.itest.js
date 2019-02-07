const Runtime = require('./Runtime');
const fetch = require('node-fetch');

async function produce(topic, key, value) {
  const res = await fetch(`http://pixy/topics/${topic}/messages?key=${key}&sync=true`, {
    method: 'post',
    body: JSON.stringify(value),
    headers: { 'Content-Type': 'application/json' }
  });

  const text = await res.text();
  console.log({ text }, 'Produce response');
}

describe('Runtime', function () {
  jest.setTimeout(5000);

  let topic, group;
  beforeEach(async () => {
    topic = 'itest-exactly-once_' + Date.now();
    group = `itest-${Date.now()}`;

    await produce(topic, 'key1', { foo: 'valueA' });
    await produce(topic, 'key1', { foo: 'valueB' });
    await produce(topic, 'key1', { foo: 'valueC' });
  })

  it('supports exactly-once semantics for async handlers', async function () {

    const runtime = new Runtime({ topic }, {
      'group.id': group,
      'enable.auto.commit': false,
      'metadata.broker.list': 'kafka:9092',
      'auto.offset.reset': 'earliest',
    });


    const handledValues = [];
    await new Promise(async resolve => {
      try {
        await runtime(async value => {
          handledValues.push(value);
          if (value.foo === 'valueB') {
            await new Promise(() => {throw new Error('Expected') });
          }

          // Produce no messages so we avoid printing stuff
          return [];
        });
      } catch (err) {
        expect(err.message).toEqual('Expected');
        resolve();
      }
    });

    expect(handledValues).toEqual([
      { foo: 'valueA' },
      { foo: 'valueB' }
    ]);
  });

  it('picks up from the last (failed) offset', async function () {
    const runtime2 = new Runtime({ topic }, {
      'group.id': group,
      'enable.auto.commit': false,
      'metadata.broker.list': 'kafka:9092',
      'auto.offset.reset': 'earliest',
    });

    const handledValues = [];

    await new Promise(async resolve => {
      await runtime2(async value => {
        handledValues.push(value);
        expect(value.foo).not.toEqual('valueA');
        if (value.foo === 'valueC') resolve();

        // Produce no messages so we avoid printing stuff
        return [];
      });
    });

    expect(handledValues).toEqual([
      { foo: 'valueB' },
      { foo: 'valueC' },
    ]);
  });
});