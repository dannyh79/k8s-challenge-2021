defmodule BoardWeb.MemoControllerTest do
  use BoardWeb.ConnCase

  import Board.MemoBoardFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  describe "index" do
    test "lists all memos", %{conn: conn} do
      conn = get(conn, Routes.memo_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Memos"
    end
  end

  describe "new memo" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.memo_path(conn, :new))
      assert html_response(conn, 200) =~ "New Memo"
    end
  end

  describe "create memo" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.memo_path(conn, :create), memo: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.memo_path(conn, :show, id)

      conn = get(conn, Routes.memo_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Memo"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.memo_path(conn, :create), memo: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Memo"
    end
  end

  describe "edit memo" do
    setup [:create_memo]

    test "renders form for editing chosen memo", %{conn: conn, memo: memo} do
      conn = get(conn, Routes.memo_path(conn, :edit, memo))
      assert html_response(conn, 200) =~ "Edit Memo"
    end
  end

  describe "update memo" do
    setup [:create_memo]

    test "redirects when data is valid", %{conn: conn, memo: memo} do
      conn = put(conn, Routes.memo_path(conn, :update, memo), memo: @update_attrs)
      assert redirected_to(conn) == Routes.memo_path(conn, :show, memo)

      conn = get(conn, Routes.memo_path(conn, :show, memo))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, memo: memo} do
      conn = put(conn, Routes.memo_path(conn, :update, memo), memo: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Memo"
    end
  end

  describe "delete memo" do
    setup [:create_memo]

    test "deletes chosen memo", %{conn: conn, memo: memo} do
      conn = delete(conn, Routes.memo_path(conn, :delete, memo))
      assert redirected_to(conn) == Routes.memo_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.memo_path(conn, :show, memo))
      end
    end
  end

  defp create_memo(_) do
    memo = memo_fixture()
    %{memo: memo}
  end
end
