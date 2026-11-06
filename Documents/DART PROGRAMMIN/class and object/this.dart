class base{
  String a = " ";
  String b = " ";
  base(String a,String b)
  {
    a=b;
    b=b;
  }void show (){
    print("A : $a B: $b");
  }
}
/* 
summary (kya ho rha hai) 
yeha jo instance variable (class ke) hai vo or local variabel(parameter variable) dono same hai a=a and b=b to system ko kaise pata chale ga ki right side vala 



 */
// yeha dekho variable name different hai vocal varible or parameter variable dono
class base2{
  String m = " ";
  String n = " ";
  base2(String a,String b)
  {
    m=a;
    n=b;
  }void show (){
    print("A : $m B: $m");
  }
}
// ab hum yeha this keyword use kr rahe hai
class base3{
  String a = " ";
  String b = " ";
  base3(String a,String b)
  {
    this.a=b;
    this.b=b;
  }void show (){
    print("A : $a B: $b");
  }
}


class base4{
  int a;
  int b;
  base4(this.a,this.b)
  {
    this.a=a;
    this.b=b;
  }void show (){
    print("this is abse 4 class");
    print(a + b);
  }
}

void main(){
base obj = base("Hello", "dart");
obj.show();
base2 obj1 = base2("Hello", "Dart");
obj1.show();

base3 obj2 = base3("Hello", "Dart");
obj2.show();


base4 obj4 = base4(2,3);
obj4.show();
 


}

/*

Instance Variables (Fields)
Static Variables (Class Variables)
ocal Variables


 */


