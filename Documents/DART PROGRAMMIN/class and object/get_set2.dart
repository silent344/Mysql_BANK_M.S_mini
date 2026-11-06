// simple get and set program
class A{
  String _name; int _age;
  String _course;
  A(this._name, this._course,this._age){
    print("the Student name ${_name} age: ${_age} course ${_course}");
  }
  String get uppercaseName{
    return _name.toUpperCase();
  }
  String get uppercasecourse{
    return _course.toUpperCase();
  }
  /*Haan, bilkul! Agar aapko course ko bhi uppercase mein dikhana hai, toh aapko uske liye ek alag se naya getter banana padega */
  set updateAge(int newage){
    if(newage>0 &&newage<60){
      _age =newage;
    }
  } int get currentage => _age;

}












void main(){
var s1 =A("Kritik ","Flutter",34);
print(s1.uppercaseName);
print(s1.uppercasecourse);
print(s1);



}