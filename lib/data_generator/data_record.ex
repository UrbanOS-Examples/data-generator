defmodule DataGenerator.DataRecord do
  @moduledoc false

  def generate(schema) do
    Enum.reduce(schema, %{}, fn %{name: name} = record, acc ->
      value = generate_value(record)
      Map.put(acc, name, value)
    end)
  end

  defp generate_value(%{type: "map", subSchema: sub_schema}) do
    generate(sub_schema)
  end

  defp generate_value(%{type: "list", itemType: "map", subSchema: sub_schema}) do
    Stream.repeatedly(fn -> generate(sub_schema) end)
    |> Enum.take(:rand.uniform(10))
  end

  defp generate_value(%{type: "list", itemType: item_type}) do
    Stream.repeatedly(fn -> generate_value(%{type: item_type}) end)
    |> Enum.take(:rand.uniform(10))
  end

  defp generate_value(%{type: "string"}), do: Faker.Name.name()
  defp generate_value(%{type: "integer"}), do: Faker.random_between(0, 100_000)
  defp generate_value(%{type: "int"}), do: Faker.random_between(0, 100_000)
  defp generate_value(%{type: "long"}), do: Faker.random_between(0, 100_000)
  defp generate_value(%{type: "date"}), do: DateTime.utc_now() |> Date.to_iso8601()
  defp generate_value(%{type: "timestamp"}), do: DateTime.utc_now() |> DateTime.to_iso8601()
  defp generate_value(%{type: "float"}), do: Faker.random_uniform()
  defp generate_value(%{type: "double"}), do: Faker.random_uniform()
  defp generate_value(%{type: "boolean"}), do: true
end
