defmodule DataGeneratorWeb.DataController do
  use DataGeneratorWeb, :controller

  alias SmartCity.Dataset
  alias DataGenerator.DataRecord

  def generate(conn, %{"dataset_id" => dataset_id, "count" => count} = params) do
    dataset = Dataset.get!(dataset_id)

    data =
      Stream.repeatedly(fn -> DataRecord.generate(dataset.technical.schema) end)
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
    csv_data = Enum.map(data, fn map -> Enum.map(map, fn {key, value} -> value end) end)

    csv =
      case Map.get(params, "include_header", "false") == "true" do
        true -> CSV.encode([header] ++ csv_data)
        false -> CSV.encode(csv_data)
      end
      |> Enum.map(fn x -> x end)

    conn
    |> put_resp_content_type(MIME.type("csv"))
    |> text(csv)
  end
end
