-module(im_store_http_server).

-behavior(e2_task).

-export([start_link/1]).

-export([init/0, handle_task/1, handle_post/1,get_content_length/1]).


	init() ->
		Port = 1156,
		e2_task:start_link(?MODULE, Port).
		
	start_link(Port) ->		
		{ok, ListenSock} = gen_tcp:listen(Port, [list,{active, false}, {packet,http}]),
		loop(ListenSock).
	
	loop(ListenSock) ->
		io:format("server started.~n"),
		{ok, Sock} = gen_tcp:accept(ListenSock),
		spawn(?MODULE, handle_task, [Sock]),
		loop(ListenSock).
	
	handle_task(Sock) ->
		{ok, {http_request, Method, Path, Version}} = gen_tcp:recv(Sock, 0),
			case (Method) of
		'POST' -> handle_post(Sock);
		_ -> send_unsupported_error(Sock)
	end.
	
	get_content_length(Sock) ->
		case gen_tcp:recv(Sock, 0, 60000) of
			{ok, {http_header, _, 'Content-Length', _, Length}} -> list_to_integer(Length);
			{ok, {http_header, _, Header, _, _}} -> get_content_length(Sock)
	end.
	
	get_body(Sock, Length) ->
		case gen_tcp:recv(Sock, 0) of
			{ok, http_eoh} ->inet:setopts(Sock, [{packet, raw}]),{ok,Body}=gen_tcp:recv(Sock, Length),Body;
		_ -> get_body(Sock, Length)
	end.
	
	handle_post(Sock) ->
		Length=get_content_length(Sock),
		PostBody=get_body(Sock, Length),
		io:fwrite(PostBody),
		send_accept(Sock).
			
		
%%%===================================================================
%%% Internal Functions
%%%===================================================================
	
	send_accept(Sock) ->
		gen_tcp:send(Sock, "HTTP/1.1 202 Accepted\r\nConnection: close\r\nContent-Type: text/html; charset=UTF-8\r\nCache-Control: no-cache\r\n\r\n"),
		gen_tcp:close(Sock).

	send_unsupported_error(Sock) ->
		gen_tcp:send(Sock, "HTTP/1.1 405 Method Not Allowed\r\nConnection: close\r\nAllow: POST\r\nContent-Type: text/html; charset=UTF-8\r\nCache-Control: no-cache\r\n\r\n"),
		gen_tcp:close(Sock).