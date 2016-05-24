## The contents of this file are subject to the Mozilla Public License
## Version 1.1 (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License
## at http://www.mozilla.org/MPL/
##
## Software distributed under the License is distributed on an "AS IS"
## basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
## the License for the specific language governing rights and
## limitations under the License.
##
## The Original Code is RabbitMQ.
##
## The Initial Developer of the Original Code is GoPivotal, Inc.
## Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.


defmodule ClusterStatusCommandTest do
  use ExUnit.Case, async: false
  import TestHelper
  import ExUnit.CaptureIO

  setup_all do
    :net_kernel.start([:rabbitmqctl, :shortnames])
    :net_kernel.connect_node(get_rabbit_hostname)

    on_exit([], fn ->
      :erlang.disconnect_node(get_rabbit_hostname)
      :net_kernel.stop()
    end)

    :ok
  end

  setup do
    {:ok, opts: %{node: get_rabbit_hostname}}
  end

  test "with extra arguments, status returns an arg count error", context do
    capture_io(fn ->
      assert ClusterStatusCommand.run(["extra"], context[:opts]) ==
      {:too_many_args, ["extra"]}
    end)
  end

  test "status request on a named, active RMQ node is successful", context do
    capture_io(fn ->
      assert ClusterStatusCommand.run([], context[:opts])[:nodes] != nil
    end)
  end

  test "status request on nonexistent RabbitMQ node returns nodedown" do
    target = :jake@thedog
    :net_kernel.connect_node(target)
    opts = %{node: target}

    capture_io(fn ->
      assert ClusterStatusCommand.run([], opts) != nil
    end)
  end

  test "by default, status request prints an info message", context do
    assert capture_io(fn ->
      ClusterStatusCommand.run([], context[:opts])
    end) =~ ~r/Cluster status of node #{get_rabbit_hostname}/
  end

  test "the quiet flag suppresses the info message", context do
    opts = Map.merge(context[:opts], %{quiet: true})

    refute capture_io(fn ->
      ClusterStatusCommand.run([], opts)
    end) =~ ~r/Cluster status of node #{get_rabbit_hostname}/
  end
end