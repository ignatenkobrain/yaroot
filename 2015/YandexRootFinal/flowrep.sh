#!/bin/bash
FILE="/var/www/flow/billing.html.new"
echo "<html><head></head><body><table>" > $FILE
flow-cat /var/flow/ft-* | flow-report -s /root/bin/report.conf -S localnet | \
  grep -v '\#' | sort -r -n -k 2 -t ',' | grep "220.123.31." | \
  awk -F',' '{print "<tr>\n  <td>"$1"</td>\n  <td>"$2"</td>\n</tr>"}' >> $FILE
echo "</table></body></html>" >> $FILE
mv /var/www/flow/billing.html.new /var/www/flow/billing.html
