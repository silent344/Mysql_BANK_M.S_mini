void greet(){
  print("hello");
}
void  showname(String name){
  print(name);
}
void add(int a,int b){
  print(a+b);
}
int add2(int a,int b){
  return a+b;
}


void main(){
greet();
showname("Silent");
add(23,34);
//this below line give error
//void type
//print(add (2,3) + 10);
// return type
print(add2(2,3)+ 10);



}