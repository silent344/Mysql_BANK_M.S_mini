// tareeka A the old/traditional way (Jo baki language use hota hai)
// sabhi language ka nahi pata pr bina null safety ya late use kiye work nahi karega or eror dega
class Student{
 late String  name;
 late  int age;
  // parameterized .C
  Student(String name,int age){
    this.name =name;
    this.age =age;
  }
}
/* you can also write by using semicolons
class Student {
  String name;
  int age;

  // Parameterized constructor
  Student(String name1, int age1)
      : name = name1,
        age = age1;
}

 */
// tarika B : short form
class Student2{
 String  name;
   int age;
  // parameterized .C
  Student2(this.name,this.age){
    name =name;
    age =age;
  }
}


void main(){
var s1 = Student("first_class", 34);
print(s1.name);
var s2 =Student("Kritik", 34);
print(s2.name);
var s3 = Student2("Second_class", 34);
print(s3.name);
var s4 =Student2("Kritik", 34);
print(s4.name);
print(s4.age);

}