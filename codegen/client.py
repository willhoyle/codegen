from typing import List, Union
from contextlib import contextmanager
from pynvim import attach
from path import Path
import cattrs

from codegen.config import Config
from codegen.types import Result, RpcNotifyEvent
from codegen.util import lua_dir


class Client:
    def __init__(self, config: Config):
        self.nvim = attach("socket", path=config.socket_path)
        self.nvim.exec_lua((lua_dir() / "lua/codegen/bootstrap.lua").read_text())
        self.nvim.lua.bootstrap.append_runtimepath(lua_dir().abspath())
        self.nvim.lua.bootstrap.append_runtimepath((lua_dir() / "lua/lib").abspath())
        self.nvim.exec_lua((lua_dir() / "lua/codegen/lib.lua").abspath().read_text())

    @property
    def lib(self):
        return self.nvim.lua.lib

    @contextmanager
    def wait_for_message(self, name):
        self.nvim.subscribe(name)
        result = Result(None)
        try:
            yield result
        finally:
            message = cattrs.structure_attrs_fromtuple(tuple(self.nvim.next_message()), RpcNotifyEvent)  # type: ignore
            if message.name != name:
                print("Got unexpected message")
                print(message)

            result.value = message.value[0]
            self.nvim.unsubscribe(name)

    def get_choice(self, choices: List):
        return self.lib.get_choice(choices)

    def get_choice_telescope(
        self,
        choices: List[Union[str, dict]],
        title="Choose:",
        preview_title="Info",
        preview_filetype="",
        preview_options=dict(),
    ):
        choices = [
            choice
            if isinstance(choice, dict)
            else {"value": choice, "display": choice, "render": choice}
            for choice in choices
        ]
        with self.wait_for_message("get_choice_telescope") as result:
            self.lib.get_choice_telescope(
                dict(
                    choices=choices,
                    title=title,
                    preview_title=preview_title,
                    preview_filetype=preview_filetype,
                    render_options=preview_options,
                )
            )
        return result.value
