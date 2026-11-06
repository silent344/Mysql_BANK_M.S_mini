/*
Question 1

Normal function ko arrow function me convert karo.

String greet(String name) {
  return "Hello $name";
}
*/
String greet(String name)=>"Hello $name";



 /* 2
 int add(int a, int b) {
  return a + b;
}
*/
int add(int a , int b)=>a+b;



/* 3.
bool isEven(int number) {
  return number % 2 == 0;
}
*/
bool isEven(int number) => number %2==0;



/* Q.4
Arrow function banao jo ek double radius le aur circle ka area return kare.
3.14 × radius × radius
*/
double returnradius(double radius)=>3.14*radius*radius;



/* 5.
Arrow function banao jo String le aur uski length return kare.
*/
name(String name)=>name.length;
/*
Bina if-else aur bina normal function ke, sirf arrow function me ye likho:
// 1.
int square(int n)

// 2.
bool isPositive(int n)

// 3.
String getGrade(int marks)

*/

void cicrleArea(double radius){
  double total = radius*radius*3.14;
  print(total);
}
double radius(double num ,double total)=>total = 3.14*num*num;
void main(){

print("\x1B[32m-_-_-_Question 1 _-_-_\x1B[0m");
print(greet("Kritik"));

print("\x1B[32m-_-_-_Question 2 _-_-_\x1B[0m");
print(add(3, 3));

print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print(isEven(20));

print("\x1B[32m_-_-_Question 4_-_-_\x1B[0m");
print(returnradius(5));

print("\x1B[32m-_-_-_Question 5 _-_-_\x1B[0m");
print("${name("kritik")}");

// print("\x1B[32m-_-_-_Question 5 _-_-_\x1B[0m");
// radius(5, 0);

// print("\x1B[32m-_-_-_Question 6 _-_-_\x1B[0m");
// cicrleArea(5);
print("\x1B[35m-_-_-_next 5-Question in next file-_-_-_\x1B[0m");

print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
}