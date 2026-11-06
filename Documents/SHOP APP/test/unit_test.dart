import 'package:flutter_test/flutter_test.dart';
import 'package:towel_shop/core/constants/app_constants.dart';
import 'package:towel_shop/features/address/models/address.dart';
import 'package:towel_shop/features/cart/models/cart_item.dart';
import 'package:towel_shop/features/cart/providers/cart_provider.dart';
import 'package:towel_shop/features/admin/models/store_settings.dart';
import 'package:towel_shop/features/auth/models/user_profile.dart';
import 'package:towel_shop/features/orders/models/order_model.dart';
import 'package:towel_shop/features/products/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Calculates discount percentage accurately', () {
      const product = Product(
        id: '1',
        name: 'Plush Bath Towel',
        price: 800.0,
        originalPrice: 1000.0,
        stock: 10,
        category: 'Bath Towel',
        imageUrl: '',
      );

      expect(product.hasDiscount, isTrue);
      expect(product.discountPercent, equals(20));
      expect(product.isInStock, isTrue);
    });

    test('Identifies out of stock correctly', () {
      const product = Product(
        id: '2',
        name: 'Zero Stock Towel',
        price: 500.0,
        stock: 0,
        category: 'Hand Towel',
        imageUrl: '',
      );

      expect(product.isInStock, isFalse);
    });
    test('Handles delivery charge correctly', () {
      const freeProduct = Product(
        id: '1',
        name: 'Free Delivery Towel',
        price: 500.0,
        stock: 10,
        deliveryCharge: 0.0,
        category: 'Bath Towel',
        imageUrl: '',
      );
      expect(freeProduct.hasFreeDelivery, isTrue);
      expect(freeProduct.deliveryText, equals('FREE Delivery'));

      const paidProduct = Product(
        id: '2',
        name: 'Paid Delivery Towel',
        price: 500.0,
        stock: 5,
        deliveryCharge: 49.0,
        category: 'Bath Towel',
        imageUrl: '',
      );
      expect(paidProduct.hasFreeDelivery, isFalse);
      expect(paidProduct.deliveryText, equals('₹49 Delivery'));
    });
  });

  group('Cart Model & Computations', () {
    test('CartItem calculates item total correctly', () {
      const product = Product(
        id: '1',
        name: 'Turkish Bath Towel',
        price: 799.0,
        stock: 10,
        category: 'Bath Towel',
        imageUrl: '',
      );

      const cartItem = CartItem(
        id: 'c1',
        userId: 'u1',
        productId: '1',
        quantity: 3,
        product: product,
      );

      expect(cartItem.totalPrice, equals(799.0 * 3));
    });

    test('Cart calculates total shipping fee from configured product delivery charges', () {
      const freeItem = CartItem(
        id: 'c1',
        userId: 'u1',
        productId: '1',
        quantity: 1,
        product: Product(
          id: '1',
          name: 'Free Item',
          price: 300,
          stock: 5,
          deliveryCharge: 0.0,
          category: 'Hand Towel',
          imageUrl: '',
        ),
      );

      const paidItem = CartItem(
        id: 'c2',
        userId: 'u1',
        productId: '2',
        quantity: 1,
        product: Product(
          id: '2',
          name: 'Heavy Item',
          price: 700,
          stock: 5,
          deliveryCharge: 49.0,
          category: 'Bath Towel',
          imageUrl: '',
        ),
      );

      // Cart with only free items
      final freeCart = CartState(items: [freeItem]);
      expect(freeCart.shippingFee, equals(0.0));
      expect(freeCart.qualifiesForFreeShipping, isTrue);
      expect(freeCart.totalAmount, equals(300.0));

      // Cart with free item + paid delivery item
      final mixedCart = CartState(items: [freeItem, paidItem]);
      expect(mixedCart.shippingFee, equals(49.0));
      expect(mixedCart.qualifiesForFreeShipping, isFalse);
      expect(mixedCart.totalAmount, equals(1049.0));
    });
  });

  group('Address Formatting', () {
    test('Generates complete formatted address line', () {
      const address = Address(
        id: 'a1',
        userId: 'u1',
        name: 'Kritik',
        phone: '9876543210',
        line1: 'Flat 402',
        line2: 'Ring Road',
        landmark: 'Near City Mall',
        city: 'Surat',
        state: 'Gujarat',
        pincode: '395007',
      );

      expect(
        address.formattedAddress,
        equals('Flat 402, Ring Road, near Near City Mall, Surat, Gujarat - 395007'),
      );
    });
  });

  group('Order Status & Cancellation Rules', () {
    test('Allows cancellation only when Placed or Confirmed', () {
      final orderPlaced = OrderModel(
        id: 'o1',
        orderNumber: 'TT-2026-0001',
        customerName: 'Kritik',
        customerPhone: '9876543210',
        addressSnapshot: {},
        totalAmount: 799.0,
        subtotal: 799.0,
        paymentMethod: AppConstants.paymentMethodCOD,
        orderStatus: AppConstants.statusPlaced,
        createdAt: DateTime.now(),
      );

      final orderShipped = orderPlaced.copyWith(orderStatus: AppConstants.statusShipped);
      final orderDelivered = orderPlaced.copyWith(orderStatus: AppConstants.statusDelivered);

      expect(orderPlaced.isCancellable, isTrue);
      expect(orderShipped.isCancellable, isFalse);
      expect(orderDelivered.isCancellable, isFalse);
    });
  });

  group('Store Settings & Admin Security Rules', () {
    test('Default StoreSettings initializes with secure defaults', () {
      const settings = StoreSettings();
      expect(settings.shopName, equals('SoftTouch Towels'));
      expect(settings.isShopClosed, isFalse);
      expect(settings.adminSecurityPin, equals('8845'));
      expect(settings.shopClosedNotice, contains('Shop is closed for some days'));
    });

    test('StoreSettings parses JSON accurately', () {
      final json = {
        'id': 'primary',
        'shop_name': 'Luxury Linens',
        'admin_phone': '+91 99999 88888',
        'is_shop_closed': true,
        'shop_closed_notice': 'Shop is closed for some days due to maintenance',
        'admin_security_pin': '1234',
      };

      final settings = StoreSettings.fromJson(json);
      expect(settings.shopName, equals('Luxury Linens'));
      expect(settings.isShopClosed, isTrue);
      expect(settings.shopClosedNotice, equals('Shop is closed for some days due to maintenance'));
      expect(settings.adminSecurityPin, equals('1234'));
      expect(settings.adminPhone, equals('+91 99999 88888'));
    });

    test('Admin PIN verification strictly matches security PIN', () {
      const settings = StoreSettings(adminSecurityPin: '8845');
      expect(settings.adminSecurityPin == '8845', isTrue);
      expect(settings.adminSecurityPin == '0000', isFalse);
      expect(settings.adminSecurityPin == ' 8845 '.trim(), isTrue);
    });

    test('Only kritikkhodiyar45@gmail.com qualifies for Admin role', () {
      bool isAuthorizedAdmin(String email) {
        return email.toLowerCase().trim() == 'kritikkhodiyar45@gmail.com';
      }

      expect(isAuthorizedAdmin('kritikkhodiyar45@gmail.com'), isTrue);
      expect(isAuthorizedAdmin('KritikKhodiyar45@Gmail.com'), isTrue);
      expect(isAuthorizedAdmin('customer@example.com'), isFalse);
      expect(isAuthorizedAdmin('admin@gmail.com'), isFalse);
      expect(isAuthorizedAdmin('hacker@store.com'), isFalse);
    });

    test('StoreSettings roundtrip serialization preserves all fields', () {
      const original = StoreSettings(
        id: 'primary',
        shopName: 'Kritik Towels Hub',
        adminPhone: '+91 98765 00000',
        isShopClosed: true,
        shopClosedNotice: 'Annual Inventory Count in progress',
        adminSecurityPin: '260102',
      );

      final json = original.toJson();
      final restored = StoreSettings.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.shopName, equals(original.shopName));
      expect(restored.adminPhone, equals(original.adminPhone));
      expect(restored.isShopClosed, equals(original.isShopClosed));
      expect(restored.shopClosedNotice, equals(original.shopClosedNotice));
      expect(restored.adminSecurityPin, equals(original.adminSecurityPin));
    });
  });

  group('UserProfile Model & Persistence Tests', () {
    test('UserProfile parses from JSON and serializes to JSON', () {
      final json = {
        'id': 'user-123',
        'email': 'customer@test.com',
        'name': 'Rahul Verma',
        'phone': '9876543210',
        'role': 'customer',
        'fcm_token': 'fcm-dummy-token',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, equals('user-123'));
      expect(profile.email, equals('customer@test.com'));
      expect(profile.name, equals('Rahul Verma'));
      expect(profile.phone, equals('9876543210'));
      expect(profile.isAdmin, isFalse);

      final serialized = profile.toJson();
      expect(serialized['id'], equals('user-123'));
      expect(serialized['name'], equals('Rahul Verma'));
      expect(serialized['phone'], equals('9876543210'));
    });

    test('UserProfile copyWith correctly updates name and phone', () {
      const original = UserProfile(
        id: 'u-1',
        email: 'test@domain.com',
        name: 'Initial Name',
        phone: '1111111111',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        phone: '9999999999',
      );

      expect(updated.name, equals('Updated Name'));
      expect(updated.phone, equals('9999999999'));
      expect(updated.email, equals('test@domain.com'));
    });
  });
}
