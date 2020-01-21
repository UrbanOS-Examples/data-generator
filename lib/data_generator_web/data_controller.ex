defmodule DataGeneratorWeb.DataController do
  use DataGeneratorWeb, :controller

  alias DataGenerator.DataRecord

  def generate(conn, %{"format" => format, "schema" => schema_string, "count" => count} = params) do
    schema = decode_schema(schema_string) # |> IO.inspect(label: "schema")

    data =
      Stream.repeatedly(fn -> DataRecord.generate(schema) end)
      |> Stream.take(String.to_integer(count))

    generate_response(conn, format, schema, data, params)
  end

  defp decode_schema(schema_string) do
    case Jason.decode(schema_string, keys: :atoms) do
      {:ok, schema} -> schema
      error -> raise "Invalid schema: #{inspect(schema_string)} : #{inspect(error)}"
    end
  end

  defp generate_response(
         conn,
         "json",
         _schema,
         data,
         _params
       ) do
    json_data =
      data
      |> Stream.map(fn entry -> Jason.encode!(entry) end)
      |> Stream.intersperse(",")

    conn
    |> put_resp_content_type(MIME.type("json"))
    |> stream_data(Stream.concat([["["], json_data, ["]"]]))
  end

  defp generate_response(
         conn,
         "csv",
         schema,
         data,
         params
       ) do
    header_row = Enum.map(schema, fn %{name: name} -> name end)
    csv_rows = Stream.map(data, &sort_record_to_schema_order(&1, schema))

    csv =
      case Map.get(params, "include_header", "false") == "true" do
        true -> CSV.encode(Stream.concat([header_row], csv_rows))
        false -> CSV.encode(csv_rows)
      end

    conn
    |> put_resp_content_type(MIME.type("csv"))
    |> stream_data(csv)
  end

  defp generate_response(_, format, _, _, _), do: raise "Invalid format: #{format}"

  defp stream_data(conn, stream) do
    conn = send_chunked(conn, 200)

    Enum.reduce_while(stream, conn, fn chunk, conn ->
      case chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, :closed} -> {:halt, conn}
      end
    end)
  end

  defp sort_record_to_schema_order(record, schema) do
    Enum.map(schema, fn %{name: name} -> Map.get(record, name) end)
  end
end
