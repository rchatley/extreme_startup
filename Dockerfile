FROM ruby:1.9-onbuild

EXPOSE 3000
CMD /usr/local/bin/ruby web_server.rb

# -onbuild should have taken care of this
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install
COPY . /usr/src/app
