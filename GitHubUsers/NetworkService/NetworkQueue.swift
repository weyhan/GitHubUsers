//
//  NetworkQueue.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 18/12/2022.
//

import Foundation

// MARK: - NetworkQueue Supporting Types
/// A type that can be enqueued in the NetworkQueue singleton object.
public protocol NetworkQueueable {
    func resume()
}

/// Methods for informing the network queue of the operation status for the executing network job.
public protocol NetworkQueueDelegate {
    func release()
}

// MARK: - NetworkQueue Class

/// Singleton network queue.
///
/// Queued network jobs are executed sequently where only one job will be processed at any one time.
final public class NetworkQueue: NetworkQueueDelegate {
    // Make NetworkQueue a Singleton object.
    public static let shared = NetworkQueue()
    private init() { }

    /// Queue state code
    private enum StateCode {
        /// Queue is processing queued network items.
        case started
        /// Queue is not processing queued network items and/or queue is empty.
        case stopped
    }

    // MARK: - Private Properties

    private var state = StateCode.stopped

    private let dispatchQueue = DispatchQueue.global(qos: .utility)

    private var queueSemaphore = DispatchSemaphore(value: 1)
    private var stateSemaphore = DispatchSemaphore(value: 1)
    private var executeSemaphore = DispatchSemaphore(value: 1)

    private var queue = [NetworkQueueable]()

    // MARK: - Public Properties

    /// A Boolean value indicating whether the network queue is empty.
    public var isEmpty: Bool {
        queueSemaphore.wait()
        let result = queue.isEmpty
        queueSemaphore.signal()
        return result
    }

    /// The number of jobs enqueued in the network queue.
    public var count: Int {
        queueSemaphore.wait()
        let result = queue.count
        queueSemaphore.signal()
        return result
    }

    // MARK: - Public Interface

    /// Append a NetworkQueueable object to the network queue.
    ///
    /// The enqueueing is semaphore guarded and is thread-safe.
    public func enqueue(networkJob: NetworkQueueable) {
        dispatchQueue.async {
            self.queueSemaphore.wait()
            self.queue.append(networkJob)
            self.queueSemaphore.signal()
        }
    }

    /// Resumes the network queue, if it is suspended.
    ///
    /// The processing of the network queued jobs are semaphore guarded and thread-safe. Each task will be executed sequentially
    /// where only one job at a time will be executed.
    public func resume() {
        dispatchQueue.async { [unowned self] in
            guard start() else { return }

            while !isEmpty {
                executeSemaphore.wait()
                let item = dequeue()
                item?.resume()
            }

            stop()
        }
    }

    // MARK: NetworkQueueDelegate Conformance

    /// Signals the release of the current network job.
    ///
    /// The `release()` method is called by the currently processing network job upon completion of it's network
    /// operation. The call signals to the network queue that the next job can proceed if one is available in the queue.
    ///
    /// - Important: This method must be call from the network job object upon completion of the job once and only once.
    public func release() {
        executeSemaphore.signal()
    }

    // MARK: - Private Internal Methods

    /// Dequeue first job from the network queue and returns the dequeued job to the caller.
    ///
    /// This method is thread-safe.
    /// - Returns: Returns `NetworkQueueable` if queue is not empty, otherwise nil is returned.
    private func dequeue() -> NetworkQueueable? {
        queueSemaphore.wait()
        let item = queue.removeFirst()
        queueSemaphore.signal()

        return item
    }

    /// Change the queue state to started if queue is not started.
    ///
    /// Set the queue state to `.started` if the queue state is not already in the `.started` state.
    /// This method is thread-safe.
    /// - Important: The return `Boolean` is to safeguard that the queue is not started more than once. Further processing of the
    /// queue at the caller side must cease if this method returns `false`.
    ///
    /// - Returns: Returns `true` if queue can start processing, otherwise returns `false`.
    private func start() -> Bool {
        guard !isEmpty else {
            return false
        }

        stateSemaphore.wait()
        guard state == .stopped else {
            stateSemaphore.signal()
            return false
        }

        state = .started
        stateSemaphore.signal()

        return true
    }

    /// Change the queue state to stopped
    ///
    /// Set the queue state to `.stopped`.
    /// This method is thread-safe.
    private func stop() {
        stateSemaphore.wait()
        if state == .started {
            state = .stopped
        }
        stateSemaphore.signal()
    }

}
