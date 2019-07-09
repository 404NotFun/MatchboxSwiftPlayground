//: [Previous](@previous) [Next](@next)

import Foundation

/*:
 ## Based on implements
 * `Array`
 * `Linked List`
 * `Ring Buffer`
 * `Double Stack`: TO-DO
 */

enum QueueBase {
    case array
    case linkedList
    case ringBuffer
    case doubleStack
}

// - Queue
protocol Queuable {
    associatedtype Element
    
    mutating func enqueue(_ element: Element) -> Bool
    mutating func dequeue() -> Element?
    
    var isEmpty: Bool { get }
    var peek: Element? { get }
}

extension Queuable {
    mutating func test(_ elements: [Element], last: Element) {
        for e in elements {
            self.enqueue(e)
        }
        self.dequeue()
        self.enqueue(last)
    }
}

//: ### Array
struct ArrayQueue<Element>: Queuable {
    private var array: [Element] = []
    
    mutating func enqueue(_ element: Element) -> Bool {
        array.insert(element, at: 0)
        print("Enqueue: \(element), Queue: \(array)")
        return true
    }
    
    mutating func dequeue() -> Element? {
        if !isEmpty {
            let element = array.removeLast()
            print("Dequeued: \(element), Queue: \(array)")
            return element
        }
        return nil
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var peek: Element? {
        return array.first
    }
}

//: ### Double Linked List
class Node<Value> {
    public var value: Value
    public var nextNode: Node?
    
    init(value: Value, next: Node? = nil) {
        self.value = value
        self.nextNode = next
    }
    
    func push(value: Value) {
        
    }
}

struct DoublyLinkedList<Value> {
    public var head: Node<Value>?
    public var tail: Node<Value>?
    
    func isEmpty() -> Bool {
        return head == nil
    }
    
    mutating func push(_ value: Value) {
        head = Node.init(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
    
    mutating func append(_ value: Value) {
        let node = Node.init(value: value)
        if isEmpty() {
            head = node
        } else {
            tail?.nextNode = node
        }
        tail = node
    }
    
    mutating func remove(after node: Node<Value>) -> Value {
        defer {
            if node === tail {
                tail = nil
            }
            head = node.nextNode
        }
        return node.value
    }
    
    func printList() {
        var values = [String]()
        var node: Node<Value>? = head
        while node != nil {
            if let value = node?.value {
                values.append("\(value)")
            }
            node = node?.nextNode
        }
        print(values.reversed().joined(separator: "<-"))
    }
}

struct LinkedListQueue<Element>: Queuable {
    var linkedList = DoublyLinkedList<Element>.init()
    
    mutating func enqueue(_ element: Element) -> Bool {
        linkedList.append(element)
        linkedList.printList()
        return true
    }
    
    mutating func dequeue() -> Element? {
        defer {
            linkedList.printList()
        }
        if let head = linkedList.head {
            return linkedList.remove(after: head)
        } else {
            return nil
        }
    }
    
    var isEmpty: Bool {
        return linkedList.isEmpty()
    }
    
    var peek: Element? {
        return linkedList.head?.value
    }
}

//: ### Ring Buffer
struct RingBuffer<T> {
    fileprivate var array: [T?]
    fileprivate var readIndex = 0
    fileprivate var writeIndex = 0
    
    init(bufferSize: Int) {
        array = [T?](repeating: nil, count: bufferSize)
    }
    
    mutating func write(_ value: T) -> Bool {
        if !isFull {
            array[writeIndex%array.count] = value
            writeIndex += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func read() -> T? {
        if isEmpty {
            return nil
        } else {
            defer {
                readIndex+=1
            }
            return array[readIndex%array.count]
        }
    }
    
    var availableSpacesForReading: Int {
        return writeIndex - readIndex
    }
    
    var availableSpacesForWriting: Int {
        return array.count - availableSpacesForReading
    }
    
    var isEmpty: Bool {
        return availableSpacesForReading == 0
    }
    
    var isFull: Bool {
        return availableSpacesForWriting == 0
    }
}

struct RingBufferQueue<Element>: Queuable {
    var buffer = RingBuffer<Element>(bufferSize: 3)
    
    mutating func enqueue(_ element: Element) -> Bool {
        defer {
            print("Enqueued: \(element), Queue: \(buffer.array.reversed().compactMap({ $0 }))")
        }
        return buffer.write(element)
    }
    
    mutating func dequeue() -> Element? {
        if let element = buffer.read() {
            print("Dequeued: \(element), Queue: \(buffer.array.reversed().compactMap({$0}))")
            return element
        }
        return nil
    }
    
    var isEmpty: Bool {
        return buffer.isEmpty
    }
    
    var peek: Element? {
        return buffer.array[buffer.readIndex]
    }
}

//: ### Usages
class Main {
    func testQueue(base: QueueBase = .array) {
        let elements: [String] = ["1", "2", "3"]
        let last: String = "4"
        switch base {
        case .array: var queue = ArrayQueue<String>(); queue.test(elements, last: last)
        case .linkedList: var queue = LinkedListQueue<String>(); queue.test(elements, last: last)
        case .ringBuffer: var queue = RingBufferQueue<String>(); queue.test(elements, last: last)
        default: var queue = ArrayQueue<String>(); queue.test(elements, last: last)
        }
        
    }
}

Main().testQueue(base: .linkedList)
