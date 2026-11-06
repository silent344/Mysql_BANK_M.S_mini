 void main(){
// // First How to decelare a variable
// //1.
// var name = 'var of BOB'; // DART KHUD DATATYPE DETECT KR LEGA
// print(name);
// print('----------');
// //2.
// //Expecitly likhna
// String name1 = 'String of Bob'; // yeha humne dart ko specify kr diya ki yeh String type hai
// print('-----------');
// print(name1);
// //3.
// Object name3 = "Object of Bob"; // Object mein different types Store kr sakte hai.
// print(name3);
// start from start
//1. var;
var fname = "kritik";
print(fname.runtimeType);
print("String? name; ('?' Hai Matlab Null ho sakta hai)");
print("String name; ('?' Nahi matlab Null nahi ho Sakta )");

// how to check null??

String? username = 'kritik';
if(username!=null){
    print(username.length);
}
// ? operator(NUll Aware)
print(username?.length);
// iska matlab “Agar username null nahi hai, toh uski length print karo. Agar username null hai, toh error mat do, bas null print kar do.”



}