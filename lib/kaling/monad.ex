defmodule Kaling.Monad do
  @moduledoc """
  Map for the Either monad. I.e `{:ok, val}` or `{:error, err}`.
  """
  @spec map_e({:error, any()} | {:ok, any()}, function()) :: {:error, any()} | {:ok, any()}
  def map_e({:ok, inp}, f) do
    case f.(inp) do
      {:ok, val} -> {:ok, val}
      {:error, err} -> {:error, err}
      val -> {:ok, val}
    end
  end

  def map_e({:error, _} = err, _f), do: err
end
