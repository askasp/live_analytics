# LiveAnalytics

A small tool to add an ecto repo analytics tab to live dashboard. It queries
the database at configurable interval and present inserts per day

![Alt text](Supervisor tree)
<img src="img/live_analytics.jpg">

Install with:

```elixir
{:live_analytics, git: "https://github.com/askasp-lang/live_analytics.git"}
```

and in your config.exs put

```elixir
config :live_analytics, :app_name, {{your_app_name}} 
config :live_analytics, :poll_interval_ms, {{your_chosen, default is 15000}}
```

