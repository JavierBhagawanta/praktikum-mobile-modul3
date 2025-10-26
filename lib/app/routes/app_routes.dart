part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const HOME = _Paths.HOME;
  static const DETAILS = _Paths.DETAILS; // <-- TAMBAHKAN INI
}

abstract class _Paths {
  _Paths._();
  
  static const HOME = '/home';
  static const DETAILS = '/details'; // <-- TAMBAHKAN INI
}