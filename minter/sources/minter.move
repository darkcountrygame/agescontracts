module dev::minter {
    
    use dev::templates;

    use std::signer;

    use aptos_framework::aptos_account;
    use aptos_framework::object::{Self, ExtendRef};

    use std::string::{Self, utf8, String};
    use aptos_token::token;
    use aptos_token::property_map;

    use std::vector;
    use 0x1::bcs;
    use 0x1::string_utils;

    struct MyRef has key, store {
        extend_ref: ExtendRef
    }

    struct CollectionData has key {
        collection_name: String,
        minted_tokens_count: u64
    }

    fun create_object_signer(account: &signer)
    {
        let account_addr = signer::address_of(account);
        let constructor_ref = object::create_object(account_addr);
        let object_addr = object::address_from_constructor_ref(&constructor_ref);

        aptos_account::create_account(object_addr);

        let extend_ref = object::generate_extend_ref(&constructor_ref);

        move_to(account, MyRef{extend_ref});
    }

    public entry fun init(account: &signer) acquires MyRef
    {
        create_object_signer(account);
        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        let collection_name = string::utf8(b"Farming");
        let collection_description = string::utf8(b"Farming game");
        let collection_uri = string::utf8(b"some uri");
        let mutate_setting = vector<bool>[true, true, true];

        token::create_collection(
            &object_signer,
            collection_name,
            collection_description,
            collection_uri,
            0,
            mutate_setting
        );

        move_to(account, CollectionData {collection_name, minted_tokens_count: 0});
    }

    public fun mint_internal(
        to: address,
        template_id: u64
    ) acquires CollectionData, MyRef
    {
        let account_addr = @dev;
        let my_ref = borrow_global<MyRef>(account_addr);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        let token_mutability_settings = vector<bool>[true, true, true, true, true];

        let collection_data = borrow_global_mut<CollectionData>(account_addr);
        collection_data.minted_tokens_count = collection_data.minted_tokens_count + 1;

        let token_name = string::utf8(b"#");
        string::append(&mut token_name,
        string_utils::to_string_with_integer_types<u64>(&collection_data.minted_tokens_count));

        let template = templates::get_template(template_id);
        let description = templates::get_description(&template);
        let uri = templates::get_uri(&template);
        let property_names = templates::get_property_names(&template);
        let property_types = templates::get_property_types(&template);
        let property_values = templates::get_property_values(&template);

        vector::push_back(&mut property_names, utf8(b"Template"));
        vector::push_back(&mut property_types, utf8(b"u64"));
        vector::push_back(&mut property_values, bcs::to_bytes<u64>(&template_id));

        let my_BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";

        let token_data_id = token::create_tokendata(
            &object_signer,
            collection_data.collection_name,
            token_name,
            description,
            0, //maximum amount
            uri,
            @dev, //payee address
            100, //denominator
            5, //numinator
            token::create_token_mutability_config(&token_mutability_settings),
            vector<String>[string::utf8(my_BURNABLE_BY_OWNER)],
            vector<vector<u8>>[bcs::to_bytes<bool>(&true)],
            vector<String>[string::utf8(b"bool")],
        );

        token::mint_token_to(
            &object_signer,
            to,
            token_data_id,
            1 //amount to mint
        );

        let token_id = token::create_token_id_raw(get_collection_creator(), string::utf8(b"Farming"), token_name, 0);
        token::mutate_one_token(&object_signer, to, token_id, property_names, property_values, property_types);
    }

    public entry fun mint(account: &signer, to: address, template_id: u64) acquires CollectionData, MyRef {
        mint_internal(to, template_id);
    }
    
    public entry fun reduce_instrument_durability(account: &signer, instrument_name: String, property_version: u64) acquires MyRef
    {
        //check if it's staked
        let account_addr = signer::address_of(account);
        let token_id = token::create_token_id_raw(get_collection_creator(), string::utf8(b"Farming"), instrument_name, property_version);
        
        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);
        
        let keys = vector<String>[string::utf8(b"Max Durability")];
        let ten: u64 = 10;
        let values = vector<vector<u8>>[bcs::to_bytes<u64>(&15)];
        let types = vector<String>[string::utf8(b"u64")];

        token::mutate_one_token(&object_signer, account_addr, token_id, keys, values, types);
    }

    public fun update_token(owner: address, token_id: token::TokenId, keys: &vector<String>, values: &vector<vector<u8>>, types: &vector<String>) acquires MyRef
    {
        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);
        
        token::mutate_one_token(&object_signer, owner, token_id, *keys, *values, *types);
    }

    #[view]
    public fun get_durability(owner: address, token_name: String, property_version: u64): u64 acquires MyRef
    {
        let token_id = token::create_token_id_raw(get_collection_creator(), string::utf8(b"Farming"), token_name, property_version);
        let pm = token::get_property_map(owner, token_id);

        property_map::read_u64(&pm, &string::utf8(b"Durability"))
    }

    #[view]
    public fun get_collection_creator(): address acquires MyRef
    {
    	let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);
        signer::address_of(&object_signer)
    }
}
