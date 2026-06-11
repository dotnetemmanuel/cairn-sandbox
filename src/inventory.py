"""A tiny in-memory inventory, long enough to produce multi-hunk diffs."""

from dataclasses import dataclass, field


@dataclass
class Item:
    sku: str
    name: str
    quantity: int = 0
    price: float = 0.0


@dataclass
class Inventory:
    items: dict = field(default_factory=dict)

    def add(self, item: Item) -> None:
        """Add a new item, or top up the quantity if the SKU exists."""
        if item.sku in self.items:
            self.items[item.sku].quantity += item.quantity
        else:
            self.items[item.sku] = item

    def remove(self, sku: str, quantity: int) -> None:
        """Remove some quantity of an item, dropping it when it hits zero."""
        if sku not in self.items:
            raise KeyError(sku)
        self.items[sku].quantity -= quantity
        if self.items[sku].quantity <= 0:
            del self.items[sku]

    def count(self, sku: str) -> int:
        """Return the quantity on hand for a SKU (zero if unknown)."""
        item = self.items.get(sku)
        return item.quantity if item else 0

    def total_value(self) -> float:
        """Return the summed value of all stock on hand."""
        return sum(i.quantity * i.price for i in self.items.values())

    def low_stock(self, threshold: int = 5) -> list:
        """Return SKUs whose quantity is at or below the threshold."""
        return [sku for sku, i in self.items.items() if i.quantity <= threshold]


if __name__ == "__main__":
    inv = Inventory()
    inv.add(Item("A1", "Widget", 10, 2.5))
    inv.add(Item("B2", "Gadget", 3, 9.99))
    print("total value:", inv.total_value())
    print("low stock:", inv.low_stock())
