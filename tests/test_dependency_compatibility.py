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
