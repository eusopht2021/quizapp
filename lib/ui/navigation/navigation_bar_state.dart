import 'package:equatable/equatable.dart';
import 'package:flutterquiz/ui/navigation/navbaritems.dart';

class NavigationbarState extends Equatable {
  final NavbarItems navbarItems;
  final int index;

  NavigationbarState(this.navbarItems, this.index);

  @override
  List<Object> get props => [this.navbarItems, this.index];
}
