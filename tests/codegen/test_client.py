import pytest

from codegen.client import Client
from codegen.config import Config


@pytest.fixture
def client():
    config = Config()
    client = Client(config)
    return client


def test_get_choice_telescope(client: Client):
    res = client.get_choice_telescope(
        ["my_valq", "my_val2"],
        title="test title",
        preview_filetype="c",
    )


@pytest.mark.test
def test_preview_markdown(client: Client):
    res = client.get_choice_telescope(
        ["my_val", "my_val2"],
        title="test title",
        preview_filetype="markdown",
        preview_options={"message": "{{yo}} {{ choice }}", "data": {"yo": 123}},
    )
    print(res)


class Test:
    pass
