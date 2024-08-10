const filePath = './large_data.json';
const file = Bun.file(filePath);

const data = await file.json();

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