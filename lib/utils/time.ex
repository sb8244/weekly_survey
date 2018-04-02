defmodule Utils.Time do
  def now(), do: NaiveDateTime.utc_now()

  def days_from_now(days) when is_number(days) do
    seconds_from_now(days * 24 * 60 * 60)
  end

  def seconds_from_now(s) when is_number(s) do
    now()
      |> NaiveDateTime.add(s, :seconds)
  end
end
