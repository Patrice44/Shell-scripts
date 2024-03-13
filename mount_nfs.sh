#/bin/bash
echo "###  sudo mount -rw -o vers=4 192.168.1.204:/volume1/homes/patrice /nfs/DS916_home"
echo ""
sudo mount -rw -o vers=4 192.168.1.204:/volume1/homes/patrice /nfs/DS916_home
echo ""
echo "###  mount -rw -o vers=4 192.168.1.204:/volume1/Public /nfs/DS916_public"
echo ""
sudo mount -rw -o vers=4 192.168.1.204:/volume1/Public /nfs/DS916_public
echo ""
echo "###  mount -rw -o vers=4 192.168.1.204:/volume1/music /nfs/DS916_music"
echo ""
sudo mount -rw -o vers=4 192.168.1.204:/volume1/music /nfs/DS916_music
#
echo "###  Liste des point de montage du Synology DS916+"
echo ""
sudo showmount -e 192.168.1.204
#
echo ""
echo "###  sudo mount |grep nfs"
echo ""
sudo mount |grep nfs
