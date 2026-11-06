import 'dart:io';


void Heading(String text){
  print("\x1B[31m-_-_-Qouestion: $text-_-_\x1B[0m");
}

void main(){
 print("Let's print pattern printing"); 
/*
1. 
*
**
***
****
*****
OUTER LOOP (I = ROW)
INNER LOOP (J = COLUMN (WHICH YOU WANT TO PRINT). )

*/
Heading("1");
int j;
for(int a=1;a<=5;a++){
  // print("Printing a: $a");
  for(j=1;j<a;j++){
    stdout.write("*");

  }print(" ");

}
/*
Q.2
*****
*****
*****
*****
*****
*/
Heading("2");
for(int i=0;i<5;i++){
  for(int j=1;j<=5;j++){
    stdout.write(j);
  }
  print(" ");
}
/*
1
12
123
1234
12345
*/
Heading("3");
for(int a=1;a<=5;a++){
  // print("Printing a: $a");
  for(j=1;j<=a;j++){
    stdout.write(j);

  }print(" ");

}
/* Q.5
5
54
543
5432
54321

*/
Heading("4");
for(int i=0;i<=5;i++){
  for(int j=5;j>(5-i);j--){
    stdout.write(j);
  }print(' ');
}
Heading("4.2");
for(int i=1;i<=5;i++){
for(int j=5;j>=i;j--){
  stdout.write(j);
}print(" ");

}
// 
// for(int i=1;i<=5;++i){
// for(int j=5;j<=5-i);)
// // i=1 or j=5 So, 5<=(1-5) => 5<=4
 
// }




}