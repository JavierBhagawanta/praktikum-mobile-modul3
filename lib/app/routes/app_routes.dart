part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const HOME = _Paths.HOME;
  static const DETAILS = _Paths.DETAILS;
  static const SETTINGS = _Paths.SETTINGS;
  static const LOGIN = _Paths.LOGIN;
}

abstract class _Paths {
  _Paths._();
  
  static const HOME = '/home';
  static const DETAILS = '/details';
  static const SETTINGS = '/settings';
  static const LOGIN = '/login';
}