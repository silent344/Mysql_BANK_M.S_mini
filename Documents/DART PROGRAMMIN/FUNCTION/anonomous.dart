void main(){
  //ANONYMOUS FUNCTON JIS FUNCTION KA KOI NAAME NA HO
  // Simple example
  // function greet variable mai store ho rha hai
  var greet = (){
    print("hello function");
  };
  greet();
/*
() {
  print("Hello, KritiK!");
}
*/
// ek anonymous function hai jise greet variable mein store kiya gaya hai.

// Example 2.Parameter ke sath 
var food = (String fname,String fname2 ){
  print("I deliver your food:'$fname' and '$fname2'");
};
food('pizza','burger');

var add = (int a, int b){
  return a+b;
};
print(add(43,34));
// use with for each(common use)
List <String> names = ['kritik','khodiyar','Silent','kk'];
names.forEach((name){
  print(name);
});




}