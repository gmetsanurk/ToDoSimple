actor EventsLogger {
    func log(_ message: @autoclosure () -> String) {
        #if LOGS_ENABLED
        print(message())
        #endif
    }
}
