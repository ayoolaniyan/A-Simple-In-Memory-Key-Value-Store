-module(im_store).

-export([start/0, stop/0]).

%%%===================================================================
%%% Public API
%%%===================================================================

start() ->
    e2_application:start_with_dependencies(im_store).

stop() ->
    application:stop(im_store).
