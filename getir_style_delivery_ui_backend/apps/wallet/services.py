"""
Wallet money movement. Every balance change goes through credit()/debit(),
which lock the wallet row, enforce no-overdraft, and append a ledger entry
with a balance_after snapshot. Callers must wrap multi-step flows in their
own transaction if atomicity across steps is required.
"""
from django.db import transaction

from .models import Wallet, WalletTransaction


class WalletError(Exception):
    """Base wallet error."""


class InsufficientFunds(WalletError):
    """Raised when a debit would drive the balance negative."""


def get_or_create_wallet(user) -> Wallet:
    wallet, _ = Wallet.objects.get_or_create(user=user)
    return wallet


def _apply(wallet_id, direction, txn_type, amount, order=None, description=''):
    if amount <= 0:
        raise WalletError('Amount must be positive.')
    with transaction.atomic():
        wallet = Wallet.objects.select_for_update().get(pk=wallet_id)
        if not wallet.is_active:
            raise WalletError('Wallet is inactive.')
        if direction == 'debit':
            if wallet.balance < amount:
                raise InsufficientFunds('Insufficient wallet balance.')
            wallet.balance -= amount
        else:
            wallet.balance += amount
        wallet.save(update_fields=['balance', 'updated_at'])
        return WalletTransaction.objects.create(
            wallet=wallet,
            direction=direction,
            txn_type=txn_type,
            amount=amount,
            balance_after=wallet.balance,
            order=order,
            description=description,
        )


def credit(wallet, amount, txn_type, order=None, description=''):
    """Increase balance. Returns the WalletTransaction."""
    return _apply(wallet.pk, 'credit', txn_type, amount, order, description)


def debit(wallet, amount, txn_type, order=None, description=''):
    """Decrease balance. Raises InsufficientFunds if balance too low."""
    return _apply(wallet.pk, 'debit', txn_type, amount, order, description)


def pay_order(user, order):
    """
    Debit the user's wallet for an order's total and mark it paid.
    Idempotent: returns None if the order is already paid.
    """
    if order.is_paid:
        return None
    wallet = get_or_create_wallet(user)
    txn = debit(
        wallet, order.total_amount, 'order_payment',
        order=order, description=f'Payment for order {order.id}',
    )
    order.is_paid = True
    order.save(update_fields=['is_paid', 'updated_at'])
    return txn


def refund_order(order):
    """
    Credit the customer's wallet for a previously wallet-paid order and clear
    its paid flag. No-op if the order was not paid. Used on cancellation.
    """
    if not order.is_paid or order.payment_method != 'wallet':
        return None
    wallet = get_or_create_wallet(order.customer)
    txn = credit(
        wallet, order.total_amount, 'refund',
        order=order, description=f'Refund for cancelled order {order.id}',
    )
    order.is_paid = False
    order.save(update_fields=['is_paid', 'updated_at'])
    return txn
