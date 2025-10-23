import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/widgets/Login/login_textfield.dart';
import 'package:portfolio/features/login/login_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/push_button.dart';
import 'package:utility/textstyle.dart';
import 'package:utility/custom_textfield.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController id = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(color: pMainColor),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: Text('Login', style: black(25, FontWeight.w700))),
          Center(
            child: Container(
              width: 500,
              height: 800,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: pWhite),
              child: Column(
                spacing: 20,
                children: [
                  LoginTextfield(
                    content: 'Email',
                    controller: id,
                    obscure: false,
                    width: double.infinity,
                    onChange: () => controller.setInputData('id', id.text),
                  ),
                  LoginTextfield(
                    content: 'Password',
                    controller: password,
                    obscure: true,
                    width: double.infinity,
                    onChange: () => controller.setInputData('password', password.text),
                  ),
                  Text(loginState.wrongMessage, style: custom(20, FontWeight.w500, color_red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
