import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/settings/settings_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              Obx(() => settingsController.isLoading.value ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: () async {
                  await settingsController.signIn(emailController.text, passwordController.text);
                  if (settingsController.isAuthenticated.value) {
                    Get.offAllNamed('/home');
                  }
                },
                child: const Text('Login'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
