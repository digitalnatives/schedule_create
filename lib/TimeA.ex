defmodule TimeA do
  @moduledoc """
  """

  @spec add_to_time(Time.t, Time.t) :: Time.t
  def add_to_time(time1, nil), do: time1
  def add_to_time(nil, time2), do: time2
  def add_to_time(time1, time2) do
   second   = rem (time1.second + time2.second), 60
   e_second = div (time1.second + time2.second), 60
   minute   = rem (time1.minute + time2.minute + e_second), 60
   e_minute = div (time1.minute + time2.minute + e_second), 60
   hour = time1.hour +  time2.hour + e_minute
   {:ok, elapsed_time} = Time.new(hour, minute, second, 0)
   elapsed_time
  end

  @spec get_bounding_time(Time.t, Time.t) :: Time.t
  def get_bounding_time(nil, _), do: nil
  def get_bounding_time(start_time, nil), do: %{start_time: start_time,
                                                end_time: start_time}
  def get_bounding_time(start_time, duration) do
    %{start_time: start_time, end_time: add_to_time(start_time, duration)}
  end

  @spec overlap?(Time.t, Time.t) :: boolean()
  def overlap?(nil, _), do: :false
  def overlap?(_, nil), do: :false
  def overlap?(time1, time2) do
    if time1.end_time >= time2.start_time
       && time1.end_time <= time2.end_time do
      :true
    else
      if time1.start_time >= time2.start_time
         && time1.start_time <= time2.end_time do
        :true
      else
        if time1.start_time < time2.start_time
           && time1.end_time > time2.end_time do
          :true
        else
          :false
        end
      end
    end
  end

  @spec inRange?(Time.t, Time.t) :: boolean()
  def inRange?(nil, _), do: :false
  def inRange?(_, nil), do: :false
  def inRange?(time1, time2) do
    if time1.start_time >= time2.start_time
       && time1.end_time <= time2.end_time do
      :true
    else
      :false
    end
  end

end
