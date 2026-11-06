class a{
  int national_highway = 23;
  int gali_No = 34;
 int house_um = 2;
 String Owner_Name = 'Shyam Kishore Sai';
 void houseType(){
  print("This is a rent house");
 }
void addres(){
  print("$national_highway $gali_No $house_um");
}

}







void main(){
a h1 =a();
// call the variable values
print(h1.Owner_Name);
// now call the class function. i,e methord.
h1.houseType();










}