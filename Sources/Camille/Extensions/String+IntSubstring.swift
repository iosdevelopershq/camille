extension String {
    func substring(from: Int) -> String {
        return substring(from: index(startIndex, offsetBy: from))
    }
}
