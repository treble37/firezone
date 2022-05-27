defmodule FzHttp.Telemetry do
  @moduledoc """
  Functions for various telemetry events.
  """

  alias FzCommon.CLI
  alias FzHttp.Users

  require Logger

  def add_network(network) do
    capture_event(
      "add_network",
      network_uuid_hash: hash(network.id),
      admin_email_hash: hash(admin_email())
    )
  end

  def delete_network(network) do
    capture_event(
      "delete_network",
      network_uuid_hash: hash(network.id),
      admin_email_hash: hash(admin_email())
    )
  end

  def add_device(device) do
    capture_event(
      "add_device",
      device_uuid_hash: hash(device.uuid),
      user_email_hash: hash(user_email(device.user_id)),
      admin_email_hash: hash(admin_email())
    )
  end

  def add_user(user) do
    capture_event(
      "add_user",
      user_email_hash: hash(user.email),
      admin_email_hash: hash(admin_email())
    )
  end

  def add_rule(rule) do
    capture_event(
      "add_rule",
      rule_uuid_hash: hash(rule.uuid),
      admin_email_hash: hash(admin_email())
    )
  end

  def delete_device(device) do
    capture_event(
      "delete_device",
      device_uuid_hash: hash(device.uuid),
      user_email_hash: hash(user_email(device.user_id)),
      admin_email_hash: hash(admin_email())
    )
  end

  def delete_user(user) do
    capture_event(
      "delete_user",
      user_email_hash: hash(user.email),
      admin_email_hash: hash(admin_email())
    )
  end

  def delete_rule(rule) do
    capture_event(
      "delete_rule",
      rule_uuid_hash: hash(rule.uuid),
      admin_email_hash: hash(admin_email())
    )
  end

  def login(user) do
    capture_event(
      "login",
      user_email_hash: hash(user.email)
    )
  end

  def disable_user(user, reason) do
    capture_event(
      "disable_user",
      user_email_hash: hash(user.email),
      reason: reason
    )
  end

  def fz_http_started, do: capture_event("fz_http_started")

  def ping, do: capture_event("ping")

  defp capture_event(name, extra_fields \\ []) do
    telemetry_module().capture(
      name,
      common_fields() ++ extra_fields
    )
  end

  defp common_fields do
    [
      distinct_id: distinct_id(),
      fqdn: fqdn(),
      version: version(),
      kernel_version: "#{os_type()} #{os_version()}",
      host_info: host_info()
    ]
  end

  defp hash(str) do
    :crypto.hash(:sha256, str) |> Base.encode16()
  end

  defp telemetry_module do
    Application.fetch_env!(:fz_http, :telemetry_module)
  end

  defp user_email(user_id) do
    Users.get_user!(user_id).email
  end

  defp admin_email do
    Application.fetch_env!(:fz_http, :admin_email)
  end

  defp fqdn do
    :fz_http
    |> Application.fetch_env!(FzHttpWeb.Endpoint)
    |> Keyword.get(:url)
    |> Keyword.get(:host)
  end

  defp distinct_id do
    Application.fetch_env!(:fz_http, :telemetry_id)
  end

  defp version do
    Application.spec(:fz_http, :vsn) |> to_string()
  end

  defp os_type do
    case :os.type() do
      {:unix, type} ->
        "#{type}"

      _ ->
        "other"
    end
  end

  defp os_version do
    case :os.version() do
      {major, minor, patch} ->
        "#{major}.#{minor}.#{patch}"

      _ ->
        "0.0.0"
    end
  end

  defp host_info do
    case CLI.bash("hostnamectl") do
      {result, 0} ->
        result

      {error, _exit_code} ->
        error
    end
  end
end
