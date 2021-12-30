defmodule Board.Repo.Migrations.CreateMemos do
  use Ecto.Migration

  def change do
    create table(:memos) do
      add :title, :string

      timestamps()
    end
  end
end
