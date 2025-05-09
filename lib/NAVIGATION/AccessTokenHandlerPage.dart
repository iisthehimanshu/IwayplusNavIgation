import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'API/RefreshTokenAPI.dart';

class AccessTokenHandlerPage extends StatelessWidget {
  final String id;
  final String accessToken;
  final String source;

  const AccessTokenHandlerPage({required this.id, required this.source, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Hive.box('SignInDatabase').put("accessToken", accessToken);
      Hive.box('SignInDatabase').put("refreshToken", accessToken);
      context.go('/web/$id/$source');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
