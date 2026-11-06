import 'dart:io';

void main(){
void heading(String name){
  print("\x1B[32mQuestion $name\x1B[0m");
}


// //Q1. 1 se 10 tak ke numbers print karo.
stdout.write("Enter Your number : ");
int n = int.parse(stdin.readLineSync()!);
print("print number from 1 to\x1B[32m $n \x1B[0m");
print(n);
stdout.write("Now your loop ends on $n \n");
for(int i=1;i<=n;i++){
print(i);
}
// Q2. 10 se 1 tak reverse counting print karo.
 heading('2');
 for(int i=10;i>=2;i--){
print(i);
 }
//Q3. 1 se 20 tak ke sirf even numbers print karo.
 heading('3');
for(int i=1;i<=20;i++){
  if(i%2==0){
    print(i);
  }
}
 heading('4');
//Q-4  1 se 20 tak ke sirf odd numbers print karo.
for(int i=1;i<=20;i++){
  if(i%2!=0){
    print(i);
  }
}
 heading('5');
int j=0;
//Q5. 1 se 100 tak jitne numbers hain unka sum nikalo. - 5050
for(int i=1;i<=100;i++){
  // print(i);
  // print(j);
  j=j+i;
  print(j);
}
// Q6. Kisi number ka table print karo.
// 7 x 1 = 7
 heading('6');
print("print the number of Seven");
int seven =7;
for(int i=1;i<=10;i++){
  print("7 * $i = ${seven*i}");

}
//Q7. 1 se 30 tak jitne numbers hain unmein agar number 3 se divisible ho to print karo.
// 3 ke multiples print karo
 heading('7');
for(int i=1;i<=30;i++){
if(i%3==0){
  print(i);
}
}
/*
Q8. 1 se 20 tak print karo.

Lekin:

* agar number 5 ho to "Five" print karo.
* baaki sab numbers normal print karo.
*/
 heading('8');
for(int i=1;i<=20;i++){

   if(i==5){
    print("Five");
    continue;
   }
  print(i);
}
/*
Q9. 1 se 50 tak print karo.

Rules:

* Even → "Even"
* Odd → "Odd"
*/
 heading('9');
for(int i=1;i<50;i++){
  if(i%2==0){
    print("${i}--- Even");
  }else{
    print("${i}---Odd");
  }
}
/*
Q10. 1 se 100 tak jitne numbers hain unmein:

* agar 3 se divisible ho → "Fizz"
* agar 5 se divisible ho → "Buzz"
* agar dono se divisible ho → "FizzBuzz"
* warna number print karo.
*/
 heading('10');
for(int i=1;i<=100;i++){
if(i%3==0){
  print("Fizz");
}else if(i%5==0){
print("Buzz");
}else if(i%3==0 && i%5==0){
  print("FizzBizz");
}else{
  print(i);
}
}
/*
Q11. 1 se 100 tak jitne numbers hain unmein count karo:

* kitne Even hain
* kitne Odd hain
*/
 heading('11');
int even=0;
int odd=0;
for(int i=1;i<=100;i++){
  if(i%2==0){
    even += 1;
  }else{
    odd += 1;
  }
}
print("Total Even: $even");
print("Total Even: $odd");
/*
Q12. Ek variable lo:
int n = 8;
Ab for loop ki help se factorial nikalo.
FORMULA - 8! = 8 × 7 × 6 × 5 × 4 × 3 × 2 × 1

Output:
40320
*/ heading('12');
int eight=8;
for(int i=7;i>1;i--){
  eight = eight*i;
 // print(eight);
}
 print(eight);
}
