defmodule ScheduleTest do
  use ExUnit.Case
  doctest Schedule

  setup do
    start_time = ~T[08:00:00]

    input =
    [
      %{name: "a", duration: ~T[01:00:00]},
      %{name: "b", duration: ~T[01:30:00]},
      %{name: "c", duration: ~T[01:45:00]},
      %{name: "d", duration: ~T[02:00:00]}
    ]

    [start_time: start_time, input: input]
  end

  test "Sample test" do
    assert 1 + 1 = 2
  end

end
