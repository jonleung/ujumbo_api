a = [1,2,3]

for (var el in a) {
  debugger
  console.log( el )
}

function avg() {
  var sum = 0;
  for(var i=0; i<arguments.length; i++) {
    sum += arguments[i];
  }
  return sum / arguments.length
}

console.log( avg(1,2,3) )
console.log( avg(1,2,3,4,5) )
console.log( avg(3,3,3,3,3) )

console.log( avg.apply(null, [1,2,3]) )