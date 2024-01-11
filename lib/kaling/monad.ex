defmodule Kaling.Monad do
  @doc """
  Map for the Either monad. I.e `{:ok, val}` or `{:error, err}`.
  """
  @spec e_map({:error, any()} | {:ok, any()}, function()) :: {:error, any()} | {:ok, any()}
  def e_map({:ok, inp}, f) do
    case f.(inp) do
      {:ok, val} -> {:ok, val}
      {:error, err} -> {:error, err}
      val -> {:ok, val}
    end
  end

  def e_map({:error, _} = err, _f), do: err

  @doc """
  A default for the list monad, since [] basically means the same thing as nil for query results
  """
  @spec arr_default(nil | list()) :: []
  def arr_default(nil), do: []
  def arr_default(list) when is_list(list), do: list
end
