defmodule LiveAnalyticsTest do
  use ExUnit.Case
  doctest LiveAnalytics

  test "greets the world" do
    assert LiveAnalytics.hello() == :world
  end
end
