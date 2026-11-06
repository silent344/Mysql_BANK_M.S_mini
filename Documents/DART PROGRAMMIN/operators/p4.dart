// from this operators topic create a simple and mini program or game 

void main(){
// logical operators in dart programming language
// logical operators are used to combine two or more conditions and it will return a boolean value true or false.
// there are three types of logical operators in dart programming language.
// 1. Logical AND operator (&&)
// 2. Logical OR operator (||)
// 3. Logical NOT operator (!)
var a = 10;
var b = 20;
var c = 30;
var d = 10;
print(a == d && b < c); // true. 1st condition is true and 2nd condition is true. so the result is true.

print('----');
print(a == d || b > c); // true. 1st condition is true and 2nd condition is false. so the result is true.
print('----');
// In the above two equation one condition is true and other condition is false. so the result is true in both cases because of logical OR operator.
// but in the first equation both conditions are true. so the result is true because of logical AND operator.
// this means that "logical AND" operator will return true only if both conditions are true. and "logical OR" operator will return true if at least one condition is true.
print(!(a == d)); // false. 1st condition is true. so the result is false.
print(a == d && b > c); // false. 1st condition is true and 2nd condition is false. so the result is false.Bacuse second condition is false. so the result is false because of logical AND operator.
//print('-----------------');
print('-------------------------------------------------');
print(a < b && b < c); // true. 1st condition is true and 2nd condition is true. so the result is true.
print('------');
print(a < b || b > c); // true. 1st condition is true and 2nd condition is false. so the result is true.
print('------');
print(!(a < b)); // false. 1st condition is true. so the result is false.
// this condition give the opposite boolen value of the condition. if the condition is true then it will return false and if the condition is false then it will return true.
// a<b which is true but when we use logical NOT operator then it will return false because logical NOT operator give the opposite boolean value of the condition.
print('--------------------------------------------------');
print((a==b) && (b==c)); // false. 1st condition is false and 2nd condition is false. so the result is false.
print('------');
print((a==b) || (b==c)); // false. 1st condition is false and 2nd condition is false. so the result is false.
print('------');
print(!(a==b)); // true. 1st condition is false. so the result is true.
var e = 20;
var f = (!(b==e));
print('condition is true but `!` makes it false i,e : ${f}'); // condition is true but `!` makes it false i,e : false. 1st condition is true but when we use logical NOT operator then it will return false because logical NOT operator give the opposite boolean value of the condition.
print('------------------------------------------------------');
// var d = 10;
print((a==d) && (b==c)); // false. 1st condition is true and 2nd condition is false. so the result is false.
print('------');
print((a==d) || (b==c)); // true. 1st condition is true and 2nd condition is false. so the result is true.
print('------');
print(!(a==d)); // false. 1st condition is true. so the result is false.
// Type test operators in dart programming language
print("-------------Type test operators in dart programming language------------");
// Type test operators are used to check the type of a variable and it will return a boolean value true or false.
// there are two types of type test operators in dart programming language.
// 1. is operator
// 2. is! operator
dynamic g = 10;
dynamic h = "Kritik";
print(g is int); // true. g is an integer value held in a dynamic variable. so the result is true
print('------');
print(h is String); // true. h is a string value held in a dynamic variable. so the result is true
print('------');
print(g is! String); // true. g is not a string variable. so the result is true
print('------');
print(h is! int); // true. h is not an integer variable. so the result is true
print('------');
print(g is String); // false. g is not a string variable. so the result is false
print('------');
print(h is int); // false. h is not an integer variable. so the result is false
print('------');
print(g is double); // false. g is not a double variable. so the result is false
print('------');
print(h is double); // false. h is not a double variable. so the result is false
print('------ Start of Assignment operators in dart programming language -----------------');
// Assignment operators in dart programming language
// Assignment operators are used to assign a value to a variable and it will return the value of the variable after assigning the value to it.
// there are several types of assignment operators in dart programming language

// 1. = equality operator
// 2. += operator
// 3. -= operator
// 4. *= operator
// 5. /= operator
// 6. %= operator
// 7. ~/= operator
// 8. ??= Null-aware assignment operator
// 9. &= bitwise AND assignment operator
// 10. |= bitwise OR assignment operator
// 11. ^= bitwise XOR assignment operator
// 12. <<= left shift assignment operator
// 13. >>= right shift assignment operator
// 14. >>>= unsigned right shift assignment operator
// 15. >>= right shift assignment operator
//1. = operator
var x = 10;
print(x); // 10
print('------');
//2. += operator
var y = 10;
y += 5; // y = y + 5. 10 + 5 = 15
print(y); // 15
print('------');
//3. -= operator
var i = 10;
i -= 5; // i = i - 5. 10 - 5 = 5
print(i); // 5
print('------');
//4. *= operator
var j = 10;
j *= 5; // j = j * 5. 10 * 5 = 50
print(j); // 50
print('------');
//5. /= operator
var k = 10.0;
k /= 5; // k = k / 5. 10.0 / 5 = 2.0
var z = k;
print(z); // 2.0
// this gives result in double value because the value of k is double. if the value of k is int then it will give result in int value.

/*
var k = 10.0;

k /= 5;

print(k); // 2.0
or
double k = 10;

k /= 5;

var z = k;

print(z); // 2.0
 */
print('------');
//6. %= operator
var l = 10;
l %= 5; // l = l % 5. 10 % 5 = 0
print(l); // 0
print('------');

//7. ~/= operator
var m = 10;
m ~/= 5; // m = m ~/ 5. 10 ~/ 5 = 2
print(m); // 2
print('------');
// this operator is used to perform integer division and it will return the integer value of the division operation without any decimal value.
//8. ??= operator
var n;
n ??= 10; // n = n ?? 10; this line says , if the value of n is null then assign the value of 10 to n otherwise keep the value of n as it is.
//
print(n); // 10
print('------');
//9. &= operator
var o = 10;
o &= 5; // o = o & 5.this line says , perform bitwise AND operation between the value of o and 5 and assign the result to o. which means the binary value of 10 is 1010 and the binary value of 5 is 0101. so the result of bitwise AND operation between 10 and 5 is 0000 which is 0 in decimal value.
// so the value of o will be 0 after performing the bitwise AND operation between 10 and 5.;
print(o); // 0
print('------');
//10. |= operator
var p = 10;
p |= 5; // p = p | 5;
print(p); // 15
print('------');
//11. ^= operator
var q = 10;
q ^= 5; // q = q ^ 5;
print(q); // 15
print('------');
//12. <<= operator
var r = 10;
r <<= 5; // r = r << 5;
print(r); // 320
print('------');
//13. >>= operator
var s = 10;
s >>= 5; // s = s >> 5;
print(s); // 0
print('------');
//14. >>>= operator
var t = 10;
t >>>= 5; // t = t >>> 5;
print(t); // 0
print('------');
//15. ??= operator
var u;
u ??= 10; // u = u ?? 10;
print(u); // 10
print('------');



}