defmodule Messaging.Mongo do
  use Mongo.Repo,
    otp_app: :messaging,
    topology: :mongo
end
