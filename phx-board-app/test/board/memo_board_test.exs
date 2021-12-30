defmodule Board.MemoBoardTest do
  use Board.DataCase

  alias Board.MemoBoard

  describe "memos" do
    alias Board.MemoBoard.Memo

    import Board.MemoBoardFixtures

    @invalid_attrs %{title: nil}

    test "list_memos/0 returns all memos" do
      memo = memo_fixture()
      assert MemoBoard.list_memos() == [memo]
    end

    test "get_memo!/1 returns the memo with given id" do
      memo = memo_fixture()
      assert MemoBoard.get_memo!(memo.id) == memo
    end

    test "create_memo/1 with valid data creates a memo" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Memo{} = memo} = MemoBoard.create_memo(valid_attrs)
      assert memo.title == "some title"
    end

    test "create_memo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MemoBoard.create_memo(@invalid_attrs)
    end

    test "update_memo/2 with valid data updates the memo" do
      memo = memo_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Memo{} = memo} = MemoBoard.update_memo(memo, update_attrs)
      assert memo.title == "some updated title"
    end

    test "update_memo/2 with invalid data returns error changeset" do
      memo = memo_fixture()
      assert {:error, %Ecto.Changeset{}} = MemoBoard.update_memo(memo, @invalid_attrs)
      assert memo == MemoBoard.get_memo!(memo.id)
    end

    test "delete_memo/1 deletes the memo" do
      memo = memo_fixture()
      assert {:ok, %Memo{}} = MemoBoard.delete_memo(memo)
      assert_raise Ecto.NoResultsError, fn -> MemoBoard.get_memo!(memo.id) end
    end

    test "change_memo/1 returns a memo changeset" do
      memo = memo_fixture()
      assert %Ecto.Changeset{} = MemoBoard.change_memo(memo)
    end
  end
end
