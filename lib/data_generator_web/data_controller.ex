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
    header_row = Enum.map(schema, fn %{name: name} -> name end)
    csv_rows = Enum.map(data, &sort_record_to_schema_order(&1, schema))

    csv =
      case Map.get(params, "include_header", "false") == "true" do
        true -> CSV.encode([header_row] ++ csv_rows)
        false -> CSV.encode(csv_rows)
      end
      |> Enum.map(fn x -> x end)

    conn
    |> put_resp_content_type(MIME.type("csv"))
    |> text(csv)
  end

  defp sort_record_to_schema_order(record, schema) do
    Enum.map(schema, fn %{name: name} -> Map.get(record, name) end)
  end
end
