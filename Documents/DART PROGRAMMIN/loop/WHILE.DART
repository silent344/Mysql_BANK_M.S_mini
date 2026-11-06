//Socho aap ek game khel rahe ho, aur jab tak game khatam nahi hota (!isDone()), tab tak aapko khelte rehna hai:
void main() {
  var energy = 3;

  // Jab tak energy 0 se badi hai, tab tak andar aao
  while (energy > 0) {
    print('Khelte raho! Energy bachi hai: $energy');
    energy--; // Har baar khelne par energy 1 kam ho jayegi
  }
  print('Game Over!');
}