#!/bin/bash

spinpause=0.10
function spinout()
{
    local spinchar="$1"
    local sz
    local ll
    echo -n -e "\r$spinchar"
    sleep $spinpause
}


USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36"
COOKIE="$(pwd)/$1"
COURSE="$2"

if [ -d $COURSE ] ; then
  echo "Direcory $COURSE already exists"
  exit 1
fi
FORMAT="mov"
mkdir $COURSE
FULLPWD="$(pwd)/$COURSE"
cd $COURSE
wget --user-agent="${USER_AGENT}" -q -x --load-cookies ${COOKIE} "https://tutsplus.com/course/${COURSE}/" -O temp
number=$(( $(grep -n 'course-lessons' temp | grep -o "^[0-9]*" | head -n 1) + 1 ))
LINES="$(sed -e "${number}q;d" -e 's/\/table\>.*$/\/table\>/g' temp | tidy -q -w 400 2> /dev/null | grep -v "/table\|/body\|/html\|section-time\|section-row\|^</tr\|^<td>\|section-header\|section-footer" | grep "^<td" | sed -e 's/^<td.*<a\ //g' -e 's/\ /_/g' -e 's/[?!@#$]//g' -e 's/&acirc\;&euro\;&rdquo\;/-/g' -e 's/&amp\;/and/g')"
rm temp
SCOUNT="1"
COUNT="1"
for line in $LINES ; do
  if echo $line | grep -q "^name" ; then
    SecNumber=$(printf "%02g" $SCOUNT)
    SectionTitle="${SecNumber}-$(echo $line | sed -e 's/^.*<strong>//g' -e 's/<\/strong>.*$//g')"
    cd $FULLPWD
    mkdir $SectionTitle
    cd $SectionTitle
    echo "Section: $SectionTitle"
    SCOUNT="$(( $SCOUNT + 1))"
    continue
  fi
  VidNumber=$(printf "%02g" $COUNT)
  LessonUrl="$(echo $line | cut -d \" -f 2)"
  VideoName="${VidNumber}-$(echo $line | sed -e 's/^.*">//g' -e 's/<\/a.*$//g' )"
  VideoName="$(echo $VideoName | sed -e 's/[\/\\]/-slash-/g' -e "s/'//"  )"
  echo -en "\tDownoading: $VideoName"
  VIDEO_URL="$(wget --user-agent="${USER_AGENT}" -q -x --load-cookies ${COOKIE} ${LessonUrl} -O - | grep -o "\"https:\/\/tutsplus.com\/?secure_download=[-_a-zA-Z0-9]*\"" | head -n 1 | tr -d \")"
  touch .spin
  nohup $(wget -q --user-agent="${USER_AGENT}" --progress=bar:force --no-host-directories -x --load-cookies ${COOKIE} --content-disposition ${VIDEO_URL} -O ${VideoName}.${FORMAT} && rm .spin) >nohup.out 2>&1 &
  while [[ -f .spin ]]
  do
      spinout "/"
      spinout "-"
      spinout "\\"
      spinout "|"
      spinout "/"
      spinout "-"
      spinout "\\"
      spinout "|"
  done
      spinout " "
  echo 
  rm nohup.out
  if [ "${COUNT}" -eq "1" ] ; then
        OLDFORMAT="${FORMAT}"
  	FORMAT="$(exiftool -FileType ${VideoName}.${OLDFORMAT} | cut -d : -f 2 | tr -d ' ' | tr [[:upper:]] [[:lower:]])"
        mv ${VideoName}.${OLDFORMAT} ${VideoName}.${FORMAT}
  fi
  COUNT="$(($COUNT + 1))"
  #sleep 15
done
cd ../..
