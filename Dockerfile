# This image fetches always the latest version of chrome and firefox and not one specified version.
FROM cypress/base:16.5.0

# avoid too many progress messages
# https://github.com/cypress-io/cypress/issues/1243
ENV CI=1

# disable shared memory X11 affecting Cypress v4 and Chrome
# https://github.com/cypress-io/cypress-docker-images/issues/270
ENV QT_X11_NO_MITSHM=1
ENV _X11_NO_MITSHM=1
ENV _MITSHM=0

# point Cypress at the /root/cache no matter what user account is used
# see https://on.cypress.io/caching
ENV CYPRESS_CACHE_FOLDER=/root/.cache/Cypress

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN apt update && apt upgrade -y

RUN npm install -g cypress -ddd
RUN cypress verify

# Dependencies for chrome
RUN apt-get install -y fonts-liberation libappindicator3-1 xdg-utils

# Fetching and installing the LATEST chrome
RUN wget -O /usr/src/google-chrome-beta_current_amd64.deb "https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-beta_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-beta_current_amd64.deb
RUN google-chrome --version

# Add zip utility - it comes in very handy
RUN apt-get install zip -y

# add codecs needed for video playback in firefox
# https://github.com/cypress-io/cypress-docker-images/issues/150
RUN apt-get install mplayer -y

# Fetching and installing the LATEST firefox
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-beta-latest&os=linux64&lang=en-US" \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && ln -fs /opt/firefox/firefox /usr/bin/firefox

RUN cypress version
RUN echo  " node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "user:            $(whoami) \n" \
  "chrome:          $(google-chrome --version || true) \n" \
  "firefox:         $(firefox --version || true) \n"

ENTRYPOINT ["cypress", "run"]
