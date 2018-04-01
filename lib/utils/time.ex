defmodule Utils.Time do
  def days_from_now(days) when is_number(days) do
    now = NaiveDateTime.utc_now()
    %{now | day: now.day + days}
  end
end
