defmodule TimeATest do
  use ExUnit.Case
  doctest TimeA

  test "add time with first argument nil" do
    assert TimeA.add_to_time(nil, ~T[08:00:00.000000]) == ~T[08:00:00.000000]
  end

  test "add time with second argument nil" do
    assert TimeA.add_to_time(~T[08:00:00.000000] ,nil) == ~T[08:00:00.000000]
  end

  test "add time with no overload" do
    assert TimeA.add_to_time(~T[08:20:20] , ~T[03:30:30]) == ~T[11:50:50.000000]
  end

  test "add time with just second overload" do
    assert TimeA.add_to_time(~T[08:00:20] , ~T[00:00:50]) == ~T[08:01:10.000000]
  end

  test "add time with just minute overload" do
    assert TimeA.add_to_time(~T[08:20:00] , ~T[00:50:00]) == ~T[09:10:00.000000]
  end

  test "add time with just hour overload" do
    assert_raise_test = "no match of right hand side value: {:error, :invalid_time}"
    assert_raise MatchError, assert_raise_test, fn ->
       TimeA.add_to_time(~T[23:00:00], ~T[02:00:00])
    end
  end

  test "add time with second and minute overload" do
    assert TimeA.add_to_time(~T[08:20:20] , ~T[00:50:50]) == ~T[09:11:10.000000]
  end

  test "add time with second and minute and hour overload" do
    assert_raise_test = "no match of right hand side value: {:error, :invalid_time}"
    assert_raise MatchError, assert_raise_test, fn ->
       TimeA.add_to_time(~T[23:20:20] , ~T[01:50:50])
    end
  end

  test "time1 starts earlier but overlap time2" do
     time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
     time2 = %{start_time: ~T[09:00:00], end_time: ~T[12:00:00]}

     assert TimeA.overlap?(time1, time2) == :true
  end

  test "time1 is completely covered by time2 and hence overlap" do
    time1 = %{start_time: ~T[09:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[12:00:00]}

    assert TimeA.overlap?(time1, time2) == :true
  end

  test "time2 is completely covered by time1 and hence overlap" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[12:00:00]}
    time2 = %{start_time: ~T[09:00:00], end_time: ~T[11:00:00]}

    assert TimeA.overlap?(time1, time2) == :true
  end

  test "time1 starts in middle of time2 and finish later, hence overlap" do
    time1 = %{start_time: ~T[10:00:00], end_time: ~T[12:00:00]}
    time2 = %{start_time: ~T[09:00:00], end_time: ~T[11:00:00]}

    assert TimeA.overlap?(time1, time2) == :true
  end

  test "time1 does not overlap time2" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[11:00:00], end_time: ~T[12:00:00]}

    assert TimeA.overlap?(time1, time2) == :false
  end

  test "time1 is exact equal time2, hence overlap" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}

    assert TimeA.overlap?(time1, time2) == :true
  end

  test "check overlap with time1 equal nil" do
    time1 = nil
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}

    assert TimeA.overlap?(time1, time2) == :false
  end

  test "check overlap with time2 equal nil" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = nil

    assert TimeA.overlap?(time1, time2) == :false
  end

  test "check overlap with time1 and time2 equal nil" do
    time1 = nil
    time2 = nil

    assert TimeA.overlap?(time1, time2) == :false
  end

  test "check if time1 is in range time 2 with time1 and time2 equal nil" do
    time1 = nil
    time2 = nil

    assert TimeA.inRange?(time1, time2) == :false
  end

  test "check if times1 is in range time 2 with time1 equal nil" do
    time1 = nil
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}

    assert TimeA.inRange?(time1, time2) == :false
  end

  test "check if time1 is in range time 2 with time2 equal nil" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = nil

    assert TimeA.inRange?(time1, time2) == :false
  end

#############################
  test "check if time1 is in range time 2 with time1 starts earlier than time1" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[09:00:00], end_time: ~T[12:00:00]}

    assert TimeA.inRange?(time1, time2) == :false
  end

  test "check if time1 is in range time2 with time1 finish after time2" do
    time1 = %{start_time: ~T[09:00:00], end_time: ~T[12:00:00]}
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[11:00:00]}

    assert TimeA.inRange?(time1, time2) == :false
  end

  test "check if time1 is in range time2 with time1 equal to time2" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}

    assert TimeA.inRange?(time1, time2) == :true
  end

  test "check if time1 is in range time2 with time1 covers time2" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[12:00:00]}
    time2 = %{start_time: ~T[09:00:00], end_time: ~T[11:00:00]}

    assert TimeA.inRange?(time1, time2) == :false
  end

  test "check if time1 is in range time2 with time2 covers time1" do
    time1 = %{start_time: ~T[09:00:00], end_time: ~T[11:00:00]}
    time2 = %{start_time: ~T[08:00:00], end_time: ~T[12:00:00]}

    assert TimeA.inRange?(time1, time2) == :true
  end

  test "check if time1 is in range time2 with time1 not matching with time2 at all" do
    time1 = %{start_time: ~T[08:00:00], end_time: ~T[10:00:00]}
    time2 = %{start_time: ~T[09:00:00], end_time: ~T[12:00:00]}

    assert TimeA.inRange?(time1, time2) == :false
  end



end
