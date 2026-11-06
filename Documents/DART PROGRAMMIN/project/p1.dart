import 'dart:io';


//add function
double add(double a,double b){
  return a + b;
}
// sub fun
double sub(double c ,double d){
  return c - d;
}
// divide fun - quetient
double divd(double e, double f){
  return e / f; 
}
//multiplication


void main(){
// calculator
stdout.write("what you want to perfrom Add, Sub, Multiplication");
String sign = stdin.readLineSync()!;
if(sign=="+"){
  stdout.write("enter your first number: ");
  double f_num = double.parse(stdin.readLineSync()!);
    stdout.write("enter your second number: ");
  double s_num = double.parse(stdin.readLineSync()!);
  print(add(f_num, s_num));
}else if(sign=="-"){
  stdout.write("Enter your First Number: ");
  double sub_1_num =double.parse(stdin.readLineSync()!);
  stdout.write("Enter your second number");
  double sub_2_num =double.parse(stdin.readLineSync()!);
  print(sub(sub_1_num, sub_2_num));
}else if(sign=="/"){ 
  print("you are dividing the number:");
  double dev_1  =double.parse(stdin.readLineSync()!);
  double devid_2 =double.parse(stdin.readLineSync()!);
  print(divd(dev_1,devid_2));
}
//calculator 2

stdout.write("Enter your First Number: ");
// double F_number = double.parse();
stdout.write("Enter your second Number");

}


// stdout.write("Enter First Number: ");
// double first_num = double.parse(stdin.readLineSync()!);
// stdout.write("Enter your Sign +, -, *, / ");
// String sign =stdin.readLineSync()!;
// stdout.write("Enter Second Nnumber: ");
// double Second_num = double.parse(stdin.readLineSync()!);
// switch(sign){
//   case "+":







