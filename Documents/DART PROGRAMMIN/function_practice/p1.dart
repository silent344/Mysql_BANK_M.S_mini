 //1. Ek function greet() banao jo ek name parameter le aur print kare:

void greet(String name){
  print("Hello ${name}");
 }
//2. Ek function addNumbers() banao jo do integers le aur unka sum print kare.
void addNumbers(int x , int y){
  print(x + y);
}
//3.
//Ek function studentInfo() banao jo ye parameters le

// * name
// * age
studentinfo(String name,int age){
  print("name:$name" );
  print("Age: $age");
}
//4.
//Ek function introduce() banao.

// * name required hai
// * city optional hai

// Agar city na mile to sirf naam print karo.
welcome(String name, [String ?city]){
  print("Name: $name");
  if(city != null){
  print("City $city");
  }
}
/*
5.
Ek function calculateBill() banao.

Parameters

* price (required)
* discount (optional)
formula 
Final Price = price - discount

 */
calculateBill(double price, [double discount = 0]){
  double final_price = price - discount;
  print(final_price);
}

/* 
6.
Ek function createAccount() banao.
Required
* username
Optional Named
* email
* phone

*/
// optional position []
void createuser(String username ,{String email ="Not provided",int? ph}){
  print(username);
  print(email);
  if(ph==null){
    print("Not provided");
  }else{
    print(ph);
  }
}

/*
7.
Ek function employee() banao.

Parameters

* name (required)
* age (optional named)

Agar age na mile to print karo
*/

employee(String name ,{int ? age}){
print("Employee: ${name}");
if(age == null){
  print("Not available");
}else {
  print(age);
}
}
/*
8.
Ek function bookTicket() banao.

Parameters

* passengerName (required)
* seatNumber (optional named)
* coach (optional named)

Agar koi value na mile to
*/
bookticket(String passengersName,{int? seatNumber ,String? coach ="Not Assigned"}){
   print("Passengers Name: $passengersName");
 
  if(seatNumber ==null){
    print("Not Assigned");
  }else{
   //print("Passengers Name: $passengersName");
  print("SeatNumber:$seatNumber");
  // print("$coach");
  }
  print("Coach: $coach");
}
/*
Ek function orderFood() banao.

Parameters

* foodName (required)
* quantity (optional positional)
* spicy (optional named)

Rules

* quantity na mile → 1
* spicy na mile → false

*/
orderfood(String Foodname,{int? quantity=1,bool? spicy}){
print("Foodname: $Foodname");
print("quality: $quantity");
if(spicy == null){
  print(false);
}else{
print("Spicy: $spicy");
}
}
//10.
/*
Ek function studentResult() banao.

Parameters

* name (required)
* marks (required)
* grade (optional positional)
* passed (optional named)

Rules

* grade na mile → "Not Given"
* passed na mile → false

*/
studentResult(String name,int marks,{String grade ="Not null" ,bool? passed}){
print("name: $name");
print("Marks: $marks");
print("Grade: \x1B[32m$grade\x1B[0m");
if(passed == null){
  print("Passed: ${false}");
}else {
  print("Passed:${true}");
}
}
/*
Ek function userProfile() banao.

Parameters:

* name (required)
* age (required)
* city (optional named, default "Unknown")
* isStudent (optional named, default false)
*/

userprofile(String named,int age,{String city ="Unknown",bool isStudent =false}){
  print("\x1B[32mName:$named\x1B[0m");
  print("\x1B[32mAge:$age\x1B[0m");
  print("\x1B[32mCity: $city\x1B[0m");
 print("\x1B[32mStudent: $isStudent\x1B[0m");
}
//12.
/*
 Ek function electricityBill() banao.

Parameters:

* units (required)
* ratePerUnit (optional named, default 8.5)
*/
electricityBill(double units ,[double ratePerUnit =8.5]){
  double bills = units*ratePerUnit;
  print("\x1B[33munits: \x1B[0m\x1B[32m$units\x1B[0m");
  print("\x1B[36mRatePerUnit: \x1B[0m\x1B[32m$bills\x1B[0m");
}
//13.
/*
Ek function movieTicket() banao.
Parameters:

* movieName (required)
* ticketPrice (required)
* numberOfTickets (optional named, default 1)
* foodCombo (optional named, default false)

Rules:

* Total = ticketPrice × numberOfTickets
* Agar foodCombo = true ho to ₹250 extra add karo.

*/
movieTicket(String movieName,double ticketPrice ,{int numberOfTickets = 1,bool foodCombo =false}){
  double price = ticketPrice*numberOfTickets;
  
  print("\x1B[37m MovieName: \x1B[0m\x1B[32m$movieName\x1B[0m");
  print("\x1B[37mTicket Price: \x1B[0m\x1B[32m$ticketPrice\x1B[0m");
  print("\x1B[37mNumber of Tickets \x1B[0m\x1B[32m$numberOfTickets\x1B[0m");
  
  //print("\x1B[37mFoodCombo \x1B[0m\x1B[32m$foodCombo\x1B[0m");
  if(foodCombo== true){
    price += 250;
     print("FoodCombo: \x1B[32m${foodCombo}\x1B[0m");
      print(price);
  }else {
     print("FoodCombo: \x1B[31m${foodCombo}\x1B[0m");
      print("price: ${price}");
  }

}


 void main(){
  



print("\x1B[31m-----Question 1--------\x1B[0m");
greet("kritik");
print("\x1B[31m-----Question 2--------\x1B[0m");
addNumbers(10,20);
print("\x1B[31m-----Question 3--------\x1B[0m");
studentinfo("kritik", 24);
print("\x1B[31m-----Question 4--------\x1B[0m");
welcome("Silent");
welcome("Silent","Dhanbad");
print("\x1B[31m-----Question 5--------\x1B[0m");
calculateBill(12500,302);
calculateBill(12500);
print("\x1B[31m-----Question 6--------\x1B[0m");
createuser("Silent");
print("------");
createuser("Silent",email: "Silent@kk");
print("-------");
createuser("Silent", email:"Silent",ph:92345);
print("\x1B[31m-----Question 7--------\x1B[0m");
employee("Kritik");
employee("Kritik",age: 34);
// employee("Kritik");
print("\x1B[31m-----Question 8--------\x1B[0m");
bookticket("kritik");
print("===");
bookticket("kritik",seatNumber: 23);
bookticket("kritik",seatNumber: 23,coach: "A3");
print("\x1B[31m-----Question 9--------\x1B[0m");
orderfood("Pizza",quantity: 3);
orderfood("Pizza",quantity: 3,spicy: true );
print("\x1B[31m-----Question 10--------\x1B[0m");
studentResult("kritik",56);
print(" 10.2");
studentResult("Kritik",56,grade: "A");
print("\x1B[31m-----Question 11--------\x1B[0m");
userprofile("kritik",23);
print("=====");
userprofile("Silent",23,city: "dhanbad",isStudent:true);
print("\x1B[31m-----Question 12--------\x1B[0m");
electricityBill(100);

print("\x1B[1;41m -------Question -13------\x1B[0m");
movieTicket("Pushpa 2",500,numberOfTickets: 3);

 }