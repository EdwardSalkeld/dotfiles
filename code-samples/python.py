import logging

logger = logging.getLogger(__name__)


# TODO: This is a todo comment
class WellNamedClass:
    def __init__(self, val: int) -> None:
        self.val = val

    def action(self) -> None:
        logger.info(f"My value is {self.val}")

    def get_name(self) -> str:
        try:
            return self._get_name()
        except Exception as e:
            logger.error(f"Error getting name: {e}")
        return "Name"


# TODO: this is a multiline todo
# that should be handled correctly
class Other:
    """
    This is a block comment
    """

    def other(self, var: str) -> None:
        if var:
            logger.info(f"Other value is {var}")
        else:
            logger.warning("No value provided")


# This is just a comment
a = WellNamedClass(1)
b = WellNamedClass(2)
c = WellNamedClass(3)
things = [a, b, c]
arr_len = len(things)
for thing in things:
    thing.action()
    thing.other("txt")
print("We're done")
