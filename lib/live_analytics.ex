defmodule LiveAnalytics do
  import Ecto.Query
  use Phoenix.LiveDashboard.PageBuilder
  alias Contex.{Dataset, Plot}

  defp repos do
    app_name()
    |> Application.fetch_env!(:ecto_repos)
  end

  defp app_name do
    Application.fetch_env!(:live_analytics, :app_name)
  end

  @impl true
  def menu_link(_, _) do
    {:ok, "Analytics"}
  end

  @impl true
  def render_page(_assigns) do
    send(self(), :poll)
    # <- note this
    {LiveAnalytics.DatabaseOperations, %{id: :live_analytics, data: 2, plots: []}}
  end

  @impl true
  def handle_info(:poll, state) do
    Process.send_after(
      self(),
      :poll,
      Application.get_env(:live_analytics, :poll_interval_ms, 15000)
    )

    {:ok, modules} = :application.get_key(app_name(), :modules)

    svg_plots =
      modules
      |> Enum.filter(&({:__schema__, 1} in &1.__info__(:functions)))
      |> Enum.filter(fn module -> Enum.member?(module.__schema__(:fields), :inserted_at) end)
      |> Enum.map(fn mod ->
        query =
          from(u in mod,
            group_by: fragment("?::date", u.inserted_at),
            order_by: fragment("?::date", u.inserted_at),
            select: {count(u.inserted_at), fragment("?::date", u.inserted_at)}
          )

        repo = Enum.at(repos(), 0)

        repo.all(query)
        |> case do
          [] ->
            []

          x ->
            x
            |> Enum.map(fn {x, date} -> {Date.to_string(date), x} end)
            |> Dataset.new(["Date", "Created"])
            |> Plot.new(Contex.BarChart, 600, 400,
              mapping: %{category_col: "Date", value_cols: ["Created"]}
            )
            |> Plot.plot_options(%{legend_setting: :legend_right})
            |> Plot.titles("Created", mod.__schema__(:source))
            |> Plot.to_svg()
        end
      end)

    send_update(LiveAnalytics.DatabaseOperations,
      id: :live_analytics,
      data: :rand.uniform(10),
      plots: svg_plots
    )

    {:noreply, state}
  end
end

defmodule LiveAnalytics.DatabaseOperations do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="phx-dashboard-metrics-grid row">
    <%= for plot <- @plots do %>
    <div class="col-xl-6 col-xxl-5 col-xxxl-4 charts-col">
    <%= plot %>
    </div>
    <% end %>
    </div>
    """
  end
end
