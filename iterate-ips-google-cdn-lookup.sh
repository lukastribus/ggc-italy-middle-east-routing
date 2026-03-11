#!/usr/bin/env sh


retrieve_google_frontend()
{
DIG_IP_RETURN=$(dig +short +subnet="$1" -tA @ns1.google.com. google.com. | tail -n1)
DIG_PTR_RETURN=$(dig +short -x "$DIG_IP_RETURN")
DIG_PTR_RETURN_LINES=$(echo "$DIG_PTR_RETURN" | wc -l)

if [ "$DIG_PTR_RETURN_LINES" -lt "1" ]; then
 echo "$1,$DIG_IP_RETURN,invalid: no PTRs returned"
 return
elif  [ "$DIG_PTR_RETURN_LINES" -gt "1" ]; then
 echo "$1,$DIG_IP_RETURN,invalid: multiple PTRs returned"
 return
else
echo "$1,$DIG_IP_RETURN,$DIG_PTR_RETURN"
fi
}

check_prefix()
{
START=0
END="$2"
i="$START"

while [ "$i" -le "$END" ]
do
  retrieve_google_frontend "$1$i.1"
  i=$((i+1))
  sleep 0.1
done
}




check_prefix "$1" "$2"



