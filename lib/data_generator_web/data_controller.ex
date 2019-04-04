defmodule DataGeneratorWeb.DataController do
  use DataGeneratorWeb, :controller

  alias SmartCity.Dataset

  def generate(conn, %{"dataset_id" => dataset_id, "count" => count} = params) do
    dataset = Dataset.get!(dataset_id)

    data =
      Stream.repeatedly(fn -> generate_record(dataset) end)
      |> Enum.take(String.to_integer(count))

    generate_response(conn, dataset, data, params)
  end

  defp generate_response(
         conn,
         %SmartCity.Dataset{technical: %{sourceFormat: "json"}},
         data,
         _params
       ) do
    json(conn, data)
  end

  defp generate_response(
         conn,
         %SmartCity.Dataset{technical: %{sourceFormat: "csv", schema: schema}},
         data,
         params
       ) do
    header = Enum.map(schema, fn %{name: name} -> name end)

    csv =
      case Map.get(params, "include_header", "false") == "true" do
        true -> CSV.encode([header] ++ data)
        false -> CSV.encode(data)
      end
      |> Enum.map(fn x -> x end)

    conn
    |> put_resp_content_type(MIME.type("csv"))
    |> text(csv)
  end

  defp generate_record(%Dataset{technical: %{sourceFormat: "json", schema: schema}}) do
    Enum.reduce(schema, %{}, fn %{name: name} = record, acc ->
      value = generate_value(record)
      Map.put(acc, name, value)
    end)
  end

  defp generate_record(%Dataset{technical: %{sourceFormat: "csv", schema: schema}}) do
    Enum.map(schema, &generate_value/1)
  end

  defp generate_value(%{type: "string"}), do: Faker.Name.name()
  defp generate_value(%{type: "integer"}), do: Faker.random_between(0, 100_000)
  defp generate_value(%{type: "int"}), do: Faker.random_between(0, 100_000)
  defp generate_value(%{type: "date"}), do: DateTime.utc_now() |> DateTime.to_iso8601()
  defp generate_value(%{type: "float"}), do: Faker.random_uniform()
  defp generate_value(%{type: "boolean"}), do: true
end
