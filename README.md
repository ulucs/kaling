# Kaling

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Architecture

Two main models: Redirects and events. 

Redirects have a standard CRUD interface, with automatically-generated short urls. They are scoped to users, so
a user can only interact with their own redirects.

Events are created when a redirect's short url is accessed and are read-only otherwise. On the user side, they
store the IP Address (this violates GDPR), request headers and cookies. They also keep track of the short url
hash and the redirected url. Events are also scoped to user, users can only reach the events from the
redirects they have created.

Event creation is handled through a GenServer which writes to the database every X events or Y seconds
(whichever is earlier). X and Y are configurable in `config.exs`. The `events` table is optimized for writes
and contains no indexes (other than the pkey for `id`). If we need to optimize for some reads without hurting
the write performance, the easiest way would be setting up a materialized view and putting the indexes there.
Refreshes then can be set up via `pg-cron` or Oban.

## Deployment

Elixir Releases is set up, with a special `entrypoint.sh` because fly.io's default configuration does not
launch on the free tier (it tries to launch a second machine for running the deployments, so `entrypoint.sh`
runs migrations before launching the app). Since docker is configured, it can be deployed almost anywhere.

Github Actions is configured to deploy on pushes to main and run tests when pull requests that target main are
created. This does not fully correspond with the requirements, but I'd rather not have untested code on the
main branch.