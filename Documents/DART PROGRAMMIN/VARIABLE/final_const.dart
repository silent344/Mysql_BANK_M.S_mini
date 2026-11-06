void main() {

  // ===== FINAL =====
  
  final String name = 'Kritik';
  print(name);  // Kritik

  final DateTime loginTime = DateTime.now();  // Runtime pe set — allowed!
  print(loginTime);  // Jo bhi abhi ka time ho

  final List<String> cities = ['Dhanbad'];
  cities.add('Ranchi');  // Andar change — allowed!
  print(cities);  // [Dhanbad, Ranchi]

  // name = 'Rahul';  // ERROR — reference nahi badal sakte
  // cities = [];     // ERROR — reference nahi badal sakte


  // ===== CONST =====

  const double pi = 3.14159;
  print(pi);  // 3.14159

  const int maxUsers = 100;
  print(maxUsers);  // 100

  const List<String> months = ['Jan', 'Feb', 'Mar'];
  print(months);
  // months.add('Apr');  // ERROR — andar bhi nahi badal sakte
  // months = [];        // ERROR — reference bhi nahi

  // const DateTime now = DateTime.now();  // ERROR!
  // DateTime.now() runtime pe chalta hai

  

//wildecard (_) first learn the loop and if else










}