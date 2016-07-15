#!/bin/bash

[ -e new ] || mkdir new

cat stadtteile_idx.txt|grep -e '^[^#]'|grep -v LK_|while IFS=, read nr id desc port; do cp ffmuc.conf new/ffmuc_$id.conf; done
cat stadtteile_idx.txt|grep -e '^[^#]'|grep  LK_|while IFS=, read nr id desc port; do cp ffmuc_umland.conf new/ffmuc_$id.conf; done


cat stadtteile_idx.txt|grep -e '^[^#]'|while IFS=, read nr id desc seg_id port; do ( echo "# processing ffmuc_$id.conf"; cat new/ffmuc_$id.conf |sed -e "s/port 100[01][0-9]/port $port/" > new/ffmuc_$id.conf.new; mv new/ffmuc_$id.conf.new new/ffmuc_$id.conf); done

