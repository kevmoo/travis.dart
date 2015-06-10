// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library travis.test;

import 'package:test/test.dart';

import 'package:travis/travis.dart';

void main() {
  test("Repo.fromJson", () {
    var json = {
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
    };

    var repo = new Repo.fromJson(json);

    expect(repo.active, json['active']);
    expect(repo.id, json['id']);
    expect(repo.lastBuildId, json['last_build_id']);
    expect(repo.lastBuildNumber, json['last_build_number']);
    expect(repo.slug, json['slug']);
  });

  test('Build.fromJson', () {
    var json = {
      "commit_id": 6534711,
      "config": {},
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
    };

    var build = new Build.fromJson(json);

    expect(build.commitId, json['commit_id']);
    expect(build.duration, json['duration']);
    expect(build.id, json['id']);
    expect(build.jobIds, json['job_ids']);
    expect(build.repositoryId, json['repository_id']);
  });

  test('Commit.fromJson', () {
    var json = {
      "id": 18898078,
      "sha": "2ea50e52a3426ffb9d1197e64f49c4898db5d291",
      "branch": "master",
      "message":
          "Add functions to help with --packages/--package-root command line parameters.\n\nR=pquitslund@google.com, sgjesse@google.com\n\nReview URL: https://codereview.chromium.org//1166443005.",
      "committed_at": "2015-06-10T07:43:56Z",
      "author_name": "Lasse R.H. Nielsen",
      "author_email": "lrn@google.com",
      "committer_name": "Lasse R.H. Nielsen",
      "committer_email": "lrn@google.com",
      "compare_url":
          "https://github.com/dart-lang/package_config/compare/cce473e326d5...2ea50e52a342",
      "pull_request_number": null
    };

    var commit = new Commit.fromJson(json);

    expect(commit.author_email, json['author_email']);
    expect(commit.author_email, json['author_email']);
    expect(commit.author_name, json['author_name']);
    expect(commit.branch, json['branch']);
    expect(commit.compare_url, json['compare_url']);
    expect(commit.id, json['id']);
    expect(commit.message, json['message']);
    expect(commit.sha, json['sha']);
  });
}
