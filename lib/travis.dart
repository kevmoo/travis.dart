library travis;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:path/path.dart' as p;

const _host = 'api.travis-ci.org';

const _encoder = const JsonEncoder.withIndent('  ');

class Commit {
  final int id;
  final String sha, branch, message, author_name, author_email, compare_url;

  Commit(this.id, this.sha, this.branch, this.message, this.author_name,
      this.author_email, this.compare_url);

  factory Commit.fromJson(Map<String, dynamic> json) => new Commit(json['id'],
      json['sha'], json['branch'], json['message'], json['author_name'],
      json['author_email'], json['compare_url']);

  /*
  {
  "id": 18898078,
  "sha": "2ea50e52a3426ffb9d1197e64f49c4898db5d291",
  "branch": "master",
  "message": "Add functions to help with --packages/--package-root command line parameters.\n\nR=pquitslund@google.com, sgjesse@google.com\n\nReview URL: https://codereview.chromium.org//1166443005.",
  "committed_at": "2015-06-10T07:43:56Z",
  "author_name": "Lasse R.H. Nielsen",
  "author_email": "lrn@google.com",
  "committer_name": "Lasse R.H. Nielsen",
  "committer_email": "lrn@google.com",
  "compare_url": "https://github.com/dart-lang/package_config/compare/cce473e326d5...2ea50e52a342",
  "pull_request_number": null
}
   */
}

class Repo {
  final int id;
  final String slug;
  final bool active;

  final int lastBuildId;
  final String lastBuildNumber;

  Repo(this.id, this.slug, this.active, this.lastBuildId, this.lastBuildNumber);

  factory Repo.fromJson(Map json) => new Repo(json['id'], json['slug'],
      (json['active'] == true) ? true : false, json['last_build_id'],
      json['last_build_number']);

  /*
  {
      "id": 1930712,
      "slug": "dart-lang/coverage",
      "description": "Dart coverage data manipulation and formatting",
      "last_build_id": 66076182,
      "last_build_number": "178",
      "last_build_state": "passed",
      "last_build_duration": 89,
      "last_build_language": null,
      "last_build_started_at": "2015-06-09T16:26:26Z",
      "last_build_finished_at": "2015-06-09T16:29:41Z",
      "active": true,
      "github_language": "Dart"
    },
   */
}

List<int> _create(value) {
  if (value == null) return const <int>[];

  return new List<int>.unmodifiable(value);
}

class Job {

}

class Build {
  final int commitId, duration, id, repositoryId;
  final List<int> jobIds;

  Build(this.commitId, this.duration, this.id, this.repositoryId, this.jobIds);

  factory Build.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic> commitJson}) {

    return new Build(json['commit_id'], json['duration'], json['id'],
        json['repository_id'], _create(json['job_ids']));
  }
  /*
   {
      "commit_id": 6534711,
      "config": { },
      "duration": 2648,
      "finished_at": "2014-04-08T19:52:56Z",
      "id": 22555277,
      "job_ids": [22555278, 22555279, 22555280, 22555281],
      "number": "784",
      "pull_request": true,
      "pull_request_number": "1912",
      "pull_request_title": "Example PR",
      "repository_id": 82,
      "started_at": "2014-04-08T19:37:44Z",
      "state": "failed"
    }
   */
}

const _buildArgError =
    'You must provide one and only one of `ids`, `repositoryId`, `slug`.';

Map<int, Map> _mapToIds(List<Map> source) {
  if (source == null) source = const [];

  return source.fold(<int, Map>{}, (map, value) {
    var id = value['id'];
    assert(id != null);
    map[id] = value;
    return map;
  });
}

class Travis {
  final String token;
  final IOClient _client;

  Travis(this.token, {IOClient httpClient})
      : _client = (httpClient == null) ? new IOClient() : httpClient;

  Future<Job> job(int jobId) async {
    var path = ['jobs', jobId.toString()];
    var json = await send('GET', p.url.joinAll(path));

    /*
    {
  "job": {
    "id": 66204145,
    "repository_id": 4793024,
    "repository_slug": "dart-lang/package_config",
    "build_id": 66204144,
    "commit_id": 18906759,
    "log_id": 46157763,
    "number": "80.1",
    "config": {
      "language": "dart",
      "dart": "dev",
      "script": "./tool/travis.sh",
      "sudo": false,
      ".result": "configured",
      "os": "linux"
    },
    "state": "failed",
    "started_at": "2015-06-10T12:04:18Z",
    "finished_at": "2015-06-10T12:04:35Z",
    "queue": "builds.docker",
    "allow_failure": false,
    "tags": null,
    "annotation_ids": []
  },
  "commit": {
    "id": 18906759,
    "sha": "d99d926741298bc250d0788140af78276a7e0a76",
    "branch": "master",
    "message": "Tweak comments added by `write` function on packages_file.dart.\n\nNow adds \"# \" in front, not just \"#\", and doesn't treat the empty\nstring after a final \"\\n\" as an extra line.\n\nR=sgjesse@google.com\n\nReview URL: https://codereview.chromium.org//1167223004.",
    "committed_at": "2015-06-10T12:03:44Z",
    "author_name": "Lasse R.H. Nielsen",
    "author_email": "lrn@google.com",
    "committer_name": "Lasse R.H. Nielsen",
    "committer_email": "lrn@google.com",
    "compare_url": "https://github.com/dart-lang/package_config/compare/2ea50e52a342...d99d92674129"
  },
  "annotations": []
}
     */

    print(_encoder.convert(json));

    throw 'not yet!';
  }

  Future<List<Build>> builds(
      {List<int> ids, int repositoryId, String slug, bool withJobs: false}) async {
    var args = {};
    if (ids != null && ids.isNotEmpty) {
      args['ids'] = ids.join((','));
    }

    if (repositoryId != null) {
      if (args.isNotEmpty) {
        throw new ArgumentError.value(
            repositoryId, 'repositoryId', _buildArgError);
      }
      args['repository_id'] = repositoryId;
    }

    if (slug != null) {
      if (args.isNotEmpty) {
        throw new ArgumentError.value(slug, 'slug', _buildArgError);
      }
    }

    if (args.isEmpty) {
      throw new ArgumentError(_buildArgError);
    }

    var json = await send('GET', 'builds', args: args);

    Map<int, Map> buildsMap = _mapToIds(json['builds']);

    Map<int, Map> commitMap = _mapToIds(json['commits']);

    var builds = <Build>[];

    buildsMap.forEach((int id, Map buildJson) {
      var commitJson = commitMap[buildJson['commit_id']];

      if (withJobs) {
        throw 'not yet!';
      }

      var build = new Build.fromJson(buildJson, commitJson: commitJson);

      builds.add(build);
    });

    return builds;
  }

  Future<List<Repo>> repos({int id, String org, String repository, bool activeOnly: false,
      String member}) async {
    var path = <String>['repos'];

    if (id != null) {
      if (org != null) {
        throw new ArgumentError.value(
            org, 'org', 'Cannot set both `id` and `org`.');
      }
      if (repository != null) {
        throw new ArgumentError.value(
            repository, 'repository', 'Cannot set both `id` and `repository`.');
      }
      path.add(id.toString());
    } else if (org != null) {
      path.add(org);

      if (repository != null) {
        path.add(repository);
      }
    } else if (repository != null) {
      throw new ArgumentError.value(repository, 'repository',
          'Cannot set `repository` unless you also set `org`.');
    }

    var args = {};
    if (activeOnly == true) {
      args['active'] = 'true';
    }

    if (member != null) {
      args['member'] = member;
    }

    var json = await send('GET', p.url.joinAll(path), args: args);

    return (json['repos'] as List).map((j) => new Repo.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> send(String method, String path,
      {Map<String, dynamic> jsonBody, Map<String, String> args}) async {
    var uri = new Uri.https(_host, path, args);

    print(uri);

    var request = new Request(method, uri)
      ..headers['Authorization'] = 'token $token'
      ..headers['Accept'] = "application/vnd.travis-ci.2+json";

    if (jsonBody != null) {
      request.body = JSON.encode(jsonBody);
      request.headers['Content-Type'] = 'application/json';
    }

    var streamedResponse = await _client.send(request);

    var response = await Response.fromStream(streamedResponse);

    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw response.body;
    }

    return JSON.decode(response.body);
  }
}
