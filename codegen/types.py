from typing import Any
from attrs import define, field


@define
class Result:
    value: Any


@define
class RpcNotifyEvent:
    type: str
    name: str
    value: Any = field()
