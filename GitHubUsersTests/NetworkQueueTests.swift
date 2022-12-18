//
//  NetworkQueueTests.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 18/12/2022.
//

import XCTest
import GitHubUsers

final class NetworkQueueTests: XCTestCase {

    func testQueueEnqueueDequeue() throws {
        let queue = NetworkQueue.shared
        let numberOfJobs = 10

        XCTAssertTrue(queue.isEmpty, "Network queue should be empty")

        for _ in 1...numberOfJobs {
            queue.enqueue(networkJob: TestNetworkNode())
        }

        // Wait for enqueue because NetworkQueue enqueues in a different thread.
        sleep(UInt32(numberOfJobs/10))
        XCTAssert(queue.count == numberOfJobs, "Network queue should have \(numberOfJobs) jobs")

        queue.resume()

        // The mock network job takes a randam amount of time between 0.5 to 1 seconds to
        // completes it's task. Therefore `numberOfJobs` seconds for `numberOfJobs` task
        // is more than sufficient wait time.
        sleep(UInt32(numberOfJobs))
        XCTAssertTrue(queue.isEmpty, "Network queue is not empty but should be")
    }

    func testSequence() throws {
        let queue = NetworkQueue.shared
        let counter = Counter(initialCount: 0, limit: 1)
        let numberOfJobs = 10

        for _ in 1...numberOfJobs {
            queue.enqueue(networkJob: TestNetworkNode(counter: counter))
        }

        queue.resume()
        sleep(UInt32(numberOfJobs))

        // Counter object keep track if the at any time the counter is over the limit.
        // The TestNetworkQueueNode will increment counter when it is resumed and decrement
        // the counter when the mock network task is finished. Therefore, if the counter's
        // isOverLimit flag is set to `true`, it means the queue have executed more than
        // one job at a time.
        XCTAssertFalse(counter.isOverLimit, "Network Queue job execution is not synchronous")
    }

    // MARK: - Mockups

    // Keep count and if count ever went over the limit
    class Counter {
        private var semaphore = DispatchSemaphore(value: 1)
        private var count = 0
        private var limit = 1
        var isOverLimit = false

        init(initialCount: Int = 0, limit: Int = 1) {
            self.count = initialCount
            self.limit = limit
        }

        var isZero: Bool { count == 0 }

        func increment() {
            semaphore.wait()
            count += 1
            if count > limit { isOverLimit = true }
            semaphore.signal()
        }

        func decrement() {
            semaphore.wait()
            count -= 1
            semaphore.signal()
        }
    }

    class TestNetworkNode: NetworkQueueable {
        let uuid = UUID().uuidString
        let waitTime: Double
        let counter: Counter?

        init(counter: Counter? = nil) {
            waitTime = Double.random(in: 0.5...1.0)
            self.counter = counter ?? nil
        }

        func resume() {
            print("[\(uuid)]: Wait time: \(waitTime)")
            counter?.increment()
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + waitTime) {
                self.counter?.decrement()
                NetworkQueue.shared.release()
                print("[\(self.uuid)]: Done")
            }
            print("[\(uuid)]: Dispatched")
        }
    }

}
