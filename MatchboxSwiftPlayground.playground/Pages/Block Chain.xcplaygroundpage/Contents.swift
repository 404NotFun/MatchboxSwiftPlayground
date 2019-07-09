//: [Previous](@previous) [Next](@next)

import Foundation
/*:
 ## Block Properties
 * `Timestamp`: The time the block is created determines the location of it on the blockchain.
 * `Data`: The information to be securely stored in the block.
 * `Hash`: A unique code produced by combining all the contents within the block itself — also known as a digital fingerprint.
 * `Previous Hash`: Each block has a reference to the block prior to its hash. This is what makes the blockchain unique because this link will be broken if a block is tampered with.
 */

struct Block<T: Codable>: Codable {
    var data: T
    let timestamp: Date = Date()
    var previousHash: String
    var nonce: Int = 0
    var hash: String = ""
    var difficulty: Int = 2
    
    init(data: T, previousHash: String) {
        self.data = data
        self.previousHash = previousHash
    }
    
    mutating func mined(difficulty: Int, proof: String, proofNonce: Int) {
        self.difficulty = difficulty
        self.nonce = proofNonce
        self.hash = proof
    }
    
    func generateHash() -> String {
        let content = "\(timestamp)\(data)\(previousHash)\(nonce)"
        return Utility.sha256(text: content)
    }
    
    func printDescription() {
        print("Timestamp: \(timestamp)")
        print("Data: \(data)")
        print("Hash: \(generateHash())")
        print("Previous Hash: \(previousHash)")
        print("Difficulty: \(difficulty)")
        print("Nonce: \(nonce)")
    }
}
/*:
 ## Block Chain Features
 1. Add a Block
 1. Validate the Chain
 1. **Proof of Work (PoW):** A security feature in blockchain to prevent attackers from easily taking over the blockchain.
 */

struct BlockChain<T: Codable> {
    var chain: [Block<T>] = []
    
    mutating func addBlock(data: T, difficulty: Int = 2) -> (proof: String, result: Block<T>) {
        var block = Block.init(data: data, previousHash: getLastBlockHash())
        let pow = proofOfWork(block: block, difficulty: difficulty)
        block.mined(difficulty: difficulty, proof: pow.proof, proofNonce: pow.nonce)
        self.chain.append(block)
        return (pow.proof, block)
    }
    
    func validateChain() -> Bool {
        printDescription()
        print("\n\(Utility.seperatureLineStar)\n")
        defer {
            print("\(Utility.seperatureLineStar)\n")
        }
        guard chain.count > 1 else { return true }
        var isValid = true
        for i in 1..<chain.count {
            if chain[i].hash != chain[i].generateHash() {
                print("Validate Chain: Bloack #\(i) hash does not equal generated hash")
                print("hash: \(chain[i].generateHash())\ngenerated hash: \(chain[i].hash)\n")
                isValid = false
            }
            if chain[i-1].generateHash() != chain[i].previousHash {
                print("Validate Chain: Previous Block #\(i-1)'s hash got changed")
                print("hash: \(chain[i-1].generateHash())\ngenerated hash: \(chain[i].previousHash)\n")
                isValid = false
            }
        }
        if isValid {
            print("Validate Chain: Chain is Valid!\n")
        }
        return isValid
    }
    
    func proofOfWork(block: Block<T>, difficulty: Int = 2) -> (nonce: Int, proof: String) {
        var _current = block
        while _current.generateHash().prefix(difficulty) != String(repeating: "0", count: difficulty) {
            _current.nonce += 1
        }
        return (_current.nonce, _current.generateHash())
    }
    
    func printDescription() {
        for (index, block) in chain.enumerated() {
            print("\(Utility.seperatureLine) Block #\(index)")
            block.printDescription()
        }
    }
    
    private func getLastBlockHash() -> String {
        return chain.last?.hash ?? ""
    }
}

/*:
 `Account Info` is a example data for the `Block`. Users receive Firecoins as a gift from Matchbox when creating a `Block`.
 * `Sender`: Must be 'Matchbox'
 * `Receiver`: Miner who mines the Firecoins
 * `Firecoins`: Virtual coins in Matchbox
 */

struct AccountInfo: Codable {
    var sender: String
    var receiver: String
    var firecoins: Int
    
    static func genesisData() -> AccountInfo {
        return AccountInfo.init(sender: "Matchbox", receiver: "Matchbox", firecoins: 0)
    }
}

class Main {
    var myBlockChain = BlockChain<AccountInfo>()
    
    func test() {
        // Add Genesis Block
        myBlockChain.addBlock(data: AccountInfo.genesisData())
        // Add More Blocks
        myBlockChain.addBlock(data: AccountInfo.init(sender: "Matchbox", receiver: "Jason", firecoins: 10))
        myBlockChain.addBlock(data: AccountInfo.init(sender: "Matchbox", receiver: "Jason", firecoins: 15))
        // Validate Chain
        myBlockChain.validateChain()
        
//        tampering1()
        tampering2()
    }
    
    func tampering1() {
        myBlockChain.chain[1].data.receiver = "Peter"
        myBlockChain.chain[1].data.firecoins = 1000000
        myBlockChain.validateChain()
    }
    
    func tampering2() {
        myBlockChain.chain[2].data.receiver = "Peter"
        myBlockChain.chain[2].data.firecoins = 1000000
        myBlockChain.validateChain()
    }
}


Main().test()
