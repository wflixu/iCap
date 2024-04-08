@main
public struct iCap {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(iCap().text)
    }
}
