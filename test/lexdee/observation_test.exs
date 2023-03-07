defmodule Lexdee.ObservationTest do
  use ExUnit.Case

  test "can parse ping" do
    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(
               %{
                 "type" => "ping",
                 "state" => "keepalive"
               },
               %{type: "cluster", id: 1}
             )

    assert %Lexdee.Message{} = event.object
  end

  test "can parse connection state" do
    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(
               %{
                 "type" => "connection",
                 "state" => "connecting"
               },
               %{type: "cluster", id: 1}
             )

    assert %Lexdee.Message{} = event.object
  end

  test "can parse connection state connected" do
    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(
               %{
                 "type" => "connection",
                 "state" => "connected"
               },
               %{type: "cluster", id: 1}
             )

    assert %Lexdee.Message{} = event.object
  end

  test "can parse operation task" do
    payload = File.read!("test/support/fixtures/websocket/task.json")

    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               type: "cluster",
               id: 1
             })

    assert %Lexdee.Operation{metadata: metadata} = event.object
    assert is_nil(metadata)
  end

  test "can parse operation websocket" do
    payload = File.read!("test/support/fixtures/websocket/websocket.json")

    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               type: "cluster",
               id: 1
             })

    assert %Lexdee.Operation{metadata: metadata} = event.object
    assert %Lexdee.Websocket{} = metadata
  end

  test "can parse lifecycle event" do
    payload = File.read!("test/support/fixtures/websocket/lifecycle.json")

    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               type: "cluster",
               id: 1
             })

    assert %Lexdee.Lifecycle{} = event.object
  end

  test "can parse logging event" do
    payload = File.read!("test/support/fixtures/websocket/logging.json")

    assert %Lexdee.Observation{event: %Lexdee.Event{} = event} =
             Lexdee.Observation.new(Jason.decode!(payload), %{
               type: "cluster",
               id: 1
             })

    assert %Lexdee.Logging{} = event.object
  end
end
