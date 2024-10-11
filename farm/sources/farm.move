module dev::farm {

    use dev::wood;
    use dev::FOOD;
    use dev::STONE;
    use dev::GEMS;

    use dev::minter;
    
    use 0x1::bcs;

    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_token::token;
    use aptos_framework::account;

    use aptos_std::table::{Self, Table};
    use aptos_token::property_map;

    use aptos_framework::aptos_account;
    use aptos_framework::object::{Self, ExtendRef};

    use std::timestamp;

    struct FarmStore has key {
        wood_worksite: String,
        wood_instruments: vector<String>,

        stone_worksite: String,
        stone_instruments: vector<String>,
        
        food_worksite: String,
        food_instruments: vector<String>,
        
        gems_worksite: String,
        gems_instruments: vector<String>,
    }

    struct StakingStore has key
    {
        staked_tokens: vector<String>
    }

    struct MyRef has key {
        extend_ref: ExtendRef
    }

    public entry fun init_farm_store(account: &signer)
    {
        let empty_string = string::utf8(b"");
        let empty_vector: vector<String> = vector::empty();

        let farm_store = FarmStore{
            wood_worksite: empty_string,
            wood_instruments: empty_vector,

            stone_worksite: empty_string,
            stone_instruments: empty_vector,
            
            food_worksite: empty_string,
            food_instruments: empty_vector,
            
            gems_worksite: empty_string,
            gems_instruments: empty_vector
        };

        move_to(account, farm_store);
    }

    fun create_obj_signer(caller: &signer)
    {
        let caller_address = signer::address_of(caller);
        let constructor_ref = object::create_object(caller_address);
        let object_address = object::address_from_constructor_ref(&constructor_ref);

        aptos_account::create_account(object_address);

        let extend_ref = object::generate_extend_ref(&constructor_ref);
        
        move_to(caller, MyRef { extend_ref: extend_ref },);
    }


    public entry fun init_object(account: &signer) acquires MyRef
    {
        create_obj_signer(account);
        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        token::opt_in_direct_transfer(&object_signer, true);
    }

    public entry fun init_staking_store(account: &signer)
    {
        let staking_store = StakingStore {
            staked_tokens: vector::empty()
        };

        move_to(account, staking_store);
    }

    fun stake_token(account: &signer, token_name: String) acquires MyRef, StakingStore
    {
        let account_addr = signer::address_of(account);
        let staking_store = borrow_global_mut<StakingStore>(account_addr);

        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        token::transfer_with_opt_in(
            account,
            @collection_creator,
            string::utf8(b"Farming"),
            token_name,
            1,
            signer::address_of(&object_signer),
            1
        );

        vector::push_back(&mut staking_store.staked_tokens, token_name);
    }

    fun unstake_token(account: &signer, token_name: String) acquires MyRef, StakingStore
    {
        let account_addr = signer::address_of(account);
        let staking_store = borrow_global_mut<StakingStore>(account_addr);

        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        token::transfer_with_opt_in(
            &object_signer,
            @collection_creator,
            string::utf8(b"Farming"),
            token_name,
            1,
            account_addr,
            1
        );

        vector::remove_value(&mut staking_store.staked_tokens, &token_name);
    }

    fun dispatch_resource_type(farm_store: &mut FarmStore, resource_type: String): (&mut String, &mut vector<String>) 
    {
        let worksite_to_change: &mut String;
        let vector_instruments: &mut vector<String>;

        if (resource_type == string::utf8(b"wood"))
        {
            worksite_to_change = &mut farm_store.wood_worksite;
            vector_instruments = &mut farm_store.wood_instruments;
        }
        else if (resource_type == string::utf8(b"food"))
        {
            worksite_to_change = &mut farm_store.food_worksite;
            vector_instruments = &mut farm_store.food_instruments;
        }
        else if (resource_type == string::utf8(b"stone"))
        {
            worksite_to_change = &mut farm_store.stone_worksite;
            vector_instruments = &mut farm_store.stone_instruments;
        }
        else if (resource_type == string::utf8(b"gems"))
        {
            worksite_to_change = &mut farm_store.gems_worksite;
            vector_instruments = &mut farm_store.gems_instruments;
        }
        else
        {
            abort 2
        };

        (worksite_to_change, vector_instruments)
    }

    public entry fun stake_worksite(account: &signer, worksite_name: String) acquires MyRef, StakingStore, FarmStore
    {
        let account_addr = signer::address_of(account);
        let farm_store = borrow_global_mut<FarmStore>(account_addr);

        let token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), worksite_name, 1);
        let token_properties = token::get_property_map(account_addr, token_id);
    
        //check is worksite
        assert!(property_map::contains_key(&token_properties, &string::utf8(b"Slots")) == true, 1);

        let resource_type = property_map::read_string(&token_properties, &string::utf8(b"Resource Type"));
        let (worksite_to_change, _) = dispatch_resource_type(farm_store, resource_type); 

        //logic check

        if (string::is_empty(worksite_to_change))
        {
            stake_token(account, worksite_name);
            *worksite_to_change = worksite_name;
        };
    }

    public entry fun unstake_worksite(account: &signer, worksite_name: String) acquires MyRef, StakingStore, FarmStore
    {
        let account_addr = signer::address_of(account);
        let farm_store = borrow_global_mut<FarmStore>(account_addr);

        let token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), worksite_name, 1);
        let token_properties = token::get_property_map(get_staking_object(), token_id);
    
        //check is worksite
        assert!(property_map::contains_key(&token_properties, &string::utf8(b"Slots")) == true, 1);

        let resource_type = property_map::read_string(&token_properties, &string::utf8(b"Resource Type"));
        let (worksite_to_change, vector_instruments) = dispatch_resource_type(farm_store, resource_type);

        //logic check

        if (string::is_empty(worksite_to_change))
        {
            return
        };

        if (!vector::is_empty(vector_instruments))
        {
            return
        };

        unstake_token(account, worksite_name);
        *worksite_to_change = string::utf8(b"");
    }

    public entry fun stake_instrument(account: &signer, instrument_name: String) acquires MyRef, StakingStore, FarmStore
    {
        let account_addr = signer::address_of(account);
        let farm_store = borrow_global_mut<FarmStore>(account_addr);

        let token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), instrument_name, 1);
        let token_properties = token::get_property_map(account_addr, token_id);

        //check is instrument
        assert!(property_map::contains_key(&token_properties, &string::utf8(b"Farming Rate")) == true, 1);

        let resource_type = property_map::read_string(&token_properties, &string::utf8(b"Resource Type"));
        let (worksite_name, vector_instruments) = dispatch_resource_type(farm_store, resource_type);

        //logic check

        if (string::is_empty(worksite_name))
        {
            return;
        };

        let wk_token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), *worksite_name, 1);
        let wk_token_properties = token::get_property_map(get_staking_object(), wk_token_id);
        let max_slots = property_map::read_u64(&wk_token_properties, &string::utf8(b"Max Slots"));

        if (vector::length(vector_instruments) == max_slots)
        {
            return;
        }; 

        vector::push_back(vector_instruments, instrument_name);
        stake_token(account, instrument_name);
    }

    public entry fun unstake_instrument(account: &signer, instrument_name: String) acquires MyRef, StakingStore, FarmStore
    {
        let account_addr = signer::address_of(account);
        let farm_store = borrow_global_mut<FarmStore>(account_addr);

        let token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), instrument_name, 1);
        let token_properties = token::get_property_map(get_staking_object(), token_id);
    
        //check is instrument
        assert!(property_map::contains_key(&token_properties, &string::utf8(b"Farming Rate")) == true, 1);

        let resource_type = property_map::read_string(&token_properties, &string::utf8(b"Resource Type"));
        let (worksite_name, vector_instruments) = dispatch_resource_type(farm_store, resource_type);

        //logic check

        assert!(vector::contains(vector_instruments, &instrument_name) == true, 1);

        vector::remove_value(vector_instruments, &instrument_name);
        unstake_token(account, instrument_name);
    }

    public entry fun farm_instrument(account: &signer, instrument_name: String) acquires MyRef, FarmStore
    {
        //check if it's staked

        let account_addr = signer::address_of(account);
        let farm_store = borrow_global_mut<FarmStore>(account_addr);
        
        let token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), instrument_name, 1);
        let token_properties = token::get_property_map(get_staking_object(), token_id);

        let resource_type = property_map::read_string(&token_properties, &string::utf8(b"Resource Type"));

        let (worksite_name, vector_instruments) = dispatch_resource_type(farm_store, resource_type);

        if (!vector::contains(vector_instruments, &instrument_name))
        {
            return
        };

        //check if can farm

        let time_now = timestamp::now_seconds();
        let last_farm_time = property_map::read_u64(&token_properties, &string::utf8(b"Last Farm"));
        let cooldown = property_map::read_u64(&token_properties, &string::utf8(b"Cooldown"));

        if (last_farm_time != 0)
        {
            if (time_now < last_farm_time + cooldown * 60)
            {
                return
            };
        };

        //check durability

        let durability = property_map::read_u64(&token_properties, &string::utf8(b"Durability"));
        
        if (durability == 0)
        {
            return
        };

        //calculate farmed amount

        let wk_token_id = token::create_token_id_raw(@collection_creator, string::utf8(b"Farming"), *worksite_name, 1);
        let wk_token_properties = token::get_property_map(get_staking_object(), wk_token_id); 

        let farming_rate = property_map::read_u64(&token_properties, &string::utf8(b"Farming Rate"));
        let farming_boost = property_map::read_u64(&wk_token_properties, &string::utf8(b"Farming Boost"));

        let farmed_amount = farming_rate * farming_boost;

        //send farmed amount

        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);

        if (resource_type == string::utf8(b"wood"))
        {
            wood::mint_to(&object_signer, account_addr, farmed_amount);
        }
        else if (resource_type == string::utf8(b"food"))
        {
            FOOD::mint_to(&object_signer, account_addr, farmed_amount);
        }
        else if (resource_type == string::utf8(b"stone"))
        {
            STONE::mint_to(&object_signer, account_addr, farmed_amount);
        }
        else if (resource_type == string::utf8(b"gems"))
        {
            GEMS::mint_to(&object_signer, account_addr, farmed_amount);
        };

        //update token state

        let new_durability = durability - 1;

        let keys = vector<String>[string::utf8(b"Durability"), string::utf8(b"Last Farm")];
        let types = vector<String>[string::utf8(b"u64"), string::utf8(b"u64")];
        let values = vector<vector<u8>>[
            bcs::to_bytes<u64>(&new_durability),
            bcs::to_bytes<u64>(&time_now),
        ];

        minter::update_token(get_staking_object(), token_id, &keys, &values, &types);
    }

    #[view]
    public fun get_staking_object(): address acquires MyRef
    {
        let my_ref = borrow_global<MyRef>(@dev);
        let object_signer = object::generate_signer_for_extending(&my_ref.extend_ref);
        signer::address_of(&object_signer)
    }
}