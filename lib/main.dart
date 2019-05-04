import 'package:flutter/material.dart';

import 'package:fb_auth_example/provider.dart';
import 'package:fb_auth_example/auth.dart';
import 'package:fb_auth_example/validators.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Auth auth = Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool loggedIn = snapshot.hasData;
          if (loggedIn == true) {
            return HomePage();
          } else {
            return LoginPage();
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
        actions: <Widget>[
          FlatButton(
            child: Text("Sign Out"),
            onPressed: () async {
              try {
                Auth auth = Provider.of(context).auth;
                await auth.signOut();
              } catch (e) {
                print(e);
              }
            },
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text('Welcome'),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _email, _password;
  FormType _formType = FormType.login;

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
        if (_formType == FormType.login) {
          String userId = await auth.signInWithEmailAndPassword(
            _email,
            _password,
          );

          print('Signed in $userId');
        } else {
          String userId = await auth.createUserWithEmailAndPassword(
            _email,
            _password,
          );

          print('Registered in $userId');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void switchFormState(String state) {
    formKey.currentState.reset();

    if (state == 'register') {
      setState(() {
        _formType = FormType.register;
      });
    } else {
      setState(() {
        _formType = FormType.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Page'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInputs() + buildButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        validator: EmailValidator.validate,
        decoration: InputDecoration(labelText: 'Email'),
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        validator: PasswordValidator.validate,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
    ];
  }

  List<Widget> buildButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text('Login'),
          color: Colors.blueAccent,
          onPressed: submit,
        ),
        FlatButton(
          child: Text('Register Account'),
          color: Colors.teal,
          onPressed: () {
            switchFormState('register');
          },
        ),
        Divider(
          height: 50.0,
        ),
        FlatButton(
          child: Text("Sign in with Google"),
          color: Colors.lightGreen,
          onPressed: () async {
            try {
              final _auth = Provider.of(context).auth;
              final id = await _auth.signInWithGoogle();
              print('signed in with google $id');
            } catch (e) {
              print(e);
            }
          },
        ),
        FlatButton(
          child: Text('Sign in with Facebook'),
          color: Colors.lightBlue,
          onPressed: () async {
            try {
              final _auth = Provider.of(context).auth;
              final id = await _auth.signInWithFacebook();
              print('signed in with facebook $id');
            } catch (e) {
              print(e);
            }
          },
        )
      ];
    } else {
      return [
        RaisedButton(
          child: Text('Create Account'),
          color: Colors.blueAccent,
          onPressed: submit,
        ),
        FlatButton(
          child: Text('Go to Login'),
          color: Colors.teal,
          onPressed: () {
            switchFormState('login');
          },
        )
      ];
    }
  }
}
