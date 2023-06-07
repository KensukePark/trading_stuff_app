import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/auth_model.dart';
import '../model/register_model.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              EmailInput(),
              PasswordInput(),
              PasswordConfirmInput(),
              RegistButton()
            ],
          ),
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (email) {
          register.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'email',
          helperText: '',
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (password) {
          register.setPassword(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'password',
          helperText: '',
          errorText: register.password != register.passwordConfirm ? 'Password incorrect' : null,
        ),
      ),
    );
  }
}

class PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (password) {
          register.setPasswordConfirm(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'password confirm',
          helperText: '',
        ),
      ),
    );
  }
}

class RegistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final register = Provider.of<RegisterModel>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: (register.password != register.passwordConfirm) ? null : () async {
          await authClient
              .auth_register(register.email, register.password)
              .then((registerStatus) {
            if (registerStatus == AuthStatus.registerSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Regist Success')),
                );
              FirebaseFirestore.instance.collection(register.email).add({
                "key":null//your data which will be added to the collection and collection will be created after this
              });
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Regist Fail')),
                );
            }
          });
        },
        child: Text('Regist'),
      ),
    );
  }
}
