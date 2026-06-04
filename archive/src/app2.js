function greet(name = 'world') {
  return `Hello, ${name}!`;
}

function sum(numbers) {
  return numbers.reduce((total, value) => total + value, 0);
}

function parseNumbers(args) {
  return args
    .map((arg) => Number(arg))
    .filter((value) => !Number.isNaN(value));
}

if (require.main === module) {
  const [, , ...args] = process.argv;
  if (args.length === 0) {
    console.log(greet());
  } else if (args.every((arg) => !Number.isNaN(Number(arg)))) {
    const numbers = parseNumbers(args);
    console.log(`Sum: ${sum(numbers)}`);
  } else {
    console.log(greet(args.join(' ')));
  }
}

module.exports = {
  greet,
  sum,
};
