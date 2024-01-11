#[starknet::component]
mod UpgradeableComponent {
    use starknet::ClassHash;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Upgraded: Upgraded
    }

    /// Emitted when the contract is upgraded.
    #[derive(Drop, starknet::Event)]
    struct Upgraded {
        class_hash: ClassHash
    }

    mod Errors {
        const INVALID_CLASS: felt252 = 'Class hash cannot be zero';
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// Replaces the contract's class hash with `new_class_hash`.
        ///
        /// Requirements:
        ///
        /// - `new_class_hash` is not the zero address.
        ///
        /// Emits an `Upgraded` event.
        fn _upgrade(ref self: ComponentState<TContractState>, new_class_hash: ClassHash) {
            assert(!new_class_hash.is_zero(), Errors::INVALID_CLASS);
            starknet::replace_class_syscall(new_class_hash).unwrap();
            self.emit(Upgraded { class_hash: new_class_hash });
        }
    }
}
