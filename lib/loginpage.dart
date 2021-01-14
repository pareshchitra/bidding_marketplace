import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:firebase_auth/firebase_auth.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final _scaffoldKey = GlobalKey<ScaffoldState>();


final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _smsController = TextEditingController();
String _verificationId;
final SmsAutoFill _autoFill = SmsAutoFill();

//Callback for when the user has already previously signed in with this phone number on this device
PhoneVerificationCompleted verificationCompleted =
    (PhoneAuthCredential phoneAuthCredential) async {
  await _auth.signInWithCredential(phoneAuthCredential);
  showSnackbar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
};

//Listens for errors with verification, such as too many attempts
PhoneVerificationFailed verificationFailed =
    (FirebaseAuthException authException) {
  showSnackbar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
};

//Callback for when the code is sent
PhoneCodeSent codeSent =
    (String verificationId, [int forceResendingToken]) async {
  showSnackbar('Please check your phone for the verification code.');
  _verificationId = verificationId;
};

PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
    (String verificationId) {
  showSnackbar("verification code: " + verificationId);
  _verificationId = verificationId;
};


void showSnackbar(String message) {
  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
}

void verifyPhoneNumber() async {
  try {
    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  } catch (e) {
    showSnackbar("Failed to Verify Phone Number: ${e}");
  }
}

void signInWithPhoneNumber() async {
  try {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;

    showSnackbar("Successfully signed in UID: ${user.uid}");
  } catch (e) {
    showSnackbar("Failed to sign in: " + e.toString());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Padding(padding: const EdgeInsets.all(8),
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone number (+xx xxx-xxx-xxxx)'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(child: Text("Get current number"),
                        onPressed: () async => {
                          _phoneNumberController.text = await _autoFill.hint
                        },
                        color: Colors.greenAccent[700]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(
                      color: Colors.greenAccent[400],
                      child: Text("Verify Number"),
                      onPressed: () async {
                        verifyPhoneNumber();
                      },
                    ),
                  ),
                  TextFormField(
                    controller: _smsController,
                    decoration: const InputDecoration(labelText: 'Verification code'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(
                        color: Colors.greenAccent[200],
                        onPressed: () async {
                          signInWithPhoneNumber();
                        },
                        child: Text("Sign in")),
                  ),
                ],
              )
          ),
        )
    );
  }
}