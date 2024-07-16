mkdir -p /live

cat <<EOF >>/etc/fstab
LABEL=EWE_ISO /live iso9660 defaults 0 0
EOF
