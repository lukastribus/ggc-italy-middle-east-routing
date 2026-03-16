# ggc-italy-middle-east-routing

Google makes DNS load-balancing decisions based on the client IP address (or more precisely the /24), mapping a /24 to a specific GGC cluster, based on the specific GGC clusters available for the particolar country. This is done by using EDNS client subnet or, if the EDNS client subnet is missing, the source IP of the DNS request arriving at Google authoritative DNS servers.

## Update 2026/03/16

At approximately Friday, March 13th 2200 UTC the issue was solved.

## Details
**A GGC cluster in the middlea east (UAE) named lcmcta appears to be misconfigured and attracts traffic for customers in Italy, Europe, a different continent and more than 100ms+ latency away.**

Also impacted at least the following Southern European countries:

- Croatia
- Hungary
- Serbia
- Bulgaria
- Albania
- Greece
- Malta
- Romania


## This is what this leads to:

```
$ ping google.com
PING google.com (142.250.202.46) 56(84) bytes of data.
64 bytes from lcmcta-ah-in-f14.1e100.net (142.250.202.46): icmp_seq=1 ttl=112 time=105 ms
64 bytes from lcmcta-ah-in-f14.1e100.net (142.250.202.46): icmp_seq=2 ttl=112 time=105 ms
64 bytes from lcmcta-ah-in-f14.1e100.net (142.250.202.46): icmp_seq=3 ttl=112 time=105 ms
64 bytes from lcmcta-ah-in-f14.1e100.net (142.250.202.46): icmp_seq=4 ttl=112 time=105 ms
^C
--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 105.135/105.211/105.255/0.047 ms
$
$
$ ping mail.google.com
PING mail.google.com (142.250.202.37) 56(84) bytes of data.
64 bytes from lcmcta-ah-in-f5.1e100.net (142.250.202.37): icmp_seq=1 ttl=113 time=109 ms
64 bytes from lcmcta-ah-in-f5.1e100.net (142.250.202.37): icmp_seq=2 ttl=113 time=109 ms
64 bytes from lcmcta-ah-in-f5.1e100.net (142.250.202.37): icmp_seq=3 ttl=113 time=109 ms
64 bytes from lcmcta-ah-in-f5.1e100.net (142.250.202.37): icmp_seq=4 ttl=113 time=109 ms
64 bytes from lcmcta-ah-in-f5.1e100.net (142.250.202.37): icmp_seq=5 ttl=113 time=109 ms
^C
--- mail.google.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4007ms
rtt min/avg/max/mdev = 108.598/108.636/108.697/0.042 ms
$
$ mtr -rc10 mail.google.com
Start: 2026-03-12T12:16:24+0100
HOST: Test-Node01                 Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- 10.0.0.254                 0.0%    10    0.2   0.3   0.2   0.4   0.1
  2.|-- static-81.161.232.255-bus  0.0%    10    0.8   0.7   0.5   0.8   0.1
  3.|-- static-162.33.215.241-bus  0.0%    10    0.6   1.0   0.6   3.7   1.0
  4.|-- 37-186-150-225.ip.bkom.it  0.0%    10    2.0   1.8   1.5   2.4   0.3
  5.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
  6.|-- 142.250.161.208            0.0%    10    5.4   5.7   5.3   8.0   0.8
  7.|-- 172.253.72.111             0.0%    10    5.6   5.8   5.4   7.4   0.6
  8.|-- 108.170.255.210           40.0%    10    5.8   6.1   5.4   8.5   1.2
  9.|-- 192.178.111.49             0.0%    10    7.6   6.7   5.8   8.2   0.8
        142.251.243.251
 10.|-- 142.251.231.87             0.0%    10   12.8  13.6  12.3  17.6   1.6
        172.253.71.229
 11.|-- 192.178.120.252            0.0%    10   41.5  43.7  41.4  55.1   4.5
        192.178.120.248
 12.|-- 192.178.86.48              0.0%    10   47.1  47.5  46.8  48.5   0.6
        192.178.105.96
 13.|-- 108.170.249.117            0.0%    10  106.9 107.2 106.9 108.4   0.5
 14.|-- 192.178.105.71             0.0%    10  105.6 105.6 105.2 106.2   0.2
 15.|-- 192.178.87.251             0.0%    10  105.3 105.6 105.3 106.4   0.3
 16.|-- lcmcta-ah-in-f5.1e100.net  0.0%    10  106.4 106.3 106.1 106.6   0.1
$

```

## Test
Thanks to EDNS client subnet, we can take a look at those load balancing decisions even for other networks:

```
$ dig +short +subnet=2.112.4.0/24 -tA @ns1.google.com. google.com.
142.250.186.238
$ dig +short -x 142.250.186.238
lcmcta-af-in-f14.1e100.net.
$
```

## Impact

Indeed all Italian networks are affected, here is an excerpt:

### Telecom Italia (AS3269)
- 23 out of 256 /24 in 2.112.0.0/16 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- see AS3269-TIM-2.112.0.0-16.txt

### Fastweb (AS12874)
- 12 out of 256 /24 in 2.224.0.0/16 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- AS12874-FASTWEB-2.224.0.0-16.txt

### Vodafone Italy (AS30722)
- 17 out of 256 /24 in 2.41.0.0/16 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- AS30722-VODAFONE-2.41.0.0-16.txt

### WINDTRE (AS1267)
- 1 out of 256 /24 in 151.21.0.0/16 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- AS1267-WINDTRE-151.21.0.0-16.txt

### Tiscali (AS8612)
- 1 out of 256 /24 in 213.205.0.0/16 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- AS8612-TISCALI-213.205.0.0-16.txt

### Eolo SpA (AS35612)
- 1 out of 128 /24 in 77.32.0.0/17 are mapped to a middle eastern Google Global Cache cluster "lcmcta", 100ms+ latency far away
- AS35612-EOLO-77.32.0.0-17.txt

Please note that IP addresses with multiple PTRs have been ignored, those possible are on this GGC cluster as well, so the real number is probably higher.



## Full output

Showing client IP, google.com IP mapping,PTR record:

```
$ grep lcmcta  *.txt
AS1267-WINDTRE-151.21.0.0-16.txt:151.21.225.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.131.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.135.1,142.251.38.46,lcmcta-ag-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.143.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.146.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.152.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.160.1,142.251.38.14,lcmcta-ac-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.161.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.162.1,142.251.38.46,lcmcta-ag-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.163.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.177.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.182.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS12874-FASTWEB-2.224.0.0-16.txt:2.224.247.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.133.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.140.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.141.1,142.251.38.14,lcmcta-ac-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.143.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.144.1,142.251.38.14,lcmcta-ac-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.145.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.147.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.149.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.160.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.163.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.164.1,142.250.187.14,lcmcta-ai-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.175.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.182.1,142.251.38.46,lcmcta-ag-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.183.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.184.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.187.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS30722-VODAFONE-2.41.0.0-16.txt:2.41.193.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.4.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.8.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.10.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.15.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.64.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.66.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.76.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.86.1,142.251.38.14,lcmcta-ac-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.88.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.94.1,142.250.186.14,lcmcta-ak-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.102.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.128.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.131.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.132.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.136.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.138.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.161.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.183.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.192.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.228.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.230.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.248.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS3269-TIM-2.112.0.0-16.txt:2.112.252.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.67.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.70.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.76.1,142.250.187.14,lcmcta-ai-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.78.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.79.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.92.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.94.1,142.250.187.14,lcmcta-ai-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.130.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.131.1,142.250.202.206,lcmcta-aj-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.177.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.178.1,142.250.202.238,lcmcta-ad-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.181.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.211.1,142.250.186.238,lcmcta-af-in-f14.1e100.net.
AS3269-TIM-2.113.0.0-16.txt:2.113.212.1,142.250.202.46,lcmcta-ah-in-f14.1e100.net.
AS35612-EOLO-77.32.0.0-17.txt:77.32.68.1,142.251.38.14,lcmcta-ac-in-f14.1e100.net.
AS8612-TISCALI-213.205.0.0-16.txt:213.205.26.1,142.250.202.174,lcmcta-ae-in-f14.1e100.net.
$
```

Files generated per:

```
$ ./iterate-ips-google-cdn-lookup.sh 2.112. 255 >AS3269-TIM-2.112.0.0-16.txt
$ ./iterate-ips-google-cdn-lookup.sh 2.224. 255 >AS12874-FASTWEB-2.224.0.0-16.txt
$ ./iterate-ips-google-cdn-lookup.sh 2.41. 255 >AS30722-VODAFONE-2.41.0.0-16.txt
$ ./iterate-ips-google-cdn-lookup.sh 151.21. 255 >ASAS1267-WINDTRE-151.21.0.0-16.txt
$ ./iterate-ips-google-cdn-lookup.sh 213.205. 255 >AS8612-TISCALI-213.205.0.0-16.txt
$ ./iterate-ips-google-cdn-lookup.sh 77.32. 128 >AS35612-EOLO-77.32.0.0-17.txt
```


## Google NOC Ticket

Google NOC Ticket 2588682096 as well as 2176711238 is currently under review.

