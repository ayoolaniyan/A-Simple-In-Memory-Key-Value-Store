-module(im_store_http_client).

-behavior(e2_task).

-export([start_link/1]).

-export([handle_task/1]).



		start_link(Host) ->
			e2_task:start_link(?MODULE, Host).
			
		%%handle_task(Host) ->
				%%{ok, Host} = gen_tcp:connect(Host, 1156,[binary, {packet, 4}]),
				 %%ok = gen_tcp:send(Host, response("Hello World")),			
				%%gen_tcp:close(Host).
		
		
		%%response(Str) ->
			%%io:format("client started:~p~n",[Str]),
			%%B = iolist_to_binary(Str),
				%%iolist_to_binary(
				%%io_lib:fwrite("HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",[size(B), B])).
				
		
		
		handle_task(Host) ->
			{ok, Socket} = gen_tcp:connect(Host,80,[binary,{packet,0}]),
			ok = gen_tcp:send(Socket, "Please respond with a sensible name.\r\n"),
			receive_data(Socket, []).

		receive_data(Socket, SoFar) ->
			receive
                {tcp, Socket, Bin} ->
                        receive_data(Socket, [Bin|SoFar]);
                {tcp_closed, Socket} ->
                        list_to_binary(lists:reverse(SoFar))
						
		end.
			
		
						
						
		
		
		
		
		