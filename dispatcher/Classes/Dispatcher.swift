import Foundation

public struct Dispatch {
    public typealias Block = () -> ()
}

// MARK: - Main / Async GCD

extension Dispatch {
    
    // Block will run on the main thread. Can provide delay.
    public static func main(delay delay: Double = 0.0, block: Block) {
        async(dispatch_get_main_queue(), block: block)
    }
    
    // Block will run on a background thread created by GCD
    public static func async(queue: dispatch_queue_t = dispatch_queue_create("com.dispatch.async", DISPATCH_QUEUE_SERIAL),
                             delay: Double = 0.0,
                             block: Block) {
        let timeNs = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(timeNs, queue, block)
    }
}

// MARK: - Timers

extension Dispatch {
    
    // Will return a handle to the timer. Be sure to store the timer in order prevent dealloc.
    public static func timerMain(interval interval: Double, leeway: UInt64 = 100, block: Block) -> dispatch_source_t {
        return timerAsync(dispatch_get_main_queue(), interval: interval, leeway: leeway, block: block)
    }
    
    public static func timerAsync(queue: dispatch_queue_t = dispatch_queue_create("com.dispatch.async", DISPATCH_QUEUE_SERIAL),
                             interval: Double,
                             leeway: UInt64 = 100,
                             block: Block) -> dispatch_source_t {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        let intervalNs = UInt64(dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC))))
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, intervalNs, leeway)
        dispatch_source_set_event_handler(timer, block)
        dispatch_resume(timer)
        return timer
    }
}

// MARK: - Invalid Timer

extension dispatch_source_t {
    public func invalid() -> Self {
        dispatch_source_cancel(self)
        return self
    }
}
