// function with parameter
// 1. postional Positional parameter[]
/*
Optional Positional Parameters wo parameters hote hain jinhe dena zaroori nahi hota, aur agar do to unki position (order) sahi honi chahiye.
 */


void demo(String name,[int age =10]){ 
  //* name → Required
// * age → Optional Positional
print("Name:${name} Age ${age}");

}

// Optional Named Parameters {} wo parameters hote hain jinhe dena zaroori nahi hota, aur agar do to parameter ka naam likhna padta hai.

demo2(String Address ,{int ? ph}){
  print(Address);
  print(ph);
}
 demo3(String Address ,{int ph = 12345}){
  print(Address);
  print(ph);
}
void main(){
  demo("kk",20);
  demo("kk");
  demo3("Ranchi",ph:09876);

demo2("Ranchi",ph: 123450);


}










//   // function without parameter
// myfun(){
//   print("hello dart");
// }
// myfun();
// // without return type
// addfun(){
//   int a=3;
//   int b=5;
//   return a + b;
// }
// var add = addfun();
// print(add);
















// int ad(a,b){
//   return a+b;
// }
// var total = ad(34,56);
// print(total);
// // 3. optional position parameter
// // parameret ko optionl bnane keliye parameter ko [] daal do with ?
// String introfun(String name,[String? city]){
//   return "i am $name from $city";
// }
// String meg = introfun("kk",'Ranchi');
// print(meg);
// // default value parameter
// String introfun2(String name,[String city = 'Dhanbad']){ // dhanbad optional hai matlab agar function call karne time value nahi di gayi hai to dhanbad print hojaaye ga.
// // or agar value di gai hai to vo dhanbad print na ho ke vo value print hogi
//   return "i am $name from $city";
// }
// String meg2 = introfun2("kk",'Ranchi');
// print(meg2);

