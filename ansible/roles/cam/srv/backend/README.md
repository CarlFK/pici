# streaming/backend

Install and configure nginx to act as a streaming backend server.

## Tasks

Everything is in the `tasks/main.yml` file.

## Available variables

Main variables are:

* `debian_version`:                Codename of the version of Debian used.

* `streaming.backend.data_root`:   nginx data_root.

* `streaming.backend.server_name`: The FQDN of your backend streaming server.

* `streaming.rooms`:               List. The name of the different rooms you are
                                   recording in. This will end up in the URL of
                                   the stream available.

* `streaming.youtube_stream_keys`: Optional, a dictionary of room names to youtube streaming keys.
                                   The stream will be mirrored to YouTube.

Other variables used are:

* `letsencrypt_well_known_dir`: Directory where to store the `/.well-known/` data
                                for the Let's Encrypt challenge.

* `skip_unit_test`:  Used internally by the test suite to disable actions that
                     can't be performed in the gitlab-ci test runner.
