import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address.dart';

final List<Address> _demoAddresses = [
  const Address(
    id: 'addr-demo-1',
    userId: 'demo-user',
    name: 'Kritik Khodiyar',
    phone: '9876543210',
    line1: 'Flat 402, Lotus Residency',
    line2: 'Ring Road, Near City Mall',
    landmark: 'Opposite Central Park',
    city: 'Surat',
    state: 'Gujarat',
    pincode: '395007',
    isDefault: true,
  ),
  const Address(
    id: 'addr-demo-2',
    userId: 'demo-user',
    name: 'Kritik Khodiyar (Office)',
    phone: '9876543210',
    line1: 'Tower B, Tech Innovation Hub',
    line2: 'Outer Ring Road, Whitefield',
    landmark: 'Near Metro Station',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560066',
    isDefault: false,
  ),
];

class AddressState {
  final List<Address> addresses;
  final Address? selectedCheckoutAddress;
  final bool isLoading;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.selectedCheckoutAddress,
    this.isLoading = false,
    this.error,
  });

  Address? get defaultAddress {
    final defaultList = addresses.where((a) => a.isDefault).toList();
    if (defaultList.isNotEmpty) return defaultList.first;
    if (addresses.isNotEmpty) return addresses.first;
    return null;
  }

  AddressState copyWith({
    List<Address>? addresses,
    Address? selectedCheckoutAddress,
    bool? isLoading,
    String? error,
    bool clearSelectedAddress = false,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedCheckoutAddress: clearSelectedAddress
          ? null
          : (selectedCheckoutAddress ?? this.selectedCheckoutAddress),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  final SupabaseService _supabaseService;

  AddressNotifier(this._supabaseService)
      : super(
          AddressState(
            addresses: LocalStorageService().getAddresses() ?? _demoAddresses,
            selectedCheckoutAddress: (LocalStorageService().getAddresses()?.isNotEmpty == true)
                ? (LocalStorageService().getAddresses()!.where((a) => a.isDefault).firstOrNull ??
                    LocalStorageService().getAddresses()!.first)
                : _demoAddresses.first,
          ),
        ) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      state = state.copyWith(isLoading: true);
      try {
        final data = await client
            .from('addresses')
            .select()
            .eq('user_id', user.id)
            .order('is_default', ascending: false);

        final items = (data as List)
            .map((item) => Address.fromJson(item as Map<String, dynamic>))
            .toList();

        final defaultAddr = items.isNotEmpty
            ? (items.where((a) => a.isDefault).firstOrNull ?? items.first)
            : null;

        await LocalStorageService().saveAddresses(items);

        state = state.copyWith(
          addresses: items,
          selectedCheckoutAddress: state.selectedCheckoutAddress ?? defaultAddr,
          isLoading: false,
        );
      } catch (e) {
        debugPrint('Error loading addresses: $e');
        final cached = LocalStorageService().getAddresses() ?? _demoAddresses;
        state = state.copyWith(
          addresses: cached,
          selectedCheckoutAddress: cached.firstOrNull,
          isLoading: false,
        );
      }
    } else {
      // Demo fallback addresses or local cache
      final cached = LocalStorageService().getAddresses() ?? _demoAddresses;
      state = state.copyWith(
        addresses: cached,
        selectedCheckoutAddress: cached.firstOrNull,
        isLoading: false,
      );
    }
  }

  void selectCheckoutAddress(Address address) {
    state = state.copyWith(selectedCheckoutAddress: address);
  }

  Future<bool> addAddress(Address address) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    final newId = const Uuid().v4();
    final newAddress = address.copyWith(
      id: newId,
      userId: user?.id ?? 'demo-user',
    );

    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        final data = newAddress.toJson();
        data.remove('id');
        data['id'] = newId;

        await client.from('addresses').insert(data);
        await loadAddresses();
        return true;
      } catch (e) {
        debugPrint('Error saving address in Supabase: $e');
        return false;
      }
    } else {
      // Local demo mode
      final updated = List<Address>.from(state.addresses);
      if (newAddress.isDefault) {
        for (var i = 0; i < updated.length; i++) {
          updated[i] = updated[i].copyWith(isDefault: false);
        }
      }
      updated.add(newAddress);
      await LocalStorageService().saveAddresses(updated);
      state = state.copyWith(
        addresses: updated,
        selectedCheckoutAddress: newAddress.isDefault ? newAddress : state.selectedCheckoutAddress,
      );
      return true;
    }
  }

  Future<bool> updateAddress(Address address) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client
            .from('addresses')
            .update(address.toJson())
            .eq('id', address.id);
        await loadAddresses();
        return true;
      } catch (e) {
        debugPrint('Error updating address: $e');
        return false;
      }
    } else {
      final updated = state.addresses.map((a) {
        if (a.id == address.id) return address;
        if (address.isDefault) return a.copyWith(isDefault: false);
        return a;
      }).toList();

      await LocalStorageService().saveAddresses(updated);
      state = state.copyWith(
        addresses: updated,
        selectedCheckoutAddress: address.id == state.selectedCheckoutAddress?.id
            ? address
            : state.selectedCheckoutAddress,
      );
      return true;
    }
  }

  Future<void> deleteAddress(String id) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client.from('addresses').delete().eq('id', id);
        await loadAddresses();
      } catch (e) {
        debugPrint('Error deleting address: $e');
      }
    } else {
      final updated = state.addresses.where((a) => a.id != id).toList();
      await LocalStorageService().saveAddresses(updated);
      state = state.copyWith(
        addresses: updated,
        selectedCheckoutAddress:
            state.selectedCheckoutAddress?.id == id ? updated.firstOrNull : state.selectedCheckoutAddress,
      );
    }
  }

  Future<void> setDefaultAddress(String id) async {
    final client = _supabaseService.client;
    final user = _supabaseService.currentUser;

    if (client != null && user != null && SupabaseService.isConfigured) {
      try {
        await client.from('addresses').update({'is_default': true}).eq('id', id);
        await loadAddresses();
      } catch (e) {
        debugPrint('Error setting default address: $e');
      }
    } else {
      final updated = state.addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();
      await LocalStorageService().saveAddresses(updated);
      state = state.copyWith(
        addresses: updated,
        selectedCheckoutAddress: updated.firstWhere((a) => a.id == id),
      );
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  final notifier = AddressNotifier(SupabaseService());
  ref.listen(authProvider, (previous, next) {
    if (previous?.user?.id != next.user?.id) {
      notifier.loadAddresses();
    }
  });
  return notifier;
});
