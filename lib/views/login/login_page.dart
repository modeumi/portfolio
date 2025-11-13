import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/views/login/widgets/login_textfield.dart';
import 'package:portfolio/controllers/login_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController id = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    id.clear();
    password.clear();
    Future.microtask(() => ref.read(loginControllerProvider.notifier).initState(context));
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1, color: color_black),
          right: BorderSide(width: 1, color: color_black),
          bottom: BorderSide(width: 1, color: color_black),
        ),
        color: back_grey_2,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 500,
              height: 800,
              padding: EdgeInsets.symmetric(vertical: 150, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: pWhite,
                border: Border.all(width: 2, color: secondary),
              ),
              child: Column(
                spacing: 20,
                children: [
                  Text('Login', style: custom(35, FontWeight.w700, secondary)),
                  Expanded(
                    child: Column(
                      spacing: 50,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          onSubmitted: (value) {
                            controller.login(context);
                          },
                        ),
                        Text(loginState.wrongMessage, style: custom(20, FontWeight.w500, color_red)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.login(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: loginState.confirm ? primary : back_grey_2),
                      child: Center(child: Text('로그인', style: custom(20, FontWeight.w700, loginState.confirm ? pWhite : color_grey))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
