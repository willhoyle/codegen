from attrs import define


@define
class Config:
    socket_path: str = "/tmp/nvim"
