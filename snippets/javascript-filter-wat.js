const a = [1,2,3,'milk', 'coffee', 4,5,6, 'bread', 'cheese']

const numberFilter = a.filter(Number);
const parseIntFilter = a.filter(parseInt);
const parseIntFnFilter = a.filter(e => parseInt(e));
const actualParseIntFnFilter = a.filter((e, i, a) => parseInt(e, i, a))

console.log(numberFilter);
console.log(parseIntFilter);
console.log(parseIntFnFilter);
console.log(actualParseIntFnFilter);
