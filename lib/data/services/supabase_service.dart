import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/hive_car_model.dart';
import '../../config/supabase_config.dart';
import '../../app/modules/settings/settings_controller.dart';

class SupabaseService extends GetxService {
  // Supabase client
  SupabaseClient get client => Supabase.instance.client;

  // Check if user is authenticated
  bool get isAuthenticated {
    try {
      return client.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Initialize Supabase
  Future<void> init() async {
    try {
      // Check jika sudah di-initialize
      try {
        final instance = Supabase.instance;
        if (instance.client.auth.currentSession != null) {
          debugPrint('Supabase already initialized');
          return;
        }
      } catch (_) {
        // Belum di-initialize, lanjutkan
      }
      
      // Initialize Supabase dengan config
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      debugPrint('Supabase initialized successfully');
      
      // Setup auth state listener
      _setupAuthListener();
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      debugPrint('Note: Supabase will not be available. Please configure .env file.');
      // Jangan throw error, biarkan app tetap berjalan
    }
  }
  
  // Setup auth state listener untuk auto-update
  void _setupAuthListener() {
    try {
      client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        
        debugPrint('Auth state changed: $event');
        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
          // Trigger update di settings controller jika ada
          try {
            final settingsController = Get.find<SettingsController>();
            settingsController.updateAuthStatus();
          } catch (e) {
            // Settings controller belum di-initialize, ignore
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to setup auth listener: $e');
    }
  }
  
  // Check if Supabase is properly initialized
  bool get isInitialized {
    try {
      final url = SupabaseConfig.url;
      if (url == 'YOUR_SUPABASE_URL' || url.isEmpty) {
        return false;
      }
      // Try to access client
      final _ = client;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ AUTH METHODS ============

  // Sign up dengan email dan password
  Future<User?> signUp(String email, String password) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase is not initialized. Please configure .env file.');
      }
      
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        debugPrint('Account created successfully: ${response.user?.email}');
        // Update auth status di settings controller
        _notifyAuthChange();
      }
      return response.user;
    } catch (e) {
      debugPrint('Failed to sign up: $e');
      rethrow;
    }
  }
  
  // Helper untuk notify auth change
  void _notifyAuthChange() {
    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.updateAuthStatus();
    } catch (e) {
      // Settings controller belum di-initialize, ignore
    }
  }

  // Sign in dengan email dan password
  Future<User?> signIn(String email, String password) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase is not initialized. Please configure .env file.');
      }
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        debugPrint('Signed in successfully: ${response.user?.email}');
        // Update auth status di settings controller
        _notifyAuthChange();
      }
      return response.user;
    } catch (e) {
      debugPrint('Failed to sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase is not initialized. Please configure .env file.');
      }
      
      await client.auth.signOut();
      debugPrint('Signed out successfully');
      // Update auth status di settings controller
      _notifyAuthChange();
    } catch (e) {
      debugPrint('Failed to sign out: $e');
      rethrow;
    }
  }

  // ============ DATABASE METHODS ============

  // Save car to Supabase
  Future<void> saveCarToCloud(HiveCarModel car) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase is not initialized. Please configure .env file.');
      }
      
      if (!isAuthenticated) {
        throw Exception('User must be authenticated to save to cloud');
      }

      // Tambahkan user_id untuk RLS
      final carMap = car.toSupabaseMap();
      carMap['user_id'] = client.auth.currentUser!.id;
      
      await client
          .from('cars') // Ganti dengan nama table Anda di Supabase
          .upsert(carMap);
      
      debugPrint('Car saved to cloud: ${car.namaMobil}');
    } catch (e) {
      debugPrint('Failed to save car to cloud: $e');
      rethrow;
    }
  }

  // Get all cars from Supabase
  Future<List<Map<String, dynamic>>> getAllCarsFromCloud() async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase is not initialized. Please configure .env file.');
      }
      
      if (!isAuthenticated) {
        throw Exception('User must be authenticated to fetch from cloud');
      }

      final response = await client
          .from('cars') // Ganti dengan nama table Anda di Supabase
          .select()
          .order('saved_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to get cars from cloud: $e');
      rethrow;
    }
  }

  // Get car by id from Supabase
  Future<Map<String, dynamic>?> getCarByIdFromCloud(String id) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User must be authenticated to fetch from cloud');
      }

      final response = await client
          .from('cars') // Ganti dengan nama table Anda di Supabase
          .select()
          .eq('id', id)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get car from cloud: ${e.toString()}');
      return null;
    }
  }

  // Delete car from Supabase
  Future<void> deleteCarFromCloud(String id) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User must be authenticated to delete from cloud');
      }

      await client
          .from('cars') // Ganti dengan nama table Anda di Supabase
          .delete()
          .eq('id', id);

      Get.snackbar('Success', 'Car deleted from cloud storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete car from cloud: ${e.toString()}');
      rethrow;
    }
  }

  // Sync local data to cloud
  Future<void> syncToCloud(List<HiveCarModel> localCars) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User must be authenticated to sync to cloud');
      }

      for (var car in localCars) {
        await saveCarToCloud(car);
      }

      Get.snackbar('Success', 'Data synced to cloud successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sync to cloud: ${e.toString()}');
      rethrow;
    }
  }
}

