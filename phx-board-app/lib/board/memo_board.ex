defmodule Board.MemoBoard do
  @moduledoc """
  The MemoBoard context.
  """

  import Ecto.Query, warn: false
  alias Board.Repo

  alias Board.MemoBoard.Memo

  @doc """
  Returns the list of memos.

  ## Examples

      iex> list_memos()
      [%Memo{}, ...]

  """
  def list_memos do
    Repo.all(Memo)
  end

  @doc """
  Gets a single memo.

  Raises `Ecto.NoResultsError` if the Memo does not exist.

  ## Examples

      iex> get_memo!(123)
      %Memo{}

      iex> get_memo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_memo!(id), do: Repo.get!(Memo, id)

  @doc """
  Creates a memo.

  ## Examples

      iex> create_memo(%{field: value})
      {:ok, %Memo{}}

      iex> create_memo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_memo(attrs \\ %{}) do
    %Memo{}
    |> Memo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a memo.

  ## Examples

      iex> update_memo(memo, %{field: new_value})
      {:ok, %Memo{}}

      iex> update_memo(memo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_memo(%Memo{} = memo, attrs) do
    memo
    |> Memo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a memo.

  ## Examples

      iex> delete_memo(memo)
      {:ok, %Memo{}}

      iex> delete_memo(memo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_memo(%Memo{} = memo) do
    Repo.delete(memo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking memo changes.

  ## Examples

      iex> change_memo(memo)
      %Ecto.Changeset{data: %Memo{}}

  """
  def change_memo(%Memo{} = memo, attrs \\ %{}) do
    Memo.changeset(memo, attrs)
  end
end
