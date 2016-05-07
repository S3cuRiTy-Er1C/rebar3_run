-module(rebar3_run).

-export([init/1,
         do/1,
         format_error/1]).

-export([console/1]).

-on_load(init/0).

-define(PROVIDER, run).
-define(DEPS, [release]).

%% ===================================================================
%% Public API
%% ===================================================================

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
                                {name, ?PROVIDER},
                                {module, ?MODULE},
                                {bare, false},
                                {deps, ?DEPS},
                                {example, "rebar3 run"},
                                {short_desc, "Run release console."},
                                {desc, ""},
                                {opts, []}
                                ]),
    State1 = rebar_state:add_provider(State, Provider),
    {ok, State1}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    ReleaseDir = filename:join(rebar_dir:base_dir(State), "rel"),
    Config = rebar_state:get(State, relx, []),
    case lists:keyfind(release, 1, Config) of
        {release, {Name, _Vsn}, _} ->
            StartScript = filename:join([ReleaseDir, Name, "bin", Name]),
            console(list_to_binary(StartScript)),
            {ok, State};
        false ->
            {error, {?MODULE, no_release}}
    end.

format_error(no_release) ->
    "No release to run was found.".

init() ->
    PrivDir = code:priv_dir(rebar3_run),
    ok = erlang:load_nif(filename:join(PrivDir, "librebar3_run"), 0).

console(_) ->
    exit(nif_library_not_loaded).
