const outputDir = '/app/test_data';
const filePath = `${outputDir}/large_data.json`;

async function generateData(count) {
  const file = Bun.file(filePath);
  const writer = file.writer();

  await writer.write('[');

  for (let i = 0; i < count; i++) {
    const obj = {
      _id: Math.random().toString(36).substr(2, 9),
      index: i,
      guid: Math.random().toString(36).substr(2, 16),
      isActive: Math.random() > 0.5,
      balance: `$${(Math.random() * 3000 + 1000).toFixed(2)}`,
      picture: 'http://placehold.it/32x32',
      age: Math.floor(Math.random() * 21) + 20,
      eyeColor: ['blue', 'brown', 'green'][Math.floor(Math.random() * 3)],
      name: `${getRandomName()} ${getRandomName()}`,
      gender: Math.random() > 0.5 ? 'male' : 'female',
      company: getRandomName().toUpperCase(),
      email: `${getRandomName().toLowerCase()}@${getRandomName().toLowerCase()}.com`,
      phone: `+1 ${Math.floor(Math.random() * 1000000000).toString().padStart(10, '0')}`,
      address: `${Math.floor(Math.random() * 900) + 100} ${getRandomName()} St, ${getRandomName()} City, ${getRandomName()} State, ${Math.floor(Math.random() * 90000) + 10000}`,
      about: getRandomParagraph(),
      registered: new Date(Date.now() - Math.random() * 315569260000).toISOString(),
      latitude: (Math.random() * 180 - 90).toFixed(6),
      longitude: (Math.random() * 360 - 180).toFixed(6),
      tags: Array.from({ length: 7 }, () => getRandomName()),
      friends: Array.from({ length: 3 }, (_, index) => ({
        id: index,
        name: `${getRandomName()} ${getRandomName()}`
      })),
      greeting: `Hello, ${getRandomName()}! You have ${Math.floor(Math.random() * 10) + 1} unread messages.`,
      favoriteFruit: ['apple', 'banana', 'strawberry'][Math.floor(Math.random() * 3)]
    };

    await writer.write(JSON.stringify(obj) + (i < count - 1 ? ',' : ''));

    // Log progress every 10000 objects
    if (i % 10000 === 0 && i > 0) {
      console.log(`Generated ${i} objects...`);
    }
  }

  await writer.write(']');
  await writer.end();
}

function getRandomName() {
  const names = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'David', 'Eva', 'Frank', 'Grace', 'Henry'];
  return names[Math.floor(Math.random() * names.length)];
}

function getRandomParagraph() {
  const words = ['lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore', 'et', 'dolore', 'magna', 'aliqua'];
  const length = Math.floor(Math.random() * 50) + 20;
  return Array.from({ length }, () => words[Math.floor(Math.random() * words.length)]).join(' ');
}

const numberOfObjects = 400000;

console.time('JSON Generation');
await generateData(numberOfObjects);
console.timeEnd('JSON Generation');
console.log(`Generated JSON file with ${numberOfObjects} objects in ${filePath}`);