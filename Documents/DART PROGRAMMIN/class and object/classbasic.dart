// class create outside the main;
// simple example
class Student{
  String name = "Kritik";
  int age = 24;
void study(){
  print("Student is studying");
}
void Studentdetails(){
  print("Student name is '${name}'and age '${age}");
}
void play(){
  print("Student is playing");
}
}


class Animal{
  String name ="Lion";
  int age = 23;
  void weight(){
    print("the animal weight are 230 kg");
  }
  void speed(){
    print("the Speed of this Animla are 34 km/h");
  }
}
class family{
  String name= "Kritik";
int member = 3;
void msg(){
  print(" family member class");
}
}




void main(){
//Call
Student s1 =Student();
print(s1.name);
print(s1.age);
s1.age;
s1.study();
// ya
var c1 = Student();
print("-------");
//ya
print(c1.name);

// how to call the function inside class
  Student student = Student();
//class. Object = Student() (constructor jo object create krta hai.)
student.study();
student.play();
Animal b1 = Animal();
print("---------");
print(b1.age);
b1.speed();
b1.weight();
//creating object
family f1 =family();
//print message
f1.msg();
// printing msg
print(f1.member);




}