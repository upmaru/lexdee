defmodule Lexdee.ObservationTest do
  use ExUnit.Case

  test "can parse ping" do
    assert %Lexdee.Observation{} =
             Lexdee.Observation.new(
               %{
                 "type" => "ping",
                 "state" => "keepalive"
               },
               %{resource: "cluster", id: 1}
             )
  end

  test "can parse connection state" do
    assert %Lexdee.Observation{} =
             Lexdee.Observation.new(
               %{
                 "type" => "connection",
                 "state" => "connecting"
               },
               %{resource: "cluster", id: 1}
             )
  end

  test "can parse connection state connected" do
    assert %Lexdee.Observation{} =
             Lexdee.Observation.new(
               %{
                 "type" => "connection",
                 "state" => "connected"
               },
               %{resource: "cluster", id: 1}
             )
  end

  test "can parse operation task" do
    payload = File.read!("test/support/fixtures/websocket/task.json")

    assert %Lexdee.Observation{} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               resource: "cluster",
               id: 1
             })
  end

  test "can parse operation websocket" do
    payload = File.read!("test/support/fixtures/websocket/websocket.json")

    assert %Lexdee.Observation{} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               resource: "cluster",
               id: 1
             })
  end
end
