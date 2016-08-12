#!/bin/sh

[ -e new ] || mkdir new

cat makefile_prefix > new/Makefile-site-select

cat stadtteile_idx.txt|grep -e '^[^#]'|grep -v LK_|while IFS=, read nr id desc port prefix4; do cp ../extra/ffmuc.conf new/$id.conf; done
cat stadtteile_idx.txt|grep -e '^[^#]'|grep LK_|while IFS=, read nr id desc port prefix4; do cp ../extra/ffmuc_umland.conf new/$id.conf; done

cat stadtteile_idx.txt | grep -e '^[^#]' \
    | while IFS=, read nr id desc seg_id port prefix4 prefix6 next_node4 next_node6; do (
      echo "# processing $id.conf";
      cat new/$id.conf | sed -e "s/port 100[01][0-9]/port $port/" \
                             | sed -e "s/.*site_code.*/  site_code = '$id',/g" \
                             | sed -e "s/.*site_name.*/  site_name = 'Freifunk München - $desc',/g" \
                             | sed -e "s/.*ip4.*/  ip4 = '$next_node4',/g" \
                             | sed -e "s@.*prefix4.*@  prefix4 = '$prefix4',@g" \
                             | sed -e "s@.*prefix6.*@  prefix6 = '$prefix6',@g" \
                             | sed -e "s/.ip6.*/  ip6 = '$next_node6',/g" > new/$id.conf.new;
      mv new/$id.conf.new new/$id.conf;
      echo "	lua -e 'print(require(\"cjson\").encode(assert(loadfile(\"site_config.lua\")(\"\$(GLUON_SITEDIR)/extra/$id.conf\"))))' > \$(1)/lib/gluon/site-select/$id.json" >> new/Makefile-site-select
      ); \
    done

cat makefile_suffix >> new/Makefile-site-select
