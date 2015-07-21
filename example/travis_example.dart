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
      // skip non-Dart repos
      if (!r.slug.startsWith('dart-lang/')) continue;

      print(r.slug);
      List<Build> builds = await client.builds(ids: [r.lastBuildId]);

      var build = builds.first;

      for (int jobId in build.jobIds) {
        var jobInfo = await client.job(jobId);

        var job = jobInfo.job;

        // skip non-Dart projects
        if (job.config.language != 'dart') continue;

        // we only want dev builds
        if (job.config.raw['dart'] != 'dev') continue;

        // Now get the log for this guy!

        var log = await client.getJobLog(job.id);

        print(log.length);

        var version = _getDartVersion(log);

        print(version);
      }
    }
  }, onError: (error, chain) {
    print(error);
    print(chain.terse);
    exit(1);
  });
}

const _encoder = const JsonEncoder.withIndent('  ');

final RegExp _reg = new RegExp(r'Dart VM version: (\S+)');

String _getDartVersion(String rawLog) {
  var matches = _reg.allMatches(rawLog).toList();

  if (matches.length == 0) return null;

  if (matches.length > 1) {
    throw 'too many matches!';
  }

  return matches.single[1];
}
