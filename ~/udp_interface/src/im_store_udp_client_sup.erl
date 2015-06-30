-module(im_store_udp_client_sup).

-behavior(e2_task_supervisor).

-export([start_link/0]).	%%, start_handler/0]).

start_link() ->
    e2_task_supervisor:start_link(?MODULE, im_store_udp_client, [registered]).

%%start_handler() ->
    %%e2_task_supervisor:start_task(?MODULE, []).