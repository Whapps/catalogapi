ExUnit.start()

defmodule TestFixtures do

  defp fixture_path(name) do
    filename = "#{name}.json"
    Path.join(["test", "fixtures", filename])
  end

  def fixture(name) do
    {:ok, xml} = name |> fixture_path |> File.read
    xml
  end
  
end
