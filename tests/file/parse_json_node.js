const fs = require('fs');

const filePath = '/app/tests/file/large_data.json';
const jsonString = fs.readFileSync(filePath, 'utf8');
const data = JSON.parse(jsonString);

let totalBalance = 0;
let activeUsers = 0;
let totalAge = 0;

for (const item of data) {
  totalBalance += parseFloat(item.balance.replace('$', '').replace(',', ''));
  if (item.isActive) activeUsers++;
  totalAge += item.age;
}

const averageBalance = totalBalance / data.length;
const averageAge = totalAge / data.length;