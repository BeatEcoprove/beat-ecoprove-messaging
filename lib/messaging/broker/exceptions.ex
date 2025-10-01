defmodule Messaging.Broker.Exceptions do
  defmodule TopicError do
    defexception [:message, :topics]

    @impl true
    def exception(opts) do
      topics = Keyword.fetch!(opts, :topics)

      msg = """
      Failed to fetch the topic

      Available topics: #{inspect(topics)}
      """

      %__MODULE__{message: msg, topics: topics}
    end
  end

  defmodule EventPublishError do
    defexception [:message, :changeset, :event]

    @impl true
    def exception(opts) do
      changeset = Keyword.fetch!(opts, :changeset)
      event = Keyword.fetch!(opts, :event)

      msg = """
      Failed to publish event due to invalid changeset:

      Changeset errors: #{inspect(changeset.errors)}
      Event: #{inspect(event)}
      """

      %__MODULE__{message: msg, changeset: changeset, event: event}
    end
  end
end
