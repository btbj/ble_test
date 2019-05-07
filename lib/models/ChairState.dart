class ChairState {
  List<int> value;
  int battery = 0;
  int temperature = 26;
  String state = '111111';
  bool buckle = true;
  bool lfix = true;
  bool rfix = true;
  bool routation = true;
  bool pad = true;
  bool leg = true;

  void setValue(List<int> value) {
    if(value == null || value.length != 6) return;
    battery = value[4];
    temperature = value[3];
    int stateInt = value[2];
    state = stateInt.toRadixString(2);

    leg = (stateInt >> 5) % 2 == 1;
    rfix = (stateInt >> 4) % 2 == 1;
    lfix = (stateInt >> 3) % 2 == 1;
    routation = (stateInt >> 2) % 2 == 1;
    pad = (stateInt >> 1) % 2 == 1;
    buckle = stateInt % 2 == 1;
  }
}