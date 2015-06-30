-module(im_store_udp_client).

-behavior(e2_task).

-export([start_link/0]).

-export([handle_task/1]).

		start_link() ->
			e2_task:start_link(?MODULE).		
		
		handle_task(Request) ->
			{ok, Socket} = gen_udp:open(0, [binary]),
			io:format("client opened socket=~p~n",[Socket]),
			ok = gen_udp:send(Socket, "localhost", 4000, Request),
			Value = receive
					{udp, Socket, _, _, Bin} ->
						io:format("client received:~p~n",[Bin])
					after 2000 ->
									0
				end,
			gen_udp:close(Socket),
			Value.