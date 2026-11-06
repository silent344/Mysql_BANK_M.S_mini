
// Ek function createAccount() banao.
// Required
// * username
// Optional Named
// * email
// * phone

// */
// optional position []
void createAccount(String username ,[String email ="Not provided",int? ph]){
  print(username);
  print(email);
  if(ph==null){
    print("Not provided");
  }else{
    print(ph);
  }
}

void main(){
  print("------Step 1-----");
createAccount("Silent");
print("------Step 2-----");
createAccount("Silent","kk@ss");
print("------Step 3-----");
createAccount("Silent","kk@ss",23);

}
