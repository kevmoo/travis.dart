library travis.example;

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:travis/travis.dart';

main(List<String> args) async {
  await Chain.capture(() async {
    String token;
    if (args.isNotEmpty) {
      token = args.first;
    }
    var client = new Travis(token: token);

    var response = await client.repos(member: 'kevmoo');

    for (Repo r in response) {
      print(r.slug);

      List<Build> builds = await client.builds(ids: [r.lastBuildId]);

      var build = builds.first;

      print([build.id, build.jobIds]);

      for (int jobId in build.jobIds) {
        var job = await client.job(jobId);
      }
    }
  }, onError: (error, chain) {
    print(error);
    print(chain.terse);
    exit(1);
  });
}

const _encoder = const JsonEncoder.withIndent('  ');
