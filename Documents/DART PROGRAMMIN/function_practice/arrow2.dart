//Q.6
/*
Arrow function banao jo teen integers me se sabse bada number return kare.

Hint: > aur ternary operator ? : use karna padega.

*/
bigNumber(int a,int b,int c)=>(a>b && a>c)?a:(b>a&&b>c)?b:c;
//Q-7

 //Arrow function banao jo ek marks parameter le aur return kare:

// * "Pass" agar marks >= 33
// * "Fail" warna
String result(int marks)=> marks>=33? "Pass":"Fail";
/*
Question 8

Arrow function banao jo kisi String ko uppercase me return kare.
*/
String upperCaseName(String name)=>name.toUpperCase();

/*
Question 9

Arrow function banao jo ek price le aur uska 18% GST add karke final amount return kare.
GST = Price × 18 / 100
Final Price = Price + GST
*/
//double calculateGST(double price,double gst= price * 18/100,double finalprice = price+gst)=>
double calculateGST(double price) => price + (price * 18 / 100);
 

//  Challenge Question 10

// Arrow function banao jo:

// * String name
// * int age

// le aur return kare:
// My name is Kritik and I am 24 years old.

// */
String studentinfo(String name,int age)=>"My Name is $name and i am $age years old";





void main(){

int big = bigNumber(533, 255, 48);
print(big);
String passYaFail = result(24);
print(passYaFail);
print(upperCaseName("silent kk"));
print(calculateGST(1000));
print(studentinfo("kritik", 24));

}