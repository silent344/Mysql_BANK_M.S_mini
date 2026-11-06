class Student {
  String name;
  int age;

  // 1. Normal Parameterized Constructor (Jo humne pehle padha)
  Student(this.name, this.age);

  // 2. HUMARA PEHLA NAMED CONSTRUCTOR!
  // Iska naam humne rakha 'newBorn'. Yeh sirf name lega aur age khud hi 4 set kar dega.
  Student.newBorn(this.name) 
  : age = 4;
}

void main() {
  // Tareeka A: Normal constructor se object banana
  var s1 = Student("Rahul", 20);
  print("${s1.name} ki age hai: ${s1.age}"); // Output: Rahul ki age hai: 20

  // Tareeka B: Named constructor se object banana (.newBorn lagakar)
  var s2 = Student.newBorn("Chintu");
  print("${s2.name} ki age hai: ${s2.age}"); // Output: Chintu ki age hai: 4
}