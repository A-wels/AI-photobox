#!/bin/bash
# CONFIGS

do_resize=false             # Should the photo be resized before processing?
resize_target=1280          # Target width of the photo

#######
name="$1"
waittime="$2"
email="$3"


path="$(pwd)"

if [ ! -d ./resized ]; then
    mkdir -p ./resized;
fi
if [ ! -d ./foreground ]; then
    mkdir -p ./foreground;
fi
if [ ! -d ./background ]; then
    mkdir -p ./background;
fi
if [ ! -d ./done ]; then
    mkdir -p ./done;
fi
if [ ! -d "./done/$name" ]; then
    mkdir -p "./done/$name";
fi

echo "Positioniere dich fürs Foto!"
sleep "$waittime"
echo "BITTE LÄCHELN!"
gphoto2 --set-config viewfinder=1 --capture-image-and-download --no-keep --filename IMG_%Y-%m-%d_%H-%M-%S.%C
#wget http://192.168.178.62:4747/cam/1/frame.jpg
#gphoto2 --set-config viewfinder=1 --capture-image-and-download --no-keep --filename $path/frame.jpg --force-overwrite
echo "Bitte warten!"
echo "Entferne Hintergrund..."
# check if file should be resized
if [ "$do_resize" = true ] ; then
    echo "Skaliere Bild..."
    magick "$path/frame.jpg" -resize $resize_target "$path/frame.jpg"
fi
base=$(basename $path/frame.jpg)
backgroundremover -i $path/frame.jpg -a -ae 15 -o "$path/foreground/frame.png"
echo "Skaliere Bild..."
for b in ./background/*.*; do
    echo "Kombiniere mit $b ..."
    new_filename="$path/done/$name/$(basename "$b")_$(mktemp -u XXXXXXXX).png"
    sh $path/overlay.sh "$b" "$path/foreground/frame.png" "$new_filename"
    cp "$new_filename" $path/static/Image/current.png
    # Sending email with mutt if an email address is provided
    if [ -n "$email" ]; then
        echo "Sending email to $email..."
        nohup mutt -s "Foto für $name" -a $path/static/Image/current.png -- "$email" < bodyTextFile &
    fi
done
exit
