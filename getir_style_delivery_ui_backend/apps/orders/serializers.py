from django.db import transaction
from rest_framework import serializers

from apps.catalog.models import Item

from .models import OfflineOrder, Order, OrderItem, ORDER_STATUS


class OrderItemSerializer(serializers.ModelSerializer):
    item_name = serializers.CharField(source='item.name', read_only=True)
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = OrderItem
        fields = ['id', 'item', 'item_name', 'quantity', 'unit_price', 'line_total']
        read_only_fields = ['id', 'unit_price']

    def get_line_total(self, obj):
        return obj.unit_price * obj.quantity


class OrderItemWriteSerializer(serializers.Serializer):
    item = serializers.UUIDField()
    quantity = serializers.IntegerField(min_value=1)


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    vendor_name = serializers.CharField(source='vendor.business_name', read_only=True)
    assigned_peyk_id = serializers.SerializerMethodField()
    assigned_peyk_name = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            'id', 'customer', 'vendor', 'vendor_name', 'status',
            'fulfillment_type', 'dining_table', 'delivery_type', 'payment_method',
            'total_amount', 'is_paid',
            'delivery_code', 'delivery_address', 'delivery_city',
            'customer_notes', 'items', 'assigned_peyk_id', 'assigned_peyk_name',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'customer', 'status', 'total_amount', 'is_paid',
                            'delivery_code', 'created_at', 'updated_at']

    def get_assigned_peyk_id(self, obj):
        assignment = getattr(obj, 'assignment', None)
        return str(assignment.peyk_id) if assignment else None

    def get_assigned_peyk_name(self, obj):
        assignment = getattr(obj, 'assignment', None)
        if assignment is None:
            return None
        peyk = getattr(assignment, 'peyk', None)
        return peyk.full_name if peyk else None

    def to_representation(self, instance):
        """Hide the delivery PIN from the peyk — they must get it from the
        customer at handoff. Everyone else (customer/operator) can see it."""
        data = super().to_representation(instance)
        request = self.context.get('request')
        if request and getattr(request.user, 'role', None) == 'peyk':
            data.pop('delivery_code', None)
        return data


class OrderCreateSerializer(serializers.ModelSerializer):
    items = OrderItemWriteSerializer(many=True, write_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'vendor', 'fulfillment_type', 'dining_table',
            'delivery_type', 'payment_method',
            'delivery_address', 'delivery_city', 'customer_notes', 'items',
        ]
        read_only_fields = ['id']

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('At least one item is required.')
        return value

    def validate(self, attrs):
        fulfillment = attrs.get('fulfillment_type', 'delivery')
        if fulfillment == 'dine_in':
            table = attrs.get('dining_table')
            if table is None:
                raise serializers.ValidationError(
                    {'dining_table': 'A table is required for dine-in orders.'},
                )
            vendor = attrs['vendor']
            if table.vendor_id != vendor.id:
                raise serializers.ValidationError(
                    {'dining_table': 'Table must belong to the chosen vendor.'},
                )
            if table.status == 'occupied':
                raise serializers.ValidationError(
                    {'dining_table': 'This table is not available.'},
                )
            if not attrs.get('delivery_address'):
                attrs['delivery_address'] = table.label
            if not attrs.get('delivery_city'):
                attrs['delivery_city'] = vendor.city
        else:
            if not (attrs.get('delivery_address') or '').strip():
                raise serializers.ValidationError(
                    {'delivery_address': 'Delivery address is required.'},
                )
            if not (attrs.get('delivery_city') or '').strip():
                raise serializers.ValidationError(
                    {'delivery_city': 'Delivery city is required.'},
                )

        vendor = attrs['vendor']
        item_ids = [i['item'] for i in attrs['items']]
        items = {str(it.id): it for it in Item.objects.filter(id__in=item_ids)}
        if len(items) != len(set(str(i) for i in item_ids)):
            raise serializers.ValidationError({'items': 'One or more items do not exist.'})
        for it in items.values():
            if it.vendor_id != vendor.id:
                raise serializers.ValidationError(
                    {'items': 'All items must belong to the chosen vendor.'}
                )
        attrs['_resolved_items'] = items
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        items_data = validated_data.pop('items')
        resolved = validated_data.pop('_resolved_items')
        customer = self.context['request'].user
        order = Order.objects.create(customer=customer, total_amount=0, **validated_data)
        for entry in items_data:
            item = resolved[str(entry['item'])]
            OrderItem.objects.create(
                order=order, item=item,
                quantity=entry['quantity'], unit_price=item.price,
            )
        order.recompute_total()
        order.save(update_fields=['total_amount', 'updated_at'])
        return order


class StatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=[s[0] for s in ORDER_STATUS])


class OfflineOrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = OfflineOrder
        fields = [
            'id', 'operator', 'customer_phone', 'customer_name', 'vendor',
            'items_description', 'total_amount', 'delivery_address',
            'status', 'notes', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'operator', 'created_at', 'updated_at']
