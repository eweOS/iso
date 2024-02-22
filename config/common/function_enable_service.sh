function enable_service(){
  ln -s /usr/lib/dinit.d/system/$1 /etc/dinit.d/boot.d
}

function enable_user_service(){
  ln -s /usr/lib/dinit.d/user/$1 /usr/lib/dinit/user/boot.d
}
