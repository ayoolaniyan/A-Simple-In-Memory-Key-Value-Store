-module(im_store_http_server).

-behavior(e2_task).

-export([start_link/1]).

-export([server_loop/1, init/1, handle_task/1]).
	
	init(Port) ->
		{ok, listen(Port)}.
		%%e2_task:start_link(?MODULE, Port).
		
	start_link(Port) ->
		e2_task:start_link(?MODULE, Port).
		
	listen(Port) ->
		io:format("server started.~n"),
		{ok, ServerSocket} = gen_tcp:listen(Port, [binary, {packet, 0},
			{reuseaddr, true}, {active, true}]),
		server_loop(ServerSocket).

	server_loop(ServerSocket) ->
		{ok, Socket} = gen_tcp:accept(ServerSocket),

		Pid = spawn(fun() -> handle_task(Socket) end),
		inet:setopts(Socket, [{packet, 0}, binary,
			{nodelay, true}, {active, true}]),
		gen_tcp:controlling_process(Socket, Pid),

		server_loop(ServerSocket).

	handle_task(Socket) ->
		receive
			{tcp, Socket, Request} ->
                io:format("received: ~p~n", [Request]),

                gen_tcp:send(Socket, dispatch_client(Socket)),
                gen_tcp:close(Socket),

                io:format("closed...~n")
    end.
	
	wait_for_client(Socket) ->
    {ok, Client} = gen_tcp:accept(Socket),
    Client.
	
	dispatch_client(Client) ->
		%%B = iolist_to_binary(Str),
    %%iolist_to_binary(
      %%io_lib:fwrite(
         %%"HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: %%~p\n\n~s",
         %%[size(B), B])).
			{ok, _} = im_store_http_client_sup:start_handler(Client).
	