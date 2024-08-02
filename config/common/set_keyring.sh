# eweos-keyring
if [ ! -z "`pacman -Qq | grep ^eweos-keyring$`" ]; then
  echo "Found eweos-keyring"
  pacman-key --init
  pacman-key --populate eweos
  #sed -i 's/SigLevel = Never/SigLevel = Required/' /etc/pacman.conf
  echo "y" | pacman -Scc
fi
