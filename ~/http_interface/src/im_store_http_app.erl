-module(im_store_http_app).

-behavior(e2_application).

-export([init/0]).

-define(DEFAULT_PORT, 1156).

%%%===================================================================
%%% e2_application callbacks
%%%===================================================================

	init() ->
		{ok, [{im_store_http_server, start_link, [server_port()]}
		%%{ok, [{im_store_http_server_sup, start_link, [supervisor]}				
		]}.
	
	
	server_port() ->
		app_config(server_port, ?DEFAULT_PORT).
		
	app_config(Name, Default) ->
    handle_app_env(application:get_env(Name), Default).

	handle_app_env({ok, Value}, _Default) -> Value;
	handle_app_env(undefined, Default) -> Default.
