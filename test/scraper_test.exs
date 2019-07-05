defmodule ScraperTest do
  use ExUnit.Case
  import Mock

  doctest Scraper

  test "Assert if returned results are correct" do
    with_mocks([
      {HTTPoison, [], [get!: fn(_)-> %HTTPoison.Response{body: body(), status_code: 200} end]}
    ]) do
      assert {:ok, data} = Scraper.fetch("https://www.nintendo.com/switch")
      assert length(data.assets) == 40
      assert length(data.links) == 61
    end
  end

  test "Assert if result returns correct assets and links" do
    with_mocks([
      {HTTPoison, [], [get!: fn(_)-> %HTTPoison.Response{body: body(), status_code: 200} end]}
    ]) do
      assert {:ok, data} = Scraper.fetch("https://www.nintendo.com/switch")

      Enum.member?(data.links, "http://en-americas-support.nintendo.com/app/answers/landing/p/897/c/693")
      Enum.member?(data.assets, "https://www.nintendo.com/etc.clientlibs/noa/clientlibs/clientlib-ncom/resources/images/page/switch/home/pane1.jpg")
    end
  end

  test "Assert if base gets appended" do
    with_mocks([
      {HTTPoison, [], [get!: fn(_)-> %HTTPoison.Response{body: body(), status_code: 200} end]}
    ]) do
      assert {:ok, data} = Scraper.fetch("https://www.nintendo.com/switch")

      Enum.member?(data.links, "https://www.nintendo.com/games")
      Enum.member?(data.assets, "https://www.nintendo.com/content/dam/noa/en_US/images/switch-home/B_1-mob.jpg")
    end
  end

  def body do
    File.read!("test/files/nintendo-switch.html")
  end
end
