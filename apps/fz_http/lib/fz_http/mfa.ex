defmodule FzHttp.MFA do
  @moduledoc """
  The Multi Factor Authentication context.
  """

  import Ecto.Query, warn: false

  alias FzHttp.{MFA.Method, Repo, Users.User}

  def list_methods(%User{id: id}) do
    Repo.all(from Method, where: [user_id: ^id])
  end

  def get_method!(credential_id: id) do
    Repo.get_by!(Method, credential_id: id)
  end

  def get_method!(id) do
    Repo.get!(Method, id)
  end

  def get_method(credential_id: id) do
    Repo.get_by(Method, credential_id: id)
  end

  def get_method(id) do
    Repo.get(Method, id)
  end

  def create_method(attrs, user_id) do
    %Method{user_id: user_id}
    |> Method.changeset(attrs)
    |> Repo.insert()
  end

  def update_method(%Method{} = method, attrs) do
    method
    |> Method.changeset(attrs)
    |> Repo.update()
  end
end
