defimpl Jason.Encoder, for: BSON.ObjectId do
  def encode(object_id, opts) do
    Jason.Encode.string(BSON.ObjectId.encode!(object_id), opts)
  end
end
