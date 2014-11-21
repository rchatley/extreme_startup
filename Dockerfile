FROM ruby:1.9-onbuild

EXPOSE 3000
CMD ["ruby" "web_server.rb"]
