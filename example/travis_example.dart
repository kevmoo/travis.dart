library travis.example;

import 'dart:convert';

import 'package:travis/travis.dart';

main(List<String> args) async {
  var client = new Travis(args.single);

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
}

const _encoder = const JsonEncoder.withIndent('  ');
