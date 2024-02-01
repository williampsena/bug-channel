defmodule BugsChannel.Api.Decorators.ParamsValidator do
  @moduledoc """
  This module is in responsible for params validation
  """

  use Decorator.Define, validate_params: 1

  import Plug.Conn
  import BugsChannel.Plugs.Api
  import BugsChannel.Api.Views.Error

  @doc ~S"""
    Validates the request body using the ecto schema.
  """
  def validate_params(module, body, context) do
    quote do
      [%Plug.Conn{} = conn, %{} = params] = unquote(context.args)

      module = unquote(module)

      conn =
        case module.validate(params) do
          %Ecto.Changeset{valid?: false} = changeset ->
            conn |> send_unprocessable_entity_resp(render_ecto_error(changeset)) |> halt()

          _ ->
            conn
        end

      if conn.halted,
        do: conn,
        else: unquote(body)
    end
  end
end
