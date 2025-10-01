defmodule Messaging do
  @moduledoc """
  Messaging keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def handle(_ = "name") do
    IO.puts("Hello World")
  end

  def handle(_ = "sopa") do
    IO.puts("Hello man! how are your")
  end
end
