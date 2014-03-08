![](http://i.imgur.com/8AoQU07.png)

# Keep a track of your milestones

This is a ruby script which allows you to view the current status of milestones for all your projects.

## Dependencies

    gem install json
    gem install gitlab
    gem install redis
    gem install formatador

## Working

After setting up your access credentials, run the script to get a pretty html report of your milestone statuses generated in your script directory.

You can automate this via sidekiq/cron.

Set up access credentials in environment var using `ENV['GITLAB_PRIVATE_TOKEN'] = "xxxxxxx"`

## Features

* Persistent data storage using redis.
* Multiple uses support (by just changing the gitlab private token, multiple data reports can be generated).
* JSON/Gitlab object/ Ruby hash formats

## Todo

* Gitlab direct login integration.
* Sidekiq integration.
* Setup mail, to mail report to admins on generate.

## Credits

Mentored under [Nidhi Sarvaiya](https://twitter.com/sarvaiya_nidhi).

## License

Available under the MIT License.
