"""One test per valid transition and one per invalid transition."""
from django.test import SimpleTestCase

from apps.orders.models import Order

# (from_status, to_status, actor_role, expected)
VALID = [
    ('pending', 'accepted', 'vendor', True),
    ('pending', 'accepted', 'operator', True),
    ('pending', 'cancelled', 'customer', True),
    ('pending', 'cancelled', 'vendor', True),
    ('pending', 'cancelled', 'operator', True),
    ('accepted', 'preparing', 'vendor', True),
    ('accepted', 'preparing', 'operator', True),
    ('accepted', 'cancelled', 'vendor', True),
    ('accepted', 'cancelled', 'operator', True),
    ('preparing', 'picked_up', 'peyk', True),
    ('picked_up', 'delivered', 'peyk', True),
    # admin / developer act as operator
    ('pending', 'accepted', 'admin', True),
    ('accepted', 'preparing', 'developer', True),
]

INVALID = [
    # wrong actor
    ('pending', 'accepted', 'customer', False),
    ('preparing', 'picked_up', 'vendor', False),
    ('picked_up', 'delivered', 'customer', False),
    ('accepted', 'preparing', 'peyk', False),
    # illegal jumps
    ('pending', 'preparing', 'vendor', False),
    ('pending', 'picked_up', 'peyk', False),
    ('pending', 'delivered', 'operator', False),
    ('accepted', 'picked_up', 'peyk', False),
    ('preparing', 'delivered', 'peyk', False),
    # from terminal states
    ('delivered', 'cancelled', 'operator', False),
    ('cancelled', 'accepted', 'operator', False),
    ('delivered', 'preparing', 'vendor', False),
]


class StateMachineTests(SimpleTestCase):
    def _check(self, from_status, to_status, role, expected):
        order = Order(status=from_status)
        self.assertEqual(
            order.can_transition_to(to_status, role), expected,
            msg=f'{from_status} -> {to_status} as {role} should be {expected}',
        )

    def test_valid_transitions(self):
        for fs, ts, role, exp in VALID:
            with self.subTest(frm=fs, to=ts, role=role):
                self._check(fs, ts, role, exp)

    def test_invalid_transitions(self):
        for fs, ts, role, exp in INVALID:
            with self.subTest(frm=fs, to=ts, role=role):
                self._check(fs, ts, role, exp)
