void student({
  required String name,
  required int age,
}) {
  print(name);
  print(age);
}

void main(){
  // function
  // returntype functionname(Parameter)
  // working area
  // return kuch
  
  //mujhe ketne function karne hai.
  //1. Named parameter
// 2. Optional named Parameter
// 3. anonymous Funciton
// 4. Arrow function.
// 5. default value parameter


//1.
// returntype(int/String/void) functionName(parameter){
//code 
// }
 print("Named Paremeter");
 void greet() {
  print("Hi Kritik");
 }//main ke bhaar bhi likh sakte hai function ko or main ke ander call karo sirf
 greet();//call the function


//1.2 Named function with parameters
void greed2(String name){
  print("Hi $name");
}
greed2('Kritik');

// Named Function Returning Value
int add(int a,int b){
  return a + b;
}
int result = add(23,45);
print(result);
// 2 Optional Positional Parameter Function
void heraferi(String name,[String? msg]){
  print("$name karne ka ki nahi krne ka ? $msg");
}
heraferi('heraFeri','nahi');

void dialog(String dialog,[String? dialog2]){
  print("$dialog,$dialog2");
}
dialog('Kya gunda banega..?','tere bache salamat rahe');
//Multiple Optional Parameter Function
void details(String name,[int? age,int? pincode,String? address,double? income,bool? working = false])// here we use default value
{
print(name);
print(age);
print(pincode);
print(address);
print(income);
print(working);
}
details('kritik',24,826001,'Dhanbad',1500.00,);


//3. Optional Named Parameter Function 
void family({
  String? name1,
  int? age1,
String? name2,
int? age20
}){
  print(name1);
  print(age1);
  print(name2);
  print(age20);
}

family(
  name1: 'kritik',age1: 24,name2: 'Nilesh',age20: 25
  );
//3.2 requied name parameter
// for function See before main function start
student(
  name: "KritiK", age: 24
  );

// Default value
void student2({
  String name = "Unknown",
  int age4 = 23,
}){
print(name);
print(age4);
}
student2();
// int add(int a, int b){
//   return a+b;
// }
// int result = add(45,64);
// print(result);
// print("------");

// int ad(a,b){
//   return a+b;
// }
// var total = ad(34,56);
// print(total);



// String greet(String name){
//   return "Hello $name";
// }
// String msg = greet('kritik');
// print(msg);
// print('----------');




// bool isAdult(int age){
//   return age>=18;
// }
// isAdult(45);
// // bool adult = isAdult(34);
// // print(adult);
// // print('--------');

// void printName(String name) {
//   print(name);   // sirf print kiya, kuch return nahi kiya
// }
// printName('kritik');
// String nam = "Silent";
// print(nam);



}