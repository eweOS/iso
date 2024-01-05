function enable_service(){
  ln -s /usr/lib/dinit.d/system/$1 /etc/dinit.d/boot.d
}
