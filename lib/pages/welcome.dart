import 'package:flutter/material.dart';
import 'package:bidding_marketplace/domain/user.dart';
import 'package:bidding_marketplace/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Welcome extends StatelessWidget {
  final User user;

  Welcome({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).setUser(user);

    return Scaffold(
      body: Container(
        child: Center(
          child: Text("WELCOME PAGE"),
        ),
      ),
    );
  }
}
