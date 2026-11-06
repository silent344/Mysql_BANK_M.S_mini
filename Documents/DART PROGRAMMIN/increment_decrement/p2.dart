void main(){
  // this file is all about increment and decrement operators in dart programming language.
  // increment operator is used to increase the value of a variable by 1 and decrement operator
  // is used to decrease the value of a variable by 1.
  // there are two types of increment and decrement operators in dart programming language.
  // 1. Postfix increment and decrement operator
  // 2. Prefix increment and decrement operator
  // Postfix increment and decrement operator is used to first use the value of the variable and then it will increment or decrement the value of the variable by 1.
  // Prefix increment and decrement operator is used to first increment or decrement the value of the variable by 1 and then it will use the value of the variable.
  var a =4;
  a++;
  print(a); // 5
  print('-----------------');
  var b = 4;
  print(b++); // 4. 1st increase the value of b by 1 
  print(b); // 5. then print the value of b after incrementing it by 1.i,e = 5
  print('-----------------');
  var c = 4;
  ++c;
  print(c); // 5
  print('-----------------');
  var d = 4;
  print(++d); // 5
  print(d); // 5
  print('-----------------');
  // same for decrement operator
  var e = 4;
  e--;
  print(e); // 3
  print('-----------------');
  var f = 4;
  print(f--); // 4. 1st decrease the value of f by 1 
  print(f); // 3. then print the value of f after decrementing it by 1.i,e = 3
  print('-----------------');
  var g = 4;
  --g;
  print(g); // 3
  print('-----------------');
  var h = 4;
  print(--h); // 3
  print(h); // 3
}