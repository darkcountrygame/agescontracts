module dev::craft {

    use dev::wood;
    use dev::FOOD;
    use dev::STONE;
    use dev::GEMS;

    use dev::minter;

    use std::signer;

    use aptos_framework::event;
    use aptos_framework::account;

    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    use aptos_std::table::{Self, Table};

    struct Recipe has store, drop, copy {
        template_id: u64,
        wood_amount: u64,
        food_amount: u64,
        stone_amount: u64,
        gems_amount: u64,
        aptos_amount: u64
    }

    struct RecipeStore has key {
        recipes: Table<u64, Recipe>,
        add_recipe_event: event::EventHandle<Recipe>
    }

    public entry fun init(account: &signer)
    {
        let recipe_store = RecipeStore {
            recipes: table::new(),
            add_recipe_event: account::new_event_handle<Recipe>(account)
        };

        move_to(account, recipe_store);
    }

    public entry fun add_recipe(
        account: &signer,
        recipe_id: u64,
        template_id: u64,
        wood_amount: u64,
        food_amount: u64,
        stone_amount: u64,
        gems_amount: u64,
        aptos_amount: u64
    ) acquires RecipeStore
    {
        let new_recipe = Recipe {
            template_id,
            wood_amount,
            food_amount,
            stone_amount,
            gems_amount,
            aptos_amount
        };

        let recipe_store = borrow_global_mut<RecipeStore>(@dev);
        table::upsert(&mut recipe_store.recipes, recipe_id, new_recipe);

        event::emit_event<Recipe>(
            &mut borrow_global_mut<RecipeStore>(@dev).add_recipe_event,
            new_recipe
        );
    }

    public entry fun craft_with_resources(account: &signer, recipe_id: u64) acquires RecipeStore
    {
        let recipe = get_recipe(recipe_id);

        if (recipe.wood_amount != 0)
        {
            wood::transfer(account, @dev, recipe.wood_amount);
            wood::burn(account, recipe.wood_amount);
        };

        if (recipe.food_amount != 0)
        {
            FOOD::transfer(account, @dev, recipe.food_amount);
            FOOD::burn(account, recipe.food_amount);
        };

        if (recipe.stone_amount != 0)
        {
            STONE::transfer(account, @dev, recipe.stone_amount);
            STONE::burn(account, recipe.stone_amount);
        };

        if (recipe.gems_amount != 0)
        {
            GEMS::transfer(account, @dev, recipe.gems_amount);
            GEMS::burn(account, recipe.gems_amount);
        };

        minter::mint_internal(signer::address_of(account), recipe.template_id);
    }

    public entry fun craft_with_aptos(account: &signer, recipe_id: u64) acquires RecipeStore
    {
        let recipe = get_recipe(recipe_id);

        if (recipe.aptos_amount != 0)
        {
            coin::transfer<aptos_coin::AptosCoin>(account, @dev, recipe.aptos_amount);
        };

        minter::mint_internal(signer::address_of(account), recipe.template_id);
    }

    #[view]
    public fun get_recipe(recipe_id: u64): Recipe acquires RecipeStore
    {
        let recipe_store = borrow_global<RecipeStore>(@dev);
        *table::borrow(&recipe_store.recipes, recipe_id)
    }

}