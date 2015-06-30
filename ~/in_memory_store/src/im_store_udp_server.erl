-module(im_store_udp_server).

-behavior(e2_task).

-export([start_link/1]).

-export([init/1, handle_task/1,loop/1]).

		
		init(Port) ->
			
		e2_task:start_link(?MODULE, [Port]).

		start_link(Port) ->
		
		  spawn(fun() -> handle_task(Port) end).

		handle_task(Port) ->			
		  {ok, Socket} = gen_udp:open(Port, [binary, {active,true}]),
		  io:format("server opened socket:~p~n",[Socket]),
		  loop(Socket).
		  
		loop(Socket) ->
			receive
				{udp, Socket, Host, Port, Bin} = Msg ->
					io:format("server received:~p~n",[Msg]),
					N = binary_to_term(Bin),
					{ok, N} = im_store_udp_client_sup:start_handler(N),
					gen_udp:send(Socket, Host, Port, term_to_binary(N)),
					loop(Socket)
		end.


		%%loop(Socket) ->
		  %%inet:setopts(Socket, [{active, once}]),
		  %%receive
			%%{udp, Socket, Host, Port, Bin} ->
			  %%Convert incoming binary message to a string
			  %%Message = binary_to_list(Bin),
			  %%io:format("Server received: "),
			  %%io:format(Message),
			  %%io:format("\n"),
			  %%gen_udp:send(Socket, Host, Port, <<"Thanks for the packet, here is my reply packet!">>),
			  %%loop(Socket)
		  %%end.
