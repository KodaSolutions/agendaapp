
class Listenerapptm{
  bool _change = false;
  DateTime _date = DateTime.now();
  int _id = 0;
  final List<Function(bool, DateTime, int)> _observadores = [];

  void setChange(bool value, DateTime dateValue, int idValue){
    _change = value;
    _date = dateValue;
    _id = idValue;
    notificarObservadores();
  }

  void registrarObservador(Function(bool, DateTime, int) callback){
    _observadores.add(callback);
  }

  void notificarObservadores(){
    for (var callback in _observadores){
      callback(_change, _date, _id);
    }
  }

  bool get change => _change;
  DateTime get date => _date;
  int get id => _id;
}