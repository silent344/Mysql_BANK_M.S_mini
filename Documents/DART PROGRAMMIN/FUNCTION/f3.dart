void main(){
  // all parameter with how to print
  // 1. Required only
void a(String name, int age) { print(name); print(age); }
a("KK", 21);  // dono dena zaroori
print('----------');

// 2. Optional Positional []
void b(String name, [int age = 23]) { print(name); print(age); }
b("KK");        // age = 23 (default)
b("KK", 25);    // age = 25
print("------------");
// 3. Optional Named {}
void c({String name = "Unknown", int age = 23}) { print(name); print(age);print('---'); }
c();                        //1.  name=Unknown, age=23
c(name: "KK");              //2.  age=23 default rahega
c(age: 25);                 //3.  name=Unknown default rahega
c(name: "KK", age: 25);    //4.  dono diye
c(age: 25, name: "KK");    //5.  order matter nahi
print("-------------");
// 4. Required + Optional Positional
void d(String name, String email, [int age = 23]) { print("$name $email");print('Age call nahi kiya agar age call karunga to vo bhi print hoga-----'); }
d("KK", "kk@gmail.com");         // age=23 default
d("KK", "kk@gmail.com", 25);     // age=25
print("---------------");
// 5. Required + Optional Named
void e(String name, String email, {int age = 23, String city = "Dhanbad"}) { print(name); }
e("KK", "kk@gmail.com");                          // dono default
e("KK", "kk@gmail.com", city: "Delhi");           // age default
e("KK", "kk@gmail.com", age: 25, city: "Delhi");  // sab diye
print("-------------------");
// 6. Fully Named (required keyword)
void f({required String name, required String email, int age = 23}) { print(name); }
f(name: "KK", email: "kk@gmail.com");           // age=23 default
f(name: "KK", email: "kk@gmail.com", age: 25);  // sab diye
f(email: "kk@gmail.com", name: "KK");           // order matter nahi
print("----------------");
// 7. Return type + Optional Named
String g(String name, {String city = "Dhanbad"}) { return "I am $name from $city"; }
print(g("KK"));              // "I am KK from Dhanbad"
print(g("KK", city: "Delhi")); // "I am KK from Delhi"
}