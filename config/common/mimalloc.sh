if [ ! -z "`pacman -Qeq | grep ^pam$`" ]; then
  echo "LD_PRELOAD=/usr/lib/libmimalloc.so" >> /etc/environment
fi
