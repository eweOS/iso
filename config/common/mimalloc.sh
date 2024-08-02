if [ ! -z "`pacman -Qq | grep ^mimalloc$`" ]; then
  echo "LD_PRELOAD=/usr/lib/libmimalloc.so" >> /etc/environment
fi
