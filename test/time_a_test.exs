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
end
