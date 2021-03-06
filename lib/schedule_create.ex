defmodule Schedule do
  @moduledoc """
  """
  require TimeA

  # an option for general unavailability should be added. like a class named *
  @config_params [
    unavailable_classes:
    [
      %{name: "a", time: %{start_time: ~T[12:00:00], end_time: ~T[17:00:00]}}
    ],
    unavailable_times:
    [%{name: "lunch_time",
       time: %{start_time: ~T[12:00:00],end_time: ~T[13:30:00]}}
    ],
    class_strict_availability:
    [%{name: "b", time: %{start_time: ~T[09:00:00], end_time: ~T[12:00:00]}}]
  ]

  @input [
    %{name: "a", duration: ~T[01:00:00]},
    %{name: "b", duration: ~T[01:30:00]},
    %{name: "c", duration: ~T[01:45:00]},
    %{name: "d", duration: ~T[02:00:00]}
  ]

  def run, do: run(~T[08:00:00], @input)

  @spec run(Time.t, [%{name: String.t, duration: Time.t}]) :: List.t
   def run(start_time, class_data) do
     Enum.map(class_data, fn(class) ->
       start_time
       |> add_to_list(class, class_data, [])
       |> redundant_tree([])
       |> flatten_tree([])
       |> remove_nil_options
       |> print_schedule
     end)
   end

   @spec flatten_tree(List.t, List.t) :: List.t
   def flatten_tree(redundant_data, output) do
     if is_list(redundant_data) && !is_map(List.first(redundant_data)) do
       Enum.reduce(redundant_data, [], fn(item, data) ->
         flatten_tree(item, output) ++ data
       end)
     else
        [%{options: List.flatten(Enum.reverse(redundant_data))} | output]
     end
   end

   @spec redundant_tree(List.t, List.t) :: List.t
   def redundant_tree([], parent), do: parent
   def redundant_tree("", parent), do: parent
    def redundant_tree([head | tail], parent) do
       if is_list(head) do
         redundant_tree(head, List.flatten(parent))
       else
         Enum.map(tail, fn(x) -> redundant_tree(x, [head | parent]) end)
       end
   end

   @spec remove_nil_options(List.t) :: List.t
   def remove_nil_options(flattened_list) do
     Enum.reject(flattened_list, fn(item) ->
                                  Enum.any?(item.options,fn(x) -> is_nil(x) end)
                                 end)
   end

   @spec print_schedule(List.t) :: List.t
   def print_schedule(flattened_tree) do
     Enum.map(flattened_tree, fn(x) ->
       Enum.map(x.options, fn(option) ->
         IO.puts "#{option.name} : #{option.start_time} - #{option.end_time}"
       end)
       IO.puts "*****************************************************"
     end)
   end

   @spec add_to_list(Time.t, %{name: String.t, duration: Time.t},
                    [%{name: String.t, duration: Time.t}], List.t) :: List.t
   def add_to_list(current_time, class, remaining_classes, data) do
     unique_list = List.delete(remaining_classes, class)
     bounding_time =
       current_time
       |> TimeA.get_bounding_time(class.duration)
       |> get_next_available_time(class, @config_params)

     calculated_class = %{name: class.name,
                          duration: class.duration,
                          start_time: bounding_time.start_time,
                          end_time: bounding_time.end_time}
     output = meet_conditions(calculated_class, bounding_time, @config_params)

     if Enum.empty?(unique_list) do
       [output | [data]]
     else
       [
         output |
         Enum.map(unique_list, fn(u_class) ->
                                 add_to_list(bounding_time.end_time,
                                             u_class, unique_list, data)
                               end)
       ]
     end
   end

   @spec meet_conditions(
          %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
          %{start_time: Time.t, end_time: Time.t},
          [unavailable_classes:
            %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
           unavailable_times:
            %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
           class_strict_availability:
            %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: List.t
   def meet_conditions(class, class_time, config_params) do
     if class_available?(class, class_time, config_params)
        && class_strict?(class, class_time, config_params) do
       class
     else
       [nil]
     end
   end

   # just finds the first occurance
   @spec class_strict?(
           %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
           %{start_time: Time.t, end_time: Time.t},
           [unavailable_classes:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            unavailable_times:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            class_strict_availability:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: boolean()
   def class_strict?(class, class_time, config_params) do
     matched_class =
       config_params[:class_strict_availability]
         |> Enum.find(fn(item) -> item.name == class.name end)
     if is_nil(matched_class) do
       :true
     else
       TimeA.inRange?(class_time, matched_class.time)
     end
   end

   # just finds the first occurance
   @spec class_available?(
           %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
           %{start_time: Time.t, end_time: Time.t},
           [unavailable_classes:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            unavailable_times:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            class_strict_availability:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: boolean()
   def class_available?(class, class_time, config_params) do
     matched_class =
       config_params[:unavailable_classes]
         |> Enum.find(fn(item) -> item.name == class.name end)
     if is_nil(matched_class) do
       :true
     else
       !TimeA.overlap?(class_time, matched_class.time)
     end
   end

   #assumes the config param is sorted
   @spec need_shift_time?(
           %{start_time: Time.t, end_time: Time.t},
           [unavailable_classes:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            unavailable_times:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            class_strict_availability:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: boolean()
   def need_shift_time?(current_time, config_params) do
     config_params[:unavailable_times]
       |> Enum.map(fn(item) ->
                   {TimeA.overlap?(current_time, item.time), item.time} end)
       |> Enum.find(fn(item) -> match?({:true, _}, item)  end)
   end

   @spec get_next_available_time(
           %{start_time: Time.t, end_time: Time.t},
           %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
           [unavailable_classes:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            unavailable_times:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            class_strict_availability:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: Time.t
   def get_next_available_time(current_time, class, config_params) do
     case need_shift_time?(current_time, config_params) do
       {:true,  config_time} -> TimeA.get_bounding_time(config_time.end_time,
                                                        class.duration)
       _                     -> current_time
     end
   end

   @spec sort_config_params(
           [unavailable_classes:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            unavailable_times:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}},
            class_strict_availability:
             %{name: String.t, time: %{start_time: Time.t, end_time: Time.t}}]
         ) :: List.t
   def sort_config_params(config_params) do
    config_params
   end

end
