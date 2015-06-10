library travis.example;

import 'dart:convert';

import 'package:travis/travis.dart';

main(List<String> args) async {
  var client = new Travis(args.single);

  var response = await client.repos(member: 'kevmoo');

  for (Repo r in response) {
    print([r.slug, r.lastBuildId, r.lastBuildNumber]);
  }
}

const _encoder = const JsonEncoder.withIndent('  ');
