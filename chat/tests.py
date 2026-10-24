from decimal import Decimal
from django.test import TestCase
from .models import Item
from .tools import calculate_total, set_item_price

class InventoryPricingTests(TestCase):
    def setUp(self):
        self.item = Item.objects.create(name="Test Chocolate", quantity=10, price=Decimal("2.50"))

    def test_vat_quote_returns_825_without_changing_inventory(self):
        result = calculate_total("Test Chocolate", 3, 10)
        self.assertEqual(result["subtotal"], "7.50")
        self.assertEqual(result["vat_amount"], "0.75")
        self.assertEqual(result["total"], "8.25")
        self.assertTrue(result["in_stock"])
        self.item.refresh_from_db()
        self.assertEqual(self.item.quantity, 10)

    def test_price_update_changes_subsequent_quote(self):
        change = set_item_price("Test Chocolate", "3.00")
        self.assertEqual(change["price"], "3.00")
        self.assertEqual(calculate_total("Test Chocolate", 3, 10)["total"], "9.90")

    def test_invalid_quantity_is_rejected(self):
        self.assertIn("error", calculate_total("Test Chocolate", 0, 10))
