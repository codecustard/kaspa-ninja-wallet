// ICP Ninja Example: Simple Kaspa Wallet
// Demonstrates basic Kaspa blockchain integration on Internet Computer

import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Wallet "mo:kaspa/wallet";

persistent actor KaspaNinjaWallet {

    // Initialize a mainnet wallet instance
    transient let wallet = Wallet.createMainnetWallet("test_key_1");

    // Simple authentication check
    private func requireAuth(caller: Principal) : Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            #err("Authentication required")
        } else {
            #ok(())
        }
    };

    // Generate a new Kaspa address
    public shared(msg) func generateAddress() : async Result.Result<Wallet.AddressInfo, Text> {
        switch (requireAuth(msg.caller)) {
            case (#err(e)) { #err(e) };
            case (#ok()) {
                let result = await wallet.generateAddress(null, null);
                switch (result) {
                    case (#ok(addr)) { #ok(addr) };
                    case (#err(e)) {
                        let errorMsg = switch (e) {
                            case (#ValidationError(details)) { details.message };
                            case (#NetworkError(details)) { details.message };
                            case (#InternalError(details)) { details.message };
                            case (_) { "Unknown error generating address" };
                        };
                        #err(errorMsg)
                    };
                }
            };
        }
    };

    // Get balance for any Kaspa address
    public shared(msg) func getBalance(address: Text) : async Result.Result<Wallet.Balance, Text> {
        switch (requireAuth(msg.caller)) {
            case (#err(e)) { #err(e) };
            case (#ok()) {
                let result = await wallet.getBalance(address);
                switch (result) {
                    case (#ok(balance)) { #ok(balance) };
                    case (#err(e)) {
                        let errorMsg = switch (e) {
                            case (#ValidationError(details)) { details.message };
                            case (#NetworkError(details)) { details.message };
                            case (#InternalError(details)) { details.message };
                            case (_) { "Unknown error getting balance" };
                        };
                        #err(errorMsg)
                    };
                }
            };
        }
    };

    // Send Kaspa transaction
    public shared(msg) func sendTransaction(
        from_address: Text,
        to_address: Text,
        amount: Nat64
    ) : async Result.Result<Wallet.TransactionResult, Text> {
        switch (requireAuth(msg.caller)) {
            case (#err(e)) { #err(e) };
            case (#ok()) {
                let result = await wallet.sendTransaction(
                    from_address,
                    to_address,
                    amount,
                    null, // Use default fee
                    null  // Use default derivation path
                );
                switch (result) {
                    case (#ok(txResult)) { #ok(txResult) };
                    case (#err(e)) {
                        let errorMsg = switch (e) {
                            case (#ValidationError(details)) { details.message };
                            case (#NetworkError(details)) { details.message };
                            case (#InsufficientFunds(details)) {
                                "Insufficient funds: need " # debug_show(details.required) # " but only have " # debug_show(details.available)
                            };
                            case (#InternalError(details)) { details.message };
                            case (_) { "Unknown error sending transaction" };
                        };
                        #err(errorMsg)
                    };
                }
            };
        }
    };

    // Build transaction without broadcasting
    public shared(msg) func buildTransaction(
        from_address: Text,
        to_address: Text,
        amount: Nat64
    ) : async Result.Result<{serialized_tx: Text; fee_paid: Nat64}, Text> {
        switch (requireAuth(msg.caller)) {
            case (#err(e)) { #err(e) };
            case (#ok()) {
                let result = await wallet.buildTransaction(
                    from_address,
                    to_address,
                    amount,
                    null, // Use default fee
                    null  // Use default derivation path
                );
                switch (result) {
                    case (#ok(buildResult)) { #ok(buildResult) };
                    case (#err(e)) {
                        let errorMsg = switch (e) {
                            case (#ValidationError(details)) { details.message };
                            case (#NetworkError(details)) { details.message };
                            case (#InsufficientFunds(details)) {
                                "Insufficient funds: need " # debug_show(details.required) # " but only have " # debug_show(details.available)
                            };
                            case (#InternalError(details)) { details.message };
                            case (_) { "Unknown error building transaction" };
                        };
                        #err(errorMsg)
                    };
                }
            };
        }
    };

    // Broadcast a pre-built transaction
    public shared(msg) func broadcastTransaction(serialized_tx: Text) : async Result.Result<Text, Text> {
        switch (requireAuth(msg.caller)) {
            case (#err(e)) { #err(e) };
            case (#ok()) {
                let result = await wallet.broadcastSerializedTransaction(serialized_tx);
                switch (result) {
                    case (#ok(txId)) { #ok(txId) };
                    case (#err(e)) {
                        let errorMsg = switch (e) {
                            case (#ValidationError(details)) { details.message };
                            case (#NetworkError(details)) { details.message };
                            case (#InternalError(details)) { details.message };
                            case (_) { "Unknown error broadcasting transaction" };
                        };
                        #err(errorMsg)
                    };
                }
            };
        }
    };

    // Get who is calling (useful for debugging)
    public shared(msg) func whoami() : async Text {
        Principal.toText(msg.caller)
    };

    // Health check
    public func health() : async Text {
        "Kaspa Ninja Wallet is running! 🚀"
    };
}