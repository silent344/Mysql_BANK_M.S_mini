void main(){
four(one,two,three);

}

  void one(){
    print("First function");
  }
    void two(){
    print("2nd function");
  }
    void three(){
    print("3ed function");
  }

void four(Function callback1,Function callback2,Function callback3){
  print("Four th Function");
  callback1();
  callback2();
  callback3();
}