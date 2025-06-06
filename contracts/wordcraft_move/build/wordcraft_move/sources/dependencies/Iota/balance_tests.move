// Copyright (c) Mysten Labs, Inc.
// Modifications Copyright (c) 2024 IOTA Stiftung
// SPDX-License-Identifier: Apache-2.0

/// A storable handler for Balances in general. Is used in the `Coin`
/// module to allow balance operations and can be used to implement
/// custom coins with `Supply` and `Balance`s.
module iota::balance {

    /// Allows calling `.into_coin()` on a `Balance` to turn it into a coin.
    public use fun iota::coin::from_balance as Balance.into_coin;

    /// For when trying to destroy a non-zero balance.
    const ENonZero: u64 = 0;
    /// For when an overflow is happening on Supply operations.
    const EOverflow: u64 = 1;
    /// For when trying to withdraw more than there is.
    const ENotEnough: u64 = 2;
    /// Sender is not @0x0 the system address.
    const ENotSystemAddress: u64 = 3;
    /// Epoch is not 0 (the genesis epoch).
    const ENotGenesisEpoch: u64 = 4;
    /// System operation performed for a coin other than IOTA
    const ENotIOTA: u64 = 5;

    /// A Supply of T. Used for minting and burning.
    /// Wrapped into a `TreasuryCap` in the `Coin` module.
    public struct Supply<phantom T> has store {
        value: u64
    }

    /// Storable balance - an inner struct of a Coin type.
    /// Can be used to store coins which don't need the key ability.
    public struct Balance<phantom T> has store {
        value: u64
    }

    /// Get the amount stored in a `Balance`.
    public fun value<T>(self: &Balance<T>): u64 {
        self.value
    }

    /// Get the `Supply` value.
    public fun supply_value<T>(supply: &Supply<T>): u64 {
        supply.value
    }

    /// Create a new supply for type T.
    public fun create_supply<T: drop>(_: T): Supply<T> {
        Supply { value: 0 }
    }

    /// Increase supply by `value` and create a new `Balance<T>` with this value.
    public fun increase_supply<T>(self: &mut Supply<T>, value: u64): Balance<T> {
        assert!(value < (18446744073709551615u64 - self.value), EOverflow);
        self.value = self.value + value;
        Balance { value }
    }

    /// Burn a Balance<T> and decrease Supply<T>.
    public fun decrease_supply<T>(self: &mut Supply<T>, balance: Balance<T>): u64 {
        let Balance { value } = balance;
        assert!(self.value >= value, EOverflow);
        self.value = self.value - value;
        value
    }

    /// Create a zero `Balance` for type `T`.
    public fun zero<T>(): Balance<T> {
        Balance { value: 0 }
    }

    /// Join two balances together.
    public fun join<T>(self: &mut Balance<T>, balance: Balance<T>): u64 {
        let Balance { value } = balance;
        self.value = self.value + value;
        self.value
    }

    /// Split a `Balance` and take a sub balance from it.
    public fun split<T>(self: &mut Balance<T>, value: u64): Balance<T> {
        assert!(self.value >= value, ENotEnough);
        self.value = self.value - value;
        Balance { value }
    }

    /// Withdraw all balance. After this the remaining balance must be 0.
    public fun withdraw_all<T>(self: &mut Balance<T>): Balance<T> {
        let value = self.value;
        split(self, value)
    }

    /// Destroy a zero `Balance`.
    public fun destroy_zero<T>(balance: Balance<T>) {
        assert!(balance.value == 0, ENonZero);
        let Balance { value: _ } = balance;
    }

    const IOTA_TYPE_NAME: vector<u8> =
        b"0000000000000000000000000000000000000000000000000000000000000002::iota::IOTA";

    #[allow(unused_function)]
    /// CAUTION: this function creates a `Balance` without increasing the supply.
    /// It should only be called by the epoch change system txn to create staking rewards,
    /// and nowhere else.
    fun create_staking_rewards<T>(value: u64, ctx: &TxContext): Balance<T> {
        assert!(ctx.sender() == @0x0, ENotSystemAddress);
        assert!(
            std::type_name::get<T>().into_string().into_bytes() == IOTA_TYPE_NAME,
            ENotIOTA,
        );
        Balance { value }
    }

    #[allow(unused_function)]
    /// CAUTION: this function destroys a `Balance` without decreasing the supply.
    /// It should only be called by the epoch change system txn to destroy storage rebates,
    /// and nowhere else.
    fun destroy_storage_rebates<T>(self: Balance<T>, ctx: &TxContext) {
        assert!(ctx.sender() == @0x0, ENotSystemAddress);
        assert!(
            std::type_name::get<T>().into_string().into_bytes() == IOTA_TYPE_NAME,
            ENotIOTA,
        );
        let Balance { value: _ } = self;
    }

    #[allow(unused_function)]
    /// CAUTION: this function destroys a `Balance` without decreasing the supply.
    /// It should only be called by the genesis txn to destroy parts of the IOTA supply
    /// which was created during the migration and for no other reason.
    fun destroy_genesis_supply<T>(self: Balance<T>, ctx: &TxContext) {
        assert!(ctx.sender() == @0x0, ENotSystemAddress);
        assert!(ctx.epoch() == 0, ENotGenesisEpoch);
        assert!(
            std::type_name::get<T>().into_string().into_bytes() == IOTA_TYPE_NAME,
            ENotIOTA,
        );

        let Balance { value: _ } = self;
    }

    /// Destroy a `Supply` preventing any further minting and burning.
    public(package) fun destroy_supply<T>(self: Supply<T>): u64 {
        let Supply { value } = self;
        value
    }

    #[test_only]
    /// Create a `Balance` of any coin for testing purposes.
    public fun create_for_testing<T>(value: u64): Balance<T> {
        Balance { value }
    }

    #[test_only]
    /// Destroy a `Balance` of any coin for testing purposes.
    public fun destroy_for_testing<T>(self: Balance<T>): u64 {
        let Balance { value } = self;
        value
    }

    #[test_only]
    /// Create a `Supply` of any coin for testing purposes.
    public fun create_supply_for_testing<T>(): Supply<T> {
        Supply { value: 0 }
    }
}

#[test_only]
module iota::balance_tests {
    use iota::balance;
    use iota::iota::IOTA;
    use iota::test_utils;

    #[test]
    fun test_balance() {
        let mut balance = balance::zero<IOTA>();
        let another = balance::create_for_testing(1000);

        balance.join(another);

        assert!(balance.value() == 1000);

        let balance1 = balance.split(333);
        let balance2 = balance.split(333);
        let balance3 = balance.split(334);

        balance.destroy_zero();

        assert!(balance1.value() == 333);
        assert!(balance2.value() == 333);
        assert!(balance3.value() == 334);

        test_utils::destroy(balance1);
        test_utils::destroy(balance2);
        test_utils::destroy(balance3);
    }
}
