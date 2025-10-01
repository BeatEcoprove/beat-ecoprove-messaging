defmodule Messaging.Flow do
  alias Messaging.Flow.Error

  @rfc_url "https://datatracker.ietf.org/doc/html/rfc2616#section-10"

  defp parse_type(status) when is_integer(status) do
    status_code = Integer.to_string(status)

    first_digit = String.at(status_code, 0)
    last_digit = String.last(status_code)

    index = String.to_integer(last_digit)

    {first_digit, Integer.to_string(index + 1)}
  end

  defp type(section, index), do: "#{@rfc_url}.#{section}.#{index}"

  defp build_error(title, detail, status, errors \\ []) when is_atom(status) do
    status_code = Plug.Conn.Status.code(status)

    {section, index} =
      status_code
      |> parse_type()

    %Error{
      type: type(section, index),
      title: title,
      status: status_code,
      detail: detail,
      errors: errors
    }
  end

  def conflict(title, detail), do: build_error(title, detail, :conflict)
  def not_found(title, detail), do: build_error(title, detail, :not_found)
  def forbidden(title, detail), do: build_error(title, detail, :forbidden)
  def service_unavailable(title, detail), do: build_error(title, detail, :service_unavailable)
  def too_many_requests(title, detail), do: build_error(title, detail, :too_many_requests)
  def not_implemented(title, detail), do: build_error(title, detail, :not_implemented)
  def method_not_allowed(title, detail), do: build_error(title, detail, :method_not_allowed)

  def unauthorized(),
    do:
      build_error("Unauthorized", "You are not authorized to access this resource", :unauthorized)

  def bad_request(errors),
    do:
      build_error(
        "Validation Error",
        "One or more validation errors occurred",
        :bad_request,
        errors
      )

  def internal_server_error(),
    do:
      build_error("Internal Server Error", "An unexpected error occurred", :internal_server_error)
end
