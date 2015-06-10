library travis;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:path/path.dart' as p;

const _host = 'api.travis-ci.org';

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

class Build {
  final int commitId, duration, id, repositoryId;
  final List<int> jobIds;

  Build(this.commitId, this.duration, this.id, this.repositoryId, this.jobIds);

  factory Build.fromJson(Map<String, dynamic> json) => new Build(
      json['commit_id'], json['duration'], json['id'], json['repository_id'],
      _create(json['job_ids']));

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

class Travis {
  final String token;
  final IOClient _client;

  Travis(this.token, {IOClient httpClient})
      : _client = (httpClient == null) ? new IOClient() : httpClient;

  Future<Build> build() {}

  Future<List<Repo>> repos({int id, String org, String repository, bool active,
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
    if (active == true) {
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
