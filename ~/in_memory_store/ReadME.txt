Running the Program:
Open cmd terminal from in_memory_store directory
and run ...
make
then...
make shell
then start the program by...
application:start(im_store).

Querying DB:
> im_store_data:del("msg").
ok

> im_store_data:get("msg").
error

> im_store_data:put("msg", "My First Erlang Application!").
ok

> im_store_data:get("msg").
{ok,"My First Erlang Application!"}


OR using im_store_db

> {ok, Db} = mydb_db:open("/tmp/test.db").
{ok,"/tmp/test.db"}

> rr(file).
[file_descriptor,file_info]

> file:read_file_info("/tmp/test.db").
{ok,#file_info{...}}

> mydb_db:put(Db, "msg", "Erlang is fun!").
ok

> mydb_db:get(Db, "msg").
[{"msg","Erlang is fun!"}]

> mydb_db:del(Db, "msg").
ok

> mydb_db:get(Db, "msg").
[]






Querying DB from TCP Interface:
$ telnet 127.0.0.1 1234
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
GET msg
-ERROR
PUT msg Testing TCP Interface
+OK
GET msg
+Testing TCP Interface
DEL msg
+OK
BAD_COMMAND
-ERROR
>> ^]
>> quit
Connection closed.



Testing the HTTP Interface:

Type this on Erlang shell: im_store_http_server_test:start_harness(8000).


Then on Another CMD Terminal:

curl -v 127.0.0.1:8000/hello

*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 8000 (#0)
> GET /hello HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 127.0.0.1:8000
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Type: text/plain; charset=UTF-8
< Connection: close
<
Helo World!

* Closing connection 0



curl -v  -X DELETE "127.0.0.1:8000/foo/abr?x=y&x=u&bar=foo"

*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 8000 (#0)
> DELETE /foo/abr?x=y&x=u&bar=foo HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 127.0.0.1:8000
> Accept: */*
>
< HTTP/1.1 501 Not Implemented
< Content-Type: text/plain; charset=UTF-8
< Connection: close
<
DELETE is not supported by this service.

* Closing connection 0


You can also Test the HTTP Interface manually by:
Type this on Erlang Shell:
GetFunction=fun(Sock, PathString, QueryString, Params, Fragment, Headers, Body)-> 
		      		  gen_tcp:send(Sock, "HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=UTF-8\r\nConnection: close\r\n\r\nHelo World!\r\n\r\n") 
		      end.

Functions=[{'GET', GetFunction}].

im_store_http_server:start_link(8000, Functions).