import io
import os
import ssl
import subprocess
import sys

import certifi
import idna
import nbformat
import pytest
import requests
import urllib3
from nbconvert import HTMLExporter, MarkdownExporter
from tornado.escape import json_decode, json_encode
from jupyterlab_code_formatter.formatters import BlackFormatter


@pytest.mark.skipif(
    os.environ.get("GITHUB_ACTIONS") != "true",
    reason="Kernel sockets are unavailable in the restricted local validation sandbox",
)
def test_kernel_executes_on_ci():
    from jupyter_client import KernelManager

    manager = KernelManager(kernel_name="python3")
    manager.start_kernel(extra_arguments=["--HistoryManager.enabled=False"])
    client = manager.client()
    client.start_channels()
    try:
        client.wait_for_ready(timeout=30)
        client.execute("assert 2 + 2 == 4")
        assert client.get_shell_msg(timeout=30)["content"]["status"] == "ok"
    finally:
        client.stop_channels()
        manager.shutdown_kernel(now=True)


def test_classic_notebook_cli_and_lab_formatter():
    result = subprocess.run(
        [sys.executable, "-m", "notebook", "--version"],
        check=True,
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert result.stdout.strip().startswith("6.")
    assert BlackFormatter().format_code("x=1", notebook=True) == "x = 1"


def test_notebook_export_preserves_markdown_and_code():
    notebook = nbformat.v4.new_notebook(
        cells=[
            nbformat.v4.new_markdown_cell("# Compatibility\n\n**safe text**"),
            nbformat.v4.new_code_cell("print(2 + 2)"),
        ]
    )
    html, _ = HTMLExporter().from_notebook_node(notebook)
    markdown, _ = MarkdownExporter().from_notebook_node(notebook)
    assert "Compatibility" in html and "<strong>safe text</strong>" in html
    assert "**safe text**" in markdown and "print(2 + 2)" in markdown


def test_network_dependencies_preserve_verification_and_encoding():
    context = ssl.create_default_context(cafile=certifi.where())
    assert context.verify_mode == ssl.CERT_REQUIRED
    assert context.check_hostname
    assert context.cert_store_stats()["x509_ca"] > 0
    assert requests.certs.where() == certifi.where()
    request = requests.Request("GET", "https://example.org", params={"q": "a b"})
    assert request.prepare().url == "https://example.org/?q=a+b"
    assert idna.encode("bücher.example") == b"xn--bcher-kva.example"
    response = urllib3.response.HTTPResponse(body=io.BytesIO(b"payload"))
    assert response.data == b"payload"
    assert json_decode(json_encode({"ok": True})) == {"ok": True}


def test_lab4_cli_and_widget_jupytext_roundtrip():
    import ipywidgets
    import jupytext
    import jupyterlab

    assert jupyterlab.__version__.startswith("4.")
    notebook = nbformat.v4.new_notebook(
        cells=[nbformat.v4.new_code_cell("print(2 + 2)")]
    )
    text = jupytext.writes(notebook, fmt="py:percent")
    assert jupytext.reads(text, fmt="py:percent").cells[0].source == "print(2 + 2)"
    widget = ipywidgets.IntSlider(value=3)
    assert widget.get_state()["value"] == 3
    widget.close()
    subprocess.run(
        [sys.executable, "-m", "jupyterlab", "--version"],
        check=True,
        capture_output=True,
        timeout=30,
    )


def test_classic_extension_setup_and_prebuilt_lab_extensions(tmp_path):
    env = dict(os.environ)
    env["JUPYTER_CONFIG_DIR"] = str(tmp_path / "config")
    env["JUPYTER_DATA_DIR"] = str(tmp_path / "data")
    commands = [
        ["contrib", "nbextension", "install", "--user"],
        ["nbextensions_configurator", "enable", "--user"],
        ["serverextension", "enable", "jupytext", "--user"],
    ]
    for extension in (
        "code_prettify/autopep8",
        "select_keymap/main",
        "highlight_selected_word/main",
        "toggle_all_line_numbers/main",
        "varInspector/main",
        "toc2/main",
        "equation-numbering/main",
        "execute_time/ExecuteTime",
    ):
        commands.append(["nbextension", "enable", extension, "--user"])
    for command in commands:
        subprocess.run(
            [sys.executable, "-m", "jupyter", *command],
            check=True,
            capture_output=True,
            text=True,
            timeout=60,
            env=env,
        )
    result = subprocess.run(
        [sys.executable, "-m", "jupyter", "labextension", "list"],
        check=True,
        capture_output=True,
        text=True,
        timeout=60,
    )
    output = result.stdout + result.stderr
    assert "incompatible" not in output
    for extension in (
        "jupyterlab-jupytext",
        "jupyterlab_code_formatter",
        "@jupyter-widgets/jupyterlab-manager",
    ):
        assert extension in output


@pytest.mark.skipif(
    os.environ.get("GITHUB_ACTIONS") != "true",
    reason="Server sockets are validated on GitHub Actions",
)
def test_lab_server_serves_login_page(tmp_path):
    import socket
    import time

    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    process = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "jupyterlab",
            "--no-browser",
            "--ip=127.0.0.1",
            f"--port={port}",
            "--ServerApp.port_retries=0",
            f"--ServerApp.root_dir={tmp_path}",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    try:
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            assert process.poll() is None, "JupyterLab exited before serving HTTP"
            try:
                response = requests.get(f"http://127.0.0.1:{port}/lab", timeout=2)
                if response.status_code == 200:
                    assert "Jupyter" in response.text
                    break
            except requests.ConnectionError:
                pass
            time.sleep(0.5)
        else:
            pytest.fail("JupyterLab did not serve its login page within 60 seconds")
    finally:
        process.terminate()
        try:
            process.wait(timeout=15)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)
