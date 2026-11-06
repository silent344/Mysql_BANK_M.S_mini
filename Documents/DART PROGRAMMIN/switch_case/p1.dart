

void main() {
  String day = "Sunday"; // agar kuch nahi doge to default value dega


  switch (day) {
    case "Monday":
      print("Start of the week");
      break;

    case "Friday":
      print("Weekend is coming");
      break;

    case "Sunday":
      print("Holiday");
      break;

    default:
      print("Normal day");
  }
  //example 2. Menu
  int option =3;
  switch(option){
  case 1:
    print("\x1B[32mHome Screen\x1B[0m");
    break;
  case 2:
     print("\x1B[33mProfile Screen Screen\x1B[0m");
     break;
  case 3:
      print("\x1B[32mHome Screen\x1B[0m");
      break;
      default:
       print("\x1B[32mInvalid option\x1B[0m");
  }

}