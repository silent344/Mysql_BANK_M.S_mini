void main(){
// 1. named parameter parameter ko name dedo
nampara({a,b}){
  // print(a);
  // print(b);
  print(a+b);
}
var value = nampara(b : 34, a : 45);
print(value);
//Dart mein agar function return type nahi deta aur return statement nahi hota, to function automatically null return karta hai.


// 1. Required only
void a(String name, int age) {}
a("KK", 21);

// 2. Optional Positional []
void b(String name, [int age = 23]) {}
b("KK"); b("KK", 25);

// 3. Optional Named {}
void c({String name = "Unknown", int age = 23}) {}
c(); c(name: "KK"); c(age: 25); c(name: "KK", age: 25);

// 4. Required + Optional Positional
void d(String name, String email, [int age = 23, String city = "Dhanbad"]) {}
d("KK", "kk@gmail.com"); d("KK", "kk@gmail.com", 25); d("KK", "kk@gmail.com", 25, "Delhi");

// 5. Required + Optional Named
void e(String name, String email, {int age = 23, String city = "Dhanbad"}) {}
e("KK", "kk@gmail.com"); e("KK", "kk@gmail.com", city: "Delhi"); e("KK", "kk@gmail.com", age: 25, city: "Delhi");

// 6. Fully Named (kuch required, kuch optional)
void f({required String name, required String email, int age = 23}) {}
f(name: "KK", email: "kk@gmail.com"); f(name: "KK", email: "kk@gmail.com", age: 25);

// 7. Return type + Optional Named
String g(String name, {String city = "Dhanbad"}) => "I am $name from $city";
print(g("KK")); print(g("KK", city: "Delhi"));






}