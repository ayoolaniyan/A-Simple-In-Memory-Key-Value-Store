-module(im_store_http_client).

-behavior(e2_task).

-export([start_link/1, handle_task/1]).

-export([get_url/1, receive_data/2]).

	start_link(Socket) ->
		e2_task:start_link(?MODULE, Socket).
	
	handle_task(Socket) ->
		handle_command_line(read_line(Socket), Socket).
		
	read_line(Socket) ->
		inet:setopts(Socket, [{active, false}, {packet, line}]),
		gen_tcp:recv(Socket, 0).
	
	get_url() ->
        e2_task:get_url("www.erlang.org").

	get_url(Host) ->
        {ok, Socket} = gen_tcp:connect(Host,80,[binary,{packet,0}]),
        ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
        receive_data(Socket, []).

	receive_data(Socket, SoFar) ->
        receive
                {tcp, Socket, Bin} ->
                        receive_data(Socket, [Bin|SoFar]);
                {tcp_closed, Socket} ->
                        list_to_binary(lists:reverse(SoFar))
        end.
		
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


		
		