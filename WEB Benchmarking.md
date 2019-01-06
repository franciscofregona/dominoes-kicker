# Benchmark of the web servers.

In order to fill the NFS VM Disk with files, I run 

```bash
ansible-playbook playbook/StressFillNFSServer.yml -I inventory/techtest/hostsDev.yml
```

This calls the script in resources/scripts/stressFileGenerator.sh, creating 200k files of around 1k in size, along with a list of 1000 files to download and test the speed. Those 1000 filenames are randomly selected from the directory in an effort to try to avoid the O.S. cache. I doubt that I managed to do it (more on that later)

This list is in the form: 

```
wget localhost:8081/f.aaaaahacc -O /dev/null
wget localhost:8081/f.aaaaakvcv -O /dev/null
wget localhost:8081/f.aaaaaknyz -O /dev/null
wget localhost:8081/f.aaaaagwrb -O /dev/null
wget localhost:8081/f.aaaaaeuql -O /dev/null
wget localhost:8081/f.aaaaakdai -O /dev/null
wget localhost:8081/f.aaaaaieuy -O /dev/null
wget localhost:8081/f.aaaaaaozl -O /dev/null
wget localhost:8081/f.aaaaaifrb -O /dev/null
wget localhost:8081/f.aaaaaelio -O /dev/null
(continues, 1000 records)
```

Then, in order to perform repeated tests, I ran:

```bash
ansible-playbook playbook/StressFillNFSServer.yml -I inventory/techtest/hostsDev.yml
wget localhost:8081/randomlist
chmod +x randomlist
time ./randomlist
```

This would show a very long list of downloads as follow:

```
--2019-01-05 19:31:57--  http://localhost:8081/f.aaaaaddde
Resolviendo localhost (localhost)... 127.0.0.1
Conectando con localhost (localhost)[127.0.0.1]:8081... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 1000
Guardando como: “/dev/null”

/dev/null                            100%[=====================================================================>]    1000  --.-KB/s    en 0s      

2019-01-05 19:31:57 (295 MB/s) - “/dev/null” guardado [1000/1000]

--2019-01-05 19:31:57--  http://localhost:8081/f.aaaaacqjm
Resolviendo localhost (localhost)... 127.0.0.1
Conectando con localhost (localhost)[127.0.0.1]:8081... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 1000
Guardando como: “/dev/null”

/dev/null                            100%[=====================================================================>]    1000  --.-KB/s    en 0s      

2019-01-05 19:31:57 (230 MB/s) - “/dev/null” guardado [1000/1000]

(snip)

--2019-01-05 19:31:57--  http://localhost:8081/f.aaaaairyq
Resolviendo localhost (localhost)... 127.0.0.1
Conectando con localhost (localhost)[127.0.0.1]:8081... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 1000
Guardando como: “/dev/null”

/dev/null                            100%[=====================================================================>]    1000  --.-KB/s    en 0s      
2019-01-05 19:31:57 (219 MB/s) - “/dev/null” guardado [1000/1000]


real	0m2,629s
user	0m1,394s
sys	0m0,638s
```

Thats 1000 files download, out of a randomly generated list (stored in /srv/data/export/randomlist). More results followed:

* Run 1
real	0m3,090s
user	0m1,433s
sys	0m0,711s


* Run 2
real	0m2,787s
user	0m1,388s
sys	0m0,727s

* Run 3
real	0m2,746s	
user	0m1,388s	
sys	0m0,738s	

* Run 4
real	0m2,709s
user	0m1,421s
sys	0m0,682s

That is 0.003s per file. I won't bother trying to improve those numbers :relaxed:
The most likely scenario is that I'm hitting the O.S. cache... ON THE NFS SERVERS (through a web server on a container on another VM!). If I can test it I will, given time constraints for this test.

Now, while getting to the homepage on the other hand, I DID find a problem:

```
frank@frank-1804 ~/tmp$ time wget localhost:8081
--2019-01-05 19:32:26--  http://localhost:8081/
Resolviendo localhost (localhost)... 127.0.0.1
Conectando con localhost (localhost)[127.0.0.1]:8081... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: no especificado [text/html]
Guardando como: “index.html”

index.html                               [  <=>                                                                 ]   9,60M  31,9MB/s    en 0,3s    

2019-01-05 19:33:30 (31,9 MB/s) - “index.html” guardado [10066575]


real	1m4,754s
user	0m0,004s
sys	0m0,045s
```

The exit obtained shows a (relatively) very fast download speed, which makes sense, since it happened across the same physical computer.
Yet the download took a whole minute, which probably was spent waiting for Apache to come back... ?

The next back to back runs throwed:

* Run 2
real	**0m9,921s**
user	0m0,016s
sys	0m0,040s

* Run 3
real	**1m9,396s**
user	0m0,000s
sys	0m0,045s

* Run 4
real	**0m50,006s**
user	0m0,000s
sys	0m0,048s

* Run 5
real	**0m38,192s**
user	0m0,019s
sys	0m0,032s

This looks like a prime target of optimization.
To check this idea, I downloaded the index.html site on the NFS server... on the same published folder and got the same lousy result:

```
root@nfsServer1:/srv/data/export# time wget web:8080 -O testindex.html
--2019-01-05 23:24:06--  http://web:8080/
Resolving web (web)... 192.168.1.33
Connecting to web (web)|192.168.1.33|:8080... connected.
HTTP request sent, awaiting response... 200 OK
Length: 10066629 (9.6M) [text/html]
Saving to: ‘testindex.html’

testindex.html  100%[====>]   9.60M  --.-KB/s    in 0.1s    

2019-01-05 23:24:06 (72.3 MB/s) - ‘testindex.html’ saved [10066629/10066629]


real	0m0.222s
user	0m0.004s
sys	0m0.068s

```

And then, from the Main server:

```
time wget localhost:8081/testindex.html
--2019-01-05 20:25:02--  http://localhost:8081/testindex.html
Resolviendo localhost (localhost)... 127.0.0.1
Conectando con localhost (localhost)[127.0.0.1]:8081... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 10066629 (9,6M) [text/html]
Guardando como: “testindex.html.1”

testindex.html.1                     100%[=====================================================================>]   9,60M  59,2MB/s    en 0,2s    

2019-01-05 20:25:02 (59,2 MB/s) - “testindex.html.1” guardado [10066629/10066629]


real	0m0,203s
user	0m0,000s
sys	0m0,034s
```

So: I'm hitting caches already, by doing nothing. :sad: