module dev::GEMS{

    use aptos_framework::coin::{Self};
    use std::signer;
    use std::string;

    struct GEMS {}

    struct TokenCaps has key {
        burn_cap: coin::BurnCapability<GEMS>,
        freeze_cap: coin::FreezeCapability<GEMS>,
        mint_cap: coin::MintCapability<GEMS>
    }

    public entry fun init(deployer: &signer) 
    {       
        assert!(@dev == signer::address_of(deployer), 1);

        let (
            burn_cap, 
            freeze_cap, 
            mint_cap
        ) = coin::initialize<GEMS>(
            deployer,
            string::utf8(b"Farming Gems"),
            string::utf8(b"GEMS"),
            4,
            true,
        );

        coin::register<GEMS>(deployer);

        move_to(deployer, 
        TokenCaps{
            burn_cap,
            freeze_cap,
            mint_cap
        });
    }

    public entry fun transfer(account: &signer, to: address, amount: u64)
    {
        coin::transfer<GEMS>(account, to, amount);
    }

    public entry fun register(account: &signer)
    {
        coin::register<GEMS>(account);
    }

    fun check_token_permissions(addr: address) : bool
    {
        let is_dev = (addr == @dev);
        is_dev
    }

    public entry fun mint(account: &signer, amount: u64) acquires TokenCaps
    {
        let token_caps = borrow_global<TokenCaps>(@dev);
        let coins_minted = coin::mint(amount, &token_caps.mint_cap);
        coin::deposit(@dev, coins_minted);
    }

    public entry fun burn(account: &signer, amount: u64) acquires TokenCaps
    {
        let token_caps = borrow_global<TokenCaps>(@dev);
        coin::burn_from(@dev, amount, &token_caps.burn_cap);
    }

    public entry fun mint_to(account: &signer, to: address, amount: u64) acquires TokenCaps
    {
        let token_caps = borrow_global<TokenCaps>(@dev);
        let coins_minted = coin::mint(amount, &token_caps.mint_cap);
        coin::deposit(to, coins_minted);
    }
}