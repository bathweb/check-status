check-status
============

Check the status of a service.

Written in ruby using Sinatra, HAML and HTML Kickstart.

[![Codeship Status for bathweb/check-status](https://www.codeship.io/projects/811a2780-30c9-0131-6215-72ccea08133e/status?branch=master)](https://www.codeship.io/projects/9557)

Usage
-----

Setup:  
```sh
gem install bundler
bundle install
```

It uses the Twitter gem, so go set that up:  
http://rdoc.info/gems/twitter  
https://devcenter.heroku.com/articles/config-vars#setting-up-config-vars-for-a-deployed-application

Go!  
```sh
rackup
```

Run status checks:
[http://localhost:9292/run](http://localhost:9292/run)

Output RSS:  
[http://localhost:9292/output](http://localhost:9292/output)

Dashboard:  
[http://localhost:9292/](http://localhost:9292/)

