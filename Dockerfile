FROM ruby:1.9-onbuild

EXPOSE 3000
CMD /usr/local/bin/ruby web_server.rb
