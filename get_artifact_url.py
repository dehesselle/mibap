#!/usr/bin/env python3

import gitlab
import argparse
import os
import urllib.request as req
from urllib.parse import urlparse


try:
    import keyring
except ImportError:
    keyring = None


def main() -> None:
    parser = argparse.ArgumentParser(description="get artifact download URL for a specific commit")
    parser.add_argument("repository", metavar="repository", type=str,
                        help="repository URL, e.g. https://gitlab.com/foo/bar")
    parser.add_argument("sha", metavar="sha", type=str, help="commit sha")
    parser.add_argument("job", metavar="job", type=str, help="job name", nargs="?")
    args = parser.parse_args()

    repository_url = urlparse(args.repository)

    # Try to retrieve token from keyring first, then fallback to environment variable.
    access_token = None
    if keyring is not None:
        access_token = keyring.get_password("gitlab_token", "read_api")
    if access_token is None:
        access_token = os.getenv("GITLAB_ACCESS_TOKEN")

    gl = gitlab.Gitlab(repository_url.scheme + "://" + repository_url.netloc, private_token=access_token)

    # Instead of the numeric project id you can use account/project (as in https://gitlab.com/ACCOUNT/PROJECT)
    # but you have to URL-encode it.
    project = gl.projects.get(req.pathname2url(repository_url.path[1:]))
    commit = project.commits.get(args.sha)
    pipeline = project.pipelines.get(commit.last_pipeline["id"])

    # Return the first (=newest) successful job.
    # (That's what the 'break' statements do.)
    for job in pipeline.jobs.list():
        if job.status == "success":
            if args.job is not None:    # because args.job is an optional argument
                if job.name == args.job:
                    print(job.web_url)
                    break
            else:
                print(job.web_url)
                break


if __name__ == "__main__":
    main()
