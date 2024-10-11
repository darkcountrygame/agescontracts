module dev::templates {

    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_framework::event;
    use aptos_framework::account;

    use 0x1::bcs;
    use aptos_std::table::{Self, Table};

    struct Template has store, drop, copy
    {
        id: u64,
        name: String,
        description: String,
        uri: String,
        property_names: vector<String>,
        property_types: vector<String>,
        property_values_bytes: vector<vector<u8>>
    }

    struct TemplatesStore has key {
        templates: Table<u64, Template>,
        add_template_event: event::EventHandle<Template>
    }

    public entry fun iniit(account: &signer)
    {
        let templates_store = TemplatesStore {
            templates: table::new(),
            add_template_event: account::new_event_handle<Template>(account)
        };

        move_to(account, templates_store);
    }

    public entry fun add_instrument_template(
        account: &signer,
        template_id: u64,
        name: String,
        description: String,
        uri: String,

        resource_type: String,
        farming_rate: u32,
        cooldown: u32,
        last_farm_time: u32,
        max_durability: u32,
        durability: u32,
        max_level: u32,
        level: u32
    ) acquires TemplatesStore
    {
        let property_names: vector<String> = vector::empty();
        let property_values_bytes: vector<vector<u8>> = vector::empty();
        let property_types: vector<String> = vector::empty();

        vector::push_back(&mut property_names, string::utf8(b"Name"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&name));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Resource Type"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&resource_type));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Farming Rate"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&farming_rate));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Cooldown"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&cooldown));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Last Farm"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&last_farm_time));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Max Durability"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&max_durability));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Durability"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&durability));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Max Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&max_level));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        vector::push_back(&mut property_names, string::utf8(b"Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u32>(&level));
        vector::push_back(&mut property_types, string::utf8(b"u32"));

        let new_template = Template {
            id: template_id,
            name,
            description,
            uri,
            property_names,
            property_types,
            property_values_bytes
        };

        let templates_store = borrow_global_mut<TemplatesStore>(@dev);
        table::upsert(&mut templates_store.templates, template_id, new_template);

        event::emit_event<Template>(
            &mut borrow_global_mut<TemplatesStore>(@dev).add_template_event,
            new_template
        )
    }

    public entry fun add_instrument_template_u64(
        account: &signer,
        template_id: u64,
        name: String,
        description: String,
        uri: String,

        resource_type: String,
        farming_rate: u64,
        cooldown: u64,
        last_farm_time: u64,
        max_durability: u64,
        durability: u64,
        max_level: u64,
        level: u64
    ) acquires TemplatesStore
    {
        let property_names: vector<String> = vector::empty();
        let property_values_bytes: vector<vector<u8>> = vector::empty();
        let property_types: vector<String> = vector::empty();

        vector::push_back(&mut property_names, string::utf8(b"Name"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&name));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Resource Type"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&resource_type));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Farming Rate"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&farming_rate));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Cooldown"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&cooldown));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Last Farm"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&last_farm_time));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Max Durability"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&max_durability));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Durability"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&durability));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Max Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&max_level));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&level));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        let new_template = Template {
            id: template_id,
            name,
            description,
            uri,
            property_names,
            property_types,
            property_values_bytes
        };

        let templates_store = borrow_global_mut<TemplatesStore>(@dev);
        table::upsert(&mut templates_store.templates, template_id, new_template);

        event::emit_event<Template>(
            &mut borrow_global_mut<TemplatesStore>(@dev).add_template_event,
            new_template
        )
    }

    public entry fun add_worksite_template(
        account: &signer,
        template_id: u64,
        name: String,
        description: String,
        uri: String,

        resource_type: String,
        farming_boost: u64,
        max_slots: u64,
        slots: u64,
        max_level: u64,
        level: u64
    ) acquires TemplatesStore
    {
        let property_names: vector<String> = vector::empty();
        let property_values_bytes: vector<vector<u8>> = vector::empty();
        let property_types: vector<String> = vector::empty();

        vector::push_back(&mut property_names, string::utf8(b"Name"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&name));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Resource Type"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes(&resource_type));
        vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));

        vector::push_back(&mut property_names, string::utf8(b"Farming Boost"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&farming_boost));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Max Slots"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&max_slots));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Slots"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&slots));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Max Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&max_level));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        vector::push_back(&mut property_names, string::utf8(b"Level"));
        vector::push_back(&mut property_values_bytes, bcs::to_bytes<u64>(&level));
        vector::push_back(&mut property_types, string::utf8(b"u64"));

        let new_template = Template {
            id: template_id,
            name,
            description,
            uri,
            property_names,
            property_types,
            property_values_bytes
        };

        let templates_store = borrow_global_mut<TemplatesStore>(@dev);
        table::upsert(&mut templates_store.templates, template_id, new_template);

        event::emit_event<Template>(
            &mut borrow_global_mut<TemplatesStore>(@dev).add_template_event,
            new_template
        )
    }

    #[view] 
    public fun get_template(template_id: u64): Template acquires TemplatesStore
    {
        let templates_store = borrow_global<TemplatesStore>(@dev);
        *table::borrow(&templates_store.templates, template_id)
    }

    public fun get_description(temp: &Template) : String
    {
        temp.description
    }

    public fun get_uri(temp: &Template) : String
    {
        temp.uri
    }

    public fun get_property_names(temp: &Template) : vector<String>
    {
        temp.property_names
    }

    public fun get_property_types(temp: &Template) : vector<String>
    {
        temp.property_types
    }

    public fun get_property_values(temp: &Template) : vector<vector<u8>>
    {
        temp.property_values_bytes
    }
}