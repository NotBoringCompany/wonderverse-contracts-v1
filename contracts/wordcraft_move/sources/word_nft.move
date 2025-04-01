module wordcraft_move::word_nft {
    use std::string;
    use iota::event;
    use iota::table;
    use iota::dynamic_object_field as dof;
    use iota::dynamic_field as df;

    /// AdminCap is a capability that allows the holder to perform admin operations.
    public struct AdminCap has key { id: UID }

    /// A composite key for tracking how many times a user has minted a specific word.
    /// Combines the user's address and the word to uniquely identify each minting record.
    public struct MintKey has copy, drop, store {
        user: address,
        word: string::String,
    }

    /// A globally shared object that stores minting records using a table of `MintKey` to count.
    /// Ensures that users cannot mint the same word more times than allowed by the configured limit.
    public struct MintTracker has key, store {
        id: UID,
        mints: table::Table<MintKey, u8>
    }

    /// Word is an NFT representing a discovered word in Wordcraft.
    public struct Word has key, store {
        id: UID,
        /// The NFT's name
        name: string::String,
    }

    // ===== Events =====

    public struct WordMinted has copy, drop {
        /// The minted NFT's Object ID
        object_id: ID,
        /// The receiver of the minted NFT
        receiver: address,
        /// The minted NFT's name
        name: string::String,
    }

    /// Initializes the contract and creates an AdminCap and transfers it the deployer.
    /// Also, initializes the AdminCap with a MintTracker and max mint count.
    fun init(ctx: &mut TxContext) {
        // Create the AdminCap ID
        let mut admin_cap_id = object::new(ctx);

        // Create MintTracker
        let tracker = MintTracker {
            id: object::new(ctx),
            mints: table::new(ctx),
        };

        // Attach the MintTracker under the AdminCap's UID
        dof::add(&mut admin_cap_id, b"tracker", tracker);
        // Attach the max mint count to the AdminCap's UID
        df::add<vector<u8>, u8>(&mut admin_cap_id, b"max_mint", 1);



        // Move admin_cap_id into AdminCap struct
        let admin_cap = AdminCap {
            id: admin_cap_id,
        };

        // Transfer AdminCap (with attached tracker) to deployer
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }


    // ===== Public view functions =====

    /// Gets the name of an NFT.
    /// 
    /// Requires passing in a reference of the entire `Word` instance.
    public fun name(nft: &Word): &string::String {
        &nft.name
    }

    // ===== Entrypoints =====

    /// Mints a new Word NFT to `to`.
    /// 
    /// Requires the sender to have an `AdminCap`.
    #[allow(lint(self_transfer))]
    public fun mint(
        cap: &mut AdminCap,
        name: string::String,
        receiver: address,
        ctx: &mut TxContext
    ) {
        // Retrieve the max mint count from AdminCap
        let max = *df::borrow<vector<u8>, u8>(&cap.id, b"max_mint");
        // Retrieve the MintTracker instance attached to AdminCap to check if the user has minted this word before
        let tracker = dof::borrow_mut<vector<u8>, MintTracker>(&mut cap.id, b"tracker");

        // Construct a MintKey instance for this user-word pair
        let key = MintKey {
            user: receiver,
            word: name
        };

        // Lookup current mint count
        let count = if (table::contains(&tracker.mints, key)) {
            *table::borrow(&tracker.mints, key)
        } else {
            0
        };

        // Enforce the max mint count
        assert!(count < max, 101); // Exceeded max mint count

        // Update mint count
        table::add(&mut tracker.mints, key, count + 1);

        // Mint the NFT
        let nft = Word {
            id: object::new(ctx),
            name,
        };

        // Emit a WordMinted event
        event::emit(WordMinted {
            object_id: object::id(&nft),
            receiver,
            name: nft.name,
        });

        // Transfer the NFT to the receiver
        transfer::public_transfer(nft, receiver)
    }

    /// Sets the maximum number of times a user can mint a specific word.
    public entry fun set_max_mint(
        cap: &mut AdminCap,
        new_max: u8
    ) {
        df::add<vector<u8>, u8>(&mut cap.id, b"max_mint", new_max);
    }
    
    /// Transfers a Word NFT from the sender to `recipient`.
    public fun transfer(
        word: Word,
        recipient: address,
        _: &mut TxContext
    ) {
        transfer::public_transfer(word, recipient)
    }

    /// Burns a Word NFT.
    public fun burn(
        word: Word,
        _: &mut TxContext
    ) {
        let Word { id, name: _ } = word;
        object::delete(id)
    }
}
