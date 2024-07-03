# Configure container startup

USER root

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-remote-desktop.sh /usr/local/bin/

RUN chsh -s /bin/bash $NB_USER

# Removal area
# Prevent screen from locking
RUN apt-get remove -y -q light-locker xfce4-screensaver \
    && apt-get autoremove -y

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-remote-desktop.sh"]
