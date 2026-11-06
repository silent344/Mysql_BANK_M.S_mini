class Student{
  String _name; //' _ ' means private variable hai
  int _age;
Student(this._name,this._age);
//1. Getter name ko hamesa capital mein dekhane ke liye
String get upperCaseName {
  return _name.toUpperCase();
  
}
//2. setter check karne ke liye
set updateAge(int newage){
  if(newage>0 && newage<100){
    _age = newage;
  }else{
    print("Error: galat age daal rahe ho !");
  }
}

int get currentAge => _age;


}

void main(){
var s1 =Student("Kritik", 20);
print(s1._name);
print(s1.upperCaseName);
s1.updateAge =23;
print(s1.currentAge);








}