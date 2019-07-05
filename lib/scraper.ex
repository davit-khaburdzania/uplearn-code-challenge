defmodule Scraper do
  def fetch(url) do
    with {:ok, body} <- fetch_page(url),
         {:ok, parsed_html} <- parse_html(body),
         {:ok, assets} <- get_assets(url, parsed_html),
         {:ok, links} <- get_links(url, parsed_html) do
      {:ok, %{assets: assets, links: links}}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "faild with unknown reason"}
    end
  end

  def fetch_page(url) do
    %{status_code: status_code, body: body} = HTTPoison.get!(url)

    if status_code >= 200 and status_code <= 300 do
      {:ok, body}
    else
      {:error, body}
    end
  end

  defp parse_html(html), do: {:ok, Floki.parse(html)}

  defp get_assets(url, html) do
    assets =
      html
      |> Floki.find("img")
      |> Enum.map(&get_attr(&1, "src"))
      |> Enum.reject(&unwanted_link?/1)
      |> Enum.map(&append_base(&1, url))

    {:ok, assets}
  end

  defp get_links(url, html) do
    links =
      html
      |> Floki.find("a")
      |> Enum.map(&get_attr(&1, "href"))
      |> Enum.reject(&unwanted_link?/1)
      |> Enum.map(&append_base(&1, url))

    {:ok, links}
  end

  defp get_attr(node, attr), do: Floki.attribute(node, attr) |> List.first()
  defp unwanted_link?(str), do: is_nil(str) or String.starts_with?(str, "#")

  defp get_base(url) do
    parsed = URI.parse(url)
    URI.to_string(%URI{scheme: parsed.scheme, host: parsed.host})
  end

  defp append_base(url, request_url) do
    if String.starts_with?(url, ["http", "www"]) do
      url
    else
      get_base(request_url) |> URI.merge(url) |> URI.to_string()
    end
  end
end
