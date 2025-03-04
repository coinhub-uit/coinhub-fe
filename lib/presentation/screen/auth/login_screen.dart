import "package:coinhub/core/bloc/auth/auth_event.dart";
import "package:coinhub/core/bloc/auth/auth_logic.dart";
import "package:coinhub/core/bloc/auth/auth_state.dart";
import "package:coinhub/presentation/routes/routes.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is LoginStateSuccess) {
            context.push(Routes.home); // Navigate on successful login
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 160, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset("assets/images/CoinHub-Wordmark.png"),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                const WelcomeText(
                  title: "Welcome!",
                  text: "Please enter your Email\nand Password to login.",
                ),
                const SignInForm(),
                const SizedBox(height: 16),
                Center(child: Text("Or", style: TextStyle())),
                const SizedBox(height: 16 * 1.5),

                Center(
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      text: "Don't have account? ",
                      children: <TextSpan>[
                        TextSpan(
                          text: "Create new account.",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  context.push(Routes.auth.signUp);
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Google Sign-In Button
                FilledButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(LoginEventGoogle());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1e66f5),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign in with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  final String title, text;

  const WelcomeText({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16 / 2),
        Text(text, style: TextStyle(color: Color(0xFF868686))),
        const SizedBox(height: 24),
      ],
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: (value) {
              _email = value?.trim() ?? "";
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email Address",
              filled: false,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const UnderlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            obscureText: _obscureText,
            onSaved: (value) {
              _password = value ?? "";
            },
            decoration: InputDecoration(
              hintText: "Password",
              filled: false,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const UnderlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Forget Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.push(Routes.auth.forgotPassword);
              },
              child: Text(
                "Forgot Your Password?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign In Button
          FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                context.read<AuthBloc>().add(
                  LoginEventLogin(_email, _password),
                );
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Sign in", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
