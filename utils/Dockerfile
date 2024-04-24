FROM scratch AS root
COPY rootfs /

RUN sed -i 's/CheckSpace/#CheckSpace/g' /etc/pacman.conf

CMD ["/usr/bin/bash"]
