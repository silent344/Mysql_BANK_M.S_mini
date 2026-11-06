

void main(){
/*
Arrow Function Dart mein short syntax hota hai. Jab function ke andar sirf ek hi expression ya ek hi statement ho, tab hum arrow function (=>) use karte hain.
normal function syntax

returnType functionName(parameters) {
  return expression;
}
arrow function syntax

returnType functionName(parameters) {
  return expression;
}
*/

//EX -1
//normal function
int add(int a ,int b){
  return a+b;
}
int sum = add(34,54);
print(sum);
//arrowfunction
int add3(int s,int d)=> s + d;
int sum2 = add(10,20,);
print(sum2);
//ex =2;
print("\x1B[32m-_-_-_Question 2 _-_-_\x1B[0m");
String greet(String name){
  return "Hello $name";
}
print(greet("Kritik"));

String greet2(String name)=>"Hello $name";
print(greet2("Kritik"));
//3
print("\x1B[32m-_-_-_Question 3 _-_-_\x1B[0m");
bool isAdult(int age)=>age>=18;
print(isAdult(23));

}