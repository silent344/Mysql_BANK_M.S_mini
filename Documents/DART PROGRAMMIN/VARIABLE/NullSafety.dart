// void main(){
// String? name = "Kritik";
// //
// print(name);
// String? middlename = null;
// print(middlename);
// String lastname ="khodiyar";
// print(lastname);

// String? age;
// int linecount;
// int a = 5 + 3;
// print(a);
// }
void main(){
// about Null Safety
// by default dart mein variable Null nahi hosakta hai.
String name;
name = 'kk';
print(name);
//1. Galat .Kyu ki value assign nahi hai.
String namw2 ='Kritik';
print(namw2);
// 2. Sahi kyu ki value assign hai.
// Null Safety
String? Class;// "?" hai . Matlab Null ho sakta hai
print(Class);
String Section; // NO "?" .Matlab Null nahi Ho Sakta hai.
Section = 'a';
print(Section);
String? city = null;// ? Allowed
print(city);
// String State = null; // Error
// how to check Null
//1.
String? username ="Kritik";
if(username!= null){ //The operand can't be 'null', so the condition is always 'true'.
  print(username.length);
}
//2. ? Operator (Null Aware)
print(username?.length);

}