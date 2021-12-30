defmodule Board.MemoBoard.Memo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memos" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(memo, attrs) do
    memo
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
