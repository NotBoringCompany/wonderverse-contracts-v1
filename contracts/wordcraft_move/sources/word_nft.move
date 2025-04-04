module wordcraft_move::word_nft {
    // ===== IMPORTS =====
    use std::string;
    use iota::event;
    use iota::table;
    use iota::package::{Self};
    use iota::display;

    // ===== ERRORS =====

    /// The mint limit per user for a specific word has been reached.
    const EMintLimitReached: u64 = 1;

    // ===== STRUCTS =====

    /// AdminCap is a capability that allows the holder to perform admin operations.
    public struct AdminCap has key { id: UID }

    /// A composite key for tracking how many times a user has minted a specific word.
    /// Combines the user's address and the word to uniquely identify each minting record.
    public struct MintKey has copy, drop, store {
        user: address,
        word: string::String,
    }

    /// An object that keeps track of a few things:
    /// 1. The current token ID, used as a benchmark for the next token ID to be minted.
    /// 2. The maximum number of times a user can mint a specific word.
    /// 3. The base image URL for the NFTs (e.g. "https://example.com/wordcraft/").
    /// 4. A table that maps a composite key (user address + word) to the number of times that user has minted that word.
    public struct WordManager has key, store {
        id: UID,
        current_token_id: u256,
        max_mints_per_word: u16,
        base_image_url: string::String,
        mints: table::Table<MintKey, u16>
    }

    /// Word is an NFT representing a discovered word in Wordcraft.
    public struct Word has key, store {
        id: UID,
        token_id: u256,
        /// The NFT's name
        name: string::String
    }

    /// One-time witness for the Word NFT.
    public struct WORD_NFT has drop {}

    // ===== Events =====

    /// Emitted when a new Word NFT is minted.
    public struct WordMinted has copy, drop {
        /// The minted NFT's Object ID
        token_id: u256,
        /// The receiver of the minted NFT
        receiver: address
    }

    /// Emitted when a Word NFT is burned.
    public struct WordBurned has copy, drop {
        token_id: u256
    }

    /// Initializes the contract. Creates the AdminCap and WordManager, transferring both to the deployer.
    fun init(otw: WORD_NFT, ctx: &mut TxContext) {
        // Initialize the keys and values for the display
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
        ];

        let values = vector[
            string::utf8(b"Token #{token_id}"),
            string::utf8(b"Word NFT Collection"),
            string::utf8(b"{base_image_url}/{name}.png"),
        ];

        // Use the one-time witness (OTW) to claim a Publisher object for this module.
        // This ensures only this contract instance can register display metadata for Word NFTs.
        let publisher = package::claim(otw, ctx);

        // Register the display settings for the `Word` NFT type using the publisher.
        // This configures how NFTs will be visually represented.
        let mut disp = display::new_with_fields<Word>(
            &publisher,
            keys,
            values,
            ctx
        );
        display::update_version(&mut disp);

        // Transfer publisher and display objects to the deployer
        transfer::public_transfer(publisher, ctx.sender());
        transfer::public_transfer(disp, ctx.sender());

        let admin_cap = AdminCap {
            id: object::new(ctx),
        };

        let manager = WordManager {
            id: object::new(ctx),
            current_token_id: 0,
            max_mints_per_word: 1,
            base_image_url: string::utf8(b"https://example.com/wordcraft/"),
            mints: table::new(ctx),
        };

        // Transfer the AdminCap and WordManager to the deployer
        transfer::transfer(admin_cap, tx_context::sender(ctx));
        transfer::transfer(manager, tx_context::sender(ctx));
    }

    // ===== Entrypoints =====

    /// Mints a new Word NFT to `receiver`.
    /// 
    /// Requires admin privileges.
    #[allow(lint(self_transfer))]
    public entry fun mint(
        _: &AdminCap,
        manager: &mut WordManager,
        name: string::String,
        receiver: address,
        ctx: &mut TxContext
    ) {
        // Construct a MintKey instance for this user-word pair
        let key = MintKey {
            user: receiver,
            word: name
        };

        // Lookup current mint count
        let count = if (table::contains(&manager.mints, key)) {
            *table::borrow(&manager.mints, key)
        } else {
            0
        };

        // Enforce the max mint count
        assert!(count < manager.max_mints_per_word, EMintLimitReached); // Exceeded max mint count

        let token_id = manager.current_token_id + 1;

        let word = Word {
            id: object::new(ctx),
            token_id,
            name,
        };

        // Update mint count
        table::add(&mut manager.mints, key, count + 1);
        // Update the current token ID
        manager.current_token_id = token_id;

        // Transfer the NFT to the receiver
        transfer::public_transfer(word, receiver);

        // Emit a WordMinted event
        event::emit(WordMinted {
            token_id,
            receiver,
        });
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
        // Emit a WordBurned event
        event::emit(WordBurned {
            token_id: word.token_id,
        });

        let Word { id, token_id: _, name: _ } = word;
        object::delete(id);
    }

    // ==== ADMIN FUNCTIONS ====

    /// Sets the maximum number of times a user can mint a specific word.
    public entry fun set_max_mint(
        _: &AdminCap,
        manager: &mut WordManager,
        new_max: u16
    ) {
        manager.max_mints_per_word = new_max;
    }

    /// Sets the base image URL for the NFTs.
    public entry fun set_base_image_url(
        _: &AdminCap,
        manager: &mut WordManager,
        new_url: string::String
    ) {
        manager.base_image_url = new_url;
    }
}
