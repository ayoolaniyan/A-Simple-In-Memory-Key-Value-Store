-module(im_store).

-export([start/0, stop/0]).

%%%===================================================================
%%% Public API
%%%===================================================================

	start() ->
		e2_application:start_with_dependencies(im_store).

	stop() ->
		io:format("### stopping im_store~n"),
		application:stop(im_store).
