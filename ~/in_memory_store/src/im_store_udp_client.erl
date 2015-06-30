-module(im_store_udp_client).

-behavior(e2_task).

-export([start_link/0]).

-export([handle_task/1, handle_command_line/2]).

		start_link() ->
			%%e2_task:start_link(?MODULE).
			spawn(fun() -> handle_task(handle_command_line) end).

		handle_task(handle_command_line) ->
			{ok, Socket} = gen_udp:open(0, [binary]),
			io:format("client opened socket=~p~n",[Socket]),
				ok = gen_udp:send(Socket, "localhost", 4000, 
					term_to_binary(handle_command_line)),
		Value = receive
			{udp, Socket, _, _, Bin} = Msg ->
		    io:format("client received:~p~n",[Msg]),
				binary_to_term(Bin)
			after 2000 ->
				0
			end,
			gen_udp:close(Socket),
		Value.
		
		%%handle_task(Request) ->
			%%{ok, Socket} = gen_udp:open(0, [binary]),
			%%io:format("client opened socket=~p~n",[Socket]),
			%%ok = gen_udp:send(Socket, "localhost", 4000, Request),
			%%Value = receive
					%%{udp, Socket, _, _, Bin} ->
						%%io:format("client received:~p~n",[Bin])
					%%after 2000 ->
									%%0
				%%end,
			%%gen_udp:close(Socket),
			%%Value.
			
		handle_command_line({ok, Data}, Socket) ->
			handle_command(parse_command(Data), Socket);
		handle_command_line({error, closed}, _Socket) ->
			{stop, normal}.

		parse_command(Data) ->
			handle_command_re_result(
			re:run(Data, "(.*?) (.*)\r\n", [{capture, all_but_first, list}])).

		handle_command_re_result({match, [Command, Arg]}) -> {Command, Arg};
			handle_command_re_result(nomatch) -> error.

		handle_command({"GET", Key}, Socket) ->
			handle_reply(db_get(Key), Socket);
		handle_command({"PUT", KeyVal}, Socket) ->
			handle_reply(db_put(split_keyval(KeyVal)), Socket);
		handle_command({"DEL", Key}, Socket) ->
			handle_reply(db_del(Key), Socket);
		handle_command(_, Socket) ->
			handle_reply(error, Socket).

		split_keyval(KeyVal) ->
			handle_keyval_parts(re:split(KeyVal, " ", [{return, list}, {parts, 2}])).

		handle_keyval_parts([Key]) -> {Key, ""};
		handle_keyval_parts([Key, Val]) -> {Key, Val}.

		db_get(Key) ->
			im_store_data:get(Key).

		db_put({Key, Val}) ->
			im_store_data:put(Key, Val).

		db_del(Key) ->
			im_store_data:del(Key).

		handle_reply(Reply, Socket) ->
			send_reply(Reply, Socket),
			{repeat, Socket}.

		send_reply({ok, Val}, Socket) ->
			gen_tcp:send(Socket, ["+", Val, "\r\n"]);
		send_reply(ok, Socket) ->
			gen_tcp:send(Socket, "+OK\r\n");
		send_reply(error, Socket) ->
			gen_tcp:send(Socket, "-ERROR\r\n").

		%%terminate(_Reason, Socket) ->
			%%gen_tcp:close(Socket).