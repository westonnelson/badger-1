
    REWARD_TOKEN = "0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475" ## $SCREAM
    SCTOKEN = "0x4565DC3Ef685E4775cdF920129111DdF43B9d882" ## $scwBTC
    WANT = "0x321162Cd933E2Be498Cd2267a90534A804051b11" ## $wBTC

    PROTECTED_TOKENS = [WANT, SCTOKEN, REWARD_TOKEN]


    ## Account that has a lot of want (we will "borrow it" for testing)
    WHALE_ADDRESS = "0x93c08a3168fc469f3fc165cd3a471d19a37ca19e"

    ## Address for Badger Registry, used to fill in default addresses
    ## See: https://github.com/Badger-Finance/badger-registry
    REGISTRY = "0xFda7eB6f8b7a9e9fCFd348042ae675d1d652454f"

    PERFORMANCE_FEE_GOVERNANCE = 2000 ## 20%
    PERFORMANCE_FEE_STRATEGIST = 0 ## 0%
    WITHDRAWAL_FEE = 10 ## 0.1%
    MANAGEMENT_FEE = 0 ## 0%

