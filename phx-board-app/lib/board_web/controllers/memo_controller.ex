defmodule BoardWeb.MemoController do
  use BoardWeb, :controller

  alias Board.MemoBoard
  alias Board.MemoBoard.Memo

  def index(conn, _params) do
    memos = MemoBoard.list_memos()
    render(conn, "index.html", memos: memos)
  end

  def new(conn, _params) do
    changeset = MemoBoard.change_memo(%Memo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"memo" => memo_params}) do
    case MemoBoard.create_memo(memo_params) do
      {:ok, memo} ->
        conn
        |> put_flash(:info, "Memo created successfully.")
        |> redirect(to: Routes.memo_path(conn, :show, memo))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    memo = MemoBoard.get_memo!(id)
    render(conn, "show.html", memo: memo)
  end

  def edit(conn, %{"id" => id}) do
    memo = MemoBoard.get_memo!(id)
    changeset = MemoBoard.change_memo(memo)
    render(conn, "edit.html", memo: memo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "memo" => memo_params}) do
    memo = MemoBoard.get_memo!(id)

    case MemoBoard.update_memo(memo, memo_params) do
      {:ok, memo} ->
        conn
        |> put_flash(:info, "Memo updated successfully.")
        |> redirect(to: Routes.memo_path(conn, :show, memo))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", memo: memo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    memo = MemoBoard.get_memo!(id)
    {:ok, _memo} = MemoBoard.delete_memo(memo)

    conn
    |> put_flash(:info, "Memo deleted successfully.")
    |> redirect(to: Routes.memo_path(conn, :index))
  end
end
