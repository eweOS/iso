function enable_service(){
  ln -s ../$1 /usr/lib/dinit.d/boot.d
}

function enable_user_service(){
  ln -s ../$1 /usr/lib/dinit.d/user/boot.d
}
