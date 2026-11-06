/*ClassName.constructorName() {
   // code
} */
class Student {

  Student() {
    print("Default Constructor");
  }

  Student.data() {
    print("Named Constructor");
  }
}



void main(){



  Student s1 = Student();
  print(s1);
  var constructors = Student();
  print(constructors);

  Student s2 = Student.data();
print(s2);



}