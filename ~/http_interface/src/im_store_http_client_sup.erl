-module(im_store_http_client_sup).

-behavior(e2_task_supervisor).

-export([start_link/0, start_handler/1]).

start_link() ->
    e2_task_supervisor:start_link(?MODULE, im_store_http_client, [registered]).

start_handler(Socket) ->
    e2_task_supervisor:start_task(?MODULE, [Socket]).