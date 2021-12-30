defmodule Board.MemoBoardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Board.MemoBoard` context.
  """

  @doc """
  Generate a memo.
  """
  def memo_fixture(attrs \\ %{}) do
    {:ok, memo} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Board.MemoBoard.create_memo()

    memo
  end
end
