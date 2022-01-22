

public func printMessage(message: String) {
    #if DEBUG
        print(message)
    #endif
}
