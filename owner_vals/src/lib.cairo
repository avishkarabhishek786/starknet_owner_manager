#[starknet::contract]

mod Ownable {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
      OwnershipTransferred: OwnershipTransferred,  
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self:ContractState) {
        self.owner.write(get_caller_address());
        self.times_changed.write(0_u32);
    }

    #[storage]
    struct Storage {
        owner:ContractAddress,  // owner address
        val: felt252,           // a value field
        times_changed: u32,           // denotes how many times val has been changed
    }

    #[external(v0)]  // This attribute makes all the functions in the impl public
    #[generate_trait]
    impl OwnerStorage of OwnerStorageTrait {

        // public write function
        fn transfer_ownership(ref self:ContractState, new_owner:ContractAddress) {
            self.only_owner();
            
            let prev_owner = self.owner.read();

            self.owner.write(new_owner);

            self.emit(Event::OwnershipTransferred(OwnershipTransferred {
                prev_owner: prev_owner,
                new_owner: new_owner,
            }));
        }

        // public read function
        fn get_owner(self:@ContractState) -> ContractAddress {
            self.owner.read()
        }

        // public write function
        fn set_times_changed(ref self:ContractState, _num:u32) {
            self.times_changed.write(_num);
        }

        // public read function
        fn get_times_changed(self:@ContractState) -> u32 {
            self.times_changed.read()
        }
    }

    // To create private functions just do not provide attribute #[external(v0)] in impl
    #[generate_trait] // This will generate the traits automatically
    impl OwnerInternalCalls of OwnerInternalCallsTrait {
        // private read function
        fn only_owner(self:@ContractState) {
            let caller = get_caller_address();
            assert(caller==self.get_owner(), 'only owner');
        }
    }  

}