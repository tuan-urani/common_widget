import 'package:get/get.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBloc>(() => MainBloc());
  }
}
